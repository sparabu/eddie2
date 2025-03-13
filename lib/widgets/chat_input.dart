import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/file_service.dart';
import '../utils/theme.dart';

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
          backgroundColor: AppTheme.errorColor,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkChatBackgroundColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_attachedFileName != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _attachedFileName!,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
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
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.attach_file),
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
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDarkMode 
                        ? Colors.grey.shade800 
                        : Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
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
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onPressed: widget.isLoading ? null : _sendMessage,
                color: AppTheme.primaryColor,
                tooltip: l10n.sendButton,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 