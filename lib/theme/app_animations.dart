import 'package:flutter/material.dart';

class AppAnimations {
  // Durées d'animation
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // Courbes d'animation
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  
  // Animation de fondu entrant
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    double beginOpacity = 0.0,
    double endOpacity = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginOpacity, end: endOpacity),
      duration: duration,
      curve: easeInOut,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: child,
    );
  }
  
  // Animation de glissement depuis le bas
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = normal,
    double beginOffset = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginOffset, end: 0.0),
      duration: duration,
      curve: fastOutSlowIn,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(0, offset * 100),
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Animation de mise à l'échelle
  static Widget scaleIn({
    required Widget child,
    Duration duration = normal,
    double beginScale = 0.8,
    double endScale = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginScale, end: endScale),
      duration: duration,
      curve: elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }
  
  // Animation de rebond pour les boutons
  static Widget bouncyButton({
    required Widget child,
    required VoidCallback onTap,
    Duration duration = fast,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: duration,
      builder: (context, scale, child) {
        return GestureDetector(
          onTapDown: (_) => scale = 0.95,
          onTapUp: (_) => scale = 1.0,
          onTap: onTap,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  // Animation de pulsation pour les notifications
  static Widget pulse({
    required Widget child,
    Duration duration = slow,
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: minScale, end: maxScale),
      duration: duration,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      onEnd: () {
        // Répéter l'animation en sens inverse
      },
      child: child,
    );
  }
  
  // Transition personnalisée pour la navigation
  static PageRouteBuilder<T> createRoute<T extends Object?>({
    required Widget page,
    Duration duration = normal,
    RouteTransitionsBuilder? transitionsBuilder,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => page,
      transitionDuration: duration,
      transitionsBuilder: transitionsBuilder ??
          (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
    );
  }
  
  // Animation de particules pour les effets spéciaux
  static Widget sparkleEffect({
    required Widget child,
    bool isActive = false,
    Color particleColor = Colors.amber,
  }) {
    return Stack(
      children: [
        child,
        if (isActive)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: SparklesPainter(
                  color: particleColor,
                  animation: AlwaysStoppedAnimation(1.0),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  // Animation de chargement personnalisée
  static Widget loadingSpinner({
    Color color = Colors.pink,
    double size = 50.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: 3.0,
      ),
    );
  }
  
  // Animation de coeur battant
  static Widget beatingHeart({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.2),
      duration: duration,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      onEnd: () {
        // Animation en boucle
      },
      child: child,
    );
  }
}

// Custom painter pour l'effet de particules
class SparklesPainter extends CustomPainter {
  final Color color;
  final Animation<double> animation;
  
  SparklesPainter({
    required this.color,
    required this.animation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    // Dessiner des étoiles/particules scintillantes
    for (int i = 0; i < 10; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 43) % size.height;
      
      canvas.drawCircle(
        Offset(x, y),
        2 + (animation.value * 3),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(SparklesPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value;
  }
}