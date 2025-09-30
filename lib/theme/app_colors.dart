import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales (basées sur l'app web existante)
  static const Color primaryBrown = Color(0xFF8B4513); // Brun principal
  static const Color lightBrown = Color(0xFFA0522D);   // Brun clair
  static const Color beige = Color(0xFFF5F5DC);        // Beige
  static const Color goldAccent = Color(0xFFFFD700);   // Or pour les pièces
  static const Color textDark = Color(0xFF2C3E50);     // Texte sombre
  static const Color cardBackground = Color(0xE6F5F5DC); // Beige avec transparence
  
  // Dégradé de fond principal (identique au web)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF8B7355), Color(0xFFA0956B), Color(0xFFD2B48C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dégradé navigation (identique au web)
  static const LinearGradient navGradient = LinearGradient(
    colors: [Color(0xFF8B4513), Color(0xFFA0522D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dégradé header (identique au web)
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xE68B4513), Color(0xE6A0522D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dégradé pièces (identique au web)
  static const LinearGradient coinsGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Couleurs des bars (identiques au web)
  static const Color romanticBar = Color(0xFFE91E63);    // Rose romantique
  static const Color humorousBar = Color(0xFFFF9800);    // Orange humoristique
  static const Color pirateBar = Color(0xFF8B4513);      // Brun pirate
  static const Color weeklyBar = Color(0xFF4169E1);      // Bleu hebdo (Mes Lettres)
  static const Color mysteryBar = Color(0xFF9400D3);     // Violet mystère
  
  // Dégradés des bars pour les effets hover
  static const LinearGradient romanticGradient = LinearGradient(
    colors: [Color(0xFFFF69B4), Color(0xFFFFB6C1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient humorousGradient = LinearGradient(
    colors: [Color(0xFFFFA500), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient pirateGradient = LinearGradient(
    colors: [Color(0xFF8B4513), Color(0xFFD2691E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient weeklyGradient = LinearGradient(
    colors: [Color(0xFF4169E1), Color(0xFF87CEEB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Couleurs système
  static const Color success = Color(0xFF00C851);
  static const Color warning = Color(0xFFFF8800);
  static const Color error = Color(0xFFFF4444);
  static const Color info = Color(0xFF33B5E5);
  
  // Compatibilité avec l'ancien code (transition)
  static const Color primary = primaryBrown;
  static const Color funPrimary = primaryBrown;
  static const Color seriousPrimary = primaryBrown;
  static const Color funBackground = Color(0xFFF5F5DC);
  static const Color seriousBackground = Color(0xFFF5F5DC);
  
  // Couleurs des bars alternatives pour compatibilité
  static const Color humorBar = humorousBar;
  static const Color randomBar = mysteryBar;
  
  // Couleurs texte et accents
  static const Color funText = textDark;
  static const Color seriousText = textDark;
  static const Color funSecondary = lightBrown;
  static const Color funAccent = goldAccent;
  static const Color seriousAccent = primaryBrown;
  
  // Couleurs texte principales
  static const Color textPrimary = textDark;
  static const Color textSecondary = Color(0xFF7F8C8D);
  
  // Couleurs secondaires
  static const Color secondary = lightBrown;
  
  // Couleur de fond générique
  static const Color background = beige;
  
  // Couleurs de cartes
  static const Color funCardBackground = cardBackground;
  static const Color seriousCardBackground = cardBackground;
}
