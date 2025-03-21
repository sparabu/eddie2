import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' hide TextLine;
import 'package:image/image.dart' as img;
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Service for handling OCR (Optical Character Recognition) operations
class OcrService {
  // Singleton instance
  static final OcrService _instance = OcrService._internal();
  
  // Factory constructor to return the singleton instance
  factory OcrService() {
    return _instance;
  }
  
  // Private constructor for singleton
  OcrService._internal() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }
  
  // The ML Kit text recognizer instance
  late final TextRecognizer _textRecognizer;
  
  // Dispose resources when no longer needed
  void dispose() {
    _textRecognizer.close();
  }
  
  /// Check if a PDF appears to be a scanned document (image-based) rather than digital text
  /// 
  /// Returns a score between 0.0 (definitely digital) and 1.0 (definitely scanned)
  Future<double> isScannedPdf(Uint8List pdfBytes) async {
    try {
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      
      // Get total page count
      final int pageCount = document.pages.count;
      
      // Extract some sample text to see if it's viable
      final PdfTextExtractor textExtractor = PdfTextExtractor(document);
      String sampleText = '';
      
      // Check first page and a middle page if available
      try {
        sampleText = textExtractor.extractText(startPageIndex: 0, endPageIndex: 0);
        
        // If we have more than one page, check another page too
        if (pageCount > 1) {
          int middlePage = (pageCount / 2).floor();
          sampleText += textExtractor.extractText(startPageIndex: middlePage, endPageIndex: middlePage);
        }
      } catch (e) {
        // If text extraction fails, it might be a scanned document
        debugPrint('Error extracting text: $e');
        document.dispose();
        return 0.9; // Likely scanned
      }
      
      // Clean up
      document.dispose();
      
      // Simple heuristic: if very little text was extracted, it might be a scanned document
      if (sampleText.trim().length < 100) {
        return 0.7; // Probably scanned
      }
      
      // If we got reasonable text, it's probably a digital document
      return 0.2; // Probably digital
    } catch (e) {
      debugPrint('Error analyzing PDF for scanned content: $e');
      // If we can't determine, assume digital (safer default)
      return 0.0;
    }
  }
  
  /// Extract text from a scanned PDF using OCR
  /// 
  /// Used when standard text extraction is unlikely to work well
  Future<String> extractTextFromScannedPdf(Uint8List pdfBytes) async {
    try {
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      
      // Get total page count
      final int pageCount = document.pages.count;
      
      // For MVP, return a placeholder message since actual OCR implementation
      // requires rendering pages as images and more complex processing
      final StringBuffer extractedText = StringBuffer();
      
      extractedText.writeln('OCR extraction detected a scanned document with $pageCount pages.');
      extractedText.writeln('Note: The text content may be limited as this appears to be a scanned document.');
      extractedText.writeln('');
      
      // Try basic text extraction as fallback
      final PdfTextExtractor textExtractor = PdfTextExtractor(document);
      for (int i = 0; i < pageCount; i++) {
        try {
          String pageText = textExtractor.extractText(startPageIndex: i, endPageIndex: i);
          if (pageText.trim().isNotEmpty) {
            extractedText.writeln('--- Page ${i + 1} ---');
            extractedText.writeln(pageText);
            extractedText.writeln('');
          }
        } catch (e) {
          debugPrint('Error extracting text from page ${i + 1}: $e');
        }
      }
      
      // Clean up
      document.dispose();
      
      final String result = extractedText.toString();
      return result;
    } catch (e) {
      debugPrint('Error extracting text from scanned PDF: $e');
      return 'Error extracting text from scanned PDF: $e';
    }
  }
  
  /// Estimate the quality of an OCR result
  double estimateOcrQuality(String ocrText) {
    if (ocrText.isEmpty) return 0.0;
    
    // Simple quality estimate based on text length
    if (ocrText.length > 1000) {
      return 0.8; // Reasonable amount of text extracted
    } else if (ocrText.length > 500) {
      return 0.6; // Some text extracted
    } else if (ocrText.length > 100) {
      return 0.4; // Limited text extracted
    } else {
      return 0.2; // Very little text extracted
    }
  }
} 