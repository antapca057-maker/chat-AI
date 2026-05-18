import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  late Box<ChatModel> _chatBox;
  ChatModel? _currentChat;
  List<ChatModel> _chats = [];

  List<ChatModel> get chats => _chats;
  ChatModel? get currentChat => _currentChat;
  bool get isInitialized => _chatBox.isOpen;

  Future<void> initialize() async {
    _chatBox = await Hive.openBox<ChatModel>('chats');
    _chats = _chatBox.values.toList();
    notifyListeners();
  }

  Future<void> createNewChat(String title) async {
    final chat = ChatModel(
      title: title,
      messages: [],
    );
    await _chatBox.add(chat);
    _chats = _chatBox.values.toList();
    _currentChat = chat;
    notifyListeners();
  }

  void selectChat(ChatModel chat) {
    _currentChat = chat;
    notifyListeners();
  }

  Future<void> addMessage(Message message) async {
    if (_currentChat == null) return;
    
    _currentChat!.messages.add(message);
    _currentChat!.updatedAt = DateTime.now();
    
    await _chatBox.putAt(
      _chats.indexOf(_currentChat!),
      _currentChat!,
    );
    
    _chats = _chatBox.values.toList();
    notifyListeners();
  }

  Future<void> deleteChat(ChatModel chat) async {
    final index = _chats.indexOf(chat);
    if (index != -1) {
      await _chatBox.deleteAt(index);
      _chats = _chatBox.values.toList();
      if (_currentChat == chat) {
        _currentChat = _chats.isNotEmpty ? _chats.first : null;
      }
      notifyListeners();
    }
  }

  Future<void> updateChatTitle(ChatModel chat, String newTitle) async {
    chat.title = newTitle;
    final index = _chats.indexOf(chat);
    if (index != -1) {
      await _chatBox.putAt(index, chat);
      _chats = _chatBox.values.toList();
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    if (_currentChat == null) return;
    
    _currentChat!.messages.clear();
    _currentChat!.updatedAt = DateTime.now();
    
    await _chatBox.putAt(
      _chats.indexOf(_currentChat!),
      _currentChat!,
    );
    
    notifyListeners();
  }
}
