import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../services/interaction_service.dart';
import '../services/matching_algorithm.dart';
import '../services/location_service.dart';
import '../utils/performance_optimizer.dart';
import '../utils/gamification_mixin.dart';

class SwipeScreen extends StatefulWidget {
  final List<MatchedUser> profiles;
  final Function(int) onCoinsUpdated;
  final VoidCallback onProfilesExhausted;

  const SwipeScreen({
    super.key,
    required this.profiles,
    required this.onCoinsUpdated,
    required this.onProfilesExhausted,
  });

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with TickerProviderStateMixin, GamificationMixin {
  late AnimationController _swipeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _heartController;
  late AnimationController _starController;

  late Animation<Offset> _swipeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _heartAnimation;
  late Animation<double> _starAnimation;

  int _currentIndex = 0;
  bool _isAnimating = false;
  Offset _dragPosition = Offset.zero;
  bool _showLikeIndicator = false;
  bool _showSuperLikeIndicator = false;
  bool _showDislikeIndicator = false;

  @override
  void initState() {
    super.initState();

    _swipeController = PerformanceOptimizer.createOptimizedController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleController = PerformanceOptimizer.createOptimizedController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _rotationController = PerformanceOptimizer.createOptimizedController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heartController = PerformanceOptimizer.createOptimizedController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _starController = PerformanceOptimizer.createOptimizedController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.0, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _heartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticOut,
    ));

