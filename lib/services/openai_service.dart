import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message.dart';
import 'dart:math' as Math;
import '../services/file_service.dart';
import '../services/pdf_service.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  
  final Dio _dio = Dio();
  
  // Get API key from environment variables
  String? getApiKey() {
    return dotenv.env['OPENAI_API_KEY'];
  }
  
  // These methods are kept for backward compatibility but don't actually store anything
  Future<String?> getApiKeyLegacy() async {
    return getApiKey();
  }
  
  Future<void> saveApiKey(String apiKey) async {
    // No longer saving to secure storage since we're using .env file
    debugPrint('API key management moved to .env file - this method is deprecated');
  }
  
  Future<void> deleteApiKey() async {
    // No longer deleting from secure storage since we're using .env file
    debugPrint('API key management moved to .env file - this method is deprecated');
  }
  
  Future<bool> hasApiKey() async {
    final apiKey = getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
  
  Future<String> sendMessage({
    required List<Message> messages,
    String? filePath,
    String? imagePath,
    List<String>? additionalImagePaths,
    String model = 'gpt-4o',
    String languageCode = 'en',
  }) async {
    try {
      final apiKey = getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found in .env file. Please add your OpenAI API key to the OPENAI_API_KEY variable.');
      }
      
      _dio.options.headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };
      
      // Create a system message to instruct the AI to respond in the user's language
      String languageName = 'English';
      if (languageCode == 'ko') {
        languageName = 'Korean';
      }
      
      final List<Map<String, dynamic>> formattedMessages = [];
      
      // Add system message with language instruction
      formattedMessages.add({
        'role': 'system',
        'content': 'You are a helpful assistant. Always respond in $languageName unless explicitly asked to use a different language.'
      });
      
      // Add user and assistant messages, handling images if present
      bool hasImageAttachment = false;
      
      for (final message in messages) {
        if (message.role == MessageRole.user && message.attachmentPath != null && 
            _isImageFile(message.attachmentPath!)) {
          // This is an image attachment from the user
          hasImageAttachment = true;
          final imageContent = await _formatImageMessageContent(message);
          formattedMessages.add({
            'role': message.role.toString().split('.').last,
            'content': imageContent,
          });
          debugPrint('Added message with image attachment: ${message.attachmentPath}');
        } else {
          // Regular text message
          formattedMessages.add({
            'role': message.role.toString().split('.').last,
            'content': message.content,
          });
        }
      }
      
      // Check if there's a PDF or other file attachment
      if (filePath != null && filePath.isNotEmpty) {
        // Check if it's an image or other file type
        if (_isImageFile(filePath)) {
          // Handle as image
          hasImageAttachment = true;
          imagePath = filePath;
        } else {
          // If it's a PDF or other file type, use the file-specific API
          final isPdf = _isPdfFile(filePath);
          debugPrint('Sending message with ${isPdf ? 'PDF' : 'file'} attachment: $filePath');
          return await _sendMessageWithFile(formattedMessages, filePath, model);
        }
      }
      
      // If there's an image file from the current message, add it now
      if (imagePath != null && imagePath.isNotEmpty) {
        hasImageAttachment = true;
        final lastMessage = formattedMessages.last;
        if (lastMessage['role'] == 'user') {
          // Replace the last user message with one that includes the image
          formattedMessages.removeLast();
          
          // Get the last user message content
          final userContent = messages.lastWhere((m) => m.role == MessageRole.user).content;
          
          // Create image content with multiple images if applicable
          List<Map<String, dynamic>> imageContent;
          if (additionalImagePaths != null && additionalImagePaths.isNotEmpty) {
            // Create content with multiple images
            imageContent = await _createMultiImageMessageContent(userContent, imagePath, additionalImagePaths);
          } else {
            // Create content with single image
            imageContent = await _createImageMessageContent(userContent, imagePath);
          }
          
          formattedMessages.add({
            'role': 'user',
            'content': imageContent
          });
          
          if (additionalImagePaths != null && additionalImagePaths.isNotEmpty) {
            debugPrint('Added message with primary image and ${additionalImagePaths.length} additional images');
          } else {
            debugPrint('Added message with current image: $imagePath');
          }
        }
      }

      // Print the first few characters of the request for debugging
      final requestData = {
        'model': model,
        'messages': formattedMessages,
      };
      
      debugPrint('Sending message to OpenAI API');
      if (hasImageAttachment) {
        debugPrint('Request includes image attachment(s)');
      }
      
      // Otherwise use the standard chat completions API
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: requestData,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];
        return content;
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        final errorMessage = errorData?['error']?['message'] ?? 'Unknown API error';
        throw Exception('API Error: $errorMessage');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
  
  /// Send a message with a file attachment (specially handling PDFs)
  Future<String> _sendMessageWithFile(
    List<Map<String, dynamic>> messages,
    String filePath,
    String model
  ) async {
    try {
      final isPdf = _isPdfFile(filePath);
      
      // Create a loading message
      String loadingMessage = isPdf 
        ? "Processing PDF document. This may take a moment..."
        : "Processing file. This may take a moment...";
      
      // Check if it's a PDF and handle it with our specialized PDF service
      if (isPdf) {
        debugPrint('Processing PDF file: $filePath');
        
        // Use PdfService to extract text from PDF
        final PdfService pdfService = PdfService();
        final FileService fileService = FileService();
        
        try {
          // Get file as bytes for processing
          Uint8List bytes;
          if (kIsWeb) {
            bytes = fileService.getWebFileBytes(filePath) ?? Uint8List(0);
            if (bytes.isEmpty) {
              throw Exception('Could not access file. The file may have been removed or the session expired.');
            }
          } else {
            bytes = await File(filePath).readAsBytes();
          }
          
          // Get file size in MB for reference
          final double fileSizeMB = bytes.length / (1024 * 1024);
          debugPrint('PDF file size: ${fileSizeMB.toStringAsFixed(2)} MB');
          
          // Extract metadata
          final metadata = await pdfService.extractMetadata(bytes);
          final int pageCount = metadata['pageCount'] ?? 0;
          final String title = metadata['title'] ?? 'Untitled Document';
          
          // Determine if we need to use chunking
          final bool isLargePdf = pageCount > 10 || fileSizeMB > 1;
          String extractedText;
          
          if (isLargePdf) {
            // Use chunking for large PDFs
            debugPrint('PDF is large, using chunking strategy');
            return await _sendMessageWithLargePdf(messages, bytes, metadata, model);
          } else {
            // Small PDF, extract all text at once
            extractedText = await pdfService.extractText(bytes);
          }
          
          // Create message with extracted text
          final pdfMessage = {
            'role': 'user',
            'content': '''
This is text extracted from a PDF document:
Title: ${metadata['title'] ?? 'Untitled'}
Pages: $pageCount
${metadata['author'] != null ? 'Author: ${metadata['author']}' : ''}

===== DOCUMENT CONTENT =====
$extractedText
===== END OF DOCUMENT =====

Please analyze the content of this document.
'''
          };
          
          // Replace loading message with PDF content
          debugPrint('Sending PDF content to OpenAI - ${extractedText.length} characters');
          
          // Ensure we're using a model that can handle large inputs (like gpt-4o) for PDFs
          String adjustedModel = model;
          if (extractedText.length > 15000 && !model.contains('gpt-4')) {
            debugPrint('Upgrading model to gpt-4o for large PDF content');
            adjustedModel = 'gpt-4o';
          }
          
          // Send the message to OpenAI with the PDF content
          final response = await _dio.post(
            '$_baseUrl/chat/completions',
            data: {
              'model': adjustedModel,
              'messages': [...messages, pdfMessage],
            },
          );
          
          if (response.statusCode == 200) {
            return response.data['choices'][0]['message']['content'];
          } else {
            throw Exception('Failed to get response: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Error processing PDF: $e');
          return 'Error processing PDF: $e';
        }
      } else {
        // For non-PDF files, create a message describing the file
        final filename = filePath.split('/').last;
        final fileExtension = filename.contains('.') ? filename.split('.').last.toLowerCase() : 'unknown';
        
        final message = {
          'role': 'user',
          'content': 'I have attached a $fileExtension file named "$filename". '
              'Please guide me on how I might extract and analyze the content of this file. '
              'What are the common tools or libraries used for working with $fileExtension files?'
        };
        
        final response = await _dio.post(
          '$_baseUrl/chat/completions',
          data: {
            'model': model,
            'messages': [...messages, message],
          },
        );
        
        if (response.statusCode == 200) {
          return response.data['choices'][0]['message']['content'];
        } else {
          throw Exception('Failed to get response: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Error in _sendMessageWithFile: $e');
      return 'Error processing file: $e';
    }
  }
  
  /// Handle large PDFs by chunking and processing sequentially
  Future<String> _sendMessageWithLargePdf(
    List<Map<String, dynamic>> messages,
    Uint8List pdfBytes,
    Map<String, dynamic> metadata,
    String model
  ) async {
    try {
      final PdfService pdfService = PdfService();
      
      // Extract meaningful document metadata
      final int pageCount = metadata['pageCount'] ?? 0;
      final String title = metadata['title'] ?? 'Untitled Document';
      final String author = metadata['author'] ?? 'Unknown Author';
      
      // Create introduction for chunked processing
      debugPrint('Starting chunked processing of large PDF');
      
      // Get chunks with intelligent splitting, enabling OCR if needed
      final chunks = await pdfService.extractAndChunkText(
        pdfBytes, 
        maxTokens: 6000,  // Use a larger chunk size for efficiency
        overlapSentences: 2,  // Overlap 2 sentences between chunks for context
        useOcrIfNeeded: true  // Enable OCR for scanned documents
      );
      
      if (chunks.isEmpty) {
        throw Exception('Failed to extract text from PDF');
      }
      
      debugPrint('PDF successfully split into ${chunks.length} chunks');
      
      // Check if OCR was used and include in message
      final bool usedOcr = chunks.isNotEmpty && chunks[0]['metadata']['processedWithOcr'] == true;
      final String ocrInfo = usedOcr ? ' (OCR processed)' : '';
      
      // If there's only one chunk, process it directly
      if (chunks.length == 1) {
        final chunk = chunks.first;
        final pdfMessage = {
          'role': 'user',
          'content': '''
This is text extracted from a PDF document$ocrInfo:
Title: $title
Pages: $pageCount
${metadata['author'] != null ? 'Author: $author' : ''}

===== DOCUMENT CONTENT =====
${chunk['chunk']}
===== END OF DOCUMENT =====

${usedOcr ? 'Note: This document was processed using OCR technology as it appears to be a scanned document. There may be some inaccuracies in the text extraction.' : ''}

Please analyze the content of this document.
'''
        };
        
        final response = await _dio.post(
          '$_baseUrl/chat/completions',
          data: {
            'model': model.contains('gpt-4') ? model : 'gpt-4o', // Use GPT-4 for better comprehension
            'messages': [...messages, pdfMessage],
          },
        );
        
        if (response.statusCode == 200) {
          return response.data['choices'][0]['message']['content'];
        } else {
          throw Exception('Failed to get response: ${response.statusCode}');
        }
      }
      
      // For multiple chunks, we need to process them sequentially and build a combined response
      StringBuffer combinedAnalysis = StringBuffer();
      combinedAnalysis.writeln('# Analysis of "$title"$ocrInfo (${chunks.length} sections)\n');
      
      // If OCR was used, add a note
      if (usedOcr) {
        combinedAnalysis.writeln('> Note: This document was processed using OCR technology as it appears to be a scanned document. There may be some inaccuracies in the text extraction.\n');
      }
      
      // Process first chunk with full context
      String currentSummary = await _processPdfChunk(
        messages,
        chunks[0],
        metadata,
        model,
        isFirstChunk: true,
        isLastChunk: false,
        chunkNumber: 1,
        totalChunks: chunks.length,
        usedOcr: usedOcr
      );
      
      combinedAnalysis.writeln('## Section 1 Analysis\n');
      combinedAnalysis.writeln('$currentSummary\n');
      
      // Process middle chunks (if any)
      for (int i = 1; i < chunks.length - 1; i++) {
        String chunkSummary = await _processPdfChunk(
          messages,
          chunks[i],
          metadata,
          model,
          isFirstChunk: false,
          isLastChunk: false,
          chunkNumber: i + 1,
          totalChunks: chunks.length,
          previousSummary: currentSummary,
          usedOcr: usedOcr
        );
        
        combinedAnalysis.writeln('## Section ${i + 1} Analysis\n');
        combinedAnalysis.writeln('$chunkSummary\n');
        
        // Update current summary for context in next chunk
        currentSummary = chunkSummary;
      }
      
      // Process final chunk if there are multiple chunks
      if (chunks.length > 1) {
        String finalSummary = await _processPdfChunk(
          messages,
          chunks[chunks.length - 1],
          metadata,
          model,
          isFirstChunk: false,
          isLastChunk: true,
          chunkNumber: chunks.length,
          totalChunks: chunks.length,
          previousSummary: currentSummary,
          usedOcr: usedOcr
        );
        
        combinedAnalysis.writeln('## Section ${chunks.length} Analysis\n');
        combinedAnalysis.writeln('$finalSummary\n');
        
        // Add an overall summary by analyzing the combined sections
        final overallSummaryMessage = {
          'role': 'user',
          'content': '''
I've analyzed a ${pageCount}-page document titled "$title"${usedOcr ? ' (OCR processed)' : ''} in ${chunks.length} sections.
Here are my section-by-section analyses:

${combinedAnalysis.toString()}

${usedOcr ? 'Note that this document was processed using OCR technology, so there may be some inaccuracies in the text extraction.' : ''}

Please provide a cohesive overall summary of this document, connecting the key points from all sections.
'''
        };
        
        final response = await _dio.post(
          '$_baseUrl/chat/completions',
          data: {
            'model': model.contains('gpt-4') ? model : 'gpt-4o',
            'messages': [...messages, overallSummaryMessage],
          },
        );
        
        if (response.statusCode == 200) {
          final overallSummary = response.data['choices'][0]['message']['content'];
          combinedAnalysis.writeln('## Overall Summary\n');
          combinedAnalysis.writeln('$overallSummary\n');
        }
      }
      
      return combinedAnalysis.toString();
    } catch (e) {
      debugPrint('Error in _sendMessageWithLargePdf: $e');
      return 'Error processing large PDF: $e';
    }
  }
  
  /// Process a single chunk of a PDF document
  Future<String> _processPdfChunk(
    List<Map<String, dynamic>> baseMessages,
    Map<String, dynamic> chunk,
    Map<String, dynamic> metadata,
    String model, {
    required bool isFirstChunk,
    required bool isLastChunk,
    required int chunkNumber,
    required int totalChunks,
    String? previousSummary,
    bool usedOcr = false
  }) async {
    try {
      // Extract chunk metadata
      final String pageRange = chunk['metadata']['pageRange'] ?? 'unknown';
      final String chunkText = chunk['chunk'] ?? '';
      
      // Create appropriate prompt based on chunk position
      String prompt;
      if (isFirstChunk) {
        prompt = '''
This is section $chunkNumber of $totalChunks from a PDF document${usedOcr ? ' (OCR processed)' : ''}:
Title: ${metadata['title'] ?? 'Untitled Document'}
Author: ${metadata['author'] ?? 'Unknown'}
Pages: $pageRange of ${metadata['pageCount'] ?? 'unknown'} total pages
${usedOcr ? 'Note: This document was processed using OCR technology as it appears to be a scanned document. There may be some inaccuracies in the text extraction.' : ''}

===== DOCUMENT CONTENT (SECTION $chunkNumber) =====
$chunkText
===== END OF SECTION $chunkNumber =====

Analyze this first section of the document. Focus on understanding the main topics and structure.
''';
      } else if (isLastChunk) {
        prompt = '''
This is the final section ($chunkNumber of $totalChunks) from a PDF document${usedOcr ? ' (OCR processed)' : ''}:
Title: ${metadata['title'] ?? 'Untitled Document'}
Pages: $pageRange of ${metadata['pageCount'] ?? 'unknown'} total pages

Previous section key points:
$previousSummary

===== DOCUMENT CONTENT (FINAL SECTION $chunkNumber) =====
$chunkText
===== END OF FINAL SECTION =====

${usedOcr ? 'Note: This document was processed using OCR technology, so there may be some inaccuracies in the text extraction.' : ''}

Analyze this final section, connecting it with the previous content. Include key conclusions if present.
''';
      } else {
        prompt = '''
This is section $chunkNumber of $totalChunks from a PDF document${usedOcr ? ' (OCR processed)' : ''}:
Title: ${metadata['title'] ?? 'Untitled Document'}
Pages: $pageRange of ${metadata['pageCount'] ?? 'unknown'} total pages

Previous section key points:
$previousSummary

===== DOCUMENT CONTENT (SECTION $chunkNumber) =====
$chunkText
===== END OF SECTION $chunkNumber =====

${usedOcr ? 'Note: This document was processed using OCR technology, so there may be some inaccuracies in the text extraction.' : ''}

Analyze this section, building on the previous sections. Focus on how this content connects with earlier material.
''';
      }
      
      // Send the chunk for analysis
      final chunkMessage = {
        'role': 'user',
        'content': prompt
      };
      
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': model.contains('gpt-4') ? model : 'gpt-4o',
          'messages': [...baseMessages, chunkMessage],
        },
      );
      
      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get response for chunk $chunkNumber: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error processing chunk $chunkNumber: $e');
      return 'Error analyzing section $chunkNumber: $e';
    }
  }
  
  Future<List<Map<String, String>>> detectQAPairs(String text, {String languageCode = 'en'}) async {
    try {
      final apiKey = getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found in .env file. Please add your OpenAI API key to the OPENAI_API_KEY variable.');
      }
      
      _dio.options.headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };
      
      // Determine language for response
      String languageName = 'English';
      if (languageCode == 'ko') {
        languageName = 'Korean';
      }
      
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a helpful assistant that identifies question-answer pairs in text. 
Your task is to:
1. Extract all question-answer pairs from the provided text
2. Format them as a JSON object with a "pairs" key containing an array of objects with "question" and "answer" fields
3. If no clear Q&A pairs are found, still return a valid JSON with an empty "pairs" array: {"pairs": []}
4. If the text itself is in a Q&A format, treat the entire text as a single Q&A pair

Always respond in $languageName unless explicitly asked to use a different language.

Example output format:
{"pairs": [{"question": "What is X?", "answer": "X is Y."}, {"question": "How does Z work?", "answer": "Z works by..."}]}'''
            },
            {
              'role': 'user',
              'content': text
            }
          ],
          'response_format': {'type': 'json_object'}
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];
        
        try {
          final decodedJson = jsonDecode(content);
          final pairs = decodedJson['pairs'] as List;
          return pairs.map<Map<String, String>>((pair) {
            return {
              'question': pair['question'],
              'answer': pair['answer'],
            };
          }).toList();
        } catch (e) {
          debugPrint('Error parsing JSON response: $e');
          return [];
        }
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        final errorMessage = errorData?['error']?['message'] ?? 'Unknown API error';
        throw Exception('API Error: $errorMessage');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error detecting Q&A pairs: $e');
    }
  }

  // Helper function to check if a file is an image based on the extension
  bool _isImageFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(extension);
  }
  
  // Helper function to check if a file is a PDF
  bool _isPdfFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return extension == 'pdf';
  }

  // Create message content for a message that contains an image
  Future<List<Map<String, dynamic>>> _formatImageMessageContent(Message message) async {
    final content = <Map<String, dynamic>>[];
    
    // Add the text content
    content.add({
      'type': 'text',
      'text': message.content,
    });
    
    // Add the image content
    try {
      debugPrint('Processing image from path: ${message.attachmentPath}');
      final imageData = await _getImageData(message.attachmentPath!);
      debugPrint('Successfully generated image data');
      
      content.add({
        'type': 'image_url',
        'image_url': {
          'url': imageData,
        }
      });
    } catch (e) {
      debugPrint('Error processing image: $e');
      content.add({
        'type': 'text',
        'text': 'I tried to send you an image, but there was an error: $e'
      });
    }
    
    return content;
  }

  // Create a message content array that includes both text and image
  Future<List<Map<String, dynamic>>> _createImageMessageContent(String text, String imagePath) async {
    final content = <Map<String, dynamic>>[];
    
    // Add the text content
    content.add({
      'type': 'text',
      'text': text,
    });
    
    // Add the image content
    try {
      debugPrint('Processing image from path: $imagePath');
      final imageData = await _getImageData(imagePath);
      debugPrint('Successfully generated image data');
      
      content.add({
        'type': 'image_url',
        'image_url': {
          'url': imageData,
        }
      });
    } catch (e) {
      debugPrint('Error processing image: $e');
      content.add({
        'type': 'text',
        'text': 'I tried to send you an image, but there was an error: $e'
      });
    }
    
    return content;
  }

  // Convert image file to base64 data URI
  Future<String> _getImageData(String imagePath) async {
    try {
      debugPrint('Starting image processing for path: $imagePath');
      
      // Special handling for web platform
      if (kIsWeb) {
        debugPrint('Running on web platform - using alternative image handling');
        
        // Check if the path starts with 'web_file_' which indicates it's a reference to our stored web files
        if (imagePath.startsWith('web_file_')) {
          // Access the FileService to get the data URI
          final fileService = FileService();
          
          // Try multiple attempts to get the data URI
          String? dataUri;
          int retryCount = 0;
          const maxRetries = 3;
          
          while (dataUri == null && retryCount < maxRetries) {
            dataUri = fileService.getWebFileDataUri(imagePath);
            if (dataUri == null) {
              retryCount++;
              if (retryCount < maxRetries) {
                debugPrint('Retry $retryCount/$maxRetries to get web file data');
                // Small delay before retrying
                await Future.delayed(const Duration(milliseconds: 100));
              }
            }
          }
          
          if (dataUri != null) {
            debugPrint('Found data URI for web file: ${dataUri.substring(0, Math.min(30, dataUri.length))}...');
            return dataUri;
          } else {
            throw Exception('Web file data not found. The file may have been removed or the session expired.');
          }
        }
        
        // Check if the imagePath starts with "data:" which indicates it's already a data URI
        if (imagePath.startsWith('data:')) {
          debugPrint('Image is already a data URI, returning as is');
          return imagePath;
        }
        
        throw Exception('Unsupported image path format for web platform: $imagePath');
      }
      
      // Native platforms (mobile/desktop) handling
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('Image file not found at path: $imagePath');
        throw Exception('Image file not found at path: $imagePath');
      }
      
      debugPrint('Reading image file bytes...');
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        debugPrint('Image file is empty or corrupted: $imagePath');
        throw Exception('Image file is empty or corrupted');
      }
      
      debugPrint('Image size: ${bytes.length} bytes');
      
      // Get file extension for MIME type
      final extension = imagePath.split('.').last.toLowerCase();
      String mimeType;
      
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        default:
          mimeType = 'image/jpeg'; // Default fallback
      }
      
      debugPrint('Using MIME type: $mimeType for extension: $extension');
      
      // Create base64 data URI
      debugPrint('Encoding image to base64...');
      final base64Data = base64Encode(bytes);
      final dataUri = 'data:$mimeType;base64,$base64Data';
      
      // Only log a substring of the base64 data to avoid flooding logs
      debugPrint('Base64 data URI created (first 50 chars): ${dataUri.substring(0, Math.min(50, dataUri.length))}...');
      
      return dataUri;
    } catch (e) {
      debugPrint('Error processing image file: $e');
      rethrow;
    }
  }

  // Create a message content array that includes both text and multiple images
  Future<List<Map<String, dynamic>>> _createMultiImageMessageContent(
    String text, 
    String primaryImagePath,
    List<String> additionalImagePaths
  ) async {
    final content = <Map<String, dynamic>>[];
    
    // Add the text content
    content.add({
      'type': 'text',
      'text': text,
    });
    
    debugPrint('Creating multi-image message with primary: ${primaryImagePath.split('/').last}');
    if (additionalImagePaths.isNotEmpty) {
      debugPrint('Additional images (in order): ${additionalImagePaths.map((p) => p.split('/').last).join(', ')}');
    }
    
    try {
      // Process all images in order, starting with the primary image
      final allImagePaths = [primaryImagePath, ...additionalImagePaths];
      debugPrint('Processing all images in this order: ${allImagePaths.map((p) => p.split('/').last).join(', ')}');
      
      for (int i = 0; i < allImagePaths.length; i++) {
        final imagePath = allImagePaths[i];
        final isPrimary = i == 0;
        
        try {
          debugPrint('Processing ${isPrimary ? "primary" : "additional"} image ${i+1}/${allImagePaths.length} from path: ${imagePath.split('/').last}');
          final imageData = await _getImageData(imagePath);
          
          content.add({
            'type': 'image_url',
            'image_url': {
              'url': imageData,
            }
          });
          debugPrint('Successfully added ${isPrimary ? "primary" : "additional"} image ${i+1}');
        } catch (e) {
          debugPrint('Error processing image ${i+1}: $e');
          content.add({
            'type': 'text',
            'text': 'I tried to send you ${isPrimary ? "the primary" : "an additional"} image, but there was an error: $e'
          });
        }
      }
    } catch (e) {
      debugPrint('Error processing images: $e');
      content.add({
        'type': 'text',
        'text': 'I tried to send you images, but there was an error: $e'
      });
    }
    
    return content;
  }

  /// Analyze an image with OpenAI Vision API
  Future<String> analyzeImage(String imagePath, String prompt) async {
    try {
      // Check if we have access to the file
      final Uint8List? imageBytes = await _getImageBytes(imagePath);
      if (imageBytes == null) {
        return 'Error: Unable to read image file.';
      }

      // Convert image bytes to base64
      final String base64Image = base64Encode(imageBytes);

      // Build the vision request with image and prompt
      final Map<String, dynamic> requestBody = {
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an OCR assistant that specializes in extracting text from scanned documents. Provide only the text content from the image, preserving formatting where possible. Do not add any explanations - only output the extracted text.'
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': prompt,
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/png;base64,$base64Image',
                },
              },
            ],
          },
        ],
        'max_tokens': 4000,
      };

      // Send API request
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${getApiKey()}',
          },
        ),
      );

      // Process response
      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['choices'][0]['message']['content'] as String;
      } else {
        return 'Error: ${response.statusCode} - ${response.statusMessage}';
      }
    } catch (e) {
      debugPrint('Error in analyzeImage: $e');
      return 'Error analyzing image: $e';
    }
  }

  /// Get image bytes from a file path
  Future<Uint8List?> _getImageBytes(String imagePath) async {
    try {
      if (kIsWeb) {
        // For web, use the FileService to get bytes from browser storage
        final FileService fileService = FileService();
        return fileService.getWebFileBytes(imagePath);
      } else {
        // For native platforms, read from the file system
        final File file = File(imagePath);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error reading image file: $e');
      return null;
    }
  }
} 