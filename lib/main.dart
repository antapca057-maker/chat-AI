import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/chat_model.dart';
import 'providers/chat_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(ChatModelAdapter());
  Hive.registerAdapter(MessageAdapter());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'NextChat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          // Полная ручная настройка цветов палитры
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF10B981),       // Мягкий зеленый акцент для кнопок
            surface: Color(0xFF161616),       // Цвет карточек и полей ввода
            background: Color(0xFF111111),    // Тот самый глубокий темный фон чата
            onPrimary: Colors.white,
            onSurface: Colors.white,
            onBackground: Color(0xFFE5E7EB),  // Светло-серый цвет текста сообщений
          ),
          // Дополнительно красим фон самого приложения и карточек
          scaffoldBackgroundColor: const Color(0xFF111111),
          cardColor: const Color(0xFF161616),
        ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
