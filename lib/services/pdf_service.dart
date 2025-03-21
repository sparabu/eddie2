import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'ocr_service.dart';
import 'dart:math' as math;

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
  
  /// Threshold for considering a PDF as scanned (0.0-1.0)
  /// Higher values require more evidence that it's a scanned document
  static const double scannedPdfThreshold = 0.6;
  
  /// Extract text from a PDF file
  /// 
  /// - [bytes] The PDF file as bytes
  /// - [useOcrIfNeeded] Whether to use OCR for scanned documents
  /// - Returns extracted text with basic preprocessing
  Future<String> extractText(Uint8List bytes, {bool useOcrIfNeeded = true}) async {
    try {
      // Check if this appears to be a scanned document that would benefit from OCR
      if (useOcrIfNeeded) {
        final OcrService ocrService = OcrService();
        final double scannedProbability = await ocrService.isScannedPdf(bytes);
        
        if (scannedProbability >= scannedPdfThreshold) {
          debugPrint('PDF appears to be scanned (score: $scannedProbability). Using OCR extraction.');
          return _extractTextWithOcr(bytes);
        }
      }
      
      // If not scanned or OCR is disabled, use standard extraction
      return _extractTextStandard(bytes);
    } catch (e) {
      debugPrint('Error extracting text from PDF: $e');
      return 'Error extracting text from PDF: $e';
    }
  }
  
  /// Standard text extraction method for digital PDFs
  Future<String> _extractTextStandard(Uint8List bytes) async {
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
      debugPrint('Error in standard text extraction: $e');
      return 'Error extracting text from PDF: $e';
    }
  }
  
  /// OCR-based extraction for scanned documents
  Future<String> _extractTextWithOcr(Uint8List bytes) async {
    try {
      final OcrService ocrService = OcrService();
      final String extractedText = await ocrService.extractTextFromScannedPdf(bytes);
      
      // Check OCR quality
      final double ocrQuality = ocrService.estimateOcrQuality(extractedText);
      debugPrint('OCR quality score: $ocrQuality');
      
      // Add quality indicator if low quality
      if (ocrQuality < 0.5) {
        return '''
OCR QUALITY WARNING: The text extraction quality appears to be low. Results may not be accurate.

$extractedText
''';
      }
      
      return extractedText;
    } catch (e) {
      debugPrint('Error in OCR text extraction: $e');
      return 'Error extracting text using OCR: $e';
    }
  }
  
  /// Extract text from a PDF and divide it into semantic chunks
  /// with overlapping sentences for context preservation
  Future<List<Map<String, dynamic>>> extractAndChunkText(
    Uint8List bytes, {
    int maxTokens = 4000,
    int overlapSentences = 2,
    bool useOcrIfNeeded = false,
  }) async {
    try {
      // Start with standard extraction or OCR extraction based on the PDF type
      bool usedOcr = false;
      String fullText;
      
      if (useOcrIfNeeded) {
        // Check if this is a scanned PDF
        final OcrService ocrService = OcrService();
        final double scannedScore = await ocrService.isScannedPdf(bytes);
        
        if (scannedScore >= scannedPdfThreshold) {
          debugPrint('Detected scanned PDF (score: $scannedScore), using OCR extraction');
          fullText = await _extractTextWithOcr(bytes);
          usedOcr = true;
        } else {
          debugPrint('Using standard text extraction for digital PDF (score: $scannedScore)');
          fullText = await _extractTextStandard(bytes);
        }
      } else {
        // Skip detection and use standard extraction
        fullText = await _extractTextStandard(bytes);
      }
      
      if (fullText.trim().isEmpty) {
        debugPrint('Warning: Extracted text is empty');
        return [];
      }
      
      // Get metadata for content understanding
      final metadata = await extractMetadata(bytes);
      final int pageCount = metadata['pageCount'] ?? 1;
      
      // Split text by pages for better semantic chunking
      final List<String> pages = _splitTextIntoPages(fullText, pageCount);
      
      // Create chunks that respect semantic boundaries
      final List<Map<String, dynamic>> chunks = _createSemanticChunks(
        pages, 
        maxTokens: maxTokens,
        overlapSentences: overlapSentences,
      );
      
      // Add metadata to each chunk including OCR info
      for (int i = 0; i < chunks.length; i++) {
        chunks[i]['metadata']['processedWithOcr'] = usedOcr;
      }
      
      return chunks;
    } catch (e) {
      debugPrint('Error in extractAndChunkText: $e');
      return [];
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
  
  /// Create semantic chunks from pages respecting natural boundaries
  List<Map<String, dynamic>> _createSemanticChunks(
    List<String> pages, {
    int maxTokens = 4000,
    int overlapSentences = 2,
  }) {
    List<Map<String, dynamic>> chunks = [];
    StringBuffer currentChunk = StringBuffer();
    List<String> lastSentences = [];
    int currentTokenEstimate = 0;
    int startPage = 0;
    int endPage = 0;
    
    // We use a rough estimate of 1.3 tokens per word
    int estimateTokens(String text) {
      return (text.split(RegExp(r'\s+')).length * 1.3).ceil();
    }
    
    for (int i = 0; i < pages.length; i++) {
      String page = pages[i];
      
      // Skip empty pages
      if (page.trim().isEmpty) continue;
      
      if (currentChunk.isEmpty) {
        startPage = i;
      }
      
      // Extract sentences from current page
      final sentenceRegex = RegExp(r'[.!?]\s+');
      List<String> sentences = page.split(sentenceRegex)
        .map((s) => s.trim() + '.')
        .where((s) => s.length > 2)
        .toList();
      
      // If the page doesn't have clear sentences, treat the whole page as one
      if (sentences.isEmpty) {
        sentences = [page];
      }
      
      // Calculate token estimate for this page
      int pageTokens = estimateTokens(page);
      
      // If adding this page would exceed token limit, finalize current chunk
      if (currentTokenEstimate > 0 && currentTokenEstimate + pageTokens > maxTokens) {
        // Add the chunk with metadata
        chunks.add({
          'chunk': currentChunk.toString(),
          'metadata': {
            'pageRange': '${startPage + 1}-${endPage + 1}',
            'tokenEstimate': currentTokenEstimate,
          }
        });
        
        // Start a new chunk with overlap from previous
        currentChunk = StringBuffer();
        if (lastSentences.isNotEmpty) {
          int sentencesToInclude = math.min(overlapSentences, lastSentences.length);
          for (int j = lastSentences.length - sentencesToInclude; j < lastSentences.length; j++) {
            currentChunk.writeln(lastSentences[j]);
          }
        }
        
        // Reset tracking variables
        currentTokenEstimate = estimateTokens(currentChunk.toString());
        startPage = i;
      }
      
      // Add current page to chunk
      currentChunk.writeln(page);
      currentTokenEstimate += pageTokens;
      endPage = i;
      
      // Track last N sentences for overlap
      if (sentences.length > overlapSentences) {
        lastSentences = sentences.sublist(sentences.length - overlapSentences);
      } else {
        lastSentences = sentences;
      }
    }
    
    // Add final chunk if there's content
    if (currentChunk.isNotEmpty) {
      chunks.add({
        'chunk': currentChunk.toString(),
        'metadata': {
          'pageRange': '${startPage + 1}-${endPage + 1}',
          'tokenEstimate': currentTokenEstimate,
        }
      });
    }
    
    return chunks;
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
    int overlapSentences = 2,
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