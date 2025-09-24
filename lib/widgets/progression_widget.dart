import 'package:flutter/material.dart';
import '../services/progression_service.dart';
import '../config/ui_reference.dart';

class ProgressionWidget extends StatefulWidget {
  final UserProgressData userData;
  final Function(UserProgressData)? onProgressUpdate;

  const ProgressionWidget({
    Key? key,
    required this.userData,
    this.onProgressUpdate,
  }) : super(key: key);

  @override
  _ProgressionWidgetState createState() => _ProgressionWidgetState();
}

class _ProgressionWidgetState extends State<ProgressionWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _levelController;
  late Animation<double> _progressAnimation;
  late Animation<double> _levelAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _levelController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: ProgressionService.getLevelProgress(widget.userData.points),
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _levelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _levelController,
      curve: Curves.elasticOut,
    ));

    // Démarrer les animations
    _progressController.forward();
    _levelController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UIReference.colors['primary']!.withOpacity(0.8),
            UIReference.colors['secondary']!.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: UIReference.colors['primary']!.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec niveau et points
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Votre Progression',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: _levelAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _levelAnimation.value,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: UIReference.colors['primary'],
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Niveau ${widget.userData.level}',
                                    style: TextStyle(
                                      color: UIReference.colors['primary'],
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Georgia',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 12),
                      Text(
                        '${widget.userData.points} pts',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontFamily: 'Georgia',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildLevelBadge(),
            ],
          ),

          SizedBox(height: 20),

          // Barre de progression
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vers le niveau ${widget.userData.level + 1}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  if (widget.userData.level < 10)
                    Text(
                      '${ProgressionService.pointsToNextLevel(widget.userData.points)} pts restants',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontFamily: 'Georgia',
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Stats rapides
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.favorite,
                label: 'Matchs',
                value: '${widget.userData.matchesFound}',
              ),
              _buildStatItem(
                icon: Icons.chat,
                label: 'Messages',
                value: '${widget.userData.messagesCount}',
              ),
              _buildStatItem(
                icon: Icons.local_bar,
                label: 'Bars',
                value: '${widget.userData.barsCompleted}',
              ),
            ],
          ),

          SizedBox(height: 16),

          // Bouton achievements/récompenses
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showAchievementsDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                foregroundColor: UIReference.colors['primary'],
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Achievements & Récompenses',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    Color badgeColor = _getLevelColor(widget.userData.level);
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${widget.userData.level}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 20,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontFamily: 'Georgia',
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 10) return Colors.purple; // Légendaire
    if (level >= 7) return Colors.amber;   // Épique  
    if (level >= 5) return Colors.blue;    // Rare
    if (level >= 3) return Colors.green;   // Commun
    return Colors.grey;                    // Débutant
  }

  void _showAchievementsDialog() {
    List<Achievement> mockAchievements = [
      Achievement(
        id: 'first_match',
        title: 'Premier Match',
        description: 'Votre première connexion',
        icon: '💘',
        points: 50,
        unlockedAt: DateTime.now().subtract(Duration(days: 2)),
        rarity: AchievementRarity.common,
      ),
      Achievement(
        id: 'level_5',
        title: 'Niveau 5',
        description: 'Vous avez atteint le niveau 5',
        icon: '🎯',
        points: 250,
        unlockedAt: DateTime.now().subtract(Duration(days: 1)),
        rarity: AchievementRarity.rare,
      ),
    ];

    List<Reward> availableRewards = ProgressionService.getAvailableRewards(widget.userData.level);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🏆 Achievements & Récompenses',
                style: UIReference.titleStyle.copyWith(fontSize: 20),
              ),
              SizedBox(height: 16),
              
              // Achievements
              Text(
                'Achievements Débloqués',
                style: UIReference.subtitleStyle.copyWith(fontSize: 16),
              ),
              SizedBox(height: 8),
              Container(
                height: 120,
                child: ListView.builder(
                  itemCount: mockAchievements.length,
                  itemBuilder: (context, index) {
                    final achievement = mockAchievements[index];
                    return ListTile(
                      leading: Text(achievement.icon, style: TextStyle(fontSize: 24)),
                      title: Text(achievement.title),
                      subtitle: Text(achievement.description),
                      trailing: Text('+${achievement.points}'),
                    );
                  },
                ),
              ),
              
              Divider(),
              
              // Récompenses
              Text(
                'Récompenses Disponibles',
                style: UIReference.subtitleStyle.copyWith(fontSize: 16),
              ),
              SizedBox(height: 8),
              Container(
                height: 120,
                child: ListView.builder(
                  itemCount: availableRewards.length,
                  itemBuilder: (context, index) {
                    final reward = availableRewards[index];
                    return ListTile(
                      leading: Text(reward.icon, style: TextStyle(fontSize: 24)),
                      title: Text(reward.title),
                      subtitle: Text(reward.description),
                      trailing: Icon(Icons.check, color: Colors.green),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _levelController.dispose();
    super.dispose();
  }
}