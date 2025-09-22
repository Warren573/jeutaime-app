import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/user_card.dart';
import '../../models/user_model.dart';
import '../../services/bar_service.dart';
import '../quiz/compatibility_quiz_screen.dart';
import '../messages/letter_composer_screen.dart';

class RomanticBarScreen extends StatefulWidget {
  @override
  _RomanticBarScreenState createState() => _RomanticBarScreenState();
}

class _RomanticBarScreenState extends State<RomanticBarScreen> with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _backgroundController;
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _backgroundController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _loadUsers();
  }

  @override
  void dispose() {
    _heartController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await BarService.getUsersInBar('romantic');
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
              animation: _heartController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_heartController.value * 0.2),
                  child: Icon(Icons.favorite, color: AppColors.romanticBar),
                );
              },
            ),
            SizedBox(width: 8),
            Text(
              'Bar Romantique',
              style: TextStyle(
                color: AppColors.romanticBar,
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
            icon: Icon(Icons.quiz, color: AppColors.romanticBar),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CompatibilityQuizScreen()),
            ),
            tooltip: 'Quiz de compatibilité',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.withOpacity(0.1),
              Colors.red.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 100), // Space for AppBar
            
            // Description du bar
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.2),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '💕 Ambiance Romantique 💕',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.romanticBar,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ici, les âmes sensibles se rencontrent. Découvrez des profils authentiques qui cherchent des connexions profondes et sincères.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  
                  // Statistiques du bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBarStat('💑', '${_users.length}', 'Connectés'),
                      _buildBarStat('💌', '47', 'Lettres envoyées'),
                      _buildBarStat('⭐', '4.8', 'Satisfaction'),
                    ],
                  ),
                ],
              ),
            ),
            
            // Filtres
            Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('all', 'Tous'),
                  _buildFilterChip('poetry', 'Poètes'),
                  _buildFilterChip('music', 'Musiciens'),
                  _buildFilterChip('sunset', 'Couchers de soleil'),
                  _buildFilterChip('books', 'Lecteurs'),
                ],
              ),
            ),
            
            SizedBox(height: 10),
            
            // Liste des utilisateurs
            Expanded(
              child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.romanticBar),
                        SizedBox(height: 16),
                        Text(
                          'Recherche d\'âmes sœurs...',
                          style: TextStyle(
                            color: AppColors.romanticBar,
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
                            barTheme: 'romantic',
                            onLike: () => _handleLike(_users[index]),
                            onMessage: () => _sendLetter(_users[index]),
                            onViewProfile: () => _viewProfile(_users[index]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      
      // Bouton action flottant
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CompatibilityQuizScreen()),
        ),
        backgroundColor: AppColors.romanticBar,
        icon: Icon(Icons.psychology, color: Colors.white),
        label: Text(
          'Quiz Compatibilité',
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
            color: AppColors.romanticBar,
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
          _loadUsers(); // Recharger avec le filtre
        },
        selectedColor: AppColors.romanticBar.withOpacity(0.3),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.romanticBar : Colors.grey[700],
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
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Aucune âme sœur pour le moment',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Revenez plus tard ou ajustez vos filtres',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadUsers,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.romanticBar,
            ),
            child: Text('Actualiser', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleLike(UserModel user) {
    // Logic pour liker un utilisateur
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('💕 Crush !'),
        content: Text('Vous avez craqué pour ${user.name} ! Une notification lui a été envoyée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.romanticBar)),
          ),
        ],
      ),
    );
  }

  void _sendLetter(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LetterComposerScreen(recipient: user),
      ),
    );
  }

  void _viewProfile(UserModel user) {
    // Navigation vers le profil détaillé
    // Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(user: user)));
  }
}
