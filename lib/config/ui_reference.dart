// IMPORTANT: Cette app doit reproduire EXACTEMENT https://jeutaime-warren.web.app/
// Style: dégradés chaleureux bois/romantique, navigation bottom avec 7 onglets
// Structure: même écrans, même UI, même fonctionnalités que la demo existante

import 'package:flutter/material.dart';

/**
 * Configuration UI basée sur https://jeutaime-warren.web.app/
 * À respecter ABSOLUMENT - ne pas inventer d'autres designs
 */
class UIReference {
  static const String url = 'https://jeutaime-warren.web.app/';
  static const String theme = 'warm-wooden'; // Style bois chaleureux comme dans la démo
  
  // Couleurs EXACTES du site de référence
  static const Map<String, Color> colors = {
    'primary': Color(0xFF8B7355),     // Brun bois principal
    'secondary': Color(0xFFA0956B),   // Brun moyen  
    'accent': Color(0xFFD2B48C),      // Beige chaleureux
    'background': Color(0xFFF5F5DC),  // Beige clair parchemin
    'cardBackground': Color(0xFFFFFFF8), // Blanc cassé pour les cartes
    'textPrimary': Color(0xFF654321),    // Texte principal brun foncé
    'textSecondary': Color(0xFF8B7355),  // Texte secondaire
  };
  
  // Navigation bottom avec ces onglets EXACTEMENT:
  // 🏠 Accueil | 👤 Profils | 🍸 Bars | 💌 Lettres |  Journal | ⚙️ Paramètres | 🛍️ Boutique (dans Paramètres)
  static const List<Map<String, String>> navigationTabs = [
    {'icon': '🏠', 'label': 'Accueil'},
    {'icon': '👤', 'label': 'Profils'},
    {'icon': '🍸', 'label': 'Bars'},
    {'icon': '💌', 'label': 'Lettres'},
    {'icon': '📖', 'label': 'Journal'},
    {'icon': '⚙️', 'label': 'Paramètres'}
  ];
  
  // 5 bars thématiques EXACTEMENT comme sur le site
  static const List<Map<String, dynamic>> bars = [
    {
      'id': 'romantic',
      'name': 'Bar Romantique',
      'emoji': '🌹',
      'description': 'Ambiance tamisée, conversations intimes',
      'color': Color(0xFFE91E63),
    },
    {
      'id': 'humor',
      'name': 'Bar Humoristique', 
      'emoji': '😄',
      'description': 'Défi du jour, rires garantis',
      'color': Color(0xFFFF9800),
    },
    {
      'id': 'pirates',
      'name': 'Bar Pirates',
      'emoji': '🏴‍☠️', 
      'description': 'Chasse au trésor en équipe',
      'color': Color(0xFF795548),
    },
    {
      'id': 'weekly',
      'name': 'Bar Hebdomadaire',
      'emoji': '📅',
      'description': 'Groupe de 4 (2H/2F) - Thème de la semaine',
      'color': Color(0xFF9C27B0),
    },
    {
      'id': 'hidden',
      'name': 'Bar Caché', 
      'emoji': '👑',
      'description': 'Accès par énigmes uniquement',
      'color': Color(0xFFFFD700),
    }
  ];
  
  // Styles de texte Georgia comme sur le site
  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFF654321),
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontFamily: 'Georgia', 
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF8B7355),
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 16,
    color: Color(0xFF654321),
  );
  
  // Getters pour un accès simplifié aux couleurs
  static Color get primaryColor => colors['primary']!;
  static Color get secondaryColor => colors['secondary']!;
  static Color get accentColor => colors['accent']!;
  static Color get backgroundColor => colors['background']!;
  static Color get cardBackground => colors['cardBackground']!;
  static Color get textPrimary => colors['textPrimary']!;
  static Color get textSecondary => colors['textSecondary']!;
  
  // Couleurs communes
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static Color get backgroundGradientStart => backgroundColor;
  static Color get backgroundGradientEnd => accentColor.withOpacity(0.3);
  
  // Couleurs système
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);
}