import 'package:flutter/material.dart';
import 'dart:math';

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final double threshold;

  const SwipeableCard({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.threshold = 100.0,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  double _dragDistance = 0;
  bool _isDragging = false;
  bool _showLikeIndicator = false;
  bool _showPassIndicator = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDistance += details.delta.dx;
      
      // Show indicators based on drag distance
      if (_dragDistance > 50) {
        _showLikeIndicator = true;
        _showPassIndicator = false;
      } else if (_dragDistance < -50) {
        _showPassIndicator = true;
        _showLikeIndicator = false;
      } else {
        _showLikeIndicator = false;
        _showPassIndicator = false;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _showLikeIndicator = false;
      _showPassIndicator = false;
    });

    if (_dragDistance.abs() > widget.threshold) {
      // Swipe detected
      _animationController.forward().then((_) {
        if (_dragDistance > 0) {
          widget.onSwipeRight();
        } else {
          widget.onSwipeLeft();
        }
        _resetCard();
      });
    } else {
      // Return to center
      _animationController.reverse().then((_) {
        setState(() {
          _dragDistance = 0;
        });
      });
    }
  }

  void _resetCard() {
    setState(() {
      _dragDistance = 0;
    });
    _animationController.reset();
  }

  void swipeRight() {
    setState(() {
      _showLikeIndicator = true;
    });
    _animationController.forward().then((_) {
      widget.onSwipeRight();
      _resetCard();
    });
  }

  void swipeLeft() {
    setState(() {
      _showPassIndicator = true;
    });
    _animationController.forward().then((_) {
      widget.onSwipeLeft();
      _resetCard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rotation = _dragDistance * 0.0015;
    final opacity = max(0.0, 1.0 - (_dragDistance.abs() / 300));

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double animatedDistance = _dragDistance;
        double animatedRotation = rotation;
        double animatedOpacity = opacity;

        if (_animationController.isAnimating) {
          // During animation, move the card off screen
          animatedDistance = _dragDistance > 0 
              ? MediaQuery.of(context).size.width * _animation.value
              : -MediaQuery.of(context).size.width * _animation.value;
          animatedRotation = rotation + (0.5 * _animation.value * (_dragDistance > 0 ? 1 : -1));
          animatedOpacity = 1.0 - _animation.value;
        }

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Transform.translate(
            offset: Offset(animatedDistance, 0),
            child: Transform.rotate(
              angle: animatedRotation,
              child: Opacity(
                opacity: animatedOpacity,
                child: Stack(
                  children: [
                    widget.child,
                    // Like indicator
                    if (_showLikeIndicator)
                      Positioned(
                        right: 30,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              border: Border.all(color: Colors.green, width: 4),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('😊', style: TextStyle(fontSize: 48)),
                                Text(
                                  'LIKE',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Pass indicator
                    if (_showPassIndicator)
                      Positioned(
                        left: 30,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              border: Border.all(color: Colors.red, width: 4),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('😕', style: TextStyle(fontSize: 48)),
                                Text(
                                  'PASSER',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}