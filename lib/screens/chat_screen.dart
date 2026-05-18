import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.title),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Очистить историю'),
                onTap: () => _clearHistory(),
              ),
              PopupMenuItem(
                child: const Text('Назад'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                return widget.chat.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.message_outlined,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Начните беседу',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: widget.chat.messages.length,
                        itemBuilder: (context, index) {
                          final message = widget.chat.messages[index];
                          return MessageBubble(message: message);
                        },
                      );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _pickImage,
          ),
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _toggleSpeech,
            color: _isListening ? Colors.red : null,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Сообщение...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                isDense: true,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      final message = Message(
        text: '[Изображение]',
        isUser: true,
        imagePath: image.path,
      );
      context.read<ChatProvider>().addMessage(message);
      _scrollToBottom();
    }
  }

  Future<void> _toggleSpeech() async {
    if (!_isListening) {
      final available = await _speechToText.initialize(
        onError: (error) => print('Ошибка: $error'),
        onStatus: (status) => print('Статус: $status'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _messageController.text = result.recognizedWords;
            });
          },
          localeId: 'ru_RU',
        );
      }
    } else {
      _speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final message = Message(
      text: _messageController.text,
      isUser: true,
    );

    context.read<ChatProvider>().addMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить историю'),
        content: const Text('Вы уверены? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ChatProvider>().clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
