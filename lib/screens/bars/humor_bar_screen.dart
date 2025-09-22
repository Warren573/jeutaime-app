import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/user_card.dart';
import '../../models/user_model.dart';
import '../../services/bar_service.dart';
// Tu peux ajouter ici l'import de l'écran des défis humoristiques et de la boîte à souvenirs

class HumorBarScreen extends StatefulWidget {
  @override
  _HumorBarScreenState createState() => _HumorBarScreenState();
}

class _HumorBarScreenState extends State<HumorBarScreen> with TickerProviderStateMixin {
  late AnimationController _laughController;
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _laughController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _loadUsers();
  }

  @override
  void dispose() {
    _laughController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await BarService.getUsersInBar('humor', filter: _selectedFilter);
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _laughController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _laughController.value * 0.5,
                  child: Icon(Icons.emoji_emotions, color: AppColors.humorBar),
                );
              },
            ),
            SizedBox(width: 8),
            Text(
              'Bar Humoristique',
              style: TextStyle(
                color: AppColors.humorBar,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.auto_awesome, color: AppColors.humorBar),
            tooltip: 'Défis drôles',
            onPressed: () {
              // Navigue vers l'écran des défis humoristiques
              // Navigator.push(context, MaterialPageRoute(builder: (context) => HumorChallengeScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.archive, color: AppColors.humorBar),
            tooltip: 'Boîte à souvenirs',
            onPressed: () {
              // Navigue vers la boîte à souvenirs
              // Navigator.pushNamed(context, '/memory_box');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 100),
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.93),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.12),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '😂 Ambiance Humoristique 😂',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.humorBar,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ici, tout est prétexte à rire ! Trouve des profils qui partagent ton sens de l’humour, lance un défi ou envoie une blague.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBarStat('🤣', '${_users.length}', 'Connectés'),
                      _buildBarStat('🎤', '21', 'Défis lancés'),
                      _buildBarStat('⭐', '4.9', 'Satisfaction'),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('all', 'Tous'),
                  _buildFilterChip('dad_joke', 'Blagues de papa'),
                  _buildFilterChip('sarcasm', 'Sarcastiques'),
                  _buildFilterChip('absurd', 'Absurde'),
                  _buildFilterChip('dark', 'Humour noir'),
                  _buildFilterChip('wordplay', 'Jeux de mots'),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.humorBar),
                          SizedBox(height: 16),
                          Text(
                            'Recherche de comiques...',
                            style: TextStyle(
                              color: AppColors.humorBar,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    )
                  : _users.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: UserCard(
                                user: _users[index],
                                barTheme: 'humor',
                                onLike: () {
                                  // logique de like humoristique
                                },
                                onMessage: () {
                                  // logique d'envoi de blague/lettre
                                },
                                onViewProfile: () {
                                  // logique de vue profil
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigue vers l'écran des défis humoristiques
          // Navigator.push(context, MaterialPageRoute(builder: (context) => HumorChallengeScreen()));
        },
        backgroundColor: AppColors.humorBar,
        icon: Icon(Icons.emoji_events, color: Colors.white),
        label: Text(
          'Défis Drôles',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBarStat(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: 20)),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.humorBar,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    bool isSelected = _selectedFilter == value;
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = value);
          _loadUsers();
        },
        selectedColor: AppColors.humorBar.withOpacity(0.3),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.humorBar : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_emotions_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Personne n’a lancé de vanne…',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Reviens plus tard ou tente un défi humoristique !',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadUsers,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.humorBar,
            ),
            child: Text('Actualiser', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
