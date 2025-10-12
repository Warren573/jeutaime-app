import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_system.dart';

/// Système d'animations et transitions modernes pour JeuTaime
class ModernAnimations {
  
  // ============================================================================
  // DURÉES STANDARDISÉES
  // ============================================================================
  
  static const Duration fastDuration = Duration(milliseconds: 150);
  static const Duration normalDuration = Duration(milliseconds: 250);
  static const Duration slowDuration = Duration(milliseconds: 400);
  static const Duration verySlowDuration = Duration(milliseconds: 600);
  
  // ============================================================================
  // COURBES D'ANIMATION
  // ============================================================================
  
  static const Curve fastCurve = Curves.easeOut;
  static const Curve normalCurve = Curves.easeInOut;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.decelerate;
  
  // ============================================================================
  // TRANSITIONS DE PAGES
  // ============================================================================
  
  /// Transition de slide moderne
  static PageRouteBuilder<T> slideTransition<T>({
    required Widget page,
    RouteSettings? settings,
    SlideDirection direction = SlideDirection.left,
    Duration duration = normalDuration,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;
        const Offset end = Offset.zero;
        
        switch (direction) {
          case SlideDirection.left:
            begin = const Offset(1.0, 0.0);
            break;
          case SlideDirection.right:
            begin = const Offset(-1.0, 0.0);
            break;
          case SlideDirection.up:
            begin = const Offset(0.0, 1.0);
            break;
          case SlideDirection.down:
            begin = const Offset(0.0, -1.0);
            break;
        }
        
        final slideTween = Tween(begin: begin, end: end);
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: normalCurve,
        );
        
        return SlideTransition(
          position: animation.drive(slideTween.chain(
            CurveTween(curve: normalCurve),
          )),
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
  
  /// Transition de scale avec fade
  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = normalDuration,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = CurvedAnimation(
          parent: animation,
          curve: bouncyCurve,
        );
        
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(scaleAnimation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
  
  /// Transition de rotation avec scale
  static PageRouteBuilder<T> rotationTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = normalDuration,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final rotationAnimation = CurvedAnimation(
          parent: animation,
          curve: normalCurve,
        );
        
        return RotationTransition(
          turns: Tween<double>(begin: 0.8, end: 1.0).animate(rotationAnimation),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
    );
  }
  
  // ============================================================================
  // WIDGETS ANIMÉS
  // ============================================================================
  
  /// Container animé avec hover effects
  static Widget animatedContainer({
    required Widget child,
    VoidCallback? onTap,
    Duration duration = normalDuration,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    bool enableHoverEffect = true,
  }) {
    return AnimatedHoverContainer(
      onTap: onTap,
      duration: duration,
      padding: padding,
      margin: margin,
      decoration: decoration,
      enableHoverEffect: enableHoverEffect,
      child: child,
    );
  }
  
  /// Bouton avec animation de pression
  static Widget pressableButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = fastDuration,
    double pressScale = 0.95,
    bool enableHaptic = true,
  }) {
    return PressableButton(
      onPressed: onPressed,
      duration: duration,
      pressScale: pressScale,
      enableHaptic: enableHaptic,
      child: child,
    );
  }
  
