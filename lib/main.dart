import 'package:flutter/material.dart';
import 'package:electra_app/core/theme/app_theme.dart';
import 'package:electra_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:electra_app/features/auth/presentation/screens/login_screen.dart';
import 'package:electra_app/features/auth/presentation/screens/register_screen.dart';
import 'package:electra_app/features/main_navigation_shell.dart';

void main() {
  runApp(const ElectraTechApp());
}

class ElectraTechApp extends StatelessWidget {
  const ElectraTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElectraTech Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainNavigationShell(),
      },
    );
  }
}
