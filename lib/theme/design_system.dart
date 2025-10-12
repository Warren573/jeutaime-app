import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design System complet pour JeuTaime
/// Système unifié avec couleurs, typographies, composants et espacements
class DesignSystem {
  // ============================================================================
  // COULEURS MODERNES
  // ============================================================================
  
  /// Couleurs principales - Palette moderne de dating app
  static const Color primaryPink = Color(0xFFFF6B9D);      // Rose principal vibrant
  static const Color primaryPurple = Color(0xFFC147E9);     // Violet secondaire
  static const Color primaryDark = Color(0xFF0F0F23);       // Bleu très sombre
  static const Color primaryNavy = Color(0xFF1A1A2E);       // Bleu marine sombre
  
  /// Couleurs de surface et backgrounds
  static const Color surfaceDark = Color(0xFF16213E);       // Surface sombre
  static const Color surfaceLight = Color(0xFF2A2A3E);      // Surface claire sombre
  static const Color backgroundDark = Color(0xFF0F0F23);    // Background principal
  static const Color backgroundLight = Color(0xFF1A1A2E);   // Background secondaire
  
  /// Couleurs d'accent et highlights
  static const Color goldAccent = Color(0xFFFFD700);        // Or pour pièces/XP
  static const Color orangeAccent = Color(0xFFFF6B35);      // Orange vibrant
  static const Color greenSuccess = Color(0xFF4CAF50);      // Vert succès
  static const Color redError = Color(0xFFFF5252);          // Rouge erreur
  static const Color blueInfo = Color(0xFF2196F3);          // Bleu information
  static const Color yellowWarning = Color(0xFFFF9800);     // Orange warning
  
  /// Couleurs de texte
  static const Color textPrimary = Color(0xFFFFFFFF);       // Blanc principal
  static const Color textSecondary = Color(0xB3FFFFFF);     // Blanc 70%
  static const Color textDisabled = Color(0x80FFFFFF);      // Blanc 50%
  static const Color textOnPrimary = Color(0xFFFFFFFF);     // Blanc sur couleurs
  
  // ============================================================================
  // DÉGRADÉS MODERNES
  // ============================================================================
  
  /// Dégradé principal de l'app
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPink, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Dégradé de background
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [primaryDark, primaryNavy],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  /// Dégradé pour cartes
  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceDark, surfaceLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Dégradé pour boutons d'action
  static const LinearGradient actionGradient = LinearGradient(
    colors: [orangeAccent, Color(0xFFFF8A50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Dégradé pour pièces/XP
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldAccent, Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Dégradé succès
  static const LinearGradient successGradient = LinearGradient(
    colors: [greenSuccess, Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ============================================================================
  // TYPOGRAPHIE MODERNE
  // ============================================================================
  
  /// Style de texte pour titres principaux
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  /// Style pour sous-titres
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  /// Style pour titres de sections
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.2,
    height: 1.4,
  );
  
  /// Style pour texte de body principal
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    letterSpacing: 0,
    height: 1.5,
  );
  
  /// Style pour texte de body secondaire
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  /// Style pour petit texte/captions
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textDisabled,
    letterSpacing: 0.2,
    height: 1.3,
  );
  
  /// Style pour labels/boutons
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textOnPrimary,
    letterSpacing: 0.5,
    height: 1.2,
  );
  
  /// Style pour labels moyens
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: 0.3,
    height: 1.3,
  );
  
  // ============================================================================
  // ESPACEMENTS ET DIMENSIONS
  // ============================================================================
  
  /// Espacements standardisés
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  
  /// Radius pour composants
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircle = 50.0;
  
  /// Elevations/shadows
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;
  
  // ============================================================================
  // THÈME MATERIAL COMPLET
  // ============================================================================
  
  /// Thème sombre principal de l'application
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    
    // Couleurs principales
    colorScheme: const ColorScheme.dark(
      primary: primaryPink,
      onPrimary: textOnPrimary,
      secondary: primaryPurple,
      onSecondary: textOnPrimary,
      tertiary: orangeAccent,
      onTertiary: textOnPrimary,
      surface: surfaceDark,
      onSurface: textPrimary,
      background: backgroundDark,
      onBackground: textPrimary,
      error: redError,
      onError: textOnPrimary,
      outline: Color(0xFF4A4A4A),
      outlineVariant: Color(0xFF2A2A2A),
    ),
    
