import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Optimiseur de performance pour JeuTaime
class PerformanceOptimizer {
  
  /// Optimise les animations pour des transitions plus fluides
  static AnimationController createOptimizedController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }
  
  /// Animation de page avec courbe optimisée
  static Widget buildPageTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.fastEaseInToSlowEaseOut,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
  
  /// Feedback haptique optimisé
  static void hapticFeedback(HapticFeedbackType type) {
    HapticFeedback.lightImpact();
  }
  
  /// Animation de bounce pour les boutons
  static Widget buildBouncyButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween<double>(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: (_) {
              // Animation de pression
            },
            onTapUp: (_) {
              onPressed();
              hapticFeedback(HapticFeedbackType.lightImpact);
            },
            onTapCancel: () {
              // Animation de relâchement
            },
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Préchargement des images pour éviter les délais
  static Future<void> precacheImages(BuildContext context, List<String> imagePaths) async {
    for (String path in imagePaths) {
      await precacheImage(AssetImage(path), context);
    }
  }
  
  /// Optimisation du rendu des listes
  static Widget buildOptimizedListView({
    required List<Widget> children,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return ListView.builder(
      itemCount: children.length,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const ClampingScrollPhysics(),
      cacheExtent: 100, // Précharge 100px en plus
      itemBuilder: (context, index) => children[index],
    );
  }
  
  /// Animation de chargement fluide
  static Widget buildLoadingAnimation({Color color = Colors.pink}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return CircularProgressIndicator(
          value: value,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: 3,
        );
      },
    );
  }
}

/// Extension pour les animations fluides
extension SmoothAnimations on AnimationController {
  /// Animation avec courbe personnalisée fluide
  Animation<double> get smoothCurve => CurvedAnimation(
    parent: this,
    curve: Curves.fastEaseInToSlowEaseOut,
  );
  
  /// Animation de rebond
  Animation<double> get bounceCurve => CurvedAnimation(
    parent: this,
    curve: Curves.elasticOut,
  );
}

/// Constantes pour la performance
class PerformanceConstants {
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 250);
  static const Duration slowAnimation = Duration(milliseconds: 400);
  
  static const Curve defaultCurve = Curves.fastEaseInToSlowEaseOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeOutCubic;
}