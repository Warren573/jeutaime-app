import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String userName;
  final String userStatus;
  final int coins;

  const AppHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.userName,
    required this.userStatus,
    required this.coins,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0x4DCD853F),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Titre principal
          Text(
            title,
            style: const TextStyle(
              fontSize: 29, // 1.8em
              fontWeight: FontWeight.bold,
              color: AppColors.beige,
              fontFamily: 'Georgia',
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Sous-titre
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.beige.withOpacity(0.9),
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 15),
          
          // Informations utilisateur
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.beige.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Info utilisateur
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: AppColors.beige,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userStatus,
                        style: TextStyle(
                          color: AppColors.beige.withOpacity(0.8),
                          fontSize: 13,
                          fontFamily: 'Georgia',
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Affichage des pièces
                CoinsDisplay(coins: coins),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CoinsDisplay extends StatefulWidget {
  final int coins;

  const CoinsDisplay({
    Key? key,
    required this.coins,
  }) : super(key: key);

  @override
  State<CoinsDisplay> createState() => _CoinsDisplayState();
}

class _CoinsDisplayState extends State<CoinsDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.coinsGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldAccent.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '💰 ${widget.coins} pièces',
              style: const TextStyle(
                color: AppColors.primaryBrown,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        );
      },
    );
  }
}