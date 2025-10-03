import 'package:flutter/material.dart';
import 'package:rampart/screens/login_screen.dart';
import 'package:rampart/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RAMPART',
      theme: AppTheme.darkTheme,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        // '/splash': (_) => const SplashPage(),
        // '/login': (_) => const LoginPage(),
        // '/register': (_) => const RegisterPage(),
        // '/main': (_) => const MainPage(),
        // '/home': (_) => const MainPage(),
        // '/admin': (_) => const AdminPage(),
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
