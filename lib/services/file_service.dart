import 'dart:io';
// Temporarily disabled due to web build issues
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  static const int maxFileSizeBytes = 20 * 1024 * 1024; // 20MB limit
  
  Future<Map<String, dynamic>?> pickFile() async {
    // Temporarily disabled due to web build issues
    debugPrint('File picking is temporarily disabled.');
    return null;
    
    /* Original implementation:
    try {
      // Check if we're on a platform where file_picker might not be fully supported
      if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
        // For desktop platforms where file_picker might have issues
        debugPrint('File picking on this platform might have limited support.');
      }
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        return null;
      }
      
      final file = result.files.first;
      
      // Check file size
      if (file.size > maxFileSizeBytes) {
        throw Exception('File size exceeds the maximum limit of 20MB.');
      }
      
      // For web, we need to handle files differently
      if (kIsWeb) {
        return {
          'name': file.name,
          'path': null, // Web doesn't have file paths
          'bytes': file.bytes,
          'size': file.size,
        };
      } else {
        // For mobile/desktop platforms
        if (file.path == null) {
          throw Exception('Could not get file path.');
        }
        
        return {
          'name': file.name,
          'path': file.path,
          'bytes': null, // We'll read from the path when needed
          'size': file.size,
        };
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      // Instead of rethrowing, we'll return null and let the UI handle it
      return null;
    }
    */
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