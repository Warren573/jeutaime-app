import 'package:flutter/material.dart';

class WeeklyBarScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const WeeklyBarScreen({
    super.key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  });

  @override
  State<WeeklyBarScreen> createState() => _WeeklyBarScreenState();
}

class _WeeklyBarScreenState extends State<WeeklyBarScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _countdownController;
  late Animation<double> _countdownAnimation;

  bool _hasJoinedGroup = false;
  String _currentChallenge = 'Défi de la Semaine #23';
  int _weeklyPoints = 0;
  int _timeRemaining = 73; // heures restantes
  
  final List<Map<String, dynamic>> _weeklyGroups = [
    {
      'id': 1,
      'name': 'Les Explorateurs',
      'members': [
        {'name': 'Alice', 'gender': 'F', 'level': 12, 'isOnline': true},
        {'name': 'Pierre', 'gender': 'M', 'level': 8, 'isOnline': true},
        {'name': 'Emma', 'gender': 'F', 'level': 15, 'isOnline': false},
      ],
      'maxMembers': 4,
      'challengeProgress': 75,
      'theme': 'adventure',
      'created': '2 jours',
      'totalPoints': 340,
    },
    {
      'id': 2,
      'name': 'Dream Team',
      'members': [
        {'name': 'Sarah', 'gender': 'F', 'level': 20, 'isOnline': true},
        {'name': 'Tom', 'gender': 'M', 'level': 18, 'isOnline': true},
        {'name': 'Lisa', 'gender': 'F', 'level': 14, 'isOnline': true},
        {'name': 'Max', 'gender': 'M', 'level': 16, 'isOnline': false},
      ],
      'maxMembers': 4,
      'challengeProgress': 92,
      'theme': 'strategy',
      'created': '5 jours',
      'totalPoints': 520,
    },
    {
      'id': 3,
      'name': 'Les Créatifs',
      'members': [
        {'name': 'Julie', 'gender': 'F', 'level': 11, 'isOnline': false},
        {'name': 'Marc', 'gender': 'M', 'level': 13, 'isOnline': true},
      ],
      'maxMembers': 4,
      'challengeProgress': 45,
      'theme': 'creativity',
      'created': '1 jour',
      'totalPoints': 180,
    },
  ];

  final List<Map<String, dynamic>> _weeklyActivities = [
    {
      'id': 'team_challenge',
      'title': '🏆 Défi d\'Équipe',
      'description': 'Relevez le défi hebdomadaire ensemble',
      'difficulty': 'Équipe',
      'reward': 50,
      'icon': '🎭',
      'type': 'group',
      'requiresGroup': true,
    },
    {
      'id': 'strategy_game',
      'title': '🧩 Jeu de Stratégie',
      'description': 'Coopérez pour résoudre les énigmes',
      'difficulty': 'Difficile',
      'reward': 25,
      'icon': '♟️',
      'type': 'puzzle',
      'requiresGroup': true,
    },
    {
      'id': 'creative_session',
      'title': '🎨 Session Créative',
      'description': 'Créez quelque chose ensemble',
      'difficulty': 'Moyen',
      'reward': 20,
      'icon': '🖌️',
      'type': 'creative',
      'requiresGroup': true,
    },
    {
      'id': 'discussion_circle',
      'title': '💬 Cercle de Discussion',
      'description': 'Débattez sur le thème de la semaine',
      'difficulty': 'Facile',
      'reward': 15,
      'icon': '🗣️',
      'type': 'discussion',
      'requiresGroup': false,
    },
  ];

  final List<Map<String, dynamic>> _groupChat = [
    {
      'sender': 'Alice',
      'message': 'Prêts pour le grand défi de cette semaine ? 🏆',
      'time': '14:30',
      'isMe': false,
      'gender': 'F',
    },
    {
      'sender': 'Pierre',
      'message': 'Absolument ! J\'ai hâte de voir ce qu\'on peut accomplir ensemble 💪',
      'time': '14:31',
      'isMe': false,
      'gender': 'M',
    },
    {
      'sender': 'Emma',
      'message': 'L\'énigme de cette semaine a l\'air passionnante !',
      'time': '14:32',
      'isMe': false,
      'gender': 'F',
    },
    {
      'sender': 'Vous',
      'message': 'C\'est parti ! Que la meilleure équipe gagne ! 🚀',
      'time': '14:33',
      'isMe': true,
      'gender': 'M',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _countdownController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _countdownAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _countdownController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
    _pulseController.repeat(reverse: true);
    _startCountdown();
  }

  void _startCountdown() {
    _countdownController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  void _joinGroup(int groupId) {
    final group = _weeklyGroups.firstWhere((g) => g['id'] == groupId);
    if (group['members'].length < group['maxMembers']) {
      setState(() {
        _hasJoinedGroup = true;
        group['members'].add({
          'name': 'Vous',
          'gender': 'M', // ou 'F' selon le profil
          'level': 10,
          'isOnline': true,
        });
      });
      _showSuccess('🎉 Bienvenue dans ${group['name']} ! Prêt pour l\'aventure ?');
    }
  }

  void _startActivity(String activityId) {
    final activity = _weeklyActivities.firstWhere((a) => a['id'] == activityId);
    
    if (activity['requiresGroup'] && !_hasJoinedGroup) {
      _showError('Vous devez rejoindre un groupe pour cette activité !');
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => _buildActivityDialog(activity),
    );
  }

  void _completeActivity(Map<String, dynamic> activity) {
    widget.onCoinsUpdated(activity['reward']);
    setState(() {
      _weeklyPoints += activity['reward'] as int;
    });
    
    Navigator.pop(context);
    _showSuccess('🎊 Défi relevé ! +${activity['reward']} points hebdomadaires !');
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4B0082),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1F),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildCountdownCard(),
                  const SizedBox(height: 20),
                  if (!_hasJoinedGroup) ...[
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),
                    _buildGroupsSection(),
                  ] else ...[
                    _buildCurrentGroupCard(),
                    const SizedBox(height: 20),
                    _buildProgressCard(),
                    const SizedBox(height: 20),
                    _buildActivitiesSection(),
                    const SizedBox(height: 20),
                    _buildGroupChatSection(),
                  ],
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4B0082),
                Color(0xFF9370DB),
              ],
            ),
          ),
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📅 Bar Hebdomadaire',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Groupes de 4 • Défis hebdomadaires',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownCard() {
    final days = _timeRemaining ~/ 24;
    final hours = _timeRemaining % 24;
    
    return AnimatedBuilder(
      animation: _countdownAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1a1a1a), Color(0xFF2a2a2a)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF9370DB).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Text(
              '⏰ Fin de la session hebdomadaire',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCountdownUnit(days.toString(), 'Jours'),
                _buildCountdownUnit(hours.toString(), 'Heures'),
                _buildCountdownUnit('45', 'Min'),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF9370DB).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Session #23 • Thème: Aventure & Découverte',
                style: TextStyle(
                  color: Color(0xFF9370DB),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_countdownAnimation.value * 0.02),
          child: child,
        );
      },
    );
  }

  Widget _buildCountdownUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF9370DB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a1a1a), Color(0xFF2a2a2a)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4B0082).withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎭 Bienvenue au Bar Hebdomadaire !',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Chaque semaine, formez des groupes de 4 personnes (2 hommes, 2 femmes) pour relever des défis exclusifs ! Coopération, stratégie et créativité seront vos meilleurs atouts.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Text('⭐', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Récompenses spéciales et matchmaking temporaire !',
                style: TextStyle(
                  color: Color(0xFF9370DB),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👥 Groupes disponibles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ..._weeklyGroups.map((group) => _buildGroupCard(group)),
      ],
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    final bool canJoin = group['members'].length < group['maxMembers'];
    final bool isBalanced = _checkGenderBalance(group['members']);
    final Color themeColor = _getThemeColor(group['theme']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canJoin ? () => _joinGroup(group['id']) : null,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: canJoin 
                    ? themeColor.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group['name'],
                            style: TextStyle(
                              color: canJoin ? Colors.white : Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Créé il y a ${group['created']}',
                            style: TextStyle(
                              color: canJoin ? Colors.grey : Colors.grey.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getThemeLabel(group['theme']),
                            style: TextStyle(
                              color: themeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${group['members'].length}/${group['maxMembers']}',
                          style: TextStyle(
                            color: canJoin ? themeColor : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Progrès: ${group['challengeProgress']}%',
                      style: TextStyle(
                        color: canJoin ? const Color(0xFF9370DB) : Colors.grey.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Text('💰', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 5),
                    Text(
                      '${group['totalPoints']} pts',
                      style: TextStyle(
                        color: canJoin ? Colors.grey : Colors.grey.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Membres avec icônes de genre
                Wrap(
                  spacing: 10,
                  children: group['members'].map<Widget>((member) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: member['isOnline'] 
                            ? const Color(0xFF4B0082).withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            member['gender'] == 'M' ? '👨' : '👩',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${member['name']} (${member['level']})',
                            style: TextStyle(
                              color: member['isOnline'] 
                                  ? const Color(0xFF9370DB)
                                  : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          if (member['isOnline']) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
                if (!isBalanced && canJoin)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.balance, color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Équilibre de genre requis (2H/2F)',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (!canJoin)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.group, color: Colors.grey, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Groupe complet',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _checkGenderBalance(List<dynamic> members) {
    final males = members.where((m) => m['gender'] == 'M').length;
    final females = members.where((m) => m['gender'] == 'F').length;
    return (males <= 2 && females <= 2);
  }

  Color _getThemeColor(String theme) {
    switch (theme) {
      case 'adventure':
        return const Color(0xFF228B22);
      case 'strategy':
        return const Color(0xFF4169E1);
      case 'creativity':
        return const Color(0xFFFF6347);
      default:
        return const Color(0xFF9370DB);
    }
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'adventure':
        return 'Aventure';
      case 'strategy':
        return 'Stratégie';
      case 'creativity':
        return 'Créativité';
      default:
        return 'Général';
    }
  }

  Widget _buildCurrentGroupCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4B0082), Color(0xFF9370DB)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '👥 Les Explorateurs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.verified, color: Colors.white),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '🎯 Thème Aventure • 4/4 membres • 75% terminé',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.group, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Alice, Pierre, Emma, Vous',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a1a1a), Color(0xFF2a2a2a)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF9370DB).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Progrès du groupe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_weeklyPoints points cette semaine',
                      style: const TextStyle(
                        color: Color(0xFF9370DB),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Continuez pour débloquer les récompenses !',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎯 Activités hebdomadaires',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: _weeklyActivities.length,
          itemBuilder: (context, index) {
            return _buildActivityCard(_weeklyActivities[index]);
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final bool canParticipate = !activity['requiresGroup'] || _hasJoinedGroup;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canParticipate ? () => _startActivity(activity['id']) : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: canParticipate 
                  ? const Color(0xFF333333)
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                activity['icon'],
                style: TextStyle(
                  fontSize: 32,
                  color: canParticipate ? Colors.white : Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                activity['title'],
                style: TextStyle(
                  color: canParticipate ? Colors.white : Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF9370DB).withOpacity(canParticipate ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${activity['reward']} pts',
                  style: TextStyle(
                    color: canParticipate 
                        ? const Color(0xFF9370DB)
                        : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (activity['requiresGroup'] && !_hasJoinedGroup) ...[
                const SizedBox(height: 8),
                const Icon(
                  Icons.lock,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityDialog(Map<String, dynamic> activity) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2a2a2a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        activity['title'],
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity['description'],
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getActivityContent(activity['id']),
              style: const TextStyle(
                color: Color(0xFF9370DB),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Récompense : ${activity['reward']} points hebdomadaires',
                style: const TextStyle(
                  color: Color(0xFF9370DB),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Plus tard', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => _completeActivity(activity),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4B0082),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: const Text('Participer !'),
        ),
      ],
    );
  }

  String _getActivityContent(String activityId) {
    switch (activityId) {
      case 'team_challenge':
        return 'Défi de cette semaine : "Créez ensemble une histoire d\'aventure en 10 chapitres". Chaque membre contribue avec 2-3 chapitres !';
      case 'strategy_game':
        return 'Énigme stratégique : Vous êtes des explorateurs perdus sur une île mystérieuse. Comment organisez-vous la survie en équipe ?';
      case 'creative_session':
        return 'Session créative : Imaginez et décrivez votre destination de voyage idéale. Combinez vos idées pour créer le voyage parfait !';
      case 'discussion_circle':
        return 'Sujet de débat : "Quelle est la plus grande aventure que vous aimeriez vivre ?" Partagez vos rêves d\'exploration !';
      default:
        return 'Préparez-vous pour une expérience unique en équipe !';
    }
  }

  Widget _buildGroupChatSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '💬 Chat du groupe',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _groupChat.length,
              itemBuilder: (context, index) {
                return _buildChatMessage(_groupChat[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF333333), width: 1),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Collaborez avec votre équipe...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        borderSide: BorderSide(color: Color(0xFF9370DB)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () => _showSuccess('🎯 Message envoyé au groupe !'),
                  backgroundColor: const Color(0xFF4B0082),
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> message) {
    final isMe = message['isMe'];
    final gender = message['gender'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: gender == 'M' 
                  ? const Color(0xFF4169E1)
                  : const Color(0xFFE91E63),
              radius: 15,
              child: Text(
                gender == 'M' ? '👨' : '👩',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    message['sender'],
                    style: TextStyle(
                      color: gender == 'M' 
                          ? const Color(0xFF4169E1)
                          : const Color(0xFFE91E63),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? const Color(0xFF4B0082)
                        : const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    message['message'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message['time'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: const Color(0xFFE91E63),
              radius: 15,
              child: Text(
                message['sender'][0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}