import 'package:flutter/material.dart';
import '../services/user_data_manager.dart';
import '../utils/responsive_helper.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _levelController;
  late Animation<double> _levelAnimation;
  
  late AnimationController _statsController;
  late Animation<double> _statsAnimation;

  final UserDataManager _userManager = UserDataManager();

  @override
  void initState() {
    super.initState();
    
    _levelController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _levelAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _levelController, curve: Curves.easeInOut)
    );
    
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _statsAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.elasticOut)
    );
    
    _levelController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _statsController.forward();
    });
  }

  @override
  void dispose() {
    _levelController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  Widget _buildLevelCard() {
    return AnimatedBuilder(
      animation: _levelAnimation,
      builder: (context, child) => Transform.scale(
        scale: _levelAnimation.value,
        child: Container(
          padding: ResponsiveHelper.getResponsivePadding(context),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Niveau ${_userManager.level}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _userManager.getLevelTitle(),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      '🏆',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 32),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'XP: ${_userManager.xp}/${_userManager.xpToNextLevel}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Prochain niveau',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _userManager.levelProgress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = _userManager.gameStats;
    
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, (1 - _statsAnimation.value) * 50),
        child: Opacity(
          opacity: _statsAnimation.value,
          child: Container(
            padding: ResponsiveHelper.getResponsivePadding(context),
            decoration: BoxDecoration(
              color: const Color(0xFF1e1e1e),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 Statistiques de Jeu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Overview stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        '🎮',
                        'Parties Jouées',
                        stats.totalGamesPlayed.toString(),
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        '🪙',
                        'Pièces Totales',
                        _userManager.coins.toString(),
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Individual game stats
                if (stats.memoryBestScore > 0)
                  _buildGameStatRow('🧠', 'Memory Game', stats.memoryGamesPlayed, stats.memoryBestScore),
                
                if (stats.snakeBestScore > 0)
                  _buildGameStatRow('🐍', 'Snake Game', stats.snakeGamesPlayed, stats.snakeBestScore),
                
                if (stats.quizBestScore > 0)
                  _buildGameStatRow('💕', 'Quiz Couple', stats.quizGamesPlayed, stats.quizBestScore),
                
                if (stats.reactivityBestScore > 0)
                  _buildGameStatRow('⚡', 'Réactivité', stats.reactivityGamesPlayed, stats.reactivityBestScore),
                
                if (stats.breakoutBestScore > 0)
                  _buildGameStatRow('🧱', 'Casse-Briques', stats.breakoutGamesPlayed, stats.breakoutBestScore),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatRow(String emoji, String game, int played, int bestScore) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$played parties jouées',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Record',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                bestScore.toString(),
                style: const TextStyle(color: Color(0xFFE91E63), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard() {
    final achievements = _userManager.unlockedAchievements;
    
    return Container(
      padding: ResponsiveHelper.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 Succès Débloqués',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          
          if (achievements.isEmpty)
            const Center(
              child: Column(
                children: [
                  Text('🎯', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 10),
                  Text(
                    'Jouez pour débloquer des succès !',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: achievements.map((achievement) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE91E63)),
                  ),
                  child: Text(
                    _getAchievementTitle(achievement),
                    style: const TextStyle(color: Color(0xFFE91E63), fontSize: 12),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _getAchievementTitle(String achievement) {
    switch (achievement) {
      case 'gamer_bronze':
        return '🥉 Joueur Bronze';
      case 'gamer_silver':
        return '🥈 Joueur Argent';
      case 'gamer_gold':
        return '🥇 Joueur Or';
      case 'memory_master':
        return '🧠 Maître Mémoire';
      case 'snake_champion':
        return '🐍 Champion Snake';
      default:
        return '🏆 $achievement';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('👤 Mon Profil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              _levelController.reset();
              _statsController.reset();
              _levelController.forward();
              Future.delayed(const Duration(milliseconds: 300), () {
                _statsController.forward();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getResponsivePadding(context),
        child: Column(
          children: [
            // Level card
            _buildLevelCard(),
            
            const SizedBox(height: 20),
            
            // Stats card
            _buildStatsCard(),
            
            const SizedBox(height: 20),
            
            // Achievements card
            _buildAchievementsCard(),
            
            const SizedBox(height: 20),
            
            // Debug actions (development only)
            if (const bool.fromEnvironment('dart.vm.product') == false)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _userManager.updateCoins(100);
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('🪙 +100 Pièces (Debug)'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _userManager.resetUserData();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('🔄 Reset Données (Debug)'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}