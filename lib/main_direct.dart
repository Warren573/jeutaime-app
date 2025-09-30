import 'package:flutter/material.dart';
import 'theme/app_themes.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const JeuTaimeApp());
}

class JeuTaimeApp extends StatelessWidget {
  const JeuTaimeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime',
      theme: AppThemes.lightTheme,
      home: const HomeScreen(),
    );
  }
}