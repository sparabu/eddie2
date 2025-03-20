import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:convert/convert.dart';

class FileService {
  // Singleton instance
  static final FileService _instance = FileService._internal();
  
  // Factory constructor to return the singleton instance
  factory FileService() {
    return _instance;
  }
  
  // Private constructor for singleton
  FileService._internal() {
    // Initialize by loading any saved web file data
    if (kIsWeb) {
      _loadPersistedWebFiles();
    }
  }
  
  static const int maxFileSizeBytes = 20 * 1024 * 1024; // 20MB limit
  
  // Map to store file bytes for web platform
  // Maps local identifiers to file bytes
  final Map<String, Uint8List> _webFileBytes = {};
  
  // Storage key for web files
  static const String _webFilesStorageKey = 'eddie_web_files';
  
  // Maximum number of files to store in local storage
  static const int _maxStoredFiles = 10;
  
  // Initialize by loading any saved web files from local storage
  void _loadPersistedWebFiles() {
    if (!kIsWeb) return;
    
    try {
      final storage = html.window.localStorage;
      final storedData = storage[_webFilesStorageKey];
      
      if (storedData != null && storedData.isNotEmpty) {
        debugPrint('Found persisted web files in local storage');
        
        final Map<String, dynamic> filesData = jsonDecode(storedData);
        
        // Clear existing data
        _webFileBytes.clear();
        
        // Load each file's data
        filesData.forEach((fileId, base64Data) {
          try {
            final bytes = base64Decode(base64Data as String);
            _webFileBytes[fileId] = bytes;
            debugPrint('Loaded persisted file: $fileId (${bytes.length} bytes)');
          } catch (e) {
            debugPrint('Error loading persisted file $fileId: $e');
          }
        });
        
        debugPrint('Loaded ${_webFileBytes.length} files from local storage');
      } else {
        debugPrint('No persisted web files found in local storage');
      }
    } catch (e) {
      debugPrint('Error loading persisted web files: $e');
    }
  }
  
  // Save current web files to local storage
  void _persistWebFiles() {
    if (!kIsWeb) return;
    
    try {
      final storage = html.window.localStorage;
      
      // Create a map of file ID to base64-encoded data
      final Map<String, String> filesData = {};
      
      // Apply file limit if needed (keep only the most recent files)
      final fileIds = _webFileBytes.keys.toList();
      if (fileIds.length > _maxStoredFiles) {
        // Sort by timestamp (assuming format web_file_TIMESTAMP_filename)
        fileIds.sort((a, b) {
          final aTimestamp = int.tryParse(a.split('_')[2]) ?? 0;
          final bTimestamp = int.tryParse(b.split('_')[2]) ?? 0;
          return bTimestamp.compareTo(aTimestamp); // Descending order
        });
        
        // Keep only the most recent files
        final recentFileIds = fileIds.take(_maxStoredFiles).toList();
        
        // Remove older files from memory
        for (final fileId in fileIds) {
          if (!recentFileIds.contains(fileId)) {
            _webFileBytes.remove(fileId);
          }
        }
      }
      
      // Convert remaining files to base64
      _webFileBytes.forEach((fileId, bytes) {
        filesData[fileId] = base64Encode(bytes);
      });
      
      // Save to localStorage
      storage[_webFilesStorageKey] = jsonEncode(filesData);
      debugPrint('Persisted ${filesData.length} web files to local storage');
    } catch (e) {
      debugPrint('Error persisting web files: $e');
    }
  }
  
  // List of file extensions that OpenAI's vision models support
  static const List<String> supportedImageExtensions = [
    'jpg', 'jpeg', 'png', 'webp', 'gif'
  ];
  
  // Add PDF to supported file types
  static const List<String> supportedDocumentExtensions = [
    'pdf'
  ];
  
