import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'ocr_service.dart';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'file_service.dart';

/// Service for handling PDF file operations
class PdfService {
  // Singleton instance
  static final PdfService _instance = PdfService._internal();
  
  // Factory constructor to return the singleton instance
  factory PdfService() {
    return _instance;
  }
  
  // Private constructor for singleton
  PdfService._internal() {
    _ocrService = OcrService();
  }
  
  /// Default token limit for chunks to stay within OpenAI's limits
  /// Using a conservative number to account for tokens in messages and metadata
  static const int defaultMaxTokens = 4000;
  
  /// Default number of sentences to overlap between chunks
  static const int defaultOverlapSentences = 2;
  
  /// Approximate characters per token (OpenAI's tokenization is ~4 chars per token)
  static const double charsPerToken = 4.0;
  
  /// Threshold for considering a PDF as scanned (0.0-1.0)
  /// Higher values require more evidence that it's a scanned document
  static const double scannedPdfThreshold = 0.6;
  
  // OCR service instance
  late final OcrService _ocrService;
  
  /// Extract text from a PDF file
  /// 
  /// - [bytes] The PDF file as bytes
  /// - [useOcrIfNeeded] Whether to use OCR for scanned documents
  /// - Returns extracted text with basic preprocessing
  Future<Map<String, dynamic>> extractText(Uint8List bytes, {bool useOcrIfNeeded = true}) async {
    debugPrint('Extracting text from PDF file (${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB)');
    
    try {
      // Check if this appears to be a scanned document that would benefit from OCR
      if (useOcrIfNeeded) {
        final double scannedProbability = await _ocrService.isScannedPdf(bytes);
        
        if (scannedProbability >= scannedPdfThreshold) {
          debugPrint('PDF appears to be scanned (score: $scannedProbability). Using OCR extraction.');
          final result = await _extractTextWithOcr(bytes);
          
          // If result is a string, it's an error message
          if (result is String) {
            return {
              'text': result,
              'isScanned': true,
              'imageFiles': <String>[],
            };
          }
          
          // Otherwise, it's a map with text and image files
          return {
            'text': result['text'],
            'isScanned': true,
            'imageFiles': result['imageFiles'],
          };
        } else {
          debugPrint('PDF appears to be digital (score: $scannedProbability). Using standard extraction.');
        }
      }
      
      // Standard text extraction for digital PDFs
      final String extractedText = await _extractTextStandard(bytes);
      return {
        'text': extractedText,
        'isScanned': false,
        'imageFiles': <String>[],
      };
    } catch (e) {
      debugPrint('Error in text extraction: $e');
      return {
        'text': 'Error extracting text: $e',
        'isScanned': false,
        'imageFiles': <String>[],
      };
    }
  }
  
  /// Extract text from PDF bytes using standard extraction
  Future<String> _extractTextStandard(Uint8List bytes) async {
    debugPrint('Using standard PDF text extraction');
    try {
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Create a text extractor
      final PdfTextExtractor textExtractor = PdfTextExtractor(document);
      
      // Get the text from the entire document
      final String text = textExtractor.extractText();
      
      // Clean up
      document.dispose();
      
      // Process the extracted text
      return _preprocessText(text);
    } catch (e) {
      debugPrint('Error in standard PDF text extraction: $e');
      return '';
    }
  }
  
