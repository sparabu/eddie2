import 'package:flutter_riverpod/flutter_riverpod.dart';

// Current screen index (0 = Chat, 1 = QA, 2 = Settings)
final selectedScreenIndexProvider = StateProvider<int>((ref) => 0);

// Flag to show a project
final showProjectProvider = StateProvider<bool>((ref) => false);

// Flag to show all chats
final showAllChatsProvider = StateProvider<bool>((ref) => false);

// Flag to show all QA pairs
final showAllQAPairsProvider = StateProvider<bool>((ref) => false); 