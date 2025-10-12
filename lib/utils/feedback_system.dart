import 'package:flutter/material.dart';
import '../utils/performance_optimizer.dart';

/// Système de feedback amélioré pour JeuTaime
class FeedbackSystem {
  
  /// Toast message avec animation fluide
  static void showToast({
    required BuildContext context,
    required String message,
    required String icon,
    Color backgroundColor = const Color(0xFF2a2a2a),
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        onComplete: () => overlayEntry.remove(),
        duration: duration,
      ),
    );
    
    overlay.insert(overlayEntry);
  }
  
  /// Snackbar optimisé avec actions
  static void showSnackbar({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? const Color(0xFF2a2a2a),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: const Color(0xFFE91E63),
              onPressed: onActionPressed,
            )
          : null,
        animation: CurvedAnimation(
          parent: AnimationController(
            duration: PerformanceConstants.normalAnimation,
            vsync: Navigator.of(context),
          )..forward(),
          curve: PerformanceConstants.defaultCurve,
        ),
      ),
    );
  }
  
  /// Dialog optimisé avec animations
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: AnimationController(
            duration: PerformanceConstants.normalAnimation,
            vsync: Navigator.of(context),
          )..forward(),
          curve: PerformanceConstants.bounceCurve,
        ),
        child: AlertDialog(
          backgroundColor: const Color(0xFF2a2a2a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                PerformanceOptimizer.hapticFeedback(HapticFeedbackType.selectionClick);
                Navigator.of(context).pop(false);
              },
              child: Text(
                cancelText,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                PerformanceOptimizer.hapticFeedback(HapticFeedbackType.selectionClick);
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor ?? const Color(0xFFE91E63),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(confirmText),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Loading dialog avec animation
  static OverlayEntry showLoadingDialog({
    required BuildContext context,
    String message = 'Chargement...',
  }) {
    final overlay = Overlay.of(context);
    
    final overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF2a2a2a),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PerformanceOptimizer.buildLoadingAnimation(),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    return overlayEntry;
  }
  
  /// Animation de succès
  static void showSuccessAnimation({
    required BuildContext context,
    String message = 'Succès !',
  }) {
    showToast(
      context: context,
      message: message,
      icon: '✅',
      backgroundColor: Colors.green.shade700,
    );
  }
  
  /// Animation d'erreur
  static void showErrorAnimation({
    required BuildContext context,
    String message = 'Erreur',
  }) {
    showToast(
      context: context,
      message: message,
      icon: '❌',
      backgroundColor: Colors.red.shade700,
    );
  }
}

/// Widget de toast personnalisé
class _ToastWidget extends StatefulWidget {
  final String message;
  final String icon;
  final Color backgroundColor;
  final VoidCallback onComplete;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.onComplete,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: PerformanceConstants.normalAnimation,
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: PerformanceConstants.bounceCurve,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: PerformanceConstants.defaultCurve,
    ));
    
    _controller.forward();
    
    // Auto-remove after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onComplete());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      widget.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}