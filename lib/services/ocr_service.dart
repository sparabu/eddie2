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
  
  // Constants for OCR processing
  static const double _dpiResolution = 300.0; // 300 DPI for good OCR quality
  static const double _pdfPointsToDpi = _dpiResolution / 72.0; // PDF points to DPI conversion
  
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
      
      // Also check for images on the first page
      bool hasImages = false;
      try {
        // Attempt to extract images from the first page
        final PdfPage firstPage = document.pages[0];
        hasImages = await _pageHasImages(firstPage);
      } catch (e) {
        debugPrint('Error checking for images: $e');
      }
      
      // Clean up
      document.dispose();
      
      // Determine if it's likely a scanned document based on text content and images
      if (sampleText.trim().length < 100) {
        if (hasImages) {
          return 0.9; // Very likely scanned with images and little text
        }
        return 0.7; // Probably scanned with little text
      }
      
      // If we got reasonable text, it's probably a digital document
      return 0.2; // Probably digital
    } catch (e) {
      debugPrint('Error analyzing PDF for scanned content: $e');
      // If we can't determine, assume digital (safer default)
      return 0.0;
    }
  }
  
  /// Check if a PDF page contains images (useful for detecting scanned documents)
  Future<bool> _pageHasImages(PdfPage page) async {
    try {
      // This is a simplistic approach - in a real implementation,
      // we would traverse the page content tree to find image objects
      // For now, we'll estimate based on presence of graphics
      return page.graphics != null;
    } catch (e) {
      debugPrint('Error checking for images on page: $e');
      return false;
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
      
      // Extract text using OCR
      final StringBuffer extractedText = StringBuffer();
      
      // Add header with metadata
      extractedText.writeln('PDF Document OCR Analysis (${pageCount} pages)');
      extractedText.writeln('---');
      
      // Process each page with OCR
      for (int i = 0; i < pageCount; i++) {
        try {
          debugPrint('Processing page ${i + 1} with OCR');
          // Render the page as an image
          final Uint8List? pageImage = await renderPdfPageAsImage(document.pages[i]);
          
          if (pageImage != null) {
            // Apply image preprocessing for better OCR quality
            final Uint8List? processedImage = await preprocessImageForOcr(pageImage);
            
            // Extract text using OCR
            final String pageText = await recognizeTextFromImage(processedImage ?? pageImage);
            
            // Skip empty pages
            if (pageText.trim().isNotEmpty) {
              extractedText.writeln('--- Page ${i + 1} ---');
              extractedText.writeln(pageText);
              extractedText.writeln();
            } else {
              debugPrint('No text extracted from page ${i + 1}');
            }
          } else {
            debugPrint('Failed to render page ${i + 1} as image');
          }
        } catch (e) {
          debugPrint('Error processing page ${i + 1} with OCR: $e');
          extractedText.writeln('--- Page ${i + 1} (Error extracting text) ---');
        }
      }
      
      // Clean up
      document.dispose();
      
      final String result = extractedText.toString();
      debugPrint('Completed OCR processing, extracted ${result.length} characters');
      return result;
    } catch (e) {
      debugPrint('Error extracting text from scanned PDF: $e');
      return 'Error extracting text from scanned PDF: $e';
    }
  }
  
  /// Render a PDF page as an image for OCR processing
  Future<Uint8List?> renderPdfPageAsImage(PdfPage page) async {
    try {
      // For MVP implementation, we'll use a simpler approach
      // that works with the Syncfusion PDF API
      
      // Export the page as an image (PNG format)
      List<int> bytes = await _exportPageAsImage(page);
      return Uint8List.fromList(bytes);
    } catch (e) {
      debugPrint('Error rendering PDF page as image: $e');
      return null;
    }
  }
  
  /// Export a PDF page as a PNG image
  Future<List<int>> _exportPageAsImage(PdfPage page) async {
    try {
      // Create a simpler image exporter
      final exporter = PdfPageImageExtractor(page);
      
      // Get the image
      final img.Image? image = await exporter.extractImage();
      
      if (image != null) {
        // Convert to PNG
        return img.encodePng(image);
      } else {
        throw Exception('Failed to extract image from PDF page');
      }
    } catch (e) {
      debugPrint('Error exporting page as image: $e');
      return [];
    }
  }
  
  /// Helper class to extract images from PDF pages
  class PdfPageImageExtractor {
    final PdfPage page;
    
    PdfPageImageExtractor(this.page);
    
    Future<img.Image?> extractImage() async {
      try {
        // Create a blank image with the page dimensions at the desired DPI
        final double width = page.size.width * _pdfPointsToDpi;
        final double height = page.size.height * _pdfPointsToDpi;
        
        // For the MVP, we'll return a placeholder image
        // In a real implementation, we would use a native method to render the PDF
        // such as pdf.js on web or a native PDF renderer on mobile
        final img.Image image = img.Image(width.toInt(), height.toInt());
        
        // Fill with white background
        img.fill(image, color: img.ColorRgb8(255, 255, 255));
        
        // Return the image
        return image;
      } catch (e) {
        debugPrint('Error creating image from PDF page: $e');
        return null;
      }
    }
  }
  
  /// Pre-process an image for better OCR quality
  Future<Uint8List?> preprocessImageForOcr(Uint8List imageBytes) async {
    try {
      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        debugPrint('Failed to decode image for OCR preprocessing');
        return null;
      }
      
      // Apply image processing to improve OCR results
      
      // 1. Convert to grayscale (often improves OCR)
      image = img.grayscale(image);
      
      // 2. Adjust contrast to make text more visible
      image = img.adjustColor(image, contrast: 1.5);
      
      // 3. Adjust exposure for sharper text
      image = img.adjustColor(image, exposure: 0.2);
      
      // 4. Apply luminance threshold to create black and white image
      image = img.luminanceThreshold(image);
      
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