    _starAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _heartController.dispose();
    _starController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating) return;
    _scaleController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;

    setState(() {
      _dragPosition += details.delta;
      
      // Calcul des seuils pour les indicateurs
      final screenWidth = MediaQuery.of(context).size.width;
      final dragRatio = _dragPosition.dx / screenWidth;
      
      // Like (swipe droite)
      _showLikeIndicator = dragRatio > 0.2;
      // Super-like (swipe haut)
      _showSuperLikeIndicator = _dragPosition.dy < -100;
      // Dislike (swipe gauche)
      _showDislikeIndicator = dragRatio < -0.2;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;

    _scaleController.reverse();

    final screenWidth = MediaQuery.of(context).size.width;
    final dragRatio = _dragPosition.dx / screenWidth;
    final velocity = details.velocity.pixelsPerSecond;

    // Déterminer l'action basée sur le drag et la vélocité
    if (_dragPosition.dy < -150 || velocity.dy < -1000) {
      // Super-like
      _performSuperLike();
    } else if (dragRatio > 0.3 || velocity.dx > 1000) {
      // Like
      _performLike();
    } else if (dragRatio < -0.3 || velocity.dx < -1000) {
      // Dislike
      _performDislike();
    } else {
      // Revenir à la position originale
      _resetCard();
    }
  }

  void _resetCard() {
    setState(() {
      _dragPosition = Offset.zero;
      _showLikeIndicator = false;
      _showSuperLikeIndicator = false;
      _showDislikeIndicator = false;
    });
  }

  Future<void> _performLike() async {
    if (_currentIndex >= widget.profiles.length) return;

    _isAnimating = true;
    
    // Animation de sortie à droite
    _swipeController.reset();
    _swipeAnimation = Tween<Offset>(
      begin: _dragPosition / MediaQuery.of(context).size.width,
      end: const Offset(2.0, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));

    await _swipeController.forward();

    // Envoyer le like
    final profile = widget.profiles[_currentIndex];
    final result = await InteractionService.instance.sendLike(
      targetUserId: profile.profile.id,
    );

    if (result.success) {
      widget.onCoinsUpdated(result.isMatch ? 20 : 5); // Bonus pour les matchs
      
      // Tracking gamification
      if (result.isMatch) {
        trackMatch(); // +50 XP pour un match
        _showMatchDialog(profile);
      } else {
        trackLike(); // +5 XP pour un like
        _showLikeAnimation();
      }
    }

    _nextProfile();
  }

  Future<void> _performSuperLike() async {
    if (_currentIndex >= widget.profiles.length) return;

    _isAnimating = true;
    
    // Animation de sortie vers le haut
    _swipeController.reset();
    _swipeAnimation = Tween<Offset>(
      begin: _dragPosition / MediaQuery.of(context).size.width,
      end: const Offset(0, -2.0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));

    await _swipeController.forward();

    // Envoyer le super-like
    final profile = widget.profiles[_currentIndex];
    final result = await InteractionService.instance.sendLike(
      targetUserId: profile.profile.id,
      isSuperLike: true,
    );

    if (result.success) {
      widget.onCoinsUpdated(result.isMatch ? 50 : 10); // Gros bonus pour les super-likes
      
      // Tracking gamification
      if (result.isMatch) {
        trackMatch(); // +50 XP pour un match
        _showMatchDialog(profile);
      } else {
        trackSuperLike(); // +15 XP pour un super-like
        _showSuperLikeAnimation();
      }
    }

    _nextProfile();
  }

  Future<void> _performDislike() async {
    if (_currentIndex >= widget.profiles.length) return;

    _isAnimating = true;
    
    // Animation de sortie à gauche
    _swipeController.reset();
    _swipeAnimation = Tween<Offset>(
      begin: _dragPosition / MediaQuery.of(context).size.width,
      end: const Offset(-2.0, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));

    await _swipeController.forward();

    // Envoyer le dislike
    final profile = widget.profiles[_currentIndex];
    await InteractionService.instance.sendDislike(profile.profile.id);

    _nextProfile();
  }

  void _nextProfile() {
    setState(() {
      _currentIndex++;
      _dragPosition = Offset.zero;
      _showLikeIndicator = false;
      _showSuperLikeIndicator = false;
      _showDislikeIndicator = false;
      _isAnimating = false;
    });

    if (_currentIndex >= widget.profiles.length) {
      widget.onProfilesExhausted();
    }
  }

  void _showLikeAnimation() {
    _heartController.reset();
    _heartController.forward();
  }

  void _showSuperLikeAnimation() {
    _starController.reset();
    _starController.forward();
  }

  void _showMatchDialog(MatchedUser match) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MatchDialog(
        match: match,
        onStartChat: () {
          Navigator.pop(context);
          // TODO: Ouvrir le chat
        },
        onContinue: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.profiles.length) {
      return _buildNoMoreProfilesScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: Stack(
        children: [
          // Cartes suivantes (effet de profondeur)
          for (int i = _currentIndex + 2; i >= _currentIndex; i--)
            if (i < widget.profiles.length)
              _buildProfileCard(
                widget.profiles[i],
                isTop: i == _currentIndex,
                depth: i - _currentIndex,
              ),
          
          // Indicateurs de swipe
          _buildSwipeIndicators(),
          
          // Animations de like/super-like
          _buildLikeAnimations(),
          
          // Boutons d'action
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProfileCard(MatchedUser match, {required bool isTop, required int depth}) {
    final profile = match.profile;
    final score = match.compatibilityScore.round();
    
    Widget card = Container(
      margin: EdgeInsets.only(
        top: 80 + (depth * 10.0),
        left: 20 + (depth * 5.0),
        right: 20 + (depth * 5.0),
        bottom: 120,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Image de fond
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Container(
                color: const Color(0xFF1e1e1e),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            
            // Score de compatibilité
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: score >= 85 
                      ? Colors.green 
                      : score >= 70 
                          ? Colors.orange 
                          : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${score}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Informations du profil
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${profile.professionCategory} • ${profile.location.city}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Intérêts
                    Wrap(
                      spacing: 8,
                      children: profile.interests.take(3).map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFE91E63),
                            ),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    // Raisons du match
                    if (match.matchReasons.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pourquoi ce match ?',
                            style: TextStyle(
                              color: Color(0xFFE91E63),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...match.matchReasons.take(2).map((reason) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                '• $reason',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!isTop) {
      // Cartes en arrière-plan avec scale réduit
      return Transform.scale(
        scale: 1.0 - (depth * 0.05),
        child: Opacity(
          opacity: 1.0 - (depth * 0.2),
          child: card,
        ),
      );
    }

    // Carte principale avec animations
    return AnimatedBuilder(
      animation: Listenable.merge([
        _swipeController,
        _scaleController,
        _rotationController,
      ]),
      builder: (context, child) {
        final swipeOffset = _isAnimating 
            ? _swipeAnimation.value 
            : _dragPosition / MediaQuery.of(context).size.width;
        
        return Transform.translate(
          offset: Offset(
            swipeOffset.dx * MediaQuery.of(context).size.width,
            swipeOffset.dy * MediaQuery.of(context).size.height,
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: swipeOffset.dx * 0.3,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: card,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwipeIndicators() {
    return Stack(
      children: [
        // Indicateur Like (droite)
        if (_showLikeIndicator)
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 50,
            right: 50,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        
        // Indicateur Super-Like (haut)
        if (_showSuperLikeIndicator)
          Positioned(
            top: 150,
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.star,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        
        // Indicateur Dislike (gauche)
        if (_showDislikeIndicator)
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 50,
            left: 50,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLikeAnimations() {
    return Stack(
      children: [
        // Animation coeur pour like
        AnimatedBuilder(
          animation: _heartAnimation,
          builder: (context, child) {
            if (_heartAnimation.value == 0) return const SizedBox.shrink();
            
            return Positioned(
              top: MediaQuery.of(context).size.height / 2 - 25,
              left: MediaQuery.of(context).size.width / 2 - 25,
              child: Transform.scale(
                scale: _heartAnimation.value,
                child: Opacity(
                  opacity: 1.0 - _heartAnimation.value,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
              ),
            );
          },
        ),
        
        // Animation étoile pour super-like
        AnimatedBuilder(
          animation: _starAnimation,
          builder: (context, child) {
            if (_starAnimation.value == 0) return const SizedBox.shrink();
            
            return Positioned(
              top: MediaQuery.of(context).size.height / 2 - 25,
              left: MediaQuery.of(context).size.width / 2 - 25,
              child: Transform.scale(
                scale: _starAnimation.value,
                child: Opacity(
                  opacity: 1.0 - _starAnimation.value,
                  child: const Icon(
                    Icons.star,
                    color: Colors.blue,
                    size: 50,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Bouton Dislike
          FloatingActionButton(
            onPressed: _isAnimating ? null : () => _performDislike(),
            backgroundColor: Colors.red,
            child: const Icon(Icons.close, color: Colors.white),
          ),
          
          // Bouton Super-Like
          FloatingActionButton(
            onPressed: _isAnimating ? null : () => _performSuperLike(),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.star, color: Colors.white),
          ),
          
          // Bouton Like
          FloatingActionButton(
            onPressed: _isAnimating ? null : () => _performLike(),
            backgroundColor: Colors.green,
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreProfilesScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Plus de profils !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Revenez plus tard pour découvrir\nde nouveaux profils',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchDialog extends StatefulWidget {
  final MatchedUser match;
  final VoidCallback onStartChat;
  final VoidCallback onContinue;

  const MatchDialog({
    super.key,
    required this.match,
    required this.onStartChat,
    required this.onContinue,
  });

  @override
  State<MatchDialog> createState() => _MatchDialogState();
}

class _MatchDialogState extends State<MatchDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _scaleController.forward();
    _confettiController.forward();
    
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE91E63),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎉',
                    style: TextStyle(fontSize: 50),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'C\'est un match !',
                    style: TextStyle(
                      color: Color(0xFFE91E63),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vous et ${widget.match.profile.name.split(',')[0]} vous êtes likés mutuellement',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // Profil utilisateur
                      Expanded(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFFE91E63),
                              child: const Text(
                                'Vous',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Vous',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Coeur au centre
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.favorite,
                          color: Color(0xFFE91E63),
                          size: 32,
                        ),
                      ),
                      
                      // Profil matché
                      Expanded(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFFE91E63),
                              child: Text(
                                widget.match.profile.name.substring(0, 1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.match.profile.name.split(',')[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onContinue,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Continuer',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onStartChat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Envoyer un message',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}