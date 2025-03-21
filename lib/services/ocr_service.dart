import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' hide TextLine;
import 'package:image/image.dart' as img;
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Helper class to extract images from PDF pages
class PdfPageImageExtractor {
  final PdfPage page;
  static const double _dpiResolution = 200.0; // Reduced from 300 to 200 for better performance
  static const double _pdfPointsToDpi = _dpiResolution / 72.0; // PDF points to DPI conversion
  
  PdfPageImageExtractor(this.page);
  
  Future<img.Image?> extractImage() async {
    try {
      // Create a blank image with the page dimensions at the desired DPI
      final int width = (page.size.width * _pdfPointsToDpi).toInt();
      final int height = (page.size.height * _pdfPointsToDpi).toInt();
      
      // For the MVP, we'll return a placeholder image
      // In a real implementation, we would use a native method to render the PDF
      // such as pdf.js on web or a native PDF renderer on mobile
      final img.Image image = img.Image(width: width, height: height);
      
      // Fill with white color (simplest way that works across versions)
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          // Using RGB values directly as an integer
          image.setPixelRgba(x, y, 255, 255, 255, 255);
        }
      }
      
      // Return the image
      return image;
    } catch (e) {
      debugPrint('Error creating image from PDF page: $e');
      return null;
    }
  }
}

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
    _textRecognizer = TextRecognizer();
  }
  
  // The ML Kit text recognizer instance
  late final TextRecognizer _textRecognizer;
  
  // Constants for OCR processing
  static const double _dpiResolution = 300.0; // 300 DPI for good OCR quality
  static const double _pdfPointsToDpi = _dpiResolution / 72.0; // PDF points to DPI conversion
  
  // Dispose resources when no longer needed
  void dispose() {
    _textRecognizer.close();
  }
  
  /// Check if a PDF appears to be a scanned document
  /// Returns a value between 0.0 (not scanned) and 1.0 (definitely scanned)
  /// This uses a heuristic approach:
  /// - Extracts text directly from the PDF
  /// - Counts images on sample pages
  /// - Analyzes text properties (sparseness, formatting)
  Future<double> isScannedPdf(Uint8List pdfBytes) async {
    try {
      // Add timeout for safety
      return await _isScannedPdfImpl(pdfBytes).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('isScannedPdf operation timed out');
          return 0.8; // Assume likely scanned on timeout for better UX
        }
      );
    } catch (e) {
      debugPrint('Error checking if PDF is scanned: $e');
      return 0.0; // Default to not scanned on error
    }
  }
  
  Future<double> _isScannedPdfImpl(Uint8List pdfBytes) async {
    try {
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      
      // Get total page count
      final int pageCount = document.pages.count;
      
      // Extract some sample text to see if it's viable
      final PdfTextExtractor textExtractor = PdfTextExtractor(document);
      String sampleText = '';
      
      // Check only the first page for performance
      try {
        sampleText = textExtractor.extractText(startPageIndex: 0, endPageIndex: 0);
      } catch (e) {
        debugPrint('Error extracting text from first page: $e');
        // If text extraction fails, it's often a sign of a scanned document
        return 0.8;
      }
      
      // Quick first check - if there's substantial text, it's likely not scanned
      if (sampleText.length > 500) {
        // Check if the text has proper formatting (not just garbage OCR)
        if (_textHasProperFormatting(sampleText)) {
          return 0.1; // Probably not scanned
        }
      }
      
      // Limit analysis to just the first page for performance
      int pagesToCheck = 1;
      
      // Sample various pages if we haven't decided yet
      double scoreSum = 0;
      int pagesAnalyzed = 0;
      
      for (int i = 0; i < pagesToCheck && i < pageCount; i++) {
        // Get the page
        final PdfPage page = document.pages[i];
        
        // Count images on the page
        final int imageCount = await _countImagesOnPage(page);
        
        // Extract text content
        String extractedText = '';
        try {
          extractedText = textExtractor.extractText(startPageIndex: i, endPageIndex: i);
        } catch (e) {
          debugPrint('Error extracting text from page $i: $e');
          // Error typically indicates a scanned page
          scoreSum += 0.8;
          pagesAnalyzed++;
          continue;
        }
        
        // Calculate the likelihood of the page being scanned
        double pageScore = await _isPageLikelyScanned(extractedText, imageCount, page);
        scoreSum += pageScore;
        pagesAnalyzed++;
      }
      
      // Determine final score (average of analyzed pages)
      double finalScore = pagesAnalyzed > 0 ? scoreSum / pagesAnalyzed : 0.5;
      debugPrint('PDF scan detection final score: $finalScore');
      return finalScore;
    } catch (e) {
      debugPrint('Error in isScannedPdf: $e');
      return 0.5; // Default to uncertain on error
    }
  }
  
  Future<int> _countImagesOnPage(PdfPage page) async {
    try {
      // For performance, we'll just check if there are any images at all
      final int imageCount = page.graphics.count;
      for (int i = 0; i < imageCount; i++) {
        if (page.graphics[i] is PdfBitmap) {
          // If we find even one image, assume there might be more
          return 1;
        }
      }
      return 0;
    } catch (e) {
      debugPrint('Error counting images: $e');
      return 0;
    }
  }
  
  Future<double> _isPageLikelyScanned(String extractedText, int imageCount, PdfPage page) async {
    // If no text but has images, very likely scanned
    if (extractedText.trim().isEmpty && imageCount > 0) {
      return 0.9;
    }
    
    // If it has substantial text, check if it's proper text or possible OCR artifacts
    if (extractedText.length > 100) {
      if (_textHasProperFormatting(extractedText)) {
        return 0.2; // Likely not scanned
      }
    }
    
    // If little text but large images, likely scanned
    if (extractedText.length < 100 && imageCount > 0) {
      return 0.8;
    }
    
    // Default: medium probability
    return 0.5;
  }
  
  bool _textHasProperFormatting(String text) {
    // Check for common signs of proper formatting
    // 1. Proper paragraph breaks
    bool hasProperParagraphs = text.contains('\n\n');
    
    // 2. Punctuation usage
    bool hasPunctuation = RegExp(r'[.,:;]').hasMatch(text);
    
    // 3. Word distribution (not just random OCR artifacts)
    List<String> words = text.split(RegExp(r'\s+'));
    bool hasReasonableWordLength = words.where((w) => w.length > 2 && w.length < 15).length > words.length * 0.7;
    
    return hasProperParagraphs && hasPunctuation && hasReasonableWordLength;
  }
  
  /// Extract text from a PDF page using OCR
  Future<String> extractTextFromPageUsingOcr(PdfPage page) async {
    try {
      // Use timeout for safety
      return await _extractTextFromPageUsingOcrImpl(page).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('OCR extraction timed out');
          return "OCR processing timed out for this page. The document may be too complex or large for web processing.";
        }
      );
    } catch (e) {
      debugPrint('Error in extractTextFromPageUsingOcr: $e');
      return "Error processing this page: $e";
    }
  }
  
  Future<String> _extractTextFromPageUsingOcrImpl(PdfPage page) async {
    // Render the page to an image
    final PdfPageImageExtractor extractor = PdfPageImageExtractor(page);
    final img.Image? pageImage = await extractor.extractImage();
    
    if (pageImage == null) {
      return "";
    }
    
    // Preprocess the image to improve OCR quality
    final Uint8List? preprocessedImage = await _preprocessImageForOcr(pageImage);
    if (preprocessedImage == null) {
      return "";
    }
    
    // Perform OCR
    final String recognizedText = await recognizeTextFromImage(preprocessedImage);
    return recognizedText;
  }
  
  /// Preprocess an image to improve OCR quality
  Future<Uint8List?> _preprocessImageForOcr(img.Image image) async {
    try {
      // Apply basic image processing for OCR enhancement
      // For now, we'll just use the original image
      // In a real implementation, you might apply:
      // - Grayscale conversion
      // - Contrast enhancement
      // - Noise reduction
      // - Thresholding
      
      // Encode the processed image
      final List<int> processed = img.encodePng(image);
      return Uint8List.fromList(processed);
    } catch (e) {
      debugPrint('Error preprocessing image for OCR: $e');
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
          size: const Size(1000, 1000), // Approximate size, will be scaled by ML Kit
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: 4000, // Approximate for BGRA format (4 bytes per pixel)
        ),
      );
      
      // Process the image with ML Kit
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Build the full text from blocks, lines, and elements
      final StringBuffer fullText = StringBuffer();
      
      for (TextBlock block in recognizedText.blocks) {
        for (var line in block.lines) {
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
  
  /// Estimate the quality of an OCR result
  double estimateOcrQuality(String ocrText) {
    if (ocrText.isEmpty) return 0.0;
    
    // Calculate multiple quality factors
    double qualityScore = 0.0;
    
    // 1. Text length quality (longer text generally means better extraction)
    if (ocrText.length > 2000) {
      qualityScore += 0.4;
    } else if (ocrText.length > 1000) {
      qualityScore += 0.3;
    } else if (ocrText.length > 500) {
      qualityScore += 0.2;
    } else if (ocrText.length > 100) {
      qualityScore += 0.1;
    }
    
    // 2. Word count and average word length (meaningful content detection)
    final List<String> words = ocrText.split(RegExp(r'\s+'));
    final int wordCount = words.length;
    
    if (wordCount > 200) {
      qualityScore += 0.3;
    } else if (wordCount > 100) {
      qualityScore += 0.2;
    } else if (wordCount > 50) {
      qualityScore += 0.1;
    }
    
    // 3. Paragraph structure (presence of line breaks indicates structure preservation)
    final int paragraphCount = ocrText.split('\n\n').length;
    if (paragraphCount > 5) {
      qualityScore += 0.2;
    } else if (paragraphCount > 2) {
      qualityScore += 0.1;
    }
    
    // 4. Presence of common words (indicates meaningful text)
    final Set<String> commonWords = {'the', 'a', 'and', 'of', 'to', 'in', 'is', 'it', 'for', 'on'};
    int commonWordCount = 0;
    
    for (String word in words) {
      if (commonWords.contains(word.toLowerCase())) {
        commonWordCount++;
      }
    }
    
    final double commonWordRatio = wordCount > 0 ? commonWordCount / wordCount : 0;
    if (commonWordRatio > 0.1) {
      qualityScore += 0.1;
    }
    
    // Ensure score is between 0.0 and 1.0
    return qualityScore.clamp(0.0, 1.0);
  }
} 