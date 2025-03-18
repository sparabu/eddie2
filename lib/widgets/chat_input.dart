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
  final bool isLoading;
  final String? hintText;
  
  const ChatInput({
    Key? key,
    required this.onSendMessage,
    required this.onSendMessageWithFile,
    required this.onSendMessageWithImage,
    this.isLoading = false,
    this.hintText,
  }) : super(key: key);
  
  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FileService _fileService = FileService();
  String? _attachedFilePath;
  String? _attachedFileName;
  bool _isAttaching = false;
  bool _isImageAttachment = false;
  
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
      final fileData = await _fileService.pickFile();
      
      if (fileData != null) {
        final isImage = fileData['isImage'] == true;
        
        setState(() {
          _attachedFilePath = fileData['path'];
          _attachedFileName = fileData['name'];
          _isImageAttachment = isImage;
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
  
  Future<void> _pickImage() async {
    setState(() {
      _isAttaching = true;
    });
    
    try {
      final imageData = await _fileService.pickImage();
      
      if (imageData != null) {
        setState(() {
          _attachedFilePath = imageData['path'];
          _attachedFileName = imageData['name'];
          _isImageAttachment = true;
        });
      } else {
        // Image picking was cancelled or failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.filePickingCancelled),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error selecting image: ${e.toString()}"),
          backgroundColor: EddieColors.getError(context),
        ),
      );
    } finally {
      setState(() {
        _isAttaching = false;
      });
    }
  }
  
  void _removeAttachment() {
    setState(() {
      _attachedFilePath = null;
      _attachedFileName = null;
      _isImageAttachment = false;
    });
  }
  
  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    
    if (_attachedFilePath != null && _attachedFileName != null) {
      if (_isImageAttachment) {
        widget.onSendMessageWithImage(message, _attachedFilePath!);
      } else {
        widget.onSendMessageWithFile(message, _attachedFilePath!);
      }
      _removeAttachment();
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
          if (_attachedFileName != null)
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
                        _isImageAttachment ? Icons.image : Icons.attach_file, 
                        size: 16,
                        color: EddieColors.getPrimary(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _attachedFileName!,
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
                        onPressed: _removeAttachment,
                      ),
                    ],
                  ),
                  // Show image preview for image attachments
                  _buildAttachmentPreview(context),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildAttachmentButton(context, isDarkMode, l10n),
              _buildImageAttachmentButton(context, isDarkMode),
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

  Widget _buildImageAttachmentButton(BuildContext context, bool isDarkMode) {
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
              Icons.image,
              color: EddieColors.getTextSecondary(context),
            ),
      onPressed: _isAttaching ? null : _pickImage,
      tooltip: 'Attach image',
    );
  }

  // Show image preview for image attachments
  Widget _buildAttachmentPreview(BuildContext context) {
    if (!_isImageAttachment || _attachedFilePath == null) {
      return const SizedBox.shrink();
    }
    
    // Show the image preview based on platform
    if (kIsWeb) {
      // For web, check if we have a stored image with a web ID
      if (_attachedFilePath!.startsWith('web_file_')) {
        final fileService = _fileService;
        final dataUri = fileService.getWebFileDataUri(_attachedFilePath!);
        
        if (dataUri != null) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
              child: SizedBox(
                height: 120,
                child: Image.network(
                  dataUri,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'Error loading image preview',
                        style: EddieTextStyles.caption(context).copyWith(
                          color: EddieColors.getError(context),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }
      }
      
      // Fallback for web
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: EddieColors.getSurfaceVariant(context),
            borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
            border: Border.all(color: EddieColors.getOutline(context)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image,
                  size: 24,
                  color: EddieColors.getTextSecondary(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'Image ready to be sent',
                  style: EddieTextStyles.caption(context),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // For native platforms
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
          child: SizedBox(
            height: 120,
            child: Image.file(
              File(_attachedFilePath!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    'Error loading image preview',
                    style: EddieTextStyles.caption(context).copyWith(
                      color: EddieColors.getError(context),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }
}

