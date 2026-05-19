Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userMessage = Message(
      text: text,
      isUser: true,
    );
    context.read<ChatProvider>().addMessage(userMessage);
    _messageController.clear();
    _scrollToBottom();

    const String apiKey = String.fromEnvironment('OPENROUTER_KEY');
    const String apiUrl = "https://openrouter.ai/api/v1/chat/completions";
    const String autoModel = "openrouter/auto";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json; charset=UTF-8',
          'HTTP-Referer': 'https://github.com/antapca057-maker/chat-AI',
        },
        body: jsonEncode({
          'model': autoModel,
          'messages': [
            {'role': 'user', 'content': text}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final botText = data['choices'][0]['message']['content'].toString().trim();

        final botMessage = Message(
          text: botText,
          isUser: false,
        );
        
        if (mounted) {
          context.read<ChatProvider>().addMessage(botMessage);
          _scrollToBottom();
        }
      } else {
        _showError('Ошибка роутера: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      _showError('Ошибка сети: $e');
    }
  }

  void _showError(String errorText) {
    if (!mounted) return;
    context.read<ChatProvider>().addMessage(Message(
      text: "❌ $errorText",
      isUser: false,
    ));
    _scrollToBottom();
  }
