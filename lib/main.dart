import 'package:flutter/material.dart';
import 'package:frontend/components/components.dart';
import 'package:frontend/screens/screens.dart';
import 'package:provider/provider.dart';
import 'services/services.dart';

void main() {
  // Capturar errores no controlados
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppState());
}

class AppState extends StatefulWidget {
  const AppState({super.key});

  @override
  State<AppState> createState() => _AppStateState();
}

class _AppStateState extends State<AppState> {
  final authService = AuthService();
  final chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: chatService),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          color: Color.fromARGB(255, 21, 45, 86),
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'LaibChat',
      initialRoute: 'dashboard', // Cambiar a splash
      routes: {
        'splash': (_) => const SplashScreen(),
        'login': (_) => const LoginScreen(),
        'register': (_) => const RegisterScreen(),
        'dashboard': (_) => const Dashboard(),
      },
    );
  }
}
