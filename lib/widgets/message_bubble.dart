import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/message.dart';
import '../theme/eddie_theme.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_constants.dart';
import '../services/file_service.dart';

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

  bool _isImageFile(String? filePath) {
    if (filePath == null) return false;
    final extension = filePath.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(extension);
  }

  // Build image widget based on platform
  Widget _buildImageWidget(BuildContext context, String imagePath) {
    if (kIsWeb) {
      // For web platform
      if (imagePath.startsWith('web_file_')) {
        // Try to get the data URI from the FileService
        final fileService = FileService();
        final dataUri = fileService.getWebFileDataUri(imagePath);
        
        if (dataUri != null) {
          // Use Image.network with the data URI
          return Image.network(
            dataUri,
            fit: BoxFit.contain,
            errorBuilder: (ctx, error, stackTrace) {
              return _buildImageErrorWidget(context);
            },
          );
        } else {
          return _buildImageErrorWidget(context, message: 'Image data not available');
        }
      } else if (imagePath.startsWith('data:')) {
        // Direct data URI
        return Image.network(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (ctx, error, stackTrace) {
            return _buildImageErrorWidget(context);
          },
        );
      } else {
        return _buildImageErrorWidget(context, message: 'Unsupported image format');
      }
    } else {
      // Native platforms
      return Image.file(
        File(imagePath),
        fit: BoxFit.contain,
        errorBuilder: (ctx, error, stackTrace) {
          return _buildImageErrorWidget(context);
        },
      );
    }
  }
  
  // Build error widget for image loading failures
  Widget _buildImageErrorWidget(BuildContext context, {String? message}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EddieColors.getError(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
        border: Border.all(
          color: EddieColors.getError(context).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image,
            color: EddieColors.getError(context),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            message ?? 'Image could not be loaded',
            style: EddieTextStyles.caption(context).copyWith(
              color: EddieColors.getError(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          if (kIsWeb) 
            Text(
              'Web attachments are temporary and may not persist across sessions',
              style: EddieTextStyles.caption(context).copyWith(
                color: EddieColors.getError(context),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle both String messages and Message objects
    late final String messageContent;
    late final String messageTimestamp;
    late final bool isUser;
    String? attachmentPath;
    String? attachmentName;
    List<String>? additionalAttachments;
    bool isImageAttachment = false;
    
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
      additionalAttachments = msg.additionalAttachments;
      isImageAttachment = _isImageFile(attachmentPath);
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
            backgroundColor: EddieColors.getPrimary(context),
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
                  ? EddieColors.getPrimary(context).withOpacity(0.1)
                  : EddieColors.getSurfaceVariant(context),
              borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  messageContent,
                  style: EddieTextStyles.body1(context),
                ),
                
                // Display image attachment if it's an image
                if (isImageAttachment && attachmentPath != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: 300,
                      ),
                      child: _buildImageWidget(context, attachmentPath),
                    ),
                  ),
                ]
                // Display file attachment for non-image files
                else if (attachmentPath != null && attachmentName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: EddieColors.getSurfaceVariant(context),
                      borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
                      border: Border.all(
                        color: EddieColors.getOutline(context),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 16,
                          color: EddieColors.getTextSecondary(context),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            attachmentName,
                            style: EddieTextStyles.caption(context).copyWith(
                              color: EddieColors.getTextSecondary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Display additional attachments
                if (additionalAttachments != null && additionalAttachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  // Show a header for additional attachments
                  Text(
                    'Additional attachments (${additionalAttachments.length}):',
                    style: EddieTextStyles.caption(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Images grid for additional image attachments
                  if (additionalAttachments.any((path) => _isImageFile(path)))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: additionalAttachments
                            .where((path) => _isImageFile(path))
                            .map((path) => ClipRRect(
                                  borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    child: _buildImageWidget(context, path),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  
                  // List of non-image additional attachments
                  ...additionalAttachments
                      .where((path) => !_isImageFile(path))
                      .map((path) => Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: EddieColors.getSurfaceVariant(context),
                              borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
                              border: Border.all(
                                color: EddieColors.getOutline(context),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  size: 16,
                                  color: EddieColors.getTextSecondary(context),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    path.split('/').last,
                                    style: EddieTextStyles.caption(context).copyWith(
                                      color: EddieColors.getTextSecondary(context),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ],
                
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      messageTimestamp,
                      style: EddieTextStyles.caption(context).copyWith(
                        color: EddieColors.getTextSecondary(context),
                      ),
                    ),
                    if (onSaveQAPair != null)
                      InkWell(
                        onTap: onSaveQAPair,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.save_alt,
                                size: 14,
                                color: EddieColors.getPrimary(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Save as Q&A',
                                style: EddieTextStyles.caption(context).copyWith(
                                  color: EddieColors.getPrimary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: EddieColors.getPrimary(context).withOpacity(0.2),
            radius: 16,
            child: Icon(
              Icons.person,
              size: 16,
              color: EddieColors.getTextPrimary(context),
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

