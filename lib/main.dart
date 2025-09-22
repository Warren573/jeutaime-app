import 'package:flutter/material.dart';
import 'theme/app_themes.dart';
import 'routes/app_routes.dart';

/// Application principale JeuTaime
/// Gère les thèmes, la navigation et la configuration globale
void main() {
  runApp(JeuTaimeApp());
}

class JeuTaimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime - Rencontres Authentiques',
      debugShowCheckedModeBanner: false,
      
      // Configuration des thèmes
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      
      // Configuration de la navigation
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.generateRoute,
      
      // Configuration de localisation (français par défaut)
      locale: Locale('fr', 'FR'),
      supportedLocales: [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
    );
  }
}
