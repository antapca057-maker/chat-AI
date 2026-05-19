void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Если у тебя тут есть инициализация Hive, оставь её
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterialDesign: true,
      ),
      home: const HomeScreen(), // Вот где должен быть HomeScreen
    );
  }
}