  /// Extract text from PDF bytes using OCR for scanned documents
  Future<String> _extractTextWithOcr(Uint8List bytes) async {
    debugPrint('Using OCR for text extraction via OpenAI vision');
    try {
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Get total page count
      final int pageCount = document.pages.count;
      
      // Add document metadata
      final StringBuffer extractedText = StringBuffer();
      extractedText.writeln('Document processed via OpenAI vision');
      extractedText.writeln('Total pages: $pageCount');
      extractedText.writeln('-----------------');
      
      // To improve performance, we'll limit processing to a reasonable number of pages
      final int maxPagesToProcess = 5; // Limit to 5 pages for OpenAI vision processing
      final int pagesToProcess = pageCount > maxPagesToProcess ? maxPagesToProcess : pageCount;
      
      if (pageCount > maxPagesToProcess) {
        extractedText.writeln('Note: This is a large document. Only processing the first $maxPagesToProcess pages.');
        extractedText.writeln('-----------------');
      }
      
      // Convert PDF pages to images and send to OpenAI
      List<String> imageFiles = [];
      for (int i = 0; i < pagesToProcess; i++) {
        try {
          // Convert PDF page to image
          final PdfPageImageExtractor extractor = PdfPageImageExtractor(document.pages[i]);
          final img.Image? pageImage = await extractor.extractImage();
          
          if (pageImage == null) {
            extractedText.writeln('--- Page ${i+1} ---');
            extractedText.writeln('(Error: Could not convert page to image)');
            extractedText.writeln();
            continue;
          }
          
          // Encode as PNG
          final List<int> pngBytes = img.encodePng(pageImage);
          final Uint8List imageData = Uint8List.fromList(pngBytes);
          
          // Save to temporary file
          final String imagePath = await _savePdfPageAsImage(imageData, i);
          imageFiles.add(imagePath);
          
          extractedText.writeln('--- Page ${i+1} converted to image ---');
        } catch (e) {
          debugPrint('Error processing page ${i+1}: $e');
          extractedText.writeln('--- Page ${i+1} (Error) ---');
          extractedText.writeln('Error: $e');
          extractedText.writeln();
        }
        
        // Yield back to the main thread to prevent UI freezes
        await Future.delayed(Duration.zero);
      }
      
      // Clean up
      document.dispose();
      
      if (imageFiles.isEmpty) {
        return 'Could not extract any images from the PDF. The document may be damaged or in an unsupported format.';
      }
      
      // Return information about the converted files
      extractedText.writeln('-----------------');
      extractedText.writeln('Converted ${imageFiles.length} pages to images for OpenAI vision processing.');
      extractedText.writeln('Please refer to OpenAI\'s analysis of the document content.');
      
      // Return both the paths and the text
      return {
        'text': extractedText.toString(),
        'imageFiles': imageFiles,
      };
    } catch (e) {
      debugPrint('Error in OCR text extraction: $e');
      return 'Error extracting text with OCR: $e';
    }
  }
  
