import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/file_service.dart';
import '../theme/eddie_theme.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_constants.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(String, String) onSendMessageWithFile;
  final Function(String, String) onSendMessageWithImage;
  final Function(String, List<String>) onSendMessageWithMultipleFiles;
  final bool isLoading;
  final String? hintText;
  
  const ChatInput({
    Key? key,
    required this.onSendMessage,
    required this.onSendMessageWithFile,
    required this.onSendMessageWithImage,
    required this.onSendMessageWithMultipleFiles,
    this.isLoading = false,
    this.hintText,
  }) : super(key: key);
  
  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FileService _fileService = FileService();
  
  // Replace single attachment with list of attachments
  final List<Map<String, dynamic>> _attachedFiles = [];
  bool _isAttaching = false;
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _pickFile() async {
    setState(() {
      _isAttaching = true;
    });
    
    try {
      // Use pickMultipleFiles instead of pickFile to allow selecting multiple files
      final filesData = await _fileService.pickMultipleFiles();
      
      if (filesData != null && filesData.isNotEmpty) {
        setState(() {
          // Add the new files to the list of attachments
          _attachedFiles.addAll(filesData);
        });
      } else {
        // File picking was cancelled or failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.filePickingCancelled),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.filePickingFailed(e.toString())),
          backgroundColor: EddieColors.getError(context),
        ),
      );
    } finally {
      setState(() {
        _isAttaching = false;
      });
    }
  }
  
  void _removeAttachment(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }
  
  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    
    if (_attachedFiles.isNotEmpty) {
      debugPrint('Sending message with ${_attachedFiles.length} attachments');
      debugPrint('Attachment order in UI: ${_attachedFiles.map((f) => f['name'] as String).join(', ')}');
      
      // Check if we have multiple files
      if (_attachedFiles.length > 1) {
        // Get all file paths as a list
        final filePaths = _attachedFiles.map((file) => file['path'] as String).toList();
        debugPrint('Sending files in order: ${filePaths.map((p) => p.split('/').last).join(', ')}');
        widget.onSendMessageWithMultipleFiles(message, filePaths);
      } else {
        // We have only one file, use existing methods for backward compatibility
        final fileData = _attachedFiles.first;
        final filePath = fileData['path'] as String;
        final isImage = fileData['isImage'] as bool? ?? false;
        
        debugPrint('Sending single file: ${filePath.split('/').last}');
        if (isImage) {
          widget.onSendMessageWithImage(message, filePath);
        } else {
          widget.onSendMessageWithFile(message, filePath);
        }
      }
      
      // Clear attachments after sending
      setState(() {
        _attachedFiles.clear();
      });
    } else {
      widget.onSendMessage(message);
    }
    
    _controller.clear();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EddieColors.getSurface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: EddieColors.getOutline(context),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_attachedFiles.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: EddieColors.getSurfaceVariant(context),
                borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
                border: Border.all(
                  color: EddieColors.getOutline(context),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.attach_file, 
                        size: 16,
                        color: EddieColors.getPrimary(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_attachedFiles.length} attached file(s)',
                          style: EddieTextStyles.caption(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close, 
                          size: 14,
                          color: EddieColors.getPrimary(context),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            _attachedFiles.clear();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // List of attachments
                  ...List.generate(_attachedFiles.length, (index) {
                    final file = _attachedFiles[index];
                    final fileName = file['name'] as String;
                    final isImage = file['isImage'] as bool? ?? false;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: EddieColors.getSurface(context),
                        borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
                        border: Border.all(
                          color: EddieColors.getOutline(context),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isImage ? Icons.image : Icons.description, 
                            size: 14,
                            color: EddieColors.getTextSecondary(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fileName,
                              style: EddieTextStyles.caption(context).copyWith(
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close, 
                              size: 12,
                              color: EddieColors.getTextSecondary(context),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _removeAttachment(index),
                          ),
                        ],
                      ),
                    );
                  }),
                  // Show image previews for the first image attachment
                  if (_attachedFiles.any((file) => file['isImage'] == true))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _attachedFiles
                            .where((file) => file['isImage'] == true)
                            .take(3) // Limit to first 3 images for preview
                            .map((file) => _buildImagePreview(context, file['path'] as String))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildAttachmentButton(context, isDarkMode, l10n),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? l10n.typeMessageHint,
                    hintStyle: EddieTextStyles.body2(context).copyWith(
                      color: EddieColors.getTextSecondary(context),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: EddieColors.getOutline(context),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: EddieColors.getOutline(context),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: EddieColors.getPrimary(context),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  style: EddieTextStyles.body2(context),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: EddieColors.getPrimary(context),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        size: 20,
                        color: EddieColors.getPrimary(context),
                      ),
                onPressed: widget.isLoading ? null : _sendMessage,
                tooltip: l10n.sendButton,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton(BuildContext context, bool isDarkMode, AppLocalizations l10n) {
    return IconButton(
      icon: _isAttaching
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: EddieColors.getPrimary(context),
              ),
            )
          : Icon(
              Icons.attach_file,
              color: EddieColors.getTextSecondary(context),
            ),
      onPressed: _isAttaching ? null : _pickFile,
      tooltip: l10n.attachFileButton,
    );
  }

  // Show image preview for image attachments
  Widget _buildImagePreview(BuildContext context, String imagePath) {
    if (kIsWeb) {
      // For web, check if we have a stored image with a web ID
      if (imagePath.startsWith('web_file_')) {
        final fileService = _fileService;
        final dataUri = fileService.getWebFileDataUri(imagePath);
        
        if (dataUri != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
            child: SizedBox(
              height: 80,
              width: 80,
              child: Image.network(
                dataUri,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 80,
                    width: 80,
                    color: EddieColors.getSurfaceVariant(context),
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: EddieColors.getError(context),
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
      
      // Fallback for web
      return Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: EddieColors.getSurfaceVariant(context),
          borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
          border: Border.all(color: EddieColors.getOutline(context)),
        ),
        child: Center(
          child: Icon(
            Icons.image,
            size: 24,
            color: EddieColors.getTextSecondary(context),
          ),
        ),
      );
    } else {
      // For native platforms
      return ClipRRect(
        borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
        child: SizedBox(
          height: 80,
          width: 80,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 80,
                width: 80,
                color: EddieColors.getSurfaceVariant(context),
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    color: EddieColors.getError(context),
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }
}

