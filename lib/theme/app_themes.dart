import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gestionnaire de thèmes pour l'application JeuTaime
/// Supporte les modes fun et sérieux avec intégration des couleurs thématiques
class AppThemes {
  /// Thème clair (mode fun) avec couleurs chaleureuses et police ludique
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.funPrimary,
    scaffoldBackgroundColor: AppColors.funBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.funPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.funPrimary,
      secondary: AppColors.funSecondary,
      surface: AppColors.funCardBackground,
      background: AppColors.funBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.funText,
      onBackground: AppColors.funText,
    ),
    cardTheme: CardTheme(
      color: AppColors.funCardBackground,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.funPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 8,
      ),
    ),
    fontFamily: 'ComicSans',
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: AppColors.funText, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.funText, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: AppColors.funText),
      bodyMedium: TextStyle(color: AppColors.funText),
    ),
  );

  /// Thème sombre (mode sérieux) avec couleurs bois/bar et police élégante
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.seriousPrimary,
    scaffoldBackgroundColor: AppColors.seriousBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.seriousPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.seriousPrimary,
      secondary: AppColors.seriousAccent,
      surface: AppColors.seriousCardBackground,
      background: AppColors.seriousBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.seriousText,
      onBackground: AppColors.seriousText,
    ),
    cardTheme: CardTheme(
      color: AppColors.seriousCardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.seriousAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4,
      ),
    ),
    fontFamily: 'Georgia',
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: AppColors.seriousText, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.seriousText, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: AppColors.seriousText),
      bodyMedium: TextStyle(color: AppColors.seriousText),
    ),
  );

  /// Obtient les couleurs des bars thématiques
  static Map<String, Color> get barColors => {
    'romantic': AppColors.romanticBar,
    'humor': AppColors.humorBar,
    'weekly': AppColors.weeklyBar,
    'mystery': AppColors.mysteryBar,
    'random': AppColors.randomBar,
  };

  /// Obtient les couleurs système
  static Map<String, Color> get systemColors => {
    'success': AppColors.success,
    'warning': AppColors.warning,
    'error': AppColors.error,
    'info': AppColors.info,
  };
}
