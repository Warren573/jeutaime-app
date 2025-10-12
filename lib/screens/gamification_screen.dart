import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/gamification_service.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  UserStats? _userStats;
  List<DailyChallengeModel> _dailyChallenges = [];
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadGamificationData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGamificationData() async {
    final service = GamificationService.instance;
    
    try {
      final futures = await Future.wait([
        service.getUserStats(),
        service.getDailyChallenges(),
        service.getGlobalLeaderboard(limit: 20),
      ]);
      
      setState(() {
        _userStats = futures[0] as UserStats;
        _dailyChallenges = futures[1] as List<DailyChallengeModel>;
        _leaderboard = futures[2] as List<LeaderboardEntry>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Progression',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF6B9D),
          labelColor: const Color(0xFFFF6B9D),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profil'),
            Tab(icon: Icon(Icons.task_alt), text: 'Défis'),
            Tab(icon: Icon(Icons.leaderboard), text: 'Classement'),
            Tab(icon: Icon(Icons.military_tech), text: 'Réussites'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6B9D),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildChallengesTab(),
                _buildLeaderboardTab(),
                _buildAchievementsTab(),
              ],
            ),
    );
  }

  Widget _buildProfileTab() {
    if (_userStats == null) {
      return const Center(
        child: Text(
          'Aucune donnée disponible',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final stats = _userStats!;
    final service = GamificationService.instance;
    final xpToNext = service.getXpToNextLevel(stats.totalXp);
    final xpForCurrent = service.getXpRequiredForLevel(stats.level);
    final xpForNext = service.getXpRequiredForLevel(stats.level + 1);
    final levelProgress = (stats.totalXp - xpForCurrent) / (xpForNext - xpForCurrent);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Carte de niveau
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFC147E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B9D).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Niveau ${stats.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${stats.totalXp} XP',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: levelProgress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
                const SizedBox(height: 8),
                Text(
                  '$xpToNext XP pour le niveau ${stats.level + 1}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Statistiques
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistiques',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '💰',
                        '${stats.totalCoins}',
                        'Coins',
                        const Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '💕',
                        '${stats.totalMatches}',
                        'Matches',
                        const Color(0xFFFF6B9D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '💬',
                        '${stats.messagesSent}',
                        'Messages',
                        const Color(0xFF4A90E2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '🎮',
                        '${stats.gamesPlayed}',
                        'Parties',
                        const Color(0xFF7ED321),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '🔥',
                        '${stats.currentStreak}',
                        'Série',
                        const Color(0xFFFF4757),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '🏆',
                        '${stats.unlockedAchievements.length}',
                        'Réussites',
                        const Color(0xFFC147E9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    return RefreshIndicator(
      onRefresh: _loadGamificationData,
      color: const Color(0xFFFF6B9D),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Défis Quotidiens',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complétez ces défis pour gagner de l\'XP et des coins !',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            
            if (_dailyChallenges.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.task_alt,
                      color: Colors.white54,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun défi disponible',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...(_dailyChallenges.map((challenge) => _buildChallengeCard(challenge)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(DailyChallengeModel challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: challenge.isCompleted 
              ? const Color(0xFF7ED321) 
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                challenge.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (challenge.isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF7ED321),
                  size: 24,
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Barre de progression
          LinearProgressIndicator(
            value: challenge.progressPercentage,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              challenge.isCompleted 
                  ? const Color(0xFF7ED321)
                  : const Color(0xFFFF6B9D),
            ),
            minHeight: 6,
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${challenge.currentProgress}/${challenge.targetValue}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  if (challenge.xpReward > 0) ...[
                    const Icon(
                      Icons.star,
                      color: Color(0xFFFFD700),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.xpReward} XP',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (challenge.coinReward > 0) ...[
                    const SizedBox(width: 12),
                    const Text(
                      '💰',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.coinReward}',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return RefreshIndicator(
      onRefresh: _loadGamificationData,
      color: const Color(0xFFFF6B9D),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Classement Global',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comparez votre progression avec les autres joueurs',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            
            if (_leaderboard.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.leaderboard,
                      color: Colors.white54,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Classement indisponible',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...(_leaderboard.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;
                return _buildLeaderboardEntry(player, index);
              }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry player, int index) {
    Color rankColor = Colors.white;
    IconData? rankIcon;
    
    if (player.rank == 1) {
      rankColor = const Color(0xFFFFD700);
      rankIcon = Icons.emoji_events;
    } else if (player.rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
      rankIcon = Icons.emoji_events;
    } else if (player.rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      rankIcon = Icons.emoji_events;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: player.isCurrentUser 
            ? const Color(0xFFFF6B9D).withOpacity(0.1)
            : const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: player.isCurrentUser 
              ? const Color(0xFFFF6B9D)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Rang
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: rankIcon != null
                  ? Icon(rankIcon, color: rankColor, size: 20)
                  : Text(
                      '${player.rank}',
                      style: TextStyle(
                        color: rankColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Avatar
          Text(
            player.avatar,
            style: const TextStyle(fontSize: 24),
          ),
          
          const SizedBox(width: 12),
          
          // Infos utilisateur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.username,
                      style: TextStyle(
                        color: player.isCurrentUser 
                            ? const Color(0xFFFF6B9D)
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (player.isCurrentUser) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '(Vous)',
                        style: TextStyle(
                          color: Color(0xFFFF6B9D),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Niveau ${player.level} • ${player.totalXp} XP',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    // TODO: Implémenter l'affichage des achievements
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.military_tech,
            color: Colors.white54,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'Réussites',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Bientôt disponible !',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}