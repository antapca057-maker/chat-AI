import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ChatProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        if (!chatProvider.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (chatProvider.currentChat == null && chatProvider.chats.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('NextChat'),
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Нет чатов',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Создайте новый чат, чтобы начать',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => _showNewChatDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Новый чат'),
                  ),
                ],
              ),
            ),
          );
        }

        if (chatProvider.currentChat != null) {
          return ChatScreen(chat: chatProvider.currentChat!);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('NextChat'),
            elevation: 0,
          ),
          body: ListView(
            children: [
              ...chatProvider.chats.map((chat) {
                return ListTile(
                  title: Text(chat.title),
                  subtitle: Text(
                    '${chat.messages.length} сообщений',
                  ),
                  onTap: () => chatProvider.selectChat(chat),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => chatProvider.deleteChat(chat),
                  ),
                );
              }),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showNewChatDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Новый чат'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Название чата',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context
                      .read<ChatProvider>()
                      .createNewChat(controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Создать'),
            ),
          ],
        );
      },
    );
  }
}
