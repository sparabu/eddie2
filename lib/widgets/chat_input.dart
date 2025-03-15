import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/file_service.dart';
import '../theme/eddie_theme.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../widgets/eddie_text_field.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(String, String) onSendMessageWithFile;
  final bool isLoading;
  final String? hintText;
  
  const ChatInput({
    Key? key,
    required this.onSendMessage,
    required this.onSendMessageWithFile,
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
        setState(() {
          _attachedFilePath = fileData['path'];
          _attachedFileName = fileData['name'];
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
          backgroundColor: EddieTheme.errorColor,
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
    });
  }
  
  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    
    if (_attachedFilePath != null && _attachedFileName != null) {
      widget.onSendMessageWithFile(message, _attachedFilePath!);
      _removeAttachment();
    } else {
      widget.onSendMessage(message);
    }
    
    _controller.clear();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? EddieColors.surfaceDark : EddieColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDarkMode ? EddieColors.outlineDark : EddieColors.outlineLight,
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
                color: isDarkMode ? EddieColors.surfaceVariantDark : EddieColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? EddieColors.outlineDark : EddieColors.outlineLight,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.attach_file, 
                    size: 16,
                    color: isDarkMode ? EddieColors.primaryDark : EddieColors.getPrimary(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _attachedFileName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? EddieColors.textPrimaryDark : EddieColors.getTextPrimary(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close, 
                      size: 14,
                      color: isDarkMode ? EddieColors.primaryDark : EddieColors.getPrimary(context),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _removeAttachment,
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: _isAttaching
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDarkMode ? EddieColors.primaryDark : EddieColors.getPrimary(context),
                        ),
                      )
                    : Icon(
                        Icons.attach_file,
                        color: isDarkMode ? EddieColors.textSecondaryDark : EddieColors.textSecondaryLight,
                      ),
                onPressed: _isAttaching ? null : _pickFile,
                tooltip: l10n.attachFileButton,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? l10n.typeMessageHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
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
                          color: isDarkMode ? EddieColors.primaryDark : EddieColors.getPrimary(context),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        size: 20,
                        color: isDarkMode ? EddieColors.primaryDark : EddieColors.getPrimary(context),
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
}

