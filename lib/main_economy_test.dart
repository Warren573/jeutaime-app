import 'package:flutter/material.dart';
import 'screens/economy_test_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const EconomyTestApp());
}

class EconomyTestApp extends StatelessWidget {
  const EconomyTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime - Test Économie',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const EconomyTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}