  // MIME types for additional validation
  static const Map<String, String> supportedImageMimeTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'gif': 'image/gif',
  };
  
  // MIME types for document files
  static const Map<String, String> supportedDocumentMimeTypes = {
    'pdf': 'application/pdf',
  };
  
  Future<Map<String, dynamic>?> pickFile({bool imagesOnly = false}) async {
    try {
      // For image selection, we need to use FileType.custom when providing allowedExtensions
      FileType fileType;
      List<String>? allowedExtensions;
      
      if (imagesOnly) {
        fileType = FileType.custom;
        allowedExtensions = supportedImageExtensions;
      } else {
        fileType = FileType.any;
        allowedExtensions = null;
      }
      
      final result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
        allowMultiple: false, // Keep single file selection for backward compatibility
        withData: true, // Important: This ensures we get the bytes on web platform
      );
      
      if (result == null || result.files.isEmpty) {
        return null;
      }
      
      final file = result.files.first;
      
      // Check file size
      if (file.size > maxFileSizeBytes) {
        throw Exception('File size exceeds the maximum limit of 20MB.');
      }
      
      // Validate file extension for images
      if (imagesOnly) {
        final extension = file.extension?.toLowerCase() ?? '';
        if (!supportedImageExtensions.contains(extension)) {
          throw Exception('Unsupported image format. Please use JPG, PNG, WEBP, or GIF.');
        }
      }
      
      // Generate a unique ID for this file (for web platform)
      String webFileId = '';
      
      // For web, we need to handle files differently
      if (kIsWeb) {
        // Ensure we have the bytes
        if (file.bytes == null) {
          throw Exception('Failed to get file bytes. Please try again.');
        }
        
        // Generate a unique identifier for this file
        webFileId = 'web_file_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        
        // Store the bytes for later retrieval
        _webFileBytes[webFileId] = file.bytes!;
        
        debugPrint('Stored web file bytes with ID: $webFileId');
        
        // Persist the updated web files to local storage
        _persistWebFiles();
        
        // For images, generate a data URI
        String? dataUri;
        if (imagesOnly || _isImageFile(file.name)) {
          final extension = file.extension?.toLowerCase() ?? '';
          final mimeType = supportedImageMimeTypes[extension] ?? 'image/jpeg';
          dataUri = 'data:$mimeType;base64,${base64Encode(file.bytes!)}';
          debugPrint('Generated data URI for web image');
        }
        
        return {
          'name': file.name,
          'path': webFileId, // Using our ID as the path
          'bytes': file.bytes,
          'size': file.size,
          'extension': file.extension?.toLowerCase(),
          'isImage': imagesOnly || _isImageFile(file.name),
          'dataUri': dataUri, // Include the data URI for images
        };
      } else {
        // For mobile/desktop platforms
        if (file.path == null) {
          throw Exception('Could not get file path.');
        }
        
        return {
          'name': file.name,
          'path': file.path,
          'bytes': file.bytes, // May be null, but we have the file path
          'size': file.size,
          'extension': file.extension?.toLowerCase(),
          'isImage': imagesOnly || _isImageFile(file.name),
          'dataUri': null,
        };
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      rethrow; // Rethrow to let the UI handle specific error messages
    }
  }
  
  // New method to pick multiple files at once
  Future<List<Map<String, dynamic>>?> pickMultipleFiles({bool imagesOnly = false}) async {
    try {
      // For image selection, we need to use FileType.custom when providing allowedExtensions
      FileType fileType;
      List<String>? allowedExtensions;
      
      if (imagesOnly) {
        fileType = FileType.custom;
        allowedExtensions = supportedImageExtensions;
      } else {
        fileType = FileType.any;
        allowedExtensions = null;
      }
      
      final result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
        allowMultiple: true, // Allow multiple files to be picked
        withData: true, // Important: This ensures we get the bytes on web platform
      );
      
      if (result == null || result.files.isEmpty) {
        return null;
      }
      
      // The FilePicker result contains files in reverse order from what the user sees in the dialog
      // Reverse the list to match the order shown to the user
      final orderedFiles = result.files.reversed.toList();
      
      debugPrint('Files selected in picker order (after correction): ${orderedFiles.map((f) => f.name).join(', ')}');
      
      // Process each file
      final List<Map<String, dynamic>> fileDataList = [];
      // Use a single base timestamp to avoid reordering based on millisecond differences
      final baseTimestamp = DateTime.now().millisecondsSinceEpoch;
      
      for (int i = 0; i < orderedFiles.length; i++) {
        final file = orderedFiles[i];
        
        // Check file size
        if (file.size > maxFileSizeBytes) {
          continue; // Skip files that are too large
        }
        
        // For images, validate file extension
        if (imagesOnly) {
          final extension = file.extension?.toLowerCase() ?? '';
          if (!supportedImageExtensions.contains(extension)) {
            continue; // Skip files with unsupported extensions
          }
        }
        
        // Process based on platform
        if (kIsWeb) {
          // Ensure we have the bytes
          if (file.bytes == null) {
            continue; // Skip files without bytes
          }
          
          // Generate a unique identifier for this file
          // Use index to maintain the original file order
          final webFileId = 'web_file_${baseTimestamp}_${i}_${file.name}';
          
          // Store the bytes for later retrieval
          _webFileBytes[webFileId] = file.bytes!;
          
          debugPrint('Stored web file bytes with ID: $webFileId');
          
          // For images, generate a data URI
          String? dataUri;
          if (imagesOnly || _isImageFile(file.name)) {
            final extension = file.extension?.toLowerCase() ?? '';
            final mimeType = supportedImageMimeTypes[extension] ?? 'image/jpeg';
            dataUri = 'data:$mimeType;base64,${base64Encode(file.bytes!)}';
          }
          
          fileDataList.add({
            'name': file.name,
            'path': webFileId, // Using our ID as the path
            'bytes': file.bytes,
            'size': file.size,
            'extension': file.extension?.toLowerCase(),
            'isImage': imagesOnly || _isImageFile(file.name),
            'dataUri': dataUri, // Include the data URI for images
          });
        } else {
          // For mobile/desktop platforms
          if (file.path == null) {
            continue; // Skip files without path
          }
          
          fileDataList.add({
            'name': file.name,
            'path': file.path,
            'bytes': file.bytes, // May be null, but we have the file path
            'size': file.size,
            'extension': file.extension?.toLowerCase(),
            'isImage': imagesOnly || _isImageFile(file.name),
            'dataUri': null,
          });
        }
      }
      
      // Persist all web files to local storage
      if (kIsWeb) {
        _persistWebFiles();
      }
      
      debugPrint('Processed files in order: ${fileDataList.map((f) => f['name']).join(', ')}');
      
      return fileDataList.isEmpty ? null : fileDataList;
    } catch (e) {
      debugPrint('Error picking multiple files: $e');
      rethrow; // Rethrow to let the UI handle specific error messages
    }
  }
  
  // Helper method to check if a file is an image based on its extension
  bool _isImageFile(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return supportedImageExtensions.contains(extension);
  }
  
  // Helper method to check if a file is a PDF document
  bool _isPdfFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return extension == 'pdf';
  }
  
  // Get web file data URI by ID
  String? getWebFileDataUri(String webFileId) {
    if (!kIsWeb) return null; // Not applicable on non-web platforms
    
    // Check if we have this file's bytes
    final bytes = _webFileBytes[webFileId];
    if (bytes == null) {
      debugPrint('Web file bytes not found for ID: $webFileId');
      return null;
    }
    
    // Try to determine MIME type from the file ID
    String fileName = webFileId.split('_').sublist(3).join('_'); // Extract filename part
    String mimeType = 'application/octet-stream'; // Default MIME type
    
    final extension = fileName.split('.').last.toLowerCase();
    if (supportedImageMimeTypes.containsKey(extension)) {
      mimeType = supportedImageMimeTypes[extension]!;
    } else if (supportedDocumentMimeTypes.containsKey(extension)) {
      mimeType = supportedDocumentMimeTypes[extension]!;
    }
    
    // Create data URI
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }
  
  // Get web file bytes by ID
  Uint8List? getWebFileBytes(String webFileId) {
    if (!kIsWeb) return null; // Not applicable on non-web platforms
    
    // Check if we have this file's bytes
    final bytes = _webFileBytes[webFileId];
    if (bytes == null) {
      debugPrint('Web file bytes not found for ID: $webFileId');
      return null;
    }
    
    return bytes;
  }
  
  // Specific method for picking images only
  Future<Map<String, dynamic>?> pickImage() async {
    return pickFile(imagesOnly: true);
  }
  
  Future<String> saveTemporaryFile(List<int> bytes, String fileName) async {
    try {
      if (kIsWeb) {
        // Web doesn't support file system, so we just return a placeholder
        return 'web_file_$fileName';
      }
      
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      debugPrint('Error saving temporary file: $e');
      // Return a placeholder instead of throwing
      return 'error_file_$fileName';
    }
  }
  
  Future<void> deleteTemporaryFile(String filePath) async {
    try {
      if (kIsWeb || filePath.startsWith('web_file_') || filePath.startsWith('error_file_')) {
        // No need to delete on web or for error placeholders
        return;
      }
      
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting temporary file: $e');
      // We don't rethrow here as this is a cleanup operation
    }
  }
  
  Future<void> clearTemporaryFiles() async {
    try {
      if (kIsWeb) {
        // No need to clear on web
        return;
      }
      
      final directory = await getTemporaryDirectory();
      final files = directory.listSync();
      
      for (final file in files) {
        if (file is File) {
          try {
            await file.delete();
          } catch (e) {
            debugPrint('Error deleting file ${file.path}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing temporary files: $e');
      // We don't rethrow here as this is a cleanup operation
    }
  }
} 