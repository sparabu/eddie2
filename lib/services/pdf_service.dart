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