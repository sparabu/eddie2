import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Service for handling PDF file operations
class PdfService {
  // Singleton instance
  static final PdfService _instance = PdfService._internal();
  
  // Factory constructor to return the singleton instance
  factory PdfService() {
    return _instance;
  }
  
  // Private constructor for singleton
  PdfService._internal();
  
  /// Default token limit for chunks to stay within OpenAI's limits
  /// Using a conservative number to account for tokens in messages and metadata
  static const int defaultMaxTokens = 4000;
  
  /// Approximate characters per token (OpenAI's tokenization is ~4 chars per token)
  static const double charsPerToken = 4.0;
  
  /// Extract text from a PDF file
  /// 
  /// - [bytes] The PDF file as bytes
  /// - Returns extracted text with basic preprocessing
  Future<String> extractText(Uint8List bytes) async {
    try {
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Capture document metadata for context
      final int pageCount = document.pages.count;
      debugPrint('PDF has $pageCount pages');
      
      final StringBuffer extractedText = StringBuffer();
      
      // Add basic document metadata
      extractedText.writeln('Document with $pageCount pages');
      extractedText.writeln('---');
      
      // Extract text from each page
      for (int i = 0; i < pageCount; i++) {
        final PdfPage page = document.pages[i];
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        
        try {
          String pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
          pageText = _preprocessText(pageText, i + 1, pageCount);
          
          extractedText.writeln('--- Page ${i + 1} ---');
          extractedText.writeln(pageText);
          extractedText.writeln();
        } catch (e) {
          debugPrint('Error extracting text from page ${i + 1}: $e');
          extractedText.writeln('--- Page ${i + 1} (Error extracting text) ---');
        }
      }
      
      // Clean up
      document.dispose();
      
      final String result = extractedText.toString();
      debugPrint('Successfully extracted ${result.length} characters from PDF');
      return result;
    } catch (e) {
      debugPrint('Error extracting text from PDF: $e');
      return 'Error extracting text from PDF: $e';
    }
  }
  
  /// Extract and chunk text from a PDF file
  /// 
  /// - [bytes] The PDF file as bytes
  /// - [maxTokens] Optional maximum tokens per chunk (default: 4000)
  /// - [overlapSize] Optional number of sentences to overlap between chunks (default: 2)
  /// - Returns list of text chunks with metadata
  Future<List<Map<String, dynamic>>> extractAndChunkText(Uint8List bytes, {
    int maxTokens = defaultMaxTokens, 
    int overlapSentences = 2
  }) async {
    try {
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final int pageCount = document.pages.count;
      
      // Extract metadata for context
      final Map<String, dynamic> metadata = await extractMetadata(bytes);
      final String title = metadata['title'] ?? 'Untitled Document';
      
      // Stores all extracted text by page 
      final List<String> pageTexts = [];
      
      // Extract text from each page
      for (int i = 0; i < pageCount; i++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        
        try {
          String pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
          pageText = _preprocessText(pageText, i + 1, pageCount);
          pageTexts.add(pageText);
        } catch (e) {
          debugPrint('Error extracting text from page ${i + 1}: $e');
          pageTexts.add('(Error extracting text)');
        }
      }
      
      // Clean up
      document.dispose();
      
      // Now chunk the extracted text semantically
      final List<Map<String, dynamic>> chunks = _createSemanticChunks(
        pageTexts: pageTexts,
        metadata: metadata,
        maxTokens: maxTokens,
        overlapSentences: overlapSentences
      );
      
      debugPrint('Successfully chunked PDF into ${chunks.length} segments');
      return chunks;
    } catch (e) {
      debugPrint('Error extracting and chunking PDF: $e');
      return [{'chunk': 'Error processing PDF: $e', 'metadata': {'error': true}}];
    }
  }
  
