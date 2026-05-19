Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // 1. Отображаем сообщение пользователя на экране
    final userMessage = Message(
      text: text,
      isUser: true,
    );
    context.read<ChatProvider>().addMessage(userMessage);
    _messageController.clear();
    _scrollToBottom();

    // НАСТРОЙКИ OPENROUTER AUTO-ROUTER
    const String apiKey = "sk-or-v1-52f8a00f384ecb6c7243d97a41586796bd"; // <-- Вставь свой токен sk-or-v1-...
    const String apiUrl = "https://openrouter.ai/api/v1/chat/completions";
    const String autoModel = "openrouter/auto"; // Универсальный роутер бесплатных моделей

    try {
      // 2. Отправляем запрос на единый эндпоинт
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

      // 3. Обрабатываем ответ
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
