void _renameChat(String chatId, String newTitle) async {
  await ref.read(chatProvider.notifier).updateChatTitle(chatId, newTitle);
}

