import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFFFF6B6B);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Mode Fun
  static const Color funPrimary = Color(0xFFFF6B6B);
  static const Color funSecondary = Color(0xFF4ECDC4);
  static const Color funAccent = Color(0xFFFFE66D);
  static const Color funBackground = Color(0xFFFFF5E6);
  static const Color funText = Color(0xFF2D3436);
  static const Color funCardBackground = Color(0xFFFFFFFF);
  
  // Mode Sérieux
  static const Color seriousPrimary = Color(0xFF2D3436);
  static const Color seriousSecondary = Color(0xFF636E72);
  static const Color seriousAccent = Color(0xFFDDA15E);
  static const Color seriousBackground = Color(0xFFF8F9FA);
  static const Color seriousText = Color(0xFF2D3436);
  static const Color seriousCardBackground = Color(0xFFFFFFFF);
  
  // Couleurs des bars
  static const Color romanticBar = Color(0xFFE91E63);
  static const Color humorBar = Color(0xFFFF9800);
  static const Color weeklyBar = Color(0xFF9C27B0);
  static const Color mysteryBar = Color(0xFF3F51B5);
  static const Color randomBar = Color(0xFF009688);
  
  // Couleurs système
  static const Color success = Color(0xFF00C851);
  static const Color warning = Color(0xFFFF8800);
  static const Color error = Color(0xFFFF4444);
  static const Color info = Color(0xFF33B5E5);
}