    // Couleurs système
    scaffoldBackgroundColor: backgroundDark,
    canvasColor: surfaceDark,
    cardColor: surfaceDark,
    dividerColor: Color(0xFF2A2A2A),
    
    // AppBar moderne
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // Cartes modernes avec élévation
    cardTheme: CardTheme(
      color: surfaceDark,
      elevation: elevationMedium,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusL),
      ),
      margin: const EdgeInsets.all(spaceS),
    ),
    
    // Boutons élevés avec dégradé
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPink,
        foregroundColor: textOnPrimary,
        elevation: elevationMedium,
        shadowColor: primaryPink.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(
          horizontal: spaceL,
          vertical: spaceM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        textStyle: labelLarge,
      ),
    ),
    
    // Boutons texte
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryPink,
        padding: const EdgeInsets.symmetric(
          horizontal: spaceM,
          vertical: spaceS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        textStyle: labelMedium,
      ),
    ),
    
    // Boutons outline
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryPink,
        side: const BorderSide(color: primaryPink, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: spaceL,
          vertical: spaceM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        textStyle: labelLarge,
      ),
    ),
    
    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryPink,
      foregroundColor: textOnPrimary,
      elevation: elevationHigh,
      shape: CircleBorder(),
    ),
    
    // Champs de saisie modernes
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(
          color: primaryPink,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(
          color: redError,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spaceM,
        vertical: spaceM,
      ),
      hintStyle: TextStyle(
        color: textDisabled,
        fontSize: 14,
      ),
      labelStyle: TextStyle(
        color: textSecondary,
        fontSize: 14,
      ),
    ),
    
    // Bottom Navigation moderne
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryPink,
      unselectedItemColor: textDisabled,
      type: BottomNavigationBarType.fixed,
      elevation: elevationHigh,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // Typographie globale
    textTheme: const TextTheme(
      headlineLarge: headingLarge,
      headlineMedium: headingMedium,
      headlineSmall: headingSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
    ),
    
    // Divider theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2A2A),
      thickness: 1,
      space: 1,
    ),
    
    // ListTile theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: spaceM,
        vertical: spaceS,
      ),
      textColor: textPrimary,
      iconColor: textSecondary,
    ),
    
    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryPink,
      linearTrackColor: Color(0xFF2A2A2A),
      circularTrackColor: Color(0xFF2A2A2A),
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: surfaceLight,
      selectedColor: primaryPink.withOpacity(0.2),
      disabledColor: Color(0xFF2A2A2A),
      labelStyle: bodyMedium,
      secondaryLabelStyle: bodyMedium.copyWith(color: textOnPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXL),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: spaceM,
        vertical: spaceS,
      ),
    ),
  );
  
  // ============================================================================
  // WIDGETS ET COMPOSANTS
  // ============================================================================
  
  /// Container avec dégradé principal
  static Widget gradientContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    Gradient? gradient,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? primaryGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(radiusL),
      ),
      child: child,
    );
  }
  
  /// Card moderne avec effet glassmorphism
  static Widget glassCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    double? elevation,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(spaceM),
      decoration: BoxDecoration(
        color: surfaceDark.withOpacity(0.8),
        borderRadius: borderRadius ?? BorderRadius.circular(radiusL),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: elevation ?? elevationMedium,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
  
  /// Badge de notification moderne
  static Widget notificationBadge({
    required String count,
    double? size,
  }) {
    return Container(
      width: size ?? 20,
      height: size ?? 20,
      decoration: const BoxDecoration(
        gradient: primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count,
          style: bodySmall.copyWith(
            color: textOnPrimary,
            fontWeight: FontWeight.w600,
            fontSize: size != null ? size * 0.5 : 10,
          ),
        ),
      ),
    );
  }
  
  /// Bouton avec dégradé personnalisé
  static Widget gradientButton({
    required String text,
    required VoidCallback onPressed,
    Gradient? gradient,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? primaryGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(radiusL),
        boxShadow: [
          BoxShadow(
            color: (gradient?.colors.first ?? primaryPink).withOpacity(0.4),
            blurRadius: elevationMedium,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(radiusL),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(
              horizontal: spaceL,
              vertical: spaceM,
            ),
            child: Center(
              child: Text(
                text,
                style: textStyle ?? labelLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}