  /// Create semantic chunks from extracted page texts
  /// 
  /// Uses intelligent chunking to preserve context and structure
  List<Map<String, dynamic>> _createSemanticChunks({
    required List<String> pageTexts,
    required Map<String, dynamic> metadata,
    required int maxTokens,
    required int overlapSentences
  }) {
    final List<Map<String, dynamic>> chunks = [];
    final int pageCount = pageTexts.length;
    final int maxCharsPerChunk = (maxTokens * charsPerToken).floor();
    final String title = metadata['title'] ?? 'Untitled Document';
    
    // Create a buffer for the current chunk
    StringBuffer currentChunk = StringBuffer();
    int currentChunkSize = 0;
    int startPage = 0;
    int endPage = 0;
    List<String> overlapSentencesList = [];
    
    for (int pageIndex = 0; pageIndex < pageTexts.length; pageIndex++) {
      final String pageText = pageTexts[pageIndex];
      final List<String> sentences = _splitIntoSentences(pageText);
      
      if (sentences.isEmpty) continue;
      
      for (int sentenceIndex = 0; sentenceIndex < sentences.length; sentenceIndex++) {
        final String sentence = sentences[sentenceIndex];
        final int sentenceLength = sentence.length;
        
        // If adding this sentence exceeds the chunk size limit, create a new chunk
        if (currentChunkSize + sentenceLength > maxCharsPerChunk && currentChunkSize > 0) {
          // Add metadata to the current chunk
          chunks.add({
            'chunk': currentChunk.toString(),
            'metadata': {
              'title': title,
              'pageRange': '${startPage+1}-${endPage+1}',
              'totalPages': pageCount,
              'chunkIndex': chunks.length,
            }
          });
          
          // Start a new chunk with the overlap sentences for context
          currentChunk = StringBuffer();
          for (String overlapSentence in overlapSentencesList) {
            currentChunk.write(overlapSentence);
          }
          currentChunkSize = overlapSentencesList.fold(0, (sum, s) => sum + s.length);
          startPage = pageIndex;
          
          // Clear the overlap list but keep track of recent sentences
          overlapSentencesList = [];
        }
        
        // Add the current sentence to the chunk
        currentChunk.write(sentence);
        currentChunkSize += sentenceLength;
        endPage = pageIndex;
        
        // Maintain a sliding window of recent sentences for overlap
        overlapSentencesList.add(sentence);
        if (overlapSentencesList.length > overlapSentences) {
          overlapSentencesList.removeAt(0);
        }
      }
      
      // Add a page separator if we're not at the end
      if (pageIndex < pageTexts.length - 1) {
        currentChunk.writeln('\n--- Next Page ---\n');
        currentChunkSize += 20; // Approximate chars for the separator
      }
    }
    
    // Add the final chunk if there's anything remaining
    if (currentChunkSize > 0) {
      chunks.add({
        'chunk': currentChunk.toString(),
        'metadata': {
          'title': title,
          'pageRange': '${startPage+1}-${endPage+1}',
          'totalPages': pageCount,
          'chunkIndex': chunks.length,
        }
      });
    }
    
    return chunks;
  }
  
  /// Split text into sentences for better chunking
  List<String> _splitIntoSentences(String text) {
    // Basic sentence splitting regex
    // This is a simplified approach - natural language processing would be more robust
    final RegExp sentenceRegex = RegExp(r'[.!?]+\s+');
    
    // Split by sentence boundaries
    List<String> sentences = text.split(sentenceRegex);
    
    // Recombine with the sentence terminators that were removed
    List<String> result = [];
    int startIndex = 0;
    
    for (String sentence in sentences) {
      if (sentence.trim().isEmpty) continue;
      
      // Find where this sentence ends in the original text
      int nextIndex = text.indexOf(sentence, startIndex) + sentence.length;
      
      // Get the sentence with its terminator
      String completesentence = text.substring(startIndex, 
        nextIndex < text.length ? 
          text.indexOf(RegExp(r'\s+'), nextIndex) + 1 : 
          text.length
      );
      
      if (completesentence.trim().isNotEmpty) {
        result.add(completesentence);
      }
      
      startIndex = nextIndex;
    }
    
    // If no sentences were found (e.g., no punctuation), return the whole text
    if (result.isEmpty && text.trim().isNotEmpty) {
      result.add(text);
    }
    
    return result;
  }
  
  /// Extract text from a PDF file path
  /// 
  /// - [filePath] Path to the PDF file
  /// - Returns extracted text with basic preprocessing
  Future<String> extractTextFromPath(String filePath) async {
    try {
      if (kIsWeb) {
        throw Exception('extractTextFromPath is not supported on web. Use extractText with file bytes instead.');
      }
      
      // Read the file
      final File file = File(filePath);
      final Uint8List bytes = await file.readAsBytes();
      
      return extractText(bytes);
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
  /// - Returns list of text chunks with metadata
  Future<List<Map<String, dynamic>>> extractAndChunkTextFromPath(String filePath, {
    int maxTokens = defaultMaxTokens,
    int overlapSentences = 2
  }) async {
    try {
      if (kIsWeb) {
        throw Exception('extractAndChunkTextFromPath is not supported on web. Use extractAndChunkText with file bytes instead.');
      }
      
      // Read the file
      final File file = File(filePath);
      final Uint8List bytes = await file.readAsBytes();
      
      return extractAndChunkText(bytes, maxTokens: maxTokens, overlapSentences: overlapSentences);
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
  
  /// Preprocess extracted text to improve quality
  /// 
  /// - [text] The raw extracted text
  /// - [pageNumber] Current page number
  /// - [totalPages] Total pages in document
  /// - Returns preprocessed text
  String _preprocessText(String text, int pageNumber, int totalPages) {
    if (text.isEmpty) return text;
    
    // Replace multiple spaces with a single space
    String processed = text.replaceAll(RegExp(r'\s+'), ' ');
    
    // Remove excessive newlines (keep max two in a row)
    processed = processed.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Fix common hyphenation issues (words broken across lines)
    processed = processed.replaceAll(RegExp(r'(\w+)-\s*\n\s*(\w+)'), r'$1$2');
    
    // Remove headers/footers that contain only page numbers
    processed = processed.replaceAll(RegExp(r'\n\s*\d+\s*\n'), '\n');
    
    // Trim whitespace from each line
    processed = processed.split('\n').map((line) => line.trim()).join('\n');
    
    return processed;
  }
} 