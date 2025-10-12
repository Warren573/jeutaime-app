import 'package:flutter/material.dart';
import '../services/gamification_service.dart';

/// Mixin pour ajouter automatiquement de l'XP aux actions utilisateur
mixin GamificationMixin<T extends StatefulWidget> on State<T> {
  final GamificationService _gamificationService = GamificationService.instance;

  /// Ajoute de l'XP pour une action spécifique
  Future<void> trackAction(String action, {
    int xpAmount = 10,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final result = await _gamificationService.addExperience(
        amount: xpAmount,
        reason: action,
        metadata: metadata,
      );

      if (mounted && result.success && result.leveledUp) {
        _showLevelUpDialog(result.oldLevel, result.newLevel, result.xpGained);
      }
    } catch (e) {
      debugPrint('Erreur tracking gamification: $e');
    }
  }

  /// Affiche une animation de level up
  void _showLevelUpDialog(int oldLevel, int newLevel, int xpGained) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'NIVEAU SUPÉRIEUR !',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Niveau $oldLevel → $newLevel',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+$xpGained XP',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFFD700),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Continuer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Auto-fermer après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  /// Actions prédéfinies avec leurs récompenses XP
  void trackLogin() => trackAction('Connexion quotidienne', xpAmount: 10);
  void trackLike() => trackAction('Profile liké', xpAmount: 5);
  void trackSuperLike() => trackAction('Super-like utilisé', xpAmount: 15);
  void trackMatch() => trackAction('Nouveau match', xpAmount: 50);
  void trackMessage() => trackAction('Message envoyé', xpAmount: 8);
  void trackGamePlayed(String gameName) => trackAction(
    'Partie jouée',
    xpAmount: 20,
    metadata: {'game': gameName},
  );
  void trackGameWon(String gameName) => trackAction(
    'Partie gagnée',
    xpAmount: 35,
    metadata: {'game': gameName, 'result': 'win'},
  );
  void trackProfileCompleted() => trackAction('Profil complété', xpAmount: 100);
  void trackPhotoAdded() => trackAction('Photo ajoutée', xpAmount: 25);
  void trackDailyChallengeCompleted() => trackAction('Défi quotidien complété', xpAmount: 0); // XP géré par le service de défis
}

/// Widget pour afficher les gains d'XP en temps réel
class XpGainWidget extends StatefulWidget {
  final String action;
  final int xpAmount;
  final VoidCallback? onComplete;

  const XpGainWidget({
    super.key,
    required this.action,
    required this.xpAmount,
    this.onComplete,
  });

  @override
  State<XpGainWidget> createState() => _XpGainWidgetState();
}

class _XpGainWidgetState extends State<XpGainWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: -50.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+${widget.xpAmount} XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Service utilitaire pour afficher les gains d'XP dans l'interface
class XpToastService {
  static OverlayEntry? _currentOverlay;

  static void showXpGain(
    BuildContext context, {
    required String action,
    required int xpAmount,
  }) {
    // Fermer le toast précédent s'il existe
    _currentOverlay?.remove();

    final overlay = Overlay.of(context);
    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 100,
        left: 20,
        right: 20,
        child: XpGainWidget(
          action: action,
          xpAmount: xpAmount,
          onComplete: () {
            _currentOverlay?.remove();
            _currentOverlay = null;
          },
        ),
      ),
    );

    overlay.insert(_currentOverlay!);
  }
}