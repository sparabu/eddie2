import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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
      
      // For efficiency, we'll only check a sample of pages
      final int pagesToCheck = pageCount < 5 ? pageCount : 5;
      int scannedPageCount = 0;
      
      // Check each page in our sample
      for (int i = 0; i < pagesToCheck; i++) {
        // Get the page to analyze
        final int pageIndex = pageCount <= 5 ? i : (i * (pageCount / 5)).floor();
        final PdfPage page = document.pages[pageIndex];
        
        // Extract text using the standard extractor
        final PdfTextExtractor textExtractor = PdfTextExtractor(document);
        final String extractedText = textExtractor.extractText(startPageIndex: pageIndex, endPageIndex: pageIndex);
        
        // Count image objects on the page
        final int imageCount = await _countImagesOnPage(page);
        
        // Analyze if this appears to be a scanned page
        final bool isLikelyScanned = _isPageLikelyScanned(extractedText, imageCount, page);
        
        if (isLikelyScanned) {
          scannedPageCount++;
        }
      }
      
      // Clean up
      document.dispose();
      
      // Calculate the probability score
      return scannedPageCount / pagesToCheck;
    } catch (e) {
      debugPrint('Error analyzing PDF for scanned content: $e');
      // If we can't determine, assume digital (safer default)
      return 0.0;
    }
  }
  
  /// Count the number of images on a PDF page
  Future<int> _countImagesOnPage(PdfPage page) async {
    try {
      // Check if page has graphic content
      if (page.graphics == null) {
        return 0;
      }
      
      // Extract images from the page
      final List<PdfBitmap> bitmaps = [];
      // Note: This is a simplified approach - a complete implementation would need
      // to traverse the page's object hierarchy to find all embedded images
      
      return bitmaps.length;
    } catch (e) {
      debugPrint('Error counting images on page: $e');
      return 0;
    }
  }
  
  /// Analyze if a page is likely a scanned document based on text properties and image count
  bool _isPageLikelyScanned(String extractedText, int imageCount, PdfPage page) {
    // Check various indicators of a scanned document:
    
    // 1. Very little text with images present
    if (extractedText.trim().length < 50 && imageCount > 0) {
      return true;
    }
    
    // 2. Text layout inconsistencies (common in OCR'd documents)
    if (_hasOcrArtifacts(extractedText)) {
      return true;
    }
    
    // 3. Large full-page image
    if (imageCount == 1 && _isNearPageSize(page)) {
      return true;
    }
    
    return false;
  }
  
  /// Check if an image is nearly the size of the page (common for scans)
  bool _isNearPageSize(PdfPage page) {
    // This would compare image dimensions to page dimensions
    // Simplified implementation
    return false;
  }
  
  /// Detect common OCR artifacts in text
  bool _hasOcrArtifacts(String text) {
    // Look for patterns common in OCR'd text:
    // - Excess line breaks at random positions
    // - Random character spacing issues
    // - Merged or split words
    
    // Simplified implementation - would be more sophisticated in production
    final int randomLineBreaks = '\n'.allMatches(text).length;
    return randomLineBreaks > text.length / 100; // Arbitrary threshold
  }
  
  /// Extract text from a PDF page using OCR
  /// 
  /// This is used for scanned documents where standard text extraction fails
  Future<String> extractTextFromPageUsingOcr(PdfPage page) async {
    try {
      // Convert PDF page to image
      final Uint8List? pageImage = await _renderPageAsImage(page);
      if (pageImage == null) {
        return '';
      }
      
      // Run OCR on the image
      final String extractedText = await recognizeTextFromImage(pageImage);
      return extractedText;
    } catch (e) {
      debugPrint('Error performing OCR on PDF page: $e');
      return '';
    }
  }
  
  /// Render a PDF page as an image for OCR processing
  Future<Uint8List?> _renderPageAsImage(PdfPage page) async {
    try {
      // Export page as image using Syncfusion's exporting capability
      // Note: This is a simplified implementation
      
      // Get page dimensions
      final Size pageSize = page.size;
      
      // Set resolution for good OCR quality (300 DPI recommended)
      final double scale = 300 / 72; // Convert from PDF points to 300 DPI
      final int width = (pageSize.width * scale).round();
      final int height = (pageSize.height * scale).round();
      
      // Render page to bitmap (actual implementation would use PdfRenderer)
      // Placeholder for rendering logic
      
      // Return dummy data for now - actual implementation would return the rendered image
      return Uint8List(0);
    } catch (e) {
      debugPrint('Error rendering PDF page as image: $e');
      return null;
    }
  }
  
  /// Recognize text from an image using Google ML Kit
  Future<String> recognizeTextFromImage(Uint8List imageBytes) async {
    try {
      // Create InputImage from bytes
      final InputImage inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: const Size(1000, 1000), // Placeholder size
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 1000, // Placeholder
        ),
      );
      
      // Process the image
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Build the full text from blocks, lines, and elements
      final StringBuffer fullText = StringBuffer();
      
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          fullText.writeln(line.text);
        }
        fullText.writeln(); // Add paragraph break between blocks
      }
      
      return fullText.toString();
    } catch (e) {
      debugPrint('Error recognizing text from image: $e');
      return '';
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
      
      // Extract text using OCR, page by page
      final StringBuffer extractedText = StringBuffer();
      
      // Add basic document metadata
      extractedText.writeln('Document with $pageCount pages (OCR processed)');
      extractedText.writeln('---');
      
      // Process each page
      for (int i = 0; i < pageCount; i++) {
        final PdfPage page = document.pages[i];
        
        try {
          // Extract text using OCR
          final String pageText = await extractTextFromPageUsingOcr(page);
          
          extractedText.writeln('--- Page ${i + 1} ---');
          extractedText.writeln(pageText);
          extractedText.writeln();
        } catch (e) {
          debugPrint('Error extracting text from page ${i + 1} using OCR: $e');
          extractedText.writeln('--- Page ${i + 1} (Error extracting text) ---');
        }
      }
      
      // Clean up
      document.dispose();
      
      final String result = extractedText.toString();
      debugPrint('Successfully extracted ${result.length} characters from scanned PDF using OCR');
      return result;
    } catch (e) {
      debugPrint('Error extracting text from scanned PDF: $e');
      return 'Error extracting text from scanned PDF: $e';
    }
  }
  
  /// Pre-process an image for better OCR quality
  Future<Uint8List?> preprocessImageForOcr(Uint8List imageBytes) async {
    try {
      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return null;
      
      // Apply image processing to improve OCR results
      
      // 1. Convert to grayscale (often improves OCR)
      image = img.grayscale(image);
      
      // 2. Adjust contrast to make text more visible
      image = img.contrast(image, 150);
      
      // 3. Apply mild sharpening for clearer text edges
      image = img.sharpen(image, 1.5);
      
      // 4. Apply threshold to create black and white image (good for text)
      image = img.threshold(image, 128);
      
      // Encode the processed image
      final List<int> processed = img.encodePng(image);
      return Uint8List.fromList(processed);
    } catch (e) {
      debugPrint('Error preprocessing image for OCR: $e');
      return null;
    }
  }
  
  /// Estimate the quality of an OCR result
  /// 
  /// Returns a score between 0.0 (poor) and 1.0 (excellent)
  double estimateOcrQuality(String ocrText) {
    if (ocrText.isEmpty) return 0.0;
    
    // Initialize quality score
    double qualityScore = 1.0;
    
    // 1. Check for presence of garbage characters (common OCR errors)
    final int garbageCount = RegExp(r'[^a-zA-Z0-9.,;:!?@#$%&*()\'"\s\-]').allMatches(ocrText).length;
    final double garbageRatio = garbageCount / ocrText.length;
    qualityScore -= garbageRatio * 0.5; // Penalize garbage characters
    
    // 2. Check for word fragmentation (typical OCR problem)
    final int wordCount = ocrText.split(RegExp(r'\s+')).length;
    final int lineCount = ocrText.split('\n').length;
    final double avgWordsPerLine = wordCount / lineCount;
    if (avgWordsPerLine < 3) {
      qualityScore -= 0.2; // Penalize low word-per-line ratio (fragmented text)
    }
    
    // 3. Check for presence of common OCR errors
    if (ocrText.contains('l<') || ocrText.contains('1l') || ocrText.contains('rn')) {
      qualityScore -= 0.1; // Penalize common character confusions
    }
    
    // Ensure the score stays in the 0.0-1.0 range
    return qualityScore.clamp(0.0, 1.0);
  }
} 