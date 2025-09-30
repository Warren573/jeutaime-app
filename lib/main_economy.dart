import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/economy_test_screen.dart';

void main() {
  runApp(const JeuTaimeApp());
}

class JeuTaimeApp extends StatelessWidget {
  const JeuTaimeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime - Economy Test',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const EconomyTestScreen(),
    );
  }
}