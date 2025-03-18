import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/project.dart';
import '../models/message.dart';
import '../providers/project_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_theme.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';
import '../widgets/eddie_button.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/chat.dart';

class ProjectScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectScreen({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  ConsumerState<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends ConsumerState<ProjectScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isEditingDescription = false;
  bool _isLoading = false;
  String? _selectedChatId;
  String? _tempImagePath;
  Uint8List? _tempImageBytes;
  
  @override
  void initState() {
    super.initState();
    // Initialize description controller with project description
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final project = ref.read(projectProvider.notifier).getProject(widget.projectId);
      if (project != null) {
        _descriptionController.text = project.description;
        
        // If this is a new project (it has no chats), start the setup flow
        final projectChats = ref.read(chatProvider.notifier).getChatsForProject(widget.projectId);
        if (projectChats.isEmpty) {
          _startSetupFlow();
        }
      }
    });
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Set loading state
        setState(() => _isLoading = true);
        
        // Get the local path of the image
        final imagePath = pickedFile.path;
        
        // For web, we need to get the bytes
        Uint8List? imageBytes;
        if (kIsWeb) {
          imageBytes = await pickedFile.readAsBytes();
        }
        
        // Update local UI immediately with the new image
        setState(() {
          _tempImagePath = imagePath;
          if (kIsWeb) {
            _tempImageBytes = imageBytes;
          }
        });
        
        // Update the project in the provider
        await ref.read(projectProvider.notifier).updateProjectImage(
          widget.projectId, 
          imagePath,
          imageBytes: imageBytes,
        );
        
        // Clear loading state
        setState(() {
          _isLoading = false;
          _tempImagePath = null; // Clear temp path as it's now in the project
          _tempImageBytes = null;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
  
  void _saveDescription() async {
    if (!_isEditingDescription) return;
    
    final newDescription = _descriptionController.text.trim();
    await ref.read(projectProvider.notifier).updateProjectDescription(
      widget.projectId,
      newDescription
    );
    
    setState(() => _isEditingDescription = false);
  }
  
  void _onChatSelected(String chatId) {
    setState(() => _selectedChatId = chatId);
  }
  
  void _createNewChat() async {
    final project = ref.read(projectProvider.notifier).getProject(widget.projectId);
    if (project == null) return;
    
    final l10n = AppLocalizations.of(context)!;
    final newChat = await ref.read(chatProvider.notifier).createChat(
      title: '${project.title} - Chat',
      projectId: widget.projectId,
    );
    
    // Select the new chat
    setState(() => _selectedChatId = newChat.id);
  }
  
  void _startSetupFlow() async {
    final l10n = AppLocalizations.of(context)!;
    final project = ref.read(projectProvider.notifier).getProject(widget.projectId);
    if (project == null) return;
    
    // Create a new chat for this project with a temporary title
    final setupChat = await ref.read(chatProvider.notifier).createChat(
      title: "New Project Chat",  // Temporary title until user's first message
      projectId: widget.projectId,
    );
    
    // Select this chat
    setState(() => _selectedChatId = setupChat.id);
    
    // Send an initial message from the assistant asking for a title
    final titlePromptMessage = Message(
      role: MessageRole.assistant,
      content: "You want to create a new project, I understand. Can you give a title for the project, please?",
    );
    
    await ref.read(chatProvider.notifier).addMessageToChat(
      setupChat.id,
      titlePromptMessage,
    );
  }
  
  void _processUserResponse(String chatId, Message message) async {
    if (message.role != MessageRole.user) return;
    
    final chat = ref.read(chatProvider.notifier).getChatById(chatId);
    if (chat == null) return;
    
    // Find all assistant messages in this chat
    final assistantMessages = chat.messages
        .where((m) => m.role == MessageRole.assistant)
        .toList();
    
    // Check if this is a response to the title prompt
    if (assistantMessages.isNotEmpty && 
        assistantMessages.last.content.contains("give a title for the project")) {
      
      // Send the user message to OpenAI with the system instruction but don't show the response
      final systemInstruction = "You are helping the user set up a new project. "
          "Extract a concise and appropriate title from the user's message. "
          "Respond ONLY in this exact format: 'TITLE: [extracted title]'. "
          "For example, if user says 'I want to create a project about AI', respond with 'TITLE: AI Project'";
      
      final responseText = await ref.read(chatProvider.notifier).processMessageWithHiddenResponse(
        chatId,
        message.content,
        systemInstruction,
      );
      
      // Extract the title from the formatted response (TITLE: [extracted title])
      final match = RegExp(r'TITLE:\s*(.+)').firstMatch(responseText);
      if (match != null && match.group(1) != null) {
        final extractedTitle = match.group(1)!.trim();
        
        // Update the project title
        await ref.read(projectProvider.notifier).updateProjectTitle(
          widget.projectId,
          extractedTitle,
        );
        
        // Update the chat title to use the user's first message
        final userMessage = message.content;
        final chatTitle = userMessage.length > 30 
            ? '${userMessage.substring(0, 30)}...' 
            : userMessage;
        
        await ref.read(chatProvider.notifier).updateChatTitle(
          chatId,
          chatTitle,
        );
      }
      
      // Now send the description prompt
      final descriptionPromptMessage = Message(
        role: MessageRole.assistant,
        content: "Great. Now can you describe your project in more detail?",
      );
      
      await ref.read(chatProvider.notifier).addMessageToChat(
        chatId,
        descriptionPromptMessage,
      );
    }
    // Check if this is a response to the description prompt
    else if (assistantMessages.isNotEmpty && 
             assistantMessages.last.content.contains("describe your project")) {
      
      // Send the user message to OpenAI with the system instruction but don't show the response
      final systemInstruction = "You are helping the user set up a new project. "
          "Extract a concise and appropriate description from the user's message. "
          "Respond ONLY in this exact format: 'DESCRIPTION: [extracted description]'. "
          "If user says something unrelated, try to formulate a valid description from contextual clues.";
      
      final responseText = await ref.read(chatProvider.notifier).processMessageWithHiddenResponse(
        chatId,
        message.content,
        systemInstruction,
      );
      
      // Extract the description from the formatted response (DESCRIPTION: [extracted description])
      final match = RegExp(r'DESCRIPTION:\s*(.+)', dotAll: true).firstMatch(responseText);
      if (match != null && match.group(1) != null) {
        final extractedDescription = match.group(1)!.trim();
        
        // Update the project description
        await ref.read(projectProvider.notifier).updateProjectDescription(
          widget.projectId,
          extractedDescription,
        );
      }
      
      // Continue the conversation with OpenAI normally after setup
      await ref.read(chatProvider.notifier).sendMessage(
        chatId,
        message.content,
      );
    }
    // Regular chat after setup is complete
    else if (!chat.title.startsWith("Setup - ")) {
      // This is a regular message, send to OpenAI normally
      await ref.read(chatProvider.notifier).sendMessage(
        chatId,
        message.content,
      );
    }
  }
  
  void _editProjectTitle() {
    // Show a dialog to edit the project title
    final projects = ref.read(projectProvider);
    final project = projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => Project(title: "Project not found"),
    );
    if (project.title == "Project not found") return;
    
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController(text: project.title);
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.editTitle),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.enterProjectTitle,
            ),
            autofocus: true,
            onSubmitted: (_) async {
              await _updateProjectTitle(titleController.text.trim());
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                await _updateProjectTitle(titleController.text.trim());
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }
  
  // Helper method to update project title
  Future<void> _updateProjectTitle(String newTitle) async {
    if (newTitle.isEmpty) return;
    
    // Update the project title
    await ref.read(projectProvider.notifier).updateProjectTitle(
      widget.projectId,
      newTitle,
    );
    
    // We no longer update chat titles when project title changes
    // This allows chat titles to remain based on user's first message
  }
  
  // Helper method to get the appropriate DecorationImage based on platform
  DecorationImage? _getDecorationImage(BuildContext context, Project project) {
    // First check if we have a temporary image
    if (kIsWeb) {
      if (_tempImageBytes != null) {
        return DecorationImage(
          image: MemoryImage(_tempImageBytes!),
          fit: BoxFit.cover,
        );
      } else if (project.imageBytes != null) {
        return DecorationImage(
          image: MemoryImage(project.imageBytes!),
          fit: BoxFit.cover,
        );
      }
    } else {
      if (_tempImagePath != null) {
        return DecorationImage(
          image: FileImage(File(_tempImagePath!)),
          fit: BoxFit.cover,
        );
      } else if (project.imageUrl != null) {
        return DecorationImage(
          image: FileImage(File(project.imageUrl!)),
          fit: BoxFit.cover,
        );
      }
    }
    return null;
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final projects = ref.watch(projectProvider);
    final project = projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => Project(title: "Project not found"),
    );
    final isUntitled = project.title.startsWith('Untitled');
    final projectChats = ref.watch(chatProvider.notifier).getChatsForProject(widget.projectId);
    
    // If project not found, show error
    if (project.title == "Project not found") {
      return Center(
        child: Text(
          l10n.projectNotFoundError,
          style: EddieTextStyles.body1(context),
        ),
      );
    }
    
    // Get the selected chat details if a chat is selected
    final selectedChat = _selectedChatId != null 
        ? projectChats.firstWhere(
            (chat) => chat.id == _selectedChatId,
            orElse: () => Chat(title: "Chat not found"),
          )
        : null;
    
    return Row(
      children: [
        // Project details (left side)
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project title
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: EddieTextStyles.heading1(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                        color: EddieColors.getPrimary(context),
                      ),
                      onPressed: _editProjectTitle,
                      tooltip: l10n.editTitle,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Project image
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: EddieColors.getSurfaceVariant(context),
                          borderRadius: BorderRadius.circular(8),
                          image: _getDecorationImage(context, project),
                        ),
                        child: (_tempImagePath == null && _tempImageBytes == null && 
                                project.imageUrl == null && project.imageBytes == null)
                            ? Icon(
                                Icons.image_outlined,
                                size: 64,
                                color: EddieColors.getTextSecondary(context),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: EddieColors.getSurface(context).withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 20,
                              color: EddieColors.getPrimary(context),
                            ),
                          ),
                        ),
                      ),
                      if (_isLoading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Project description
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.description,
                      style: EddieTextStyles.heading3(context),
                    ),
                    if (!_isEditingDescription)
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 18,
                          color: EddieColors.getPrimary(context),
                        ),
                        onPressed: () => setState(() => _isEditingDescription = true),
                        tooltip: l10n.editDescription,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                if (_isEditingDescription)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: l10n.enterProjectDescription,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 5,
                        style: EddieTextStyles.body1(context),
                        onEditingComplete: _saveDescription,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _isEditingDescription = false),
                            child: Text(l10n.cancel),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _saveDescription,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: EddieColors.getPrimary(context),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(l10n.save),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: EddieColors.getSurfaceVariant(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: EddieColors.getOutline(context),
                      ),
                    ),
                    child: Text(
                      project.description.isEmpty
                          ? l10n.noDescriptionProvided
                          : project.description,
                      style: EddieTextStyles.body1(context).copyWith(
                        color: project.description.isEmpty
                            ? EddieColors.getTextSecondary(context)
                            : EddieColors.getTextPrimary(context),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Project chats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.projectChats,
                      style: EddieTextStyles.heading3(context),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        size: 18,
                        color: EddieColors.getPrimary(context),
                      ),
                      onPressed: _createNewChat,
                      tooltip: l10n.newChat,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                if (projectChats.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: EddieColors.getSurfaceVariant(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: EddieColors.getOutline(context),
                      ),
                    ),
                    child: Text(
                      l10n.noChatsYet,
                      style: EddieTextStyles.body1(context).copyWith(
                        color: EddieColors.getTextSecondary(context),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: projectChats.length,
                    itemBuilder: (context, index) {
                      final chat = projectChats[index];
                      final isSelected = chat.id == _selectedChatId;
                      
                      return InkWell(
                        onTap: () => _onChatSelected(chat.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? EddieColors.getPrimary(context).withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? EddieColors.getPrimary(context)
                                  : EddieColors.getOutline(context),
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 16,
                                color: isSelected
                                    ? EddieColors.getPrimary(context)
                                    : EddieColors.getTextSecondary(context),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  chat.title,
                                  style: EddieTextStyles.body2(context).copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? EddieColors.getPrimary(context)
                                        : EddieColors.getTextPrimary(context),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                
                // If this is an untitled project, show starting a chat
                if (isUntitled && projectChats.isEmpty) ...[
                  const SizedBox(height: 24),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: EddieColors.getSurfaceVariant(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: EddieColors.getOutline(context),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.startAChat,
                          style: EddieTextStyles.body1(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.startAChatDescription,
                          style: EddieTextStyles.body2(context),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _createNewChat,
                            icon: const Icon(Icons.add),
                            label: Text(l10n.newChat),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: EddieColors.getPrimary(context),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // Vertical divider
        Container(
          width: 1,
          height: double.infinity,
          color: EddieColors.getOutline(context),
        ),
        
        // Chat window (right side)
        if (_selectedChatId != null && selectedChat != null)
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Chat header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: EddieColors.getSurface(context),
                    border: Border(
                      bottom: BorderSide(
                        color: EddieColors.getOutline(context),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: EddieColors.getTextSecondary(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                // Just display the chat title without modification
                                selectedChat.title,
                                style: EddieTextStyles.heading3(context),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Chat messages
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    reverse: true,
                    itemCount: selectedChat.messages.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = selectedChat.messages.length - 1 - index;
                      final message = selectedChat.messages[reversedIndex];
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: MessageBubble(
                          message: message,
                        ),
                      );
                    },
                  ),
                ),
                
                // Chat input
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ChatInput(
                    onSendMessage: (content) async {
                      if (content.trim().isEmpty) return;
                      
                      final message = Message(
                        role: MessageRole.user,
                        content: content,
                      );
                      
                      // Add the user message to the chat
                      await ref.read(chatProvider.notifier).addMessageToChat(
                        _selectedChatId!,
                        message,
                      );
                      
                      // Process the message - this will handle both setup flow and regular chats
                      _processUserResponse(_selectedChatId!, message);
                    },
                    onSendMessageWithFile: (content, filePath) async {
                      // Get the current chat
                      final chat = ref.read(chatProvider.notifier).getChatById(_selectedChatId!);
                      
                      // For setup flow chats, don't allow file attachments
                      if (chat != null && chat.title.startsWith("Setup - ")) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Files cannot be attached during project setup.')),
                        );
                        return;
                      }
                      
                      // For regular chats, handle file attachments
                      await ref.read(chatProvider.notifier).sendMessageWithFile(
                        _selectedChatId!,
                        content,
                        filePath,
                      );
                    },
                    onSendMessageWithImage: (content, imagePath) async {
                      // Get the current chat
                      final chat = ref.read(chatProvider.notifier).getChatById(_selectedChatId!);
                      
                      // For setup flow chats, don't allow image attachments
                      if (chat != null && chat.title.startsWith("Setup - ")) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Images cannot be attached during project setup.')),
                        );
                        return;
                      }
                      
                      // For regular chats, handle image attachments
                      await ref.read(chatProvider.notifier).sendMessageWithImage(
                        _selectedChatId!,
                        content,
                        imagePath,
                      );
                    },
                    onSendMessageWithMultipleFiles: (content, filePaths) async {
                      // Get the current chat
                      final chat = ref.read(chatProvider.notifier).getChatById(_selectedChatId!);
                      
                      // For setup flow chats, don't allow file attachments
                      if (chat != null && chat.title.startsWith("Setup - ")) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Files cannot be attached during project setup.')),
                        );
                        return;
                      }
                      
                      // For regular chats, handle multiple file attachments
                      await ref.read(chatProvider.notifier).sendMessageWithMultipleFiles(
                        _selectedChatId!,
                        content,
                        filePaths,
                      );
                    },
                    isLoading: false,
                  ),
                ),
              ],
            ),
          )
        else if (_selectedChatId == null)
          // No chat selected
          Expanded(
            flex: 3,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: EddieColors.getTextSecondary(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.selectOrCreateChat,
                    style: EddieTextStyles.heading3(context).copyWith(
                      color: EddieColors.getTextSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _createNewChat,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.newChat),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EddieColors.getPrimary(context),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
} 