  /// Slide animation pour les listes
  static Widget slideInListItem({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 50),
    Duration duration = normalDuration,
    SlideDirection direction = SlideDirection.up,
  }) {
    return SlideInAnimation(
      child: child,
      index: index,
      delay: delay,
      duration: duration,
      direction: direction,
    );
  }
  
  /// Fade in avec délai
  static Widget fadeInWithDelay({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = normalDuration,
  }) {
    return FadeInAnimation(
      child: child,
      delay: delay,
      duration: duration,
    );
  }
  
  /// Scale animation avec bounce
  static Widget scaleIn({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = normalDuration,
    Curve curve = bouncyCurve,
  }) {
    return ScaleInAnimation(
      child: child,
      delay: delay,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Shimmer loading effect
  static Widget shimmerLoading({
    required Widget child,
    bool isLoading = true,
    Color? highlightColor,
    Color? baseColor,
  }) {
    return ShimmerWidget(
      child: child,
      isLoading: isLoading,
      highlightColor: highlightColor,
      baseColor: baseColor,
    );
  }
  
  /// Notification popup animée
  static void showAnimatedSnackBar({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: DesignSystem.textOnPrimary,
                size: 20,
              ),
              const SizedBox(width: DesignSystem.spaceS),
            ],
            Expanded(
              child: Text(
                message,
                style: DesignSystem.bodyMedium.copyWith(
                  color: DesignSystem.textOnPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? DesignSystem.primaryPink,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        ),
        action: action,
        margin: const EdgeInsets.all(DesignSystem.spaceM),
      ),
    );
  }
  
  /// Dialog animé avec blur background
  static Future<T?> showAnimatedDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Duration animationDuration = normalDuration,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: animationDuration,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: bouncyCurve,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Directions pour les animations de slide
enum SlideDirection { left, right, up, down }

// ============================================================================
// WIDGETS D'ANIMATION PERSONNALISÉS
// ============================================================================

/// Container avec effet hover animé
class AnimatedHoverContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final bool enableHoverEffect;

  const AnimatedHoverContainer({
    Key? key,
    required this.child,
    this.onTap,
    this.duration = ModernAnimations.normalDuration,
    this.padding,
    this.margin,
    this.decoration,
    this.enableHoverEffect = true,
  }) : super(key: key);

  @override
  State<AnimatedHoverContainer> createState() => _AnimatedHoverContainerState();
}

class _AnimatedHoverContainerState extends State<AnimatedHoverContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: ModernAnimations.fastCurve),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: ModernAnimations.fastCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.enableHoverEffect ? (_) => _controller.forward() : null,
      onTapUp: widget.enableHoverEffect ? (_) => _controller.reverse() : null,
      onTapCancel: widget.enableHoverEffect ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding,
              margin: widget.margin,
              decoration: widget.decoration,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Bouton avec animation de pression
class PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Duration duration;
  final double pressScale;
  final bool enableHaptic;

  const PressableButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.duration = ModernAnimations.fastDuration,
    this.pressScale = 0.95,
    this.enableHaptic = true,
  }) : super(key: key);

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.pressScale).animate(
      CurvedAnimation(parent: _controller, curve: ModernAnimations.fastCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown() {
    _controller.forward();
    if (widget.enableHaptic) {
      HapticFeedback.selectionClick();
    }
  }

  void _handleTapUp() {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Animation de slide pour les éléments de liste
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final SlideDirection direction;

  const SlideInAnimation({
    Key? key,
    required this.child,
    required this.index,
    required this.delay,
    required this.duration,
    required this.direction,
  }) : super(key: key);

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    Offset begin;
    switch (widget.direction) {
      case SlideDirection.left:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.right:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.up:
        begin = const Offset(0.0, 1.0);
        break;
      case SlideDirection.down:
        begin = const Offset(0.0, -1.0);
        break;
    }
    
    _slideAnimation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: ModernAnimations.normalCurve,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: ModernAnimations.normalCurve,
    ));

    // Démarre l'animation avec délai basé sur l'index
    Future.delayed(
      Duration(milliseconds: widget.delay.inMilliseconds * widget.index),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Animation de fade in avec délai
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const FadeInAnimation({
    Key? key,
    required this.child,
    required this.delay,
    required this.duration,
  }) : super(key: key);

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: ModernAnimations.normalCurve,
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}

/// Animation de scale in
class ScaleInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const ScaleInAnimation({
    Key? key,
    required this.child,
    required this.delay,
    required this.duration,
    required this.curve,
  }) : super(key: key);

  @override
  State<ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<ScaleInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// Widget shimmer pour loading states
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? highlightColor;
  final Color? baseColor;

  const ShimmerWidget({
    Key? key,
    required this.child,
    required this.isLoading,
    this.highlightColor,
    this.baseColor,
  }) : super(key: key);

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor ?? DesignSystem.surfaceLight.withOpacity(0.3),
                widget.highlightColor ?? Colors.white.withOpacity(0.1),
                widget.baseColor ?? DesignSystem.surfaceLight.withOpacity(0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}