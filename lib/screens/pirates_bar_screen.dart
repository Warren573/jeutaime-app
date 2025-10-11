import 'package:flutter/material.dart';

class PiratesBarScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const PiratesBarScreen({
    super.key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  });

  @override
  State<PiratesBarScreen> createState() => _PiratesBarScreenState();
}

class _PiratesBarScreenState extends State<PiratesBarScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _treasureController;
  late Animation<double> _treasureAnimation;

  bool _hasJoinedCrew = false;
  String _selectedQuest = '';
  int _treasurePoints = 0;
  
  final List<Map<String, dynamic>> _crews = [
    {
      'id': 1,
      'name': 'Les Corsaires',
      'captain': 'Capitaine Jack',
      'members': ['Emma', 'Tom', 'Lisa'],
      'ship': '🚢 Black Pearl',
      'maxMembers': 5,
      'level': 'Capitaine',
      'treasureFound': 12,
    },
    {
      'id': 2,
      'name': 'Barbe Rouge',
      'captain': 'Anne Bonny',
      'members': ['Marc', 'Julie'],
      'ship': '⛵ Revenge Queen',
      'maxMembers': 4,
      'level': 'Matelot',
      'treasureFound': 8,
    },
    {
      'id': 3,
      'name': 'Moussaillons',
      'captain': 'Marin Débutant',
      'members': ['Alex'],
      'ship': '🛶 Petit Navire',
      'maxMembers': 3,
      'level': 'Apprenti',
      'treasureFound': 3,
    },
  ];

  final List<Map<String, dynamic>> _quests = [
    {
      'id': 'riddle',
      'title': '🗝️ Énigme du Trésor',
      'description': 'Résolvez l\'énigme pour découvrir l\'emplacement du trésor',
      'difficulty': 'Facile',
      'reward': 3,
      'icon': '🧩',
      'type': 'puzzle',
    },
    {
      'id': 'story',
      'title': '📜 Récit d\'Aventure',
      'description': 'Racontez votre plus grande aventure maritime',
      'difficulty': 'Moyen',
      'reward': 2,
      'icon': '⚓',
      'type': 'story',
    },
    {
      'id': 'challenge',
      'title': '⚔️ Défi du Capitaine',
      'description': 'Relevez le défi proposé par le capitaine',
      'difficulty': 'Difficile',
      'reward': 5,
      'icon': '🏴‍☠️',
      'type': 'challenge',
    },
    {
      'id': 'treasure',
      'title': '💰 Chasse au Trésor',
      'description': 'Participez à la chasse au trésor en groupe',
      'difficulty': 'Épique',
      'reward': 8,
      'icon': '🗺️',
      'type': 'group',
    },
  ];

  final List<Map<String, dynamic>> _crewChat = [
    {
      'sender': 'Capitaine Jack',
      'message': 'Ahoy moussaillons ! Prêts pour l\'aventure ? ⚓',
      'time': '15:30',
      'isMe': false,
      'isCaptain': true,
    },
    {
      'sender': 'Emma',
      'message': 'Oui Capitaine ! 🏴‍☠️ Où nous menez-vous cette fois ?',
      'time': '15:31',
      'isMe': false,
      'isCaptain': false,
    },
    {
      'sender': 'Tom',
      'message': 'J\'ai entendu parler d\'un trésor sur l\'île mystérieuse... 🗝️',
      'time': '15:32',
      'isMe': false,
      'isCaptain': false,
    },
    {
      'sender': 'Vous',
      'message': 'Prêt à partir à l\'aventure ! 🗺️',
      'time': '15:33',
      'isMe': true,
      'isCaptain': false,
    },
  ];

  final List<String> _treasureRiddles = [
    'Je suis invisible mais toujours présent, je guide les navires par tous les temps. Qui suis-je ?',
    'Plus je suis proche, plus je suis loin. Plus tu me poursuis, plus je m\'éloigne. Qui suis-je ?',
    'Je n\'ai ni début ni fin, mais je délimite tout. Les pirates me suivent sans jamais me voir. Qui suis-je ?',
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
    
    _treasureController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _treasureAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _treasureController, curve: Curves.elasticOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _treasureController.dispose();
    super.dispose();
  }

  void _joinCrew(int crewId) {
    setState(() {
      _hasJoinedCrew = true;
    });
    _showSuccess('🏴‍☠️ Bienvenue à bord moussaillon ! Prêt pour l\'aventure ?');
  }

  void _startQuest(String questId) {
    final quest = _quests.firstWhere((q) => q['id'] == questId);
    setState(() {
      _selectedQuest = questId;
    });
    
    showDialog(
      context: context,
      builder: (context) => _buildQuestDialog(quest),
    );
  }

  void _completeQuest(Map<String, dynamic> quest) {
    widget.onCoinsUpdated(quest['reward']);
    setState(() {
      _treasurePoints += quest['reward'] as int;
    });
    
    _treasureController.forward().then((_) {
      _treasureController.reset();
    });
    
    Navigator.pop(context);
    _showSuccess('⚓ Quête terminée ! +${quest['reward']} coins de trésor !');
    
    setState(() {
      _selectedQuest = '';
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF8B4513),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (!_hasJoinedCrew) ...[
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),
                    _buildCrewsSection(),
                  ] else ...[
                    _buildCurrentCrewCard(),
                    const SizedBox(height: 20),
                    _buildTreasureStats(),
                    const SizedBox(height: 20),
                    _buildQuestsSection(),
                    const SizedBox(height: 20),
                    _buildCrewChatSection(),
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
                Color(0xFF2F4F4F),
                Color(0xFF708090),
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
                    '🏴‍☠️ Bar des Pirates',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Aventures et chasses au trésor !',
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

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a1a1a), Color(0xFF2a2a2a)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B4513).withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚓ Ahoy ! Bienvenue au Bar des Pirates !',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Embarquez pour des aventures épiques ! Rejoignez un équipage de pirates pour participer aux quêtes : énigmes de trésors, récits d\'aventures, défis du capitaine et chasses au trésor en groupe.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Text('💰', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Plus vous participez, plus votre trésor grandit !',
                style: TextStyle(
                  color: Color(0xFFFFD700),
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

  Widget _buildCrewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏴‍☠️ Équipages disponibles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ..._crews.map((crew) => _buildCrewCard(crew)),
      ],
    );
  }

  Widget _buildCrewCard(Map<String, dynamic> crew) {
    final bool canJoin = crew['members'].length < crew['maxMembers'];
    final Color levelColor = _getLevelColor(crew['level']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canJoin ? () => _joinCrew(crew['id']) : null,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: canJoin 
                    ? const Color(0xFF8B4513).withOpacity(0.5)
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
                            crew['name'],
                            style: TextStyle(
                              color: canJoin ? Colors.white : Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            crew['ship'],
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
                            color: levelColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            crew['level'],
                            style: TextStyle(
                              color: levelColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${crew['members'].length}/${crew['maxMembers']}',
                          style: TextStyle(
                            color: canJoin ? const Color(0xFF8B4513) : Colors.grey,
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
                    const Icon(Icons.person, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Capitaine ${crew['captain']}',
                      style: TextStyle(
                        color: canJoin ? const Color(0xFFFFD700) : Colors.grey.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      '${crew['treasureFound']} trésors trouvés',
                      style: TextStyle(
                        color: canJoin ? Colors.grey : Colors.grey.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.group, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        crew['members'].join(', '),
                        style: TextStyle(
                          color: canJoin ? Colors.grey : Colors.grey.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (canJoin)
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF8B4513),
                        size: 16,
                      ),
                  ],
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
                        Icon(Icons.lock, color: Colors.grey, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Équipage complet',
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

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Capitaine':
        return const Color(0xFFFFD700);
      case 'Matelot':
        return const Color(0xFF87CEEB);
      case 'Apprenti':
        return const Color(0xFF90EE90);
      default:
        return Colors.grey;
    }
  }

  Widget _buildCurrentCrewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B4513), Color(0xFFCD853F)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🏴‍☠️ Les Corsaires',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Icon(Icons.anchor, color: Colors.white),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '🚢 Black Pearl • Niveau Capitaine',
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
                'Capitaine Jack, Emma, Tom, Lisa, Vous',
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
    );
  }

  Widget _buildTreasureStats() {
    return AnimatedBuilder(
      animation: _treasureAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_treasureAnimation.value * 0.1),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1a1a1a), Color(0xFF2a2a2a)],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('💰', style: TextStyle(fontSize: 48)),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Votre Trésor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$_treasurePoints points de trésor',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Continuez les quêtes pour enrichir votre butin !',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
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

  Widget _buildQuestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🗺️ Quêtes disponibles',
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
          itemCount: _quests.length,
          itemBuilder: (context, index) {
            return _buildQuestCard(_quests[index]);
          },
        ),
      ],
    );
  }

  Widget _buildQuestCard(Map<String, dynamic> quest) {
    final Color difficultyColor = _getDifficultyColor(quest['difficulty']);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _startQuest(quest['id']),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                quest['icon'],
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 10),
              Text(
                quest['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  quest['difficulty'],
                  style: TextStyle(
                    color: difficultyColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${quest['reward']} 💰',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Facile':
        return const Color(0xFF90EE90);
      case 'Moyen':
        return const Color(0xFFFFD700);
      case 'Difficile':
        return const Color(0xFFFF6347);
      case 'Épique':
        return const Color(0xFF9370DB);
      default:
        return Colors.grey;
    }
  }

  Widget _buildQuestDialog(Map<String, dynamic> quest) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2a2a2a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        quest['title'],
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quest['description'],
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getQuestContent(quest['id']),
                  style: const TextStyle(
                    color: Color(0xFF8B4513),
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (quest['id'] == 'riddle') ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Réponse : L\'horizon !',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                _getDifficultyColor(quest['difficulty']) == const Color(0xFF9370DB) ? '🏆' : '💰',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'Récompense : ${quest['reward']} points de trésor',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
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
          child: const Text('Abandonner', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => _completeQuest(quest),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B4513),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: const Text('Accepter la quête !'),
        ),
      ],
    );
  }

  String _getQuestContent(String questId) {
    switch (questId) {
      case 'riddle':
        return _treasureRiddles.first;
      case 'story':
        return 'Racontez-nous votre plus grande aventure en mer. Qu\'avez-vous découvert lors de votre dernière expédition ?';
      case 'challenge':
        return 'Défi du jour : Créez un plan pour retrouver un trésor perdu sur une île déserte. Soyez créatif !';
      case 'treasure':
        return 'Quête en groupe : Suivez les indices avec votre équipage pour découvrir l\'emplacement du grand trésor !';
      default:
        return 'Préparez-vous pour l\'aventure !';
    }
  }

  Widget _buildCrewChatSection() {
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
              '💬 Chat de l\'équipage',
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
              itemCount: _crewChat.length,
              itemBuilder: (context, index) {
                return _buildChatMessage(_crewChat[index]);
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
                      hintText: 'Partagez vos aventures...',
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
                        borderSide: BorderSide(color: Color(0xFF8B4513)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () => _showSuccess('⚓ Message envoyé à l\'équipage !'),
                  backgroundColor: const Color(0xFF8B4513),
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
    final isCaptain = message['isCaptain'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: isCaptain 
                  ? const Color(0xFFFFD700)
                  : const Color(0xFF8B4513),
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
                          color: isCaptain 
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF8B4513),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isCaptain) ...[
                        const SizedBox(width: 5),
                        const Text('👑', style: TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? const Color(0xFF8B4513)
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