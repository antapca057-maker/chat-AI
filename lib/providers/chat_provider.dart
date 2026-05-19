import 'package:flutter/material.dart';
import '../models/chat_model.dart'; // Проверь, что этот путь правильный

class ChatProvider with ChangeNotifier {
  final List<ChatModel> _chats = [];
  ChatModel? _currentChat;
  
  // Новая переменная для отслеживания инициализации (нужна для home_screen)
  bool _isInitialized = false;

  List<ChatModel> get chats => _chats;
  ChatModel? get currentChat => _currentChat;
  
  // Геттер статуса инициализации
  bool get isInitialized => _isInitialized;

  // 1. Метод инициализации (загрузка данных, если нужно)
  Future<void> initialize() async {
    // Если у тебя тут была загрузка чатов из БД/памяти — добавь её логику сюда.
    // Пока просто ставим статус true.
    _isInitialized = true;
    notifyListeners();
  }

  // 2. Метод выбора чата
  void selectChat(ChatModel chat) {
    _currentChat = chat;
    notifyListeners();
  }

  // 3. Метод создания нового чата
  void createNewChat(String title) {
    final newChat = ChatModel(
      title: title,
      messages: [],
    );
    _chats.add(newChat);
    _currentChat = newChat;
    notifyListeners();
  }

  // 4. Метод удаления чата (добавили, чтобы исправить ошибку на строке 91)
  void deleteChat(ChatModel chat) {
    _chats.remove(chat);
    if (_currentChat == chat) {
      _currentChat = null;
    }
    notifyListeners();
  }

  // 5. Метод добавления сообщения
  void addMessageToChat(ChatModel chat, Message message) {
    chat.messages.add(message);
    notifyListeners();
  }

  // 6. Метод очистки истории
  void clearHistory() {
    if (_currentChat != null) {
      _currentChat!.messages.clear();
      notifyListeners();
    }
  }
}
