import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes {
  // Couleurs modernes pour l'app de rencontre
  static const Color primaryPink = Color(0xFFFF1493); // Deep Pink
  static const Color secondaryPink = Color(0xFFFF69B4); // Hot Pink
  static const Color backgroundLight = Color(0xFFFFF0F5); // Lavender Blush
  static const Color backgroundDark = Color(0xFF1A1A2E); // Dark Navy
  static const Color surfaceDark = Color(0xFF16213E); // Darker Navy
  static const Color accentOrange = Color(0xFFFF6B35); // Vibrant Orange
  static const Color accentPurple = Color(0xFF9D4EDD); // Modern Purple

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    primaryColor: primaryPink,
    scaffoldBackgroundColor: backgroundLight,
    
    // Schéma de couleurs moderne
    colorScheme: ColorScheme.light(
      primary: primaryPink,
      secondary: accentOrange,
      tertiary: accentPurple,
      surface: Colors.white,
      background: backgroundLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF2D3748),
    ),
    
    // AppBar avec dégradé
    appBarTheme: AppBarTheme(
      backgroundColor: primaryPink,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    
    // Cartes modernes
    cardTheme: CardThemeData(
      elevation: 8,
      shadowColor: primaryPink.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Boutons stylés
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 5,
      ),
    ),
    
    // Bottom Navigation Bar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: primaryPink,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
    
    // Typographie
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF4A5568),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF718096),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    primaryColor: secondaryPink,
    scaffoldBackgroundColor: backgroundDark,
    
    // Schéma de couleurs sombre
    colorScheme: ColorScheme.dark(
      primary: secondaryPink,
      secondary: accentOrange,
      tertiary: accentPurple,
      surface: surfaceDark,
      background: backgroundDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    
    // AppBar sombre
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    
    // Cartes sombres
    cardTheme: CardThemeData(
      elevation: 8,
      color: surfaceDark,
      shadowColor: secondaryPink.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Boutons sombres
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryPink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 5,
      ),
    ),
    
    // Bottom Navigation Bar sombre
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: secondaryPink,
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
    
    // Typographie sombre
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xDEFFFFFF), // Colors.white87 équivalent
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xB3FFFFFF), // Colors.white70 équivalent
      ),
    ),
  );
  
  // Thème spécial pour les bars
  static ThemeData getBarTheme(Color barColor) {
    return lightTheme.copyWith(
      primaryColor: barColor,
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: barColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: barColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        ),
      ),
    );
  }
}
