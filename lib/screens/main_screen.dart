import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/chat.dart';
import '../models/qa_pair.dart';
import '../providers/chat_provider.dart';
import '../providers/qa_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';
import '../widgets/app_logo.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final newChat = await ref.read(chatProvider.notifier).createChat(title: l10n.newChatButton);
    ref.read(selectedChatIdProvider.notifier).state = newChat.id;
    
    // Switch to chat screen if not already there
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
        _showAllChats = false;
        _showAllQAPairs = false;
      });
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
              color: isDarkMode ? AppTheme.darkSidebarColor : AppTheme.sidebarColor,
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
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  
                  // New Chat button
                  NewChatButton(onPressed: _createNewChat),
                  
                  // Navigation sections
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // Chat section
                        SidebarSection(
                          title: l10n.chatTabLabel,
                          children: chats.isEmpty
                              ? [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Text(
                                      l10n.noChatsYet,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ]
                              : [
                                  ...(() {
                                    // Sort chats by updatedAt (most recent first)
                                    final sortedChats = List<Chat>.from(chats)
                                      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                                    
                                    // Take only the 5 most recent chats
                                    final recentChats = sortedChats.take(5).toList();
                                    
                                    return recentChats.map((chat) {
                                      return ChatListItem(
                                        chat: chat,
                                        isSelected: chat.id == selectedChatId && _selectedIndex == 0 && !_showAllQAPairs,
                                        onTap: () => _selectChat(chat.id),
                                        onDelete: () => _deleteChat(chat.id),
                                      );
                                    }).toList();
                                  })(),
                                  if (chats.length > 5)
                                    ViewAllLink(
                                      onTap: _viewAllChats,
                                      text: l10n.viewAll,
                                    ),
                                ],
                        ),
                        
                        // Q&A section
                        SidebarSection(
                          title: l10n.qaTabLabel,
                          onAddPressed: _createNewQAPair,
                          children: qaPairs.isEmpty
                              ? [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Text(
                                      l10n.noQAPairsYet,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ]
                              : [
                                  ...(() {
                                    // Take only the first 5 QA pairs
                                    final recentQAPairs = qaPairs.take(5).toList();
                                    
                                    return recentQAPairs.map((qaPair) {
                                      return QAListItem(
                                        qaPair: qaPair,
                                        isSelected: qaPair.id == selectedQAPairId && _selectedIndex == 1 && !_showAllChats,
                                        onTap: () => _selectQAPair(qaPair),
                                        onDelete: () => _deleteQAPair(qaPair.id),
                                      );
                                    }).toList();
                                  })(),
                                  if (qaPairs.length > 5)
                                    ViewAllLink(
                                      onTap: _viewAllQAPairs,
                                      text: l10n.viewAll,
                                    ),
                                ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Settings at the bottom
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SidebarItem(
                        title: l10n.settingsTabLabel,
                        icon: Icons.settings_outlined,
                        isSelected: _selectedIndex == 2,
                        onTap: () => setState(() {
                          _selectedIndex = 2;
                          _showAllChats = false;
                          _showAllQAPairs = false;
                        }),
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
                  color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
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
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
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
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      if (!_isSidebarExpanded)
                        const SizedBox(width: 16),
                      const AppLogo(size: 24),
                      const SizedBox(width: 8),
                      Text(
                        _showAllChats ? l10n.chatTabLabel :
                        _showAllQAPairs ? l10n.qaTabLabel :
                        _selectedIndex == 0 ? l10n.chatTabLabel :
                        _selectedIndex == 1 ? l10n.qaTabLabel : l10n.settingsTabLabel,
                        style: Theme.of(context).appBarTheme.titleTextStyle,
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