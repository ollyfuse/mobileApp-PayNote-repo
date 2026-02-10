import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/app_initializer.dart';

void main() {
  runApp(const ProviderScope(child: PayNoteApp()));
}

class PayNoteApp extends StatelessWidget {
  const PayNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayNote',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0B), // Deep charcoal
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF88), // Liquid green
          secondary: Color(0xFF00FF88),
          surface: Color(0xFF1A1A1C),
          background: Color(0xFF0A0A0B),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'SF Pro Display',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF88),
            foregroundColor: Colors.black,
            elevation: 0,
            shadowColor: const Color(0xFF00FF88).withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1A1A1C).withOpacity(0.8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w700,
            fontFamily: 'SF Pro Display',
          ),
          headlineLarge: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w600,
            fontFamily: 'SF Pro Display',
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'SF Pro Text',
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 14,
            fontFamily: 'SF Pro Text',
          ),
        ),
      ),
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}
