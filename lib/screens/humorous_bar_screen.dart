import 'package:flutter/material.dart';

class HumorousBarScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const HumorousBarScreen({
    super.key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  });

  @override
  State<HumorousBarScreen> createState() => _HumorousBarScreenState();
}

class _HumorousBarScreenState extends State<HumorousBarScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _hasJoinedGroup = false;
  String _selectedActivity = '';
  
  final List<Map<String, dynamic>> _groups = [
    {
      'id': 1,
      'name': 'Les Rigolots',
      'members': ['Alex', 'Marie', 'Tom'],
      'theme': 'Jeux de mots',
      'maxMembers': 4,
      'isActive': true,
    },
    {
      'id': 2,
      'name': 'Stand-Up Club',
      'members': ['Julie', 'Marc'],
      'theme': 'Histoires drôles',
      'maxMembers': 4,
      'isActive': true,
    },
    {
      'id': 3,
      'name': 'Mime & Cie',
      'members': ['Emma', 'Paul', 'Lisa', 'Max'],
      'theme': 'Mime et gestuelles',
      'maxMembers': 4,
      'isActive': false,
    },
  ];

  final List<Map<String, dynamic>> _activities = [
    {
      'id': 'joke',
      'title': '😂 Raconter une blague',
      'description': 'Partagez votre meilleure blague avec le groupe !',
      'reward': 2,
      'icon': '🎭',
    },
    {
      'id': 'pun',
      'title': '🤹 Jeu de mots',
      'description': 'Créez un calembour à partir d\'un mot donné',
      'reward': 1,
      'icon': '💭',
    },
    {
      'id': 'mime',
      'title': '🎪 Mime challenge',
      'description': 'Décrivez quelque chose par gestes (vidéo courte)',
      'reward': 3,
      'icon': '🤸',
    },
    {
      'id': 'story',
      'title': '📚 Histoire en groupe',
      'description': 'Continuez l\'histoire commencée par les autres',
      'reward': 2,
      'icon': '✍️',
    },
  ];

  final List<Map<String, dynamic>> _chatMessages = [
    {
      'sender': 'Alex',
      'message': 'Pourquoi les plongeurs plongent-ils toujours en arrière ? 🤔',
      'time': '14:23',
      'isMe': false,
    },
    {
      'sender': 'Marie',
      'message': 'Parce que sinon... ils tombent dans le bateau ! 😂',
      'time': '14:24',
      'isMe': false,
    },
    {
      'sender': 'Tom',
      'message': 'Excellent ! 👏 Mon tour : Que dit un escargot quand il croise une limace ?',
      'time': '14:25',
      'isMe': false,
    },
    {
      'sender': 'Vous',
      'message': 'Aucune idée... 🤷‍♀️',
      'time': '14:26',
      'isMe': true,
    },
    {
      'sender': 'Tom',
      'message': '"Regarde, un nudiste !" 🐌😂',
      'time': '14:26',
      'isMe': false,
    },
  ];

  final List<String> _jokePrompts = [
    'Racontez une blague sur les animaux',
    'Partagez un jeu de mots avec "chat"',
    'Mimez "faire du shopping"',
    'Continuez : "Il était une fois un pingouin qui..."',
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _joinGroup(int groupId) {
    setState(() {
      _hasJoinedGroup = true;
    });
    _showSuccess('🎉 Vous avez rejoint le groupe ! Préparez-vous à rire !');
  }

  void _startActivity(String activityId) {
    final activity = _activities.firstWhere((a) => a['id'] == activityId);
    setState(() {
      _selectedActivity = activityId;
    });
    
    showDialog(
      context: context,
      builder: (context) => _buildActivityDialog(activity),
    );
  }

  void _completeActivity(Map<String, dynamic> activity) {
    widget.onCoinsUpdated(activity['reward']);
    Navigator.pop(context);
    _showSuccess('🎭 Activité terminée ! +${activity['reward']} coins');
    
    setState(() {
      _selectedActivity = '';
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B35),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (!_hasJoinedGroup) ...[
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),
                    _buildGroupsSection(),
                  ] else ...[
                    _buildCurrentGroupCard(),
                    const SizedBox(height: 20),
                    _buildActivitiesSection(),
                    const SizedBox(height: 20),
                    _buildChatSection(),
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
                Color(0xFFFF6B35),
                Color(0xFFF7931E),
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
                    '😄 Bar Humoristique',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Rires garantis et bonne humeur !',
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
          colors: [Color(0xFF1e1e1e), Color(0xFF2a2a2a)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎭 Bienvenue dans le Bar Humoristique !',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Ici, on partage les rires et la bonne humeur ! Rejoignez un groupe pour participer aux activités comiques : blagues, jeux de mots, mime, et histoires drôles en groupe.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text(
                'Gagnez des coins en faisant rire les autres !',
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

  Widget _buildGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎪 Groupes disponibles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ..._groups.map((group) => _buildGroupCard(group)),
      ],
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    final bool canJoin = group['members'].length < group['maxMembers'];
    
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
              color: const Color(0xFF1e1e1e),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: canJoin 
                    ? const Color(0xFFFF6B35).withOpacity(0.5)
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group['name'],
                        style: TextStyle(
                          color: canJoin ? Colors.white : Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: canJoin 
                            ? const Color(0xFFFF6B35).withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${group['members'].length}/${group['maxMembers']}',
                        style: TextStyle(
                          color: canJoin ? const Color(0xFFFF6B35) : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '🎯 Thème : ${group['theme']}',
                  style: TextStyle(
                    color: canJoin ? Colors.grey : Colors.grey.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        group['members'].join(', '),
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
                        color: Color(0xFFFF6B35),
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

  Widget _buildCurrentGroupCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🎭 Les Rigolots',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Icon(Icons.check_circle, color: Colors.white),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Thème : Jeux de mots • 4 membres actifs',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.people, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Alex, Marie, Tom, Vous',
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

  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎪 Activités disponibles',
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
            childAspectRatio: 1.1,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: _activities.length,
          itemBuilder: (context, index) {
            return _buildActivityCard(_activities[index]);
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _startActivity(activity['id']),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF1e1e1e),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                activity['icon'],
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 10),
              Text(
                activity['title'],
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
                  color: const Color(0xFFFF6B35).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${activity['reward']} 💎',
                  style: const TextStyle(
                    color: Color(0xFFFF6B35),
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
              color: const Color(0xFF1e1e1e),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getActivityPrompt(activity['id']),
              style: const TextStyle(
                color: Color(0xFFFF6B35),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 20),
              const SizedBox(width: 8),
              Text(
                'Récompense : ${activity['reward']} coins',
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
          child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => _completeActivity(activity),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: const Text('Participer !'),
        ),
      ],
    );
  }

  String _getActivityPrompt(String activityId) {
    final prompts = {
      'joke': _jokePrompts[0],
      'pun': _jokePrompts[1],
      'mime': _jokePrompts[2],
      'story': _jokePrompts[3],
    };
    return prompts[activityId] ?? 'Faites de votre mieux !';
  }

  Widget _buildChatSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
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
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                return _buildChatMessage(_chatMessages[index]);
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
                      hintText: 'Écrivez quelque chose de drôle...',
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
                        borderSide: BorderSide(color: Color(0xFFFF6B35)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () => _showSuccess('😂 Message envoyé !'),
                  backgroundColor: const Color(0xFFFF6B35),
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFFFF6B35),
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
                  Text(
                    message['sender'],
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? const Color(0xFFFF6B35)
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