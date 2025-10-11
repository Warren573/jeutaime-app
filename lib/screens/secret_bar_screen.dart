import 'package:flutter/material.dart';

class SecretBarScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const SecretBarScreen({
    super.key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  });

  @override
  State<SecretBarScreen> createState() => _SecretBarScreenState();
}

class _SecretBarScreenState extends State<SecretBarScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _mysteryController;
  late Animation<double> _mysteryAnimation;
  late AnimationController _unlockController;
  late Animation<double> _unlockAnimation;

  bool _hasAccess = false;
  int _riddlesSolved = 2; // Progression actuelle
  int _vipLevel = 1;
  int _secretPoints = 0;
  
  final List<Map<String, dynamic>> _mysteries = [
    {
      'id': 1,
      'title': '🔍 Le Premier Indice',
      'riddle': 'Je suis le début de tout, la fin de rien, présent dans chaque question mais absent des réponses.',
      'answer': 'le point d\'interrogation',
      'reward': 10,
      'isUnlocked': true,
      'isSolved': true,
      'difficulty': 'Novice',
    },
    {
      'id': 2,
      'title': '🗝️ La Clé du Mystère',
      'riddle': 'Plus on me partage, plus je grandis. Plus on me garde, plus je rapetisse. Que suis-je ?',
      'answer': 'le bonheur',
      'reward': 15,
      'isUnlocked': true,
      'isSolved': true,
      'difficulty': 'Apprenti',
    },
    {
      'id': 3,
      'title': '👁️ L\'Œil qui Voit Tout',
      'riddle': 'Je peux voir sans yeux, entendre sans oreilles, parler sans bouche. Je connais tous vos secrets.',
      'answer': 'l\'esprit',
      'reward': 25,
      'isUnlocked': true,
      'isSolved': false,
      'difficulty': 'Expert',
    },
    {
      'id': 4,
      'title': '🌟 Le Secret Ultime',
      'riddle': 'Je suis ce que vous cherchez en cherchant ce que vous ne cherchez pas.',
      'answer': 'l\'amour véritable',
      'reward': 50,
      'isUnlocked': false,
      'isSolved': false,
      'difficulty': 'Maître',
    },
  ];

  final List<Map<String, dynamic>> _vipMembers = [
    {
      'name': 'L\'Oracle',
      'level': 'Maître des Mystères',
      'achievements': 47,
      'isOnline': true,
      'lastSeen': 'maintenant',
      'speciality': 'Énigmes philosophiques',
    },
    {
      'name': 'Sphinx',
      'level': 'Gardien des Secrets',
      'achievements': 38,
      'isOnline': true,
      'lastSeen': 'maintenant',
      'speciality': 'Puzzles logiques',
    },
    {
      'name': 'Énigme',
      'level': 'Sage Mystique',
      'achievements': 29,
      'isOnline': false,
      'lastSeen': '2h',
      'speciality': 'Codes cachés',
    },
    {
      'name': 'Mystère',
      'level': 'Chasseur d\'Indices',
      'achievements': 15,
      'isOnline': true,
      'lastSeen': 'maintenant',
      'speciality': 'Déduction',
    },
  ];

  final List<Map<String, dynamic>> _vipActivities = [
    {
      'id': 'cipher_challenge',
      'title': '🔐 Défi de Chiffrement',
      'description': 'Décodez le message secret caché',
      'difficulty': 'Élite',
      'reward': 30,
      'icon': '🔤',
      'type': 'cipher',
      'vipRequired': 2,
    },
    {
      'id': 'philosophy_riddle',
      'title': '🧠 Énigme Philosophique',
      'description': 'Réfléchissez sur les mystères de l\'existence',
      'difficulty': 'Transcendant',
      'reward': 40,
      'icon': '🤔',
      'type': 'philosophy',
      'vipRequired': 3,
    },
    {
      'id': 'pattern_recognition',
      'title': '🔍 Reconnaissance de Motifs',
      'description': 'Trouvez le pattern caché dans le chaos',
      'difficulty': 'Génie',
      'reward': 35,
      'icon': '🧩',
      'type': 'pattern',
      'vipRequired': 1,
    },
    {
      'id': 'ancient_wisdom',
      'title': '📜 Sagesse Ancienne',
      'description': 'Interprétez les textes mystiques',
      'difficulty': 'Légendaire',
      'reward': 60,
      'icon': '📚',
      'type': 'wisdom',
      'vipRequired': 4,
    },
  ];

  final List<Map<String, dynamic>> _secretChat = [
    {
      'sender': 'L\'Oracle',
      'message': 'Un nouveau chercheur de vérité nous rejoint... 🔮',
      'time': '15:45',
      'isMe': false,
      'isVip': true,
    },
    {
      'sender': 'Sphinx',
      'message': 'La sagesse ne se révèle qu\'aux esprits préparés. Êtes-vous prêt ?',
      'time': '15:46',
      'isMe': false,
      'isVip': true,
    },
    {
      'sender': 'Mystère',
      'message': 'Chaque énigme résolue ouvre une nouvelle porte... 🚪',
      'time': '15:47',
      'isMe': false,
      'isVip': true,
    },
    {
      'sender': 'Vous',
      'message': 'Je suis prêt à percer tous les mystères ! ✨',
      'time': '15:48',
      'isMe': true,
      'isVip': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _mysteryController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _mysteryAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mysteryController, curve: Curves.easeInOut),
    );
    
    _unlockController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _unlockAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _unlockController, curve: Curves.elasticOut),
    );
    
    _animationController.forward();
    _mysteryController.repeat(reverse: true);
    
    // Vérifier si l'utilisateur a l'accès
    _checkAccess();
  }

  void _checkAccess() {
    // Logique pour vérifier l'accès (basée sur les énigmes résolues)
    if (_riddlesSolved >= 2) {
      setState(() {
        _hasAccess = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mysteryController.dispose();
    _unlockController.dispose();
    super.dispose();
  }

  void _solveRiddle(int riddleId) {
    final riddle = _mysteries.firstWhere((r) => r['id'] == riddleId);
    
    showDialog(
      context: context,
      builder: (context) => _buildRiddleDialog(riddle),
    );
  }

  void _completeRiddle(Map<String, dynamic> riddle) {
    widget.onCoinsUpdated(riddle['reward']);
    setState(() {
      riddle['isSolved'] = true;
      _secretPoints += riddle['reward'] as int;
      _riddlesSolved++;
      
      // Débloquer la prochaine énigme
      final nextRiddleIndex = _mysteries.indexWhere((r) => r['id'] == riddle['id']) + 1;
      if (nextRiddleIndex < _mysteries.length) {
        _mysteries[nextRiddleIndex]['isUnlocked'] = true;
      }
      
      // Augmenter le niveau VIP
      if (_riddlesSolved >= 4) _vipLevel = 4;
      else if (_riddlesSolved >= 3) _vipLevel = 3;
      else if (_riddlesSolved >= 2) _vipLevel = 2;
      
      _checkAccess();
    });
    
    _unlockController.forward().then((_) {
      _unlockController.reset();
    });
    
    Navigator.pop(context);
    _showSuccess('🌟 Mystère élucidé ! +${riddle['reward']} points secrets !');
  }

  void _startVipActivity(String activityId) {
    final activity = _vipActivities.firstWhere((a) => a['id'] == activityId);
    
    if (_vipLevel < activity['vipRequired']) {
      _showError('Niveau VIP ${activity['vipRequired']} requis !');
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => _buildActivityDialog(activity),
    );
  }

  void _completeVipActivity(Map<String, dynamic> activity) {
    widget.onCoinsUpdated(activity['reward']);
    setState(() {
      _secretPoints += activity['reward'] as int;
    });
    
    Navigator.pop(context);
    _showSuccess('💎 Défi VIP relevé ! +${activity['reward']} points secrets !');
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4A148C),
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
      backgroundColor: const Color(0xFF0A0A0A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (!_hasAccess) ...[
                    _buildAccessDeniedCard(),
                    const SizedBox(height: 20),
                    _buildRiddlesSection(),
                  ] else ...[
                    _buildWelcomeVipCard(),
                    const SizedBox(height: 20),
                    _buildVipStatusCard(),
                    const SizedBox(height: 20),
                    _buildVipMembersSection(),
                    const SizedBox(height: 20),
                    _buildVipActivitiesSection(),
                    const SizedBox(height: 20),
                    _buildSecretChatSection(),
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
                Color(0xFF1A1A2E),
                Color(0xFF4A148C),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '🤫 Bar Secret',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_hasAccess)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1BEE7),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'VIP $_vipLevel',
                            style: const TextStyle(
                              color: Color(0xFF4A148C),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _hasAccess 
                        ? 'Mystères & contenu exclusif VIP'
                        : 'Accès restreint • Résolvez les énigmes',
                    style: const TextStyle(
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

  Widget _buildAccessDeniedCard() {
    return AnimatedBuilder(
      animation: _mysteryAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_mysteryAnimation.value * 0.02),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1a1a1a), Color(0xFF2a2a2a)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF4A148C).withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A148C).withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '🔒',
                  style: TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Accès Restreint',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Le Bar Secret n\'ouvre ses portes qu\'aux esprits les plus brillants. Résolvez au moins 2 énigmes pour prouver votre sagesse.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A148C).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Progression actuelle',
                        style: TextStyle(
                          color: Color(0xFFE1BEE7),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_riddlesSolved',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            ' / 2',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 24,
                            ),
                          ),
                          const Text(
                            ' 🧩',
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRiddlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🧩 Énigmes à résoudre',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ..._mysteries.map((riddle) => _buildRiddleCard(riddle)),
      ],
    );
  }

  Widget _buildRiddleCard(Map<String, dynamic> riddle) {
    final bool isUnlocked = riddle['isUnlocked'];
    final bool isSolved = riddle['isSolved'];
    final Color difficultyColor = _getDifficultyColor(riddle['difficulty']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUnlocked && !isSolved ? () => _solveRiddle(riddle['id']) : null,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSolved 
                    ? Colors.green.withOpacity(0.5)
                    : isUnlocked 
                        ? difficultyColor.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isSolved ? '✅' : isUnlocked ? '🧩' : '🔒',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        riddle['title'],
                        style: TextStyle(
                          color: isSolved 
                              ? Colors.green
                              : isUnlocked 
                                  ? Colors.white
                                  : Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: difficultyColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        riddle['difficulty'],
                        style: TextStyle(
                          color: difficultyColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isUnlocked) ...[
                  const SizedBox(height: 15),
                  Text(
                    riddle['riddle'],
                    style: TextStyle(
                      color: isSolved ? Colors.grey : Colors.white70,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        '+${riddle['reward']} points secrets',
                        style: TextStyle(
                          color: isSolved ? Colors.grey : const Color(0xFFE1BEE7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (!isSolved && isUnlocked)
                        const Icon(
                          Icons.psychology,
                          color: Color(0xFF4A148C),
                          size: 20,
                        ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Résolvez les énigmes précédentes pour débloquer',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Novice':
        return const Color(0xFF4CAF50);
      case 'Apprenti':
        return const Color(0xFF2196F3);
      case 'Expert':
        return const Color(0xFFFF9800);
      case 'Maître':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  Widget _buildWelcomeVipCard() {
    return AnimatedBuilder(
      animation: _unlockAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_unlockAnimation.value * 0.05),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A148C).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '👑',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Bienvenue dans le Cercle Secret',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Votre sagesse vous a ouvert les portes du Bar Secret. Découvrez un monde de mystères exclusifs et de défis transcendants.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildVipStat('🧩', _riddlesSolved.toString(), 'Énigmes'),
                    _buildVipStat('⭐', _vipLevel.toString(), 'Niveau VIP'),
                    _buildVipStat('💎', _secretPoints.toString(), 'Points'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVipStat(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVipStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a1a1a), Color(0xFF2a2a2a)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF4A148C).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👑 Statut VIP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niveau VIP $_vipLevel • ${_getVipTitle(_vipLevel)}',
                      style: const TextStyle(
                        color: Color(0xFFE1BEE7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Accès aux mystères les plus profonds',
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

  String _getVipTitle(int level) {
    switch (level) {
      case 1:
        return 'Initié aux Mystères';
      case 2:
        return 'Gardien des Secrets';
      case 3:
        return 'Sage Mystique';
      case 4:
        return 'Maître des Énigmes';
      default:
        return 'Chercheur de Vérité';
    }
  }

  Widget _buildVipMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎭 Membres VIP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _vipMembers.length,
            itemBuilder: (context, index) {
              return _buildVipMemberCard(_vipMembers[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVipMemberCard(Map<String, dynamic> member) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF4A148C).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎭', style: TextStyle(fontSize: 20)),
              const Spacer(),
              if (member['isOnline'])
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            member['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            member['level'],
            style: const TextStyle(
              color: Color(0xFFE1BEE7),
              fontSize: 10,
            ),
          ),
          Text(
            '${member['achievements']} succès',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💎 Activités VIP Exclusives',
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
          itemCount: _vipActivities.length,
          itemBuilder: (context, index) {
            return _buildVipActivityCard(_vipActivities[index]);
          },
        ),
      ],
    );
  }

  Widget _buildVipActivityCard(Map<String, dynamic> activity) {
    final bool canAccess = _vipLevel >= activity['vipRequired'];
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canAccess ? () => _startVipActivity(activity['id']) : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: canAccess 
                  ? const Color(0xFF4A148C).withOpacity(0.5)
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
                  color: canAccess ? Colors.white : Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                activity['title'],
                style: TextStyle(
                  color: canAccess ? Colors.white : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A148C).withOpacity(canAccess ? 0.3 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'VIP ${activity['vipRequired']}',
                  style: TextStyle(
                    color: canAccess 
                        ? const Color(0xFFE1BEE7)
                        : Colors.grey,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '+${activity['reward']} 💎',
                style: TextStyle(
                  color: canAccess 
                      ? const Color(0xFFE1BEE7)
                      : Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!canAccess) ...[
                const SizedBox(height: 5),
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

  Widget _buildRiddleDialog(Map<String, dynamic> riddle) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2a2a2a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        riddle['title'],
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              riddle['riddle'],
              style: const TextStyle(
                color: Color(0xFFE1BEE7),
                fontSize: 16,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Réfléchissez bien... La réponse est en vous.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text('💎', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Récompense : ${riddle['reward']} points secrets',
                style: const TextStyle(
                  color: Color(0xFFE1BEE7),
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
          child: const Text('Méditer encore', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => _completeRiddle(riddle),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A148C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: const Text('J\'ai la réponse !'),
        ),
      ],
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
              _getVipActivityContent(activity['id']),
              style: const TextStyle(
                color: Color(0xFFE1BEE7),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('💎', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Récompense VIP : ${activity['reward']} points secrets',
                style: const TextStyle(
                  color: Color(0xFFE1BEE7),
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
          child: const Text('Pas maintenant', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => _completeVipActivity(activity),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A148C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: const Text('Relever le défi !'),
        ),
      ],
    );
  }

  String _getVipActivityContent(String activityId) {
    switch (activityId) {
      case 'cipher_challenge':
        return 'DJHR FRQVHLOH : OD YLH HVWIL WURS FRXUWH SRXU FKDUFER Q GDQV OHV FKRVHV VXSHUILFLHOOHV';
      case 'philosophy_riddle':
        return 'Si l\'amour véritable transcende les apparences, quelle est la nature de l\'attraction authentique ?';
      case 'pattern_recognition':
        return 'Dans cette séquence, trouvez le motif : ♥ ♦ ♠ ♣ ♥♦ ♠♣ ♥♦♠ ?';
      case 'ancient_wisdom':
        return '"L\'œil ne voit que ce que l\'esprit est prêt à comprendre." - Robertson Davies. Méditez sur cette sagesse.';
      default:
        return 'Un défi digne des plus grands esprits vous attend...';
    }
  }

  Widget _buildSecretChatSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4A148C).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '🔮 Cercle des Sages',
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
              itemCount: _secretChat.length,
              itemBuilder: (context, index) {
                return _buildSecretChatMessage(_secretChat[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF4A148C), width: 1),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Partagez votre sagesse...',
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
                        borderSide: BorderSide(color: Color(0xFF4A148C)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () => _showSuccess('🔮 Votre sagesse a été partagée !'),
                  backgroundColor: const Color(0xFF4A148C),
                  mini: true,
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecretChatMessage(Map<String, dynamic> message) {
    final isMe = message['isMe'];
    final isVip = message['isVip'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: isVip 
                  ? const Color(0xFF4A148C)
                  : const Color(0xFF7B1FA2),
              radius: 15,
              child: Text(
                isVip ? '🎭' : '🔮',
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message['sender'],
                        style: TextStyle(
                          color: isVip 
                              ? const Color(0xFF4A148C)
                              : const Color(0xFFE1BEE7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isVip) ...[
                        const SizedBox(width: 5),
                        const Text('👑', style: TextStyle(fontSize: 10)),
                      ],
                    ],
                  ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? const Color(0xFF4A148C)
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