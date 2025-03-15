import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/chat.dart';
import '../models/qa_pair.dart';
import '../providers/chat_provider.dart';
import '../providers/qa_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/eddie_theme.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../widgets/eddie_logo.dart';
import '../widgets/theme_toggle.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/new_chat_button.dart';
import '../widgets/qa_list_item.dart';
import '../widgets/sidebar_item.dart';
import '../widgets/sidebar_section.dart';
import '../widgets/qa_pair_form.dart';
import '../widgets/view_all_link.dart';
import 'chat_screen.dart';
import 'qa_screen.dart';
import 'settings_screen.dart';
import 'all_chats_screen.dart';
import 'all_qa_pairs_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;
  bool _showAllChats = false;
  bool _showAllQAPairs = false;
  
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
    if (!hasApiKey && _selectedIndex != 2) {
      setState(() {
        _selectedIndex = 2; // Settings index
      });
    } else if (hasApiKey && _selectedIndex == 2) {
      // If API key was just added and we're on settings, switch to chat
      setState(() {
        _selectedIndex = 0; // Chat index
      });
    }
  }
  
  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }
  
  void _createNewChat() async {
    // Clear the current chat selection
    ref.read(selectedChatIdProvider.notifier).state = null;
    
    // Switch to chat screen if not already there
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
        _showAllChats = false;
        _showAllQAPairs = false;
      });
    } else {
      // Force a rebuild even if we're already on the chat screen
      setState(() {});
    }
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
    ref.read(selectedChatIdProvider.notifier).state = chatId;
    
    // Switch to chat screen if not already there
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
        _showAllChats = false;
        _showAllQAPairs = false;
      });
    }
  }
  
  void _selectQAPair(QAPair qaPair) {
    ref.read(selectedQAPairIdProvider.notifier).state = qaPair.id;
    
    // Switch to QA screen if not already there
    if (_selectedIndex != 1) {
      setState(() {
        _selectedIndex = 1;
        _showAllChats = false;
        _showAllQAPairs = false;
      });
    }
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
              
              // Switch to QA screen if not already there
              if (_selectedIndex != 1) {
                setState(() {
                  _selectedIndex = 1;
                  _showAllChats = false;
                  _showAllQAPairs = false;
                });
              }
              
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
      _selectedIndex = 0;
      _showAllChats = true;
      _showAllQAPairs = false;
    });
  }
  
  void _viewAllQAPairs() {
    setState(() {
      _selectedIndex = 1;
      _showAllChats = false;
      _showAllQAPairs = true;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;
    final hasApiKey = ref.watch(settingsProvider).hasApiKey;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final l10n = AppLocalizations.of(context)!;
    
    // Get chats and QA pairs
    final chats = ref.watch(chatProvider);
    final qaPairs = ref.watch(qaPairProvider);
    final selectedChatId = ref.watch(selectedChatIdProvider);
    final selectedQAPairId = ref.watch(selectedQAPairIdProvider);
    
    // Determine which screen to show
    Widget contentScreen;
    if (_showAllChats) {
      contentScreen = AllChatsScreen(
        chats: chats,
        selectedChatId: selectedChatId,
        onSelectChat: _selectChat,
        onDeleteChat: _deleteChat,
      );
    } else if (_showAllQAPairs) {
      contentScreen = AllQAPairsScreen(
        qaPairs: qaPairs,
        selectedQAPairId: selectedQAPairId,
        onSelectQAPair: _selectQAPair,
        onDeleteQAPair: _deleteQAPair,
      );
    } else {
      contentScreen = _screens[_selectedIndex];
    }
    
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          if (!isSmallScreen && _isSidebarExpanded)
            Container(
              width: 260,
              color: EddieTheme.getSurface(context),
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
                          color: EddieTheme.getTextPrimary(context),
                        ),
                        const Spacer(),
                        const ThemeToggle(),
                      ],
                    ),
                  ),
                  
                  // New Chat button
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
                  
                  // Navigation sections
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
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
                                  
                                  // Take only the 5 most recent chats
                                  final recentChats = sortedChats.take(5).toList();
                                  
                                  return recentChats.map((chat) {
                                    return InkWell(
                                      onTap: () => _selectChat(chat.id),
                                      borderRadius: BorderRadius.circular(4),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.chat_bubble_outline,
                                              size: 16,
                                              color: chat.id == selectedChatId && _selectedIndex == 0 && !_showAllQAPairs
                                                  ? EddieTheme.getPrimary(context)
                                                  : EddieTheme.getTextSecondary(context),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                chat.title,
                                                style: EddieTextStyles.body2(context).copyWith(
                                                  color: chat.id == selectedChatId && _selectedIndex == 0 && !_showAllQAPairs
                                                      ? EddieTheme.getPrimary(context)
                                                      : EddieTheme.getTextPrimary(context),
                                                  fontWeight: chat.id == selectedChatId && _selectedIndex == 0 && !_showAllQAPairs
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (chat.id == selectedChatId && _selectedIndex == 0 && !_showAllQAPairs)
                                              Icon(
                                                Icons.check,
                                                size: 16,
                                                color: EddieTheme.getPrimary(context),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList();
                                })(),
                              if (chats.length > 5)
                                TextButton(
                                  onPressed: _viewAllChats,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        l10n.viewAll,
                                        style: EddieTextStyles.caption(context).copyWith(
                                          color: EddieTheme.getPrimary(context),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        size: 14,
                                        color: EddieTheme.getPrimary(context),
                                      ),
                                    ],
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
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
                                      color: EddieTheme.getTextSecondary(context),
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
                                  // Take only the first 5 QA pairs
                                  final recentQAPairs = qaPairs.take(5).toList();
                                  
                                  return recentQAPairs.map((qaPair) {
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
                                              color: qaPair.id == selectedQAPairId && _selectedIndex == 1 && !_showAllChats
                                                  ? EddieTheme.getPrimary(context)
                                                  : EddieTheme.getTextSecondary(context),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                qaPair.question,
                                                style: EddieTextStyles.body2(context).copyWith(
                                                  color: qaPair.id == selectedQAPairId && _selectedIndex == 1 && !_showAllChats
                                                      ? EddieTheme.getPrimary(context)
                                                      : EddieTheme.getTextPrimary(context),
                                                  fontWeight: qaPair.id == selectedQAPairId && _selectedIndex == 1 && !_showAllChats
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (qaPair.id == selectedQAPairId && _selectedIndex == 1 && !_showAllChats)
                                              Icon(
                                                Icons.check,
                                                size: 16,
                                                color: EddieTheme.getPrimary(context),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList();
                                })(),
                              if (qaPairs.length > 5)
                                TextButton(
                                  onPressed: _viewAllQAPairs,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        l10n.viewAll,
                                        style: EddieTextStyles.caption(context).copyWith(
                                          color: EddieTheme.getPrimary(context),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        size: 14,
                                        color: EddieTheme.getPrimary(context),
                                      ),
                                    ],
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
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
                          color: EddieTheme.getColor(context, EddieColors.outlineLight, EddieColors.outlineDark),
                          width: 1,
                        ),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => setState(() {
                        _selectedIndex = 2;
                        _showAllChats = false;
                        _showAllQAPairs = false;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings_outlined,
                              size: 16,
                              color: _selectedIndex == 2
                                  ? EddieTheme.getPrimary(context)
                                  : EddieTheme.getTextSecondary(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.settingsTabLabel,
                              style: EddieTextStyles.body2(context).copyWith(
                                color: _selectedIndex == 2
                                    ? EddieTheme.getPrimary(context)
                                    : EddieTheme.getTextPrimary(context),
                                fontWeight: _selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
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
                  color: EddieTheme.getColor(context, EddieColors.outlineLight, EddieColors.outlineDark),
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
                    color: EddieTheme.getSurface(context),
                    border: Border(
                      bottom: BorderSide(
                        color: EddieTheme.getColor(context, EddieColors.outlineLight, EddieColors.outlineDark),
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
                          color: EddieTheme.getTextPrimary(context),
                        ),
                      if (!_isSidebarExpanded)
                        const SizedBox(width: 16),
                      const EddieLogo(size: 24, withText: true),
                      const SizedBox(width: 8),
                      if (_selectedIndex == 0 && selectedChatId != null)
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
                                  color: EddieTheme.getTextSecondary(context),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  chats.firstWhere((chat) => chat.id == selectedChatId, orElse: () => Chat(title: '')).title,
                                  style: EddieTextStyles.body1(context),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_showAllChats)
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
                                  color: EddieTheme.getTextSecondary(context),
                                ),
                              ),
                              Text(
                                l10n.viewAll,
                                style: EddieTextStyles.body1(context),
                              ),
                            ],
                          ),
                        )
                      else if (_selectedIndex == 1 && selectedQAPairId != null)
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
                                  color: EddieTheme.getTextSecondary(context),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  qaPairs.firstWhere((qa) => qa.id == selectedQAPairId, orElse: () => QAPair(question: '', answer: '')).question,
                                  style: EddieTextStyles.body1(context),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_showAllQAPairs)
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
                                  color: EddieTheme.getTextSecondary(context),
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
                            _showAllChats ? l10n.chatTabLabel :
                            _showAllQAPairs ? l10n.qaTabLabel :
                            _selectedIndex == 0 ? l10n.chatTabLabel :
                            _selectedIndex == 1 ? l10n.qaTabLabel : l10n.settingsTabLabel,
                            style: EddieTextStyles.body1(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (_isSidebarExpanded)
                        const ThemeToggle(),
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
              currentIndex: _selectedIndex,
              onTap: (index) {
                // Only allow navigation if API key is set or if navigating to Settings
                if (hasApiKey || index == 2) {
                  setState(() {
                    _selectedIndex = index;
                    _showAllChats = false;
                    _showAllQAPairs = false;
                  });
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