  /// Save a PDF page as an image file and return the path
  Future<String> _savePdfPageAsImage(Uint8List imageData, int pageIndex) async {
    final String fileName = 'pdf_page_${pageIndex + 1}_${DateTime.now().millisecondsSinceEpoch}.png';
    
    if (kIsWeb) {
      // For web, use the FileService to store in browser
      final FileService fileService = FileService();
      final String webId = await fileService.saveWebFileData(fileName, imageData);
      return webId;
    } else {
      // For native platforms, save to temporary directory
      final Directory tempDir = await Directory.systemTemp.createTemp('pdf_images');
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageData);
      return file.path;
    }
  }
  
  /// Extract text from a PDF and divide it into semantic chunks
  /// with overlapping sentences for context preservation
  Future<List<Map<String, dynamic>>> extractAndChunkText(
    Uint8List bytes, {
    int maxTokens = defaultMaxTokens,
    int overlapSentences = defaultOverlapSentences,
    bool useOcrIfNeeded = true,
  }) async {
    try {
      // Extract the text
      final extractResult = await extractText(bytes, useOcrIfNeeded: useOcrIfNeeded);
      final String extractedText = extractResult['text'];
      final bool isScanned = extractResult['isScanned'];
      final List<String> imageFiles = extractResult['imageFiles'] ?? <String>[];
      
      // If the document is scanned and we have image files, return them
      if (isScanned && imageFiles.isNotEmpty) {
        // For scanned documents, we'll return the image files for processing by OpenAI vision
        return [
          {
            'content': 'This document appears to be scanned. Processing with OpenAI vision.',
            'chunk_index': 0,
            'total_chunks': 1,
            'metadata': {
              'isScanned': true,
              'imageFiles': imageFiles,
              'pageCount': imageFiles.length,
            }
          }
        ];
      }
      
      // If we have valid text, proceed with chunking
      if (extractedText.isNotEmpty) {
        // Process into chunks
        final chunks = await _createSemanticChunks(extractedText, maxTokens, overlapSentences);
        
        // Add metadata to each chunk
        return chunks.asMap().entries.map((entry) {
          return {
            'content': entry.value,
            'chunk_index': entry.key,
            'total_chunks': chunks.length,
            'metadata': {
              'isScanned': isScanned,
              'imageFiles': <String>[],
            }
          };
        }).toList();
      } else {
        // Return empty content with metadata if no text was extracted
        return [
          {
            'content': 'No text content could be extracted from this document.',
            'chunk_index': 0,
            'total_chunks': 1,
            'metadata': {
              'isScanned': isScanned,
              'imageFiles': <String>[],
            }
          }
        ];
      }
    } catch (e) {
      debugPrint('Error in text extraction and chunking: $e');
      return [
        {
          'content': 'Error processing document: $e',
          'chunk_index': 0,
          'total_chunks': 1,
          'metadata': {
            'isScanned': false,
            'imageFiles': <String>[],
            'error': e.toString(),
          }
        }
      ];
    }
  }
  
  /// Split text into pages using page markers or estimating page breaks
  List<String> _splitTextIntoPages(String fullText, int pageCount) {
    List<String> pages = [];
    
    // Try to find page breaks using regex patterns
    final pageBreakRegex = RegExp(r'(?:\r?\n){2,}');
    final possiblePages = fullText.split(pageBreakRegex);
    
    // If we have a reasonable match between detected breaks and actual pages
    if (possiblePages.length >= pageCount * 0.8 && possiblePages.length <= pageCount * 1.2) {
      pages = possiblePages;
    } else {
      // Fallback: Split text into roughly equal parts based on page count
      final int charsPerPage = (fullText.length / pageCount).ceil();
      for (int i = 0; i < pageCount; i++) {
        final int start = i * charsPerPage;
        final int end = (i + 1) * charsPerPage < fullText.length 
          ? (i + 1) * charsPerPage 
          : fullText.length;
        
        if (start < end) {
          pages.add(fullText.substring(start, end));
        }
      }
    }
    
    return pages.where((page) => page.trim().isNotEmpty).toList();
  }
  
  /// Create semantically meaningful chunks from text
  Future<List<String>> _createSemanticChunks(
    String fullText,
    int maxTokens,
    int overlapSentences,
  ) async {
    try {
      // Split text into paragraphs
      final paragraphs = fullText.split(RegExp(r'\n{2,}'));
      final List<String> chunks = [];
      
      String currentChunk = '';
      List<String> overlapBuffer = [];
      
      for (final paragraph in paragraphs) {
        // Skip empty paragraphs
        if (paragraph.trim().isEmpty) continue;
        
        // If adding this paragraph would exceed the token limit
        if (_estimateTokens(currentChunk + paragraph) > maxTokens && currentChunk.isNotEmpty) {
          // Add the current chunk to the list
          chunks.add(currentChunk);
          
          // Start a new chunk with the overlap buffer
          currentChunk = overlapBuffer.join(' ');
          
          // Reset overlap buffer but keep latest sentences for continuity
          overlapBuffer = [];
        }
        
        // Add paragraph to current chunk
        if (currentChunk.isNotEmpty) {
          currentChunk += '\n\n';
        }
        currentChunk += paragraph;
        
        // Update overlap buffer with sentences from this paragraph
        final sentences = paragraph.split(RegExp(r'(?<=[.!?])\s+'));
        if (sentences.length <= overlapSentences) {
          overlapBuffer.add(paragraph);
        } else {
          // Keep only the last N sentences for overlap
          overlapBuffer = sentences.sublist(sentences.length - overlapSentences);
        }
      }
      
      // Add the last chunk if not empty
      if (currentChunk.isNotEmpty) {
        chunks.add(currentChunk);
      }
      
      return chunks;
    } catch (e) {
      debugPrint('Error creating semantic chunks: $e');
      // Return original text as a single chunk on error
      return [fullText];
    }
  }
  
  /// Estimate the number of tokens in a text string
  /// This is a rough approximation using word count * 1.3
  int _estimateTokens(String text) {
    return (text.split(RegExp(r'\s+')).length * 1.3).ceil();
  }
  
  /// Extract text from a PDF file path
  /// 
  /// - [filePath] Path to the PDF file
  /// - [useOcrIfNeeded] Whether to use OCR for scanned documents
  /// - Returns extracted text with basic preprocessing
  Future<String> extractTextFromPath(String filePath, {bool useOcrIfNeeded = true}) async {
    try {
      if (kIsWeb) {
        throw Exception('extractTextFromPath is not supported on web. Use extractText with file bytes instead.');
      }
      
      // Read the file
      final File file = File(filePath);
      final Uint8List bytes = await file.readAsBytes();
      
      return extractText(bytes, useOcrIfNeeded: useOcrIfNeeded);
    } catch (e) {
      debugPrint('Error reading PDF file: $e');
      return 'Error reading PDF file: $e';
    }
  }
  
  /// Extract and chunk text from a PDF file path
  /// 
  /// - [filePath] Path to the PDF file
  /// - [maxTokens] Optional maximum tokens per chunk
  /// - [overlapSize] Optional sentences to overlap between chunks
  /// - [useOcrIfNeeded] Whether to use OCR for scanned documents
  /// - Returns list of text chunks with metadata
  Future<List<Map<String, dynamic>>> extractAndChunkTextFromPath(
    String filePath, {
    int maxTokens = defaultMaxTokens,
    int overlapSentences = defaultOverlapSentences,
    bool useOcrIfNeeded = true
  }) async {
    try {
      if (kIsWeb) {
        throw Exception('extractAndChunkTextFromPath is not supported on web. Use extractAndChunkText with file bytes instead.');
      }
      
      // Read the file
      final File file = File(filePath);
      final Uint8List bytes = await file.readAsBytes();
      
      return extractAndChunkText(
        bytes, 
        maxTokens: maxTokens, 
        overlapSentences: overlapSentences,
        useOcrIfNeeded: useOcrIfNeeded
      );
    } catch (e) {
      debugPrint('Error reading PDF file for chunking: $e');
      return [{'chunk': 'Error reading PDF file: $e', 'metadata': {'error': true}}];
    }
  }
  
  /// Extract basic metadata from a PDF
  /// 
  /// - [bytes] The PDF file as bytes
  /// - Returns a map of metadata
  Future<Map<String, dynamic>> extractMetadata(Uint8List bytes) async {
    try {
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Extract basic metadata
      final Map<String, dynamic> metadata = {
        'pageCount': document.pages.count,
        'isEncrypted': document.security.userPassword.isNotEmpty,
        'isFormDocument': document.form != null,
      };
      
      // Try to extract more detailed metadata if available
      if (document.documentInformation != null) {
        final info = document.documentInformation!;
        
        if (info.title != null) metadata['title'] = info.title;
        if (info.author != null) metadata['author'] = info.author;
        if (info.subject != null) metadata['subject'] = info.subject;
        if (info.keywords != null) metadata['keywords'] = info.keywords;
        if (info.creator != null) metadata['creator'] = info.creator;
        if (info.producer != null) metadata['producer'] = info.producer;
        if (info.creationDate != null) metadata['creationDate'] = info.creationDate.toString();
        if (info.modificationDate != null) metadata['modificationDate'] = info.modificationDate.toString();
      }
      
      // Clean up
      document.dispose();
      
      return metadata;
    } catch (e) {
      debugPrint('Error extracting metadata from PDF: $e');
      return {'error': e.toString()};
    }
  }
  
  /// Preprocess extracted text to improve quality and readability
  /// 
  /// - [text] Raw extracted text
  /// - Returns preprocessed text
  String _preprocessText(String text) {
    if (text.isEmpty) return text;
    
    String processed = text;
    
    // 1. Fix multiple spaces and tabs
    processed = processed.replaceAll(RegExp(r'\s{2,}'), ' ');
    
    // 2. Fix excessive line breaks
    processed = processed.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // 3. Fix hyphenated words split across lines
    processed = processed.replaceAll(RegExp(r'(\w+)-\s*\n\s*(\w+)'), r'$1$2');
    
    // 4. Trim each line
    processed = processed.split('\n').map((line) => line.trim()).join('\n');
    
    // 5. Remove any non-printable characters
    processed = processed.replaceAll(RegExp(r'[^\x20-\x7E\n\r\t]'), '');
    
    return processed;
  }
} 