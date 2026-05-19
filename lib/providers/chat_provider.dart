import 'package:flutter/material.dart';
import '../models/chat_model.dart'; // Убедись, что путь к твоей модели ChatModel правильный

class ChatProvider with ChangeNotifier {
  // Список чатов (если у тебя локальное хранилище, адаптируй под себя)
  final List<ChatModel> _chats = [];
  ChatModel? _currentChat;

  List<ChatModel> get chats => _chats;
  ChatModel? get currentChat => _currentChat;

  // 1. Метод выбора чата (нужен для home_screen)
  void selectChat(ChatModel chat) {
    _currentChat = chat;
    notifyListeners();
  }

  // 2. Метод создания нового чата (нужен для home_screen)
  void createNewChat(String title) {
    final newChat = ChatModel(
      title: title,
      messages: [],
    );
    _chats.add(newChat);
    _currentChat = newChat;
    notifyListeners();
  }

  // 3. Метод добавления сообщения (нужен для chat_screen)
  void addMessageToChat(ChatModel chat, Message message) {
    chat.messages.add(message);
    notifyListeners();
  }

  // 4. Метод очистки истории (нужен для chat_screen)
  void clearHistory() {
    if (_currentChat != null) {
      _currentChat!.messages.clear();
      notifyListeners();
    }
  }
}
