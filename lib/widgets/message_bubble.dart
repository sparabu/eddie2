import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../theme/eddie_theme.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Message Bubble
/// 
/// A styled message bubble component for the chat interface.
class MessageBubble extends StatelessWidget {
  final dynamic message;
  final String? timestamp;
  final MessageType? type;
  final VoidCallback? onSaveQAPair;

  const MessageBubble({
    Key? key,
    required this.message,
    this.timestamp,
    this.type,
    this.onSaveQAPair,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle both String messages and Message objects
    late final String messageContent;
    late final String messageTimestamp;
    late final bool isUser;
    String? attachmentPath;
    String? attachmentName;
    
    if (message is String) {
      messageContent = message as String;
      messageTimestamp = timestamp ?? DateFormat('HH:mm').format(DateTime.now());
      isUser = type == MessageType.user;
    } else if (message is Message) {
      final msg = message as Message;
      messageContent = msg.content;
      messageTimestamp = DateFormat('HH:mm').format(msg.timestamp);
      isUser = msg.role == MessageRole.user;
      attachmentPath = msg.attachmentPath;
      attachmentName = msg.attachmentName;
    } else {
      messageContent = "Unsupported message type";
      messageTimestamp = DateFormat('HH:mm').format(DateTime.now());
      isUser = false;
    }
    
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          CircleAvatar(
            backgroundColor: EddieTheme.getPrimary(context),
            radius: 16,
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser
                  ? EddieTheme.getPrimary(context).withOpacity(0.1)
                  : EddieTheme.getColor(
                      context,
                      EddieColors.backgroundLight,
                      Color(0xFF2A2A2A),
                    ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  messageContent,
                  style: EddieTextStyles.body1(context),
                ),
                // Display attachment if available
                if (attachmentPath != null && attachmentName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: EddieColors.getSurfaceVariant(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: EddieColors.getColor(context, EddieColors.outlineLight, EddieColors.outlineDark),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 16,
                          color: EddieTheme.getTextSecondary(context),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            attachmentName,
                            style: EddieTextStyles.caption(context).copyWith(
                              color: EddieTheme.getTextSecondary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      messageTimestamp,
                      style: EddieTextStyles.caption(context),
                    ),
                    if (!isUser && onSaveQAPair != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onSaveQAPair,
                        child: Text(
                          'Save as Q&A',
                          style: TextStyle(
                            fontSize: 12,
                            color: EddieTheme.getPrimary(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: EddieTheme.getPrimary(context).withOpacity(0.2),
            radius: 16,
            child: Icon(
              Icons.person,
              size: 16,
              color: EddieTheme.getTextPrimary(context),
            ),
          ),
        ],
      ],
    );
  }
}

enum MessageType {
  user,
  assistant,
}

