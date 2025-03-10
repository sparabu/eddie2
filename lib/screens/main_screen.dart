import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';
import 'chat_screen.dart';
import 'qa_screen.dart';
import 'settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;
  
  final List<Widget> _screens = [
    const ChatScreen(),
    const QAScreen(),
    const SettingsScreen(),
  ];
  
  final List<String> _titles = [
    'Chat',
    'Q&A Pairs',
    'Settings',
  ];
  
  final List<IconData> _icons = [
    Icons.chat_bubble_outline,
    Icons.question_answer_outlined,
    Icons.settings_outlined,
  ];
  
  @override
  void initState() {
    super.initState();
    // We'll check for API key in didChangeDependencies
  }
  
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
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;
    final hasApiKey = ref.watch(settingsProvider).hasApiKey;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          if (!isSmallScreen)
            NavigationRail(
              extended: _isSidebarExpanded,
              minExtendedWidth: 200,
              backgroundColor: isDarkMode 
                  ? AppTheme.darkSidebarColor 
                  : AppTheme.sidebarColor,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                // Only allow navigation if API key is set or if navigating to Settings
                if (hasApiKey || index == 2) {
                  setState(() {
                    _selectedIndex = index;
                  });
                } else {
                  // Show a message that API key is required
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please add your OpenAI API key in Settings first'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              leading: IconButton(
                icon: Icon(
                  _isSidebarExpanded 
                      ? Icons.menu_open 
                      : Icons.menu,
                ),
                onPressed: _toggleSidebar,
              ),
              destinations: List.generate(
                _titles.length,
                (index) => NavigationRailDestination(
                  icon: Icon(
                    _icons[index],
                    // Gray out icons for disabled sections
                    color: (!hasApiKey && index != 2) 
                        ? Colors.grey.shade400 
                        : null,
                  ),
                  label: Text(
                    _titles[index],
                    // Gray out text for disabled sections
                    style: (!hasApiKey && index != 2)
                        ? TextStyle(color: Colors.grey.shade400)
                        : null,
                  ),
                ),
              ),
            ),
          
          // Main content
          Expanded(
            child: _screens[_selectedIndex],
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
                  });
                } else {
                  // Show a message that API key is required
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please add your OpenAI API key in Settings first'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              items: List.generate(
                _titles.length,
                (index) => BottomNavigationBarItem(
                  icon: Icon(
                    _icons[index],
                    // Gray out icons for disabled sections
                    color: (!hasApiKey && index != 2) 
                        ? Colors.grey.shade400 
                        : null,
                  ),
                  label: _titles[index],
                ),
              ),
            )
          : null,
    );
  }
} 