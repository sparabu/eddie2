import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/chat.dart';
import '../models/qa_pair.dart';
import '../models/project.dart';
import '../providers/chat_provider.dart';
import '../providers/qa_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/project_provider.dart';
import '../providers/navigation_provider.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_constants.dart';
import '../theme/eddie_text_styles.dart';
import '../widgets/eddie_logo.dart';
import '../widgets/theme_toggle.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/new_chat_button.dart';
import '../widgets/qa_list_item.dart';
import '../widgets/sidebar_item.dart';
import '../widgets/sidebar_section.dart';
import '../widgets/project_sidebar_section.dart';
import '../widgets/qa_pair_form.dart';
import '../widgets/view_all_link.dart';
import 'chat_screen.dart';
import 'qa_screen.dart';
import 'settings_screen.dart';
import 'all_chats_screen.dart';
import 'all_qa_pairs_screen.dart';
import 'project_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _isSidebarExpanded = true;
  bool _isChatsExpanded = false;
  bool _isQAPairsExpanded = false;
  
  final List<Widget> _screens = [
    const ChatScreen(),
    const QAScreen(),
    const SettingsScreen(),
  ];
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set selected index to Settings (2) if no API key is available
    // or to Chat (0) if API key is available
    final hasApiKey = ref.read(settingsProvider).hasApiKey;
    final selectedScreenIndex = ref.read(selectedScreenIndexProvider);
    
    if (!hasApiKey && selectedScreenIndex != 2) {
      ref.read(selectedScreenIndexProvider.notifier).state = 2; // Settings index
    } else if (hasApiKey && selectedScreenIndex == 2) {
      // If API key was just added and we're on settings, switch to chat
      ref.read(selectedScreenIndexProvider.notifier).state = 0; // Chat index
    }
  }
  
  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }
  
  void _createNewChat() async {
    // Clear the current chat selection - this triggers the ChatScreen to create a new chat
    ref.read(selectedChatIdProvider.notifier).state = null;
    
    // Clear project selection to ensure we're in standalone chat mode
    ref.read(selectedProjectIdProvider.notifier).state = null;
    
    // Reset navigation state
    ref.read(showProjectProvider.notifier).state = false;
    ref.read(showAllChatsProvider.notifier).state = false;
    ref.read(showAllQAPairsProvider.notifier).state = false;
    ref.read(selectedScreenIndexProvider.notifier).state = 0; // Chat index
  }
  
  void _deleteChat(String chatId) async {
    final selectedChatId = ref.read(selectedChatIdProvider);
    
    await ref.read(chatProvider.notifier).deleteChat(chatId);
    
    // If the deleted chat was selected, clear the selection
    if (selectedChatId == chatId) {
      ref.read(selectedChatIdProvider.notifier).state = null;
    }
  }
  
  void _selectChat(String chatId) {
    // Set the selected chat
    ref.read(selectedChatIdProvider.notifier).state = chatId;
    
    // Clear project selection to ensure we're in standalone chat mode
    ref.read(selectedProjectIdProvider.notifier).state = null;
    
    // Reset navigation state
    ref.read(showProjectProvider.notifier).state = false;
    ref.read(showAllChatsProvider.notifier).state = false;
    ref.read(showAllQAPairsProvider.notifier).state = false;
    ref.read(selectedScreenIndexProvider.notifier).state = 0; // Chat index
  }
  
  void _selectQAPair(QAPair qaPair) {
    ref.read(selectedQAPairIdProvider.notifier).state = qaPair.id;
    
    // Reset navigation state
    ref.read(showProjectProvider.notifier).state = false;
    ref.read(showAllChatsProvider.notifier).state = false;
    ref.read(showAllQAPairsProvider.notifier).state = false;
    ref.read(selectedScreenIndexProvider.notifier).state = 1; // QA index
  }
  
  void _deleteQAPair(String qaPairId) async {
    await ref.read(qaPairProvider.notifier).deleteQAPair(qaPairId);
  }
  
  void _createNewQAPair() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createQAPairTitle),
        content: SizedBox(
          width: 600,
          child: QAPairForm(
            onSave: (qaPair) {
              ref.read(qaPairProvider.notifier).addQAPair(qaPair);
              Navigator.of(context).pop();
              
              // Reset navigation state
              ref.read(showProjectProvider.notifier).state = false;
              ref.read(showAllChatsProvider.notifier).state = false;
              ref.read(showAllQAPairsProvider.notifier).state = false;
              ref.read(selectedScreenIndexProvider.notifier).state = 1; // QA index
              
              // Select the newly created QA pair
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(selectedQAPairIdProvider.notifier).state = qaPair.id;
              });
            },
          ),
        ),
      ),
    );
  }
  
  void _viewAllChats() {
    setState(() {
      _isChatsExpanded = !_isChatsExpanded;
    });
  }
  
  void _viewAllQAPairs() {
    setState(() {
      _isQAPairsExpanded = !_isQAPairsExpanded;
    });
  }
  
  void _renameChat(String chatId, String newTitle) async {
    await ref.read(chatProvider.notifier).updateChatTitle(chatId, newTitle);
  }
  
  void _selectProject(String projectId) {
    ref.read(selectedProjectIdProvider.notifier).state = projectId;
    ref.read(showProjectProvider.notifier).state = true;
    ref.read(showAllChatsProvider.notifier).state = false;
    ref.read(showAllQAPairsProvider.notifier).state = false;
  }
  
  void _goToSettings() {
    // Reset all navigation state and go to settings
    ref.read(selectedProjectIdProvider.notifier).state = null;
    ref.read(showProjectProvider.notifier).state = false;
    ref.read(showAllChatsProvider.notifier).state = false;
    ref.read(showAllQAPairsProvider.notifier).state = false;
    ref.read(selectedScreenIndexProvider.notifier).state = 2; // Settings index
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;
    final hasApiKey = ref.watch(settingsProvider).hasApiKey;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final l10n = AppLocalizations.of(context)!;
    
    // Get chats, QA pairs, and projects
    final chats = ref.watch(chatProvider);
    final qaPairs = ref.watch(qaPairProvider);
    final selectedChatId = ref.watch(selectedChatIdProvider);
    final selectedQAPairId = ref.watch(selectedQAPairIdProvider);
    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    
    // Get navigation state
    final selectedScreenIndex = ref.watch(selectedScreenIndexProvider);
    final showProject = ref.watch(showProjectProvider);
    final showAllChats = ref.watch(showAllChatsProvider);
    final showAllQAPairs = ref.watch(showAllQAPairsProvider);
    
    // Determine which screen to show
    Widget contentScreen;
    if (showProject && selectedProjectId != null) {
      contentScreen = ProjectScreen(projectId: selectedProjectId);
    } else if (showAllChats) {
      contentScreen = AllChatsScreen(
        chats: chats,
        selectedChatId: selectedChatId,
        onSelectChat: _selectChat,
        onDeleteChat: _deleteChat,
      );
    } else if (showAllQAPairs) {
      contentScreen = AllQAPairsScreen(
        qaPairs: qaPairs,
        selectedQAPairId: selectedQAPairId,
        onSelectQAPair: _selectQAPair,
        onDeleteQAPair: _deleteQAPair,
      );
    } else {
      // Default to the regular screens based on selectedIndex
      contentScreen = _screens[selectedScreenIndex];
    }
    
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          if (!isSmallScreen && _isSidebarExpanded)
            Container(
              width: 260,
              color: EddieColors.getSurface(context),
              child: Column(
                children: [
                  // Toggle sidebar button (moved to top left)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            size: 20,
                          ),
                          onPressed: _toggleSidebar,
                          tooltip: l10n.collapseSidebar,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: EddieColors.getTextPrimary(context),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  
                  // Navigation sections
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // Projects section
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ProjectSidebarSection(
                            onSelectProject: _selectProject,
                            selectedProjectId: selectedProjectId,
                          ),
                        ),
                        
                        // New Chat button - moved below Projects
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: OutlinedButton.icon(
                            onPressed: _createNewChat,
                            icon: const Icon(Icons.add_circle_outline),
                            label: Text(l10n.newChatButton ?? "New Chat"),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                            ),
                          ),
                        ),
                        
                        // Chat section
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.chatTabLabel,
                                style: EddieTextStyles.body2(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (chats.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    l10n.noChatsYet,
                                    style: EddieTextStyles.caption(context),
                                  ),
                                )
                              else
                                ...(() {
                                  // Sort chats by updatedAt (most recent first)
                                  final sortedChats = List<Chat>.from(chats)
                                    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                                  
                                  // Display all chats if expanded, otherwise just the first 5
                                  final displayedChats = _isChatsExpanded 
                                      ? sortedChats 
                                      : sortedChats.take(5).toList();
                                  
                                  return displayedChats.map((chat) {
                                    return SidebarItem(
                                      id: chat.id,
                                      title: chat.title,
                                      icon: Icons.chat_bubble_outline,
                                      isSelected: chat.id == selectedChatId && selectedScreenIndex == 0 && !showAllQAPairs,
                                      onTap: () => _selectChat(chat.id),
                                      onDelete: () => _deleteChat(chat.id),
                                      onRename: (newTitle) => _renameChat(chat.id, newTitle),
                                    );
                                  }).toList();
                                })(),
                              if (chats.length > 5)
                                ViewAllLink(
                                  onTap: _viewAllChats,
                                  isExpanded: _isChatsExpanded,
                                  collapsedText: l10n.viewAll,
                                  expandedText: l10n.showLess,
                                ),
                            ],
                          ),
                        ),
                        
                        // Q&A section
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.qaTabLabel,
                                    style: EddieTextStyles.body2(context).copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: EddieColors.getTextSecondary(context),
                                    ),
                                    onPressed: _createNewQAPair,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: l10n.createQAPairButton,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (qaPairs.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    l10n.noQAPairsYet,
                                    style: EddieTextStyles.caption(context),
                                  ),
                                )
                              else
                                ...(() {
                                  // Display all QA pairs if expanded, otherwise just the first 5
                                  final displayedQAPairs = _isQAPairsExpanded 
                                      ? qaPairs 
                                      : qaPairs.take(5).toList();
                                  
                                  return displayedQAPairs.map((qaPair) {
                                    return InkWell(
                                      onTap: () => _selectQAPair(qaPair),
                                      borderRadius: BorderRadius.circular(4),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.question_answer_outlined,
                                              size: 16,
                                              color: qaPair.id == selectedQAPairId && selectedScreenIndex == 1 && !showAllChats
                                                  ? EddieColors.getPrimary(context)
                                                  : EddieColors.getTextSecondary(context),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                qaPair.question,
                                                style: EddieTextStyles.body2(context).copyWith(
                                                  color: qaPair.id == selectedQAPairId && selectedScreenIndex == 1 && !showAllChats
                                                      ? EddieColors.getPrimary(context)
                                                      : EddieColors.getTextPrimary(context),
                                                  fontWeight: qaPair.id == selectedQAPairId && selectedScreenIndex == 1 && !showAllChats
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (qaPair.id == selectedQAPairId && selectedScreenIndex == 1 && !showAllChats)
                                              Icon(
                                                Icons.check,
                                                size: 16,
                                                color: EddieColors.getPrimary(context),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList();
                                })(),
                              if (qaPairs.length > 5)
                                ViewAllLink(
                                  onTap: _viewAllQAPairs,
                                  isExpanded: _isQAPairsExpanded,
                                  collapsedText: l10n.viewAll,
                                  expandedText: l10n.showLess,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Settings at the bottom
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: EddieColors.getOutline(context),
                          width: 1,
                        ),
                      ),
                    ),
                    child: InkWell(
                      onTap: _goToSettings,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings_outlined,
                              size: 16,
                              color: selectedScreenIndex == 2
                                  ? EddieColors.getPrimary(context)
                                  : EddieColors.getTextSecondary(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.settingsTabLabel,
                              style: EddieTextStyles.body2(context).copyWith(
                                color: selectedScreenIndex == 2
                                    ? EddieColors.getPrimary(context)
                                    : EddieColors.getTextPrimary(context),
                                fontWeight: selectedScreenIndex == 2 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Vertical divider that acts as a toggle button
          if (!isSmallScreen)
            MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: GestureDetector(
                onTap: _toggleSidebar,
                child: Container(
                  width: 1,
                  height: double.infinity,
                  color: EddieColors.getOutline(context),
                ),
              ),
            ),
          
          // Main content
          Expanded(
            child: Column(
              children: [
                // App bar with logo, title, and toggle sidebar button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  height: 56, // Fixed height for the app bar
                  decoration: BoxDecoration(
                    color: EddieColors.getSurface(context),
                    border: Border(
                      bottom: BorderSide(
                        color: EddieColors.getOutline(context),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (!_isSidebarExpanded)
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            size: 20,
                          ),
                          onPressed: _toggleSidebar,
                          tooltip: l10n.expandSidebar,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: EddieColors.getTextPrimary(context),
                        ),
                      if (!_isSidebarExpanded)
                        const SizedBox(width: 16),
                      const EddieLogo(size: 24, showText: true),
                      const SizedBox(width: 8),
                      if (showProject && selectedProjectId != null)
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                l10n.projects,
                                style: EddieTextStyles.body1(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: EddieColors.getTextSecondary(context),
                                ),
                              ),
                              Expanded(
                                flex: 3, // Give the title more space in the row
                                child: Text(
                                  ref.watch(projectProvider)
                                      .firstWhere(
                                        (p) => p.id == selectedProjectId,
                                        orElse: () => Project(title: ''),
                                      )
                                      .title,
                                  style: EddieTextStyles.body1(context),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (selectedScreenIndex == 0 && selectedChatId != null)
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                l10n.chatTabLabel,
                                style: EddieTextStyles.body1(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: EddieColors.getTextSecondary(context),
                                ),
                              ),
                              Expanded(
                                flex: 3, // Give the title more space in the row
                                child: Text(
                                  chats.firstWhere((chat) => chat.id == selectedChatId, orElse: () => Chat(title: '')).title,
                                  style: EddieTextStyles.body1(context),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (showAllChats)
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                l10n.chatTabLabel,
                                style: EddieTextStyles.body1(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: EddieColors.getTextSecondary(context),
                                ),
                              ),
                              Text(
                                l10n.viewAll,
                                style: EddieTextStyles.body1(context),
                              ),
                            ],
                          ),
                        )
                      else if (selectedScreenIndex == 1 && selectedQAPairId != null)
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                l10n.qaTabLabel,
                                style: EddieTextStyles.body1(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: EddieColors.getTextSecondary(context),
                                ),
                              ),
                              Expanded(
                                flex: 3, // Give the title more space in the row
                                child: Text(
                                  qaPairs.firstWhere((qa) => qa.id == selectedQAPairId, orElse: () => QAPair(question: '', answer: '')).question,
                                  style: EddieTextStyles.body1(context),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (showAllQAPairs)
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                l10n.qaTabLabel,
                                style: EddieTextStyles.body1(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: EddieColors.getTextSecondary(context),
                                ),
                              ),
                              Text(
                                l10n.viewAll,
                                style: EddieTextStyles.body1(context),
                              ),
                            ],
                          ),
                        )
                      else
                        Expanded(
                          child: Text(
                            showAllChats ? l10n.chatTabLabel :
                            showAllQAPairs ? l10n.qaTabLabel :
                            selectedScreenIndex == 0 ? l10n.chatTabLabel :
                            selectedScreenIndex == 1 ? l10n.qaTabLabel : l10n.settingsTabLabel,
                            style: EddieTextStyles.body1(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Screen content
                Expanded(
                  child: contentScreen,
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Bottom navigation for small screens
      bottomNavigationBar: isSmallScreen
          ? BottomNavigationBar(
              currentIndex: selectedScreenIndex,
              onTap: (index) {
                // Only allow navigation if API key is set or if navigating to Settings
                if (hasApiKey || index == 2) {
                  // Reset project state and update screen index
                  ref.read(selectedProjectIdProvider.notifier).state = null;
                  ref.read(showProjectProvider.notifier).state = false;
                  ref.read(showAllChatsProvider.notifier).state = false;
                  ref.read(showAllQAPairsProvider.notifier).state = false;
                  ref.read(selectedScreenIndexProvider.notifier).state = index;
                } else {
                  // Show a message that API key is required
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.apiKeyRequiredForChat),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: l10n.chatTabLabel,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.question_answer_outlined),
                  label: l10n.qaTabLabel,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings_outlined),
                  label: l10n.settingsTabLabel,
                ),
              ],
            )
          : null,
    );
  }
}

