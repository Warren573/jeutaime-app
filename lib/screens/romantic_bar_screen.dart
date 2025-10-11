import 'package:flutter/material.dart';
import 'continue_histoire_screen.dart';

class RomanticBarScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const RomanticBarScreen({
    super.key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  });

  @override
  State<RomanticBarScreen> createState() => _RomanticBarScreenState();
}

class _RomanticBarScreenState extends State<RomanticBarScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _members = [
    {'name': 'Emma', 'age': 29, 'avatar': 'E', 'status': '💕 Active'},
    {'name': 'Julien', 'age': 32, 'avatar': 'J', 'status': '🌹 En ligne'},
    {'name': 'Sophie', 'age': 27, 'avatar': 'S', 'status': '✨ Disponible'},
  ];

  final List<Map<String, dynamic>> _activities = [
    {
      'icon': '💝',
      'title': 'Compliments Sincères',
      'description': 'Envoyez un compliment authentique',
      'reward': 25,
      'color': Colors.pink,
    },
    {
      'icon': '📝',
      'title': 'Poème Express',
      'description': 'Composez un haïku romantique',
      'reward': 40,
      'color': Colors.purple,
    },
    {
      'icon': '🌟',
      'title': 'Plus Beau Souvenir',
      'description': 'Partagez un souvenir romantique',
      'reward': 35,
      'color': Colors.amber,
    },
    {
      'icon': '💭',
      'title': 'Citation Préférée',
      'description': 'Une citation qui vous touche',
      'reward': 30,
      'color': Colors.indigo,
    },
    {
      'icon': '🎭',
      'title': 'Continue l\'Histoire',
      'description': 'Créez ensemble une histoire romantique',
      'reward': 35,
      'color': Colors.purple,
      'special': 'story_game',
    },
  ];

  final List<Map<String, dynamic>> _chatMessages = [
    {
      'author': '🌸 Emma',
      'message': '"L\'amour c\'est comme un livre, certains préfèrent les nouvelles, d\'autres les romans..." 📚💕',
      'time': 'Il y a 3 min',
      'color': Colors.pink,
    },
    {
      'author': '🎭 Julien',
      'message': 'Cette ambiance jazz est parfaite ! Quelqu\'un connaît du Chet Baker ? 🎺',
      'time': 'Il y a 5 min',
      'color': Colors.blue,
    },
    {
      'author': '🌺 Sophie',
      'message': 'Bonsoir tout le monde ! Belle soirée pour un peu de poésie... ✨',
      'time': 'Il y a 8 min',
      'color': Colors.purple,
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _joinGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('🌹 Rejoindre le groupe', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Groupe "Poésie & Émotions"',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '3/4 membres • Place libre disponible',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 15),
            Text(
              'Rejoignez ce groupe pour partager des moments romantiques et créer des liens authentiques.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('🌹 Vous avez rejoint le groupe "Poésie & Émotions" !');
            },
            child: const Text('Rejoindre', style: TextStyle(color: Color(0xFFE91E63))),
          ),
        ],
      ),
    );
  }

  void _doActivity(Map<String, dynamic> activity) {
    // Cas spécial pour le jeu "Continue l'Histoire"
    if (activity['special'] == 'story_game') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContinueHistoireScreen(
            playersCount: 2,
            isBarMode: false,
            opponentName: 'Votre partenaire romantique',
            onCoinsUpdated: widget.onCoinsUpdated,
            currentCoins: widget.currentCoins,
          ),
        ),
      );
      return;
    }

    // Activités normales
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: Text(
          '${activity['icon']} ${activity['title']}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              activity['description'],
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              'Récompense : +${activity['reward']} 🪙',
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCoinsUpdated(activity['reward']);
              _showSuccessMessage(
                '✅ Activité terminée !\n\n+${activity['reward']} pièces gagnées'
              );
            },
            child: const Text('Participer', style: TextStyle(color: Color(0xFFE91E63))),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGroupCard(),
                      const SizedBox(height: 25),
                      _buildActivitiesSection(),
                      const SizedBox(height: 25),
                      _buildChatSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a1a1a), Color(0xFF2a2a2a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFE91E63), width: 2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text('🌹', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bar Romantique',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Ambiance tamisée • Discussions profondes',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👥 Groupe "Poésie & Émotions"',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            '3/4 membres • Une place libre vous attend',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          // Members grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 2.5,
            ),
            itemCount: _members.length + 1, // +1 for empty slot
            itemBuilder: (context, index) {
              if (index < _members.length) {
                final member = _members[index];
                return _buildMemberCard(member);
              } else {
                return _buildEmptySlotCard();
              }
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _joinGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                '🌹 Rejoindre ce groupe',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member['avatar'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${member['name']}, ${member['age']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  member['status'],
                  style: const TextStyle(color: Colors.green, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlotCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE91E63).withOpacity(0.5),
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xFFE91E63), size: 24),
            SizedBox(height: 5),
            Text(
              'Place libre',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💕 Activités Romantiques',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2,
          ),
          itemCount: _activities.length,
          itemBuilder: (context, index) {
            final activity = _activities[index];
            return _buildActivityCard(activity);
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return InkWell(
      onTap: () => _doActivity(activity),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE91E63).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: activity['color'].withOpacity(0.3), width: 2),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(activity['icon'], style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              activity['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              '+${activity['reward']} 🪙',
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💬 Discussion générale',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: _chatMessages
                .map((message) => _buildChatMessage(message))
                .toList(),
          ),
        ),
        const SizedBox(height: 15),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.only(bottom: 15),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message['author'],
            style: TextStyle(
              color: message['color'],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message['message'],
            style: const TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 5),
          Text(
            message['time'],
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Partagez vos pensées romantiques...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _showSuccessMessage('💕 Message envoyé dans le bar romantique !');
            },
            icon: const Icon(Icons.send, color: Color(0xFFE91E63)),
          ),
        ],
      ),
    );
  }
}