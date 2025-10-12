import 'package:flutter/material.dart';
import '../utils/performance_optimizer.dart';

/// Composants UI optimisés pour JeuTaime
class OptimizedWidgets {
  
  /// Bouton avec animation et feedback améliorés
  static Widget smoothButton({
    required String text,
    required VoidCallback onPressed,
    required Gradient gradient,
    IconData? icon,
    double borderRadius = 15,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  }) {
    return PerformanceOptimizer.buildBouncyButton(
      onPressed: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Card avec animations d'apparition fluides
  static Widget animatedCard({
    required Widget child,
    required int index,
    EdgeInsets margin = const EdgeInsets.all(10),
    double borderRadius = 15,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 50)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: PerformanceConstants.defaultCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: const Color(0xFF1e1e1e),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
  
  /// Shimmer loading effect
  static Widget buildShimmerLoading({
    required double width,
    required double height,
    double borderRadius = 10,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween<double>(begin: -1.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + value, 0.0),
              end: Alignment(1.0 + value, 0.0),
              colors: const [
                Color(0xFF2a2a2a),
                Color(0xFF404040),
                Color(0xFF2a2a2a),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Navigation avec transition fluide
  static void navigateWithTransition({
    required BuildContext context,
    required Widget destination,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionDuration: PerformanceConstants.normalAnimation,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return PerformanceOptimizer.buildPageTransition(
            child: child,
            animation: animation,
          );
        },
      ),
    );
  }
  
  /// Loading overlay avec animation
  static Widget buildLoadingOverlay({String text = 'Chargement...'}) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PerformanceOptimizer.buildLoadingAnimation(),
            const SizedBox(height: 20),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Bouton avec état de chargement
  static Widget buildAsyncButton({
    required String text,
    required Future<void> Function() onPressed,
    required Gradient gradient,
    IconData? icon,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isLoading = false;
        
        return smoothButton(
          text: isLoading ? 'Chargement...' : text,
          gradient: gradient,
          icon: isLoading ? null : icon,
          onPressed: isLoading ? () {} : () async {
            setState(() => isLoading = true);
            try {
              await onPressed();
            } finally {
              setState(() => isLoading = false);
            }
          },
        );
      },
    );
  }
  
  /// Coin counter avec animation
  static Widget buildAnimatedCoinCounter({
    required int coins,
    required int previousCoins,
  }) {
    return TweenAnimationBuilder<int>(
      duration: PerformanceConstants.normalAnimation,
      tween: IntTween(begin: previousCoins, end: coins),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFffa500)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💰', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 5),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}