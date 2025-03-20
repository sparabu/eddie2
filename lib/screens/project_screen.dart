import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/project.dart';
import '../models/message.dart';
import '../providers/project_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/navigation_provider.dart';
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
    // Instead of creating a chat immediately, just set _selectedChatId to null
    // to indicate we're in a "new chat" state, similar to how the main ChatScreen works
    setState(() => _selectedChatId = null);
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
    
    // Send an initial message from the assistant to start the conversation
    final initialMessage = Message(
      role: MessageRole.assistant,
      content: "Welcome to your new project! Please tell me about what you'd like to work on.",
    );
    
    await ref.read(chatProvider.notifier).addMessageToChat(
      setupChat.id,
      initialMessage,
    );
  }
  
  // Helper method to check if project needs setup
  bool _projectNeedsSetup(Project project) {
    return project.title == "Untitled" || project.description.isEmpty;
  }
  
  // Get the appropriate system instruction based on project state
  String _getSystemInstruction(Project project) {
    final needsTitle = project.title == "Untitled";
    final needsDescription = project.description.isEmpty;
    
    if (needsTitle && needsDescription) {
      return "A new project has been created, but the user has not provided a title or description. "
          "Your task is to request these fields from the user and then extract them from the user's response. "
          "After extraction, respond using only the following formats:\n\n"
          "Title Extraction\n"
          "Response Format: TITLE: [extracted title]\n"
          "Example: If the user says \"I want to create a project about AI,\" respond with 'TITLE: AI'\n\n"
          "Description Extraction\n"
          "Response Format: DESCRIPTION: [extracted description]\n"
          "Example: If the user says \"This project is about the Oxford English Dictionary,\" extract an appropriate description.\n\n"
          "If the user's message contains information for both title and description, extract both. "
          "If the user's message only contains information for one field, extract that field and ask for the other.";
    } else if (needsTitle) {
      return "The project needs a title. "
          "Extract a concise and appropriate title from the user's message. "
          "Respond ONLY in this exact format: 'TITLE: [extracted title]'.";
    } else if (needsDescription) {
      return "The project needs a description. "
          "Extract a concise and appropriate description from the user's message. "
          "Respond ONLY in this exact format: 'DESCRIPTION: [extracted description]'.";
    }
    
    // If neither title nor description is needed, return empty string
    return "";
  }
  
  void _processUserResponse(String chatId, Message message) async {
    if (message.role != MessageRole.user) return;
    
    final chat = ref.read(chatProvider.notifier).getChatById(chatId);
    if (chat == null) return;
    
    // Get the current project
    final project = ref.read(projectProvider.notifier).getProject(widget.projectId);
    if (project == null) return;
    
    // Check if the project needs setup (title is "Untitled" or description is empty)
    final needsSetup = _projectNeedsSetup(project);
    
    if (needsSetup) {
      // Get the appropriate system instruction
      final systemInstruction = _getSystemInstruction(project);
      
      // Process the message with the system instruction
      final responseText = await ref.read(chatProvider.notifier).processMessageWithHiddenResponse(
        chatId,
        message.content,
        systemInstruction,
      );
      
      // Check for title in the response
      final titleMatch = RegExp(r'TITLE:\s*(.+)(?:\n|$)').firstMatch(responseText);
      if (titleMatch != null && titleMatch.group(1) != null && project.title == "Untitled") {
        final extractedTitle = titleMatch.group(1)!.trim();
        
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
      
      // Check for description in the response
      final descMatch = RegExp(r'DESCRIPTION:\s*(.+)', dotAll: true).firstMatch(responseText);
      if (descMatch != null && descMatch.group(1) != null && project.description.isEmpty) {
        final extractedDescription = descMatch.group(1)!.trim();
        
        // Update the project description
        await ref.read(projectProvider.notifier).updateProjectDescription(
          widget.projectId,
          extractedDescription,
        );
      }
      
      // Create an appropriate response message based on what was extracted
      String responseContent;
      final updatedProject = ref.read(projectProvider.notifier).getProject(widget.projectId);
      
      if (updatedProject != null) {
        if (updatedProject.title != "Untitled" && !updatedProject.description.isEmpty) {
          // Both title and description are set
          responseContent = "Thank you! I've updated your project with the title '${updatedProject.title}' and saved your description. How can I help you with this project?";
        } else if (updatedProject.title != "Untitled") {
          // Only title is set
          responseContent = "Great! I've set your project title to '${updatedProject.title}'. Could you also provide a brief description of what this project is about?";
        } else if (!updatedProject.description.isEmpty) {
          // Only description is set
          responseContent = "Thanks for the description! Could you also provide a title for your project?";
        } else {
          // Neither was set (extraction failed)
          responseContent = "I'd like to set up your project. Could you provide a title and a brief description of what you're working on?";
        }
      } else {
        responseContent = "I'd like to set up your project. Could you provide a title and a brief description of what you're working on?";
      }
      
      // Add the response to the chat
      final aiResponseMessage = Message(
        role: MessageRole.assistant,
        content: responseContent,
      );
      
      await ref.read(chatProvider.notifier).addMessageToChat(
        chatId,
        aiResponseMessage,
      );
    } else {
      // Project is fully set up, process message normally
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
  
  // New method to handle settings navigation
  void _navigateToSettings() {
    // Reset project view
    ref.read(selectedProjectIdProvider.notifier).state = null;
    ref.read(showProjectProvider.notifier).state = false;
    
    // Show settings
    ref.read(selectedScreenIndexProvider.notifier).state = 2;
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
                      
                      // Check if we're in a "new chat" state (no selected chat)
                      if (_selectedChatId == null) {
                        // Create a new chat with the first message as the title
                        final title = content.length > 60 ? '${content.substring(0, 60)}...' : content;
                        final newChat = await ref.read(chatProvider.notifier).createChat(
                          title: title,
                          projectId: widget.projectId,
                        );
                        
                        // Set the selected chat ID
                        setState(() => _selectedChatId = newChat.id);
                        
                        // Get the current project to check if setup is needed
                        final project = ref.read(projectProvider.notifier).getProject(widget.projectId);
                        if (project != null && _projectNeedsSetup(project)) {
                          // Special handling for project setup phase
                          // Create and add the user message
                          final message = Message(
                            role: MessageRole.user,
                            content: content,
                          );
                          
                          // Add the user message to the chat
                          await ref.read(chatProvider.notifier).addMessageToChat(
                            newChat.id,
                            message,
                          );
                          
                          // Process the response
                          _processUserResponse(newChat.id, message);
                        } else {
                          // Normal chat processing for projects that are already set up
                          await ref.read(chatProvider.notifier).sendMessage(
                            newChat.id,
                            content,
                          );
                        }
                      } else {
                        // Get the current project to check if setup is needed
                        final project = ref.read(projectProvider.notifier).getProject(widget.projectId);
                        if (project != null && _projectNeedsSetup(project)) {
                          // Special handling for project setup phase
                          // Create and add the user message
                          final message = Message(
                            role: MessageRole.user,
                            content: content,
                          );
                          
                          // Add the user message to the chat
                          await ref.read(chatProvider.notifier).addMessageToChat(
                            _selectedChatId!,
                            message,
                          );
                          
                          // Process the response
                          _processUserResponse(_selectedChatId!, message);
                        } else {
                          // Normal chat processing for projects that are already set up
                          // The sendMessage method internally adds the user message to the chat,
                          // so we don't need to add it separately
                          await ref.read(chatProvider.notifier).sendMessage(
                            _selectedChatId!,
                            content,
                          );
                        }
                      }
                    },
                    onSendMessageWithFile: (content, filePath) async {
                      // Get the current chat
                      final chat = ref.read(chatProvider.notifier).getChatById(_selectedChatId!);
                      final project = ref.read(projectProvider.notifier).getProject(widget.projectId);
                      
                      // Don't allow file attachments during project setup
                      if (project != null && _projectNeedsSetup(project)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Files cannot be attached until project setup is complete.')),
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
                      final project = ref.read(projectProvider.notifier).getProject(widget.projectId);
                      
                      // Don't allow image attachments during project setup
                      if (project != null && _projectNeedsSetup(project)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Images cannot be attached until project setup is complete.')),
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
                      final project = ref.read(projectProvider.notifier).getProject(widget.projectId);
                      
                      // Don't allow file attachments during project setup
                      if (project != null && _projectNeedsSetup(project)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Files cannot be attached until project setup is complete.')),
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
          // New chat state - show input but no messages yet
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Empty message area with welcome text
                Expanded(
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
                          l10n.startAChat,
                          style: EddieTextStyles.heading3(context).copyWith(
                            color: EddieColors.getTextPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.sendMessageToStartChatting,
                          style: EddieTextStyles.body1(context).copyWith(
                            color: EddieColors.getTextSecondary(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Chat input
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ChatInput(
                    onSendMessage: (content) async {
                      if (content.trim().isEmpty) return;
                      
                      // Create a new chat with the first message as the title
                      final title = content.length > 60 ? '${content.substring(0, 60)}...' : content;
                      final newChat = await ref.read(chatProvider.notifier).createChat(
                        title: title,
                        projectId: widget.projectId,
                      );
                      
                      // Set the selected chat ID
                      setState(() => _selectedChatId = newChat.id);
                      
                      // Get the current project to check if setup is needed
                      final project = ref.read(projectProvider.notifier).getProject(widget.projectId);
                      if (project != null && _projectNeedsSetup(project)) {
                        // Special handling for project setup phase
                        final message = Message(
                          role: MessageRole.user,
                          content: content,
                        );
                        
                        // Add the user message to the chat
                        await ref.read(chatProvider.notifier).addMessageToChat(
                          newChat.id,
                          message,
                        );
                        
                        // Process the response
                        _processUserResponse(newChat.id, message);
                      } else {
                        // Normal chat processing for projects that are already set up
                        await ref.read(chatProvider.notifier).sendMessage(
                          newChat.id,
                          content,
                        );
                      }
                    },
                    onSendMessageWithFile: (_, __) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please send a message first to create the chat before attaching files.')),
                      );
                    },
                    onSendMessageWithImage: (_, __) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please send a message first to create the chat before attaching images.')),
                      );
                    },
                    onSendMessageWithMultipleFiles: (_, __) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please send a message first to create the chat before attaching files.')),
                      );
                    },
                    isLoading: false,
                  ),
                ),
              ],
            ),
          )
        else 
          // No chat selected - show the "select or create chat" message
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