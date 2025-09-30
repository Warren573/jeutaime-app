import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/comprehensive_screen_working.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeTaime - Système Complet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6B73FF),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const ComprehensiveScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthDemoScreen extends StatefulWidget {
  const AuthDemoScreen({Key? key}) : super(key: key);

  @override
  _AuthDemoScreenState createState() => _AuthDemoScreenState();
}

class _AuthDemoScreenState extends State<AuthDemoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink.shade400, Colors.pink.shade600],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  SizedBox(height: 40),
                  
                  Text(
                    'JeuTaime',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade700,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  Text(
                    'L\'amour commence ici ✨',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  SizedBox(height: 60),
                  
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => DemoHomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 8,
                        shadowColor: Colors.pink.withOpacity(0.3),
                      ),
                      child: Text(
                        'COMMENCER L\'AVENTURE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  
                  Text(
                    'Version Demo Complète',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
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
}

class DemoHomeScreen extends StatefulWidget {
  @override
  _DemoHomeScreenState createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          FullSwipeScreen(),
          FullBarsScreen(),
          _buildMessagesTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.pink.shade600,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Découvrir'),
            BottomNavigationBarItem(icon: Icon(Icons.local_bar), label: 'Bars'),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.pink.shade50, Colors.white],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bonjour ! 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      Text('Prêt pour de nouvelles rencontres ?', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.monetization_on, color: Colors.yellow.shade700, size: 20),
                        SizedBox(width: 4),
                        Text('150', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow.shade700)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade100, Colors.purple.shade100]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 40, color: Colors.blue.shade600),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Statistiques', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Vos performances cette semaine', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(child: _buildStatCard('Matches', '12', Icons.favorite, Colors.red)),
                  SizedBox(width: 15),
                  Expanded(child: _buildStatCard('Messages', '8', Icons.message, Colors.blue)),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Profils vus', '45', Icons.visibility, Colors.green)),
                  SizedBox(width: 15),
                  Expanded(child: _buildStatCard('Bars visités', '3', Icons.local_bar, Colors.orange)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text('Messages', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildMessageCard('Sophie', 'Salut ! Comment ça va ?', '2 min', true),
                _buildMessageCard('Marc', 'On se voit ce soir ?', '1h', false),
                _buildMessageCard('Emma', 'Merci pour le super moment !', '3h', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(String name, String message, String time, bool unread) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unread ? Colors.pink.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.pink.shade100,
            child: Text(name[0], style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 4),
                Text(message, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          if (unread) Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: Colors.pink.shade600, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 40),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.pink.shade100,
            child: Icon(Icons.person, size: 50, color: Colors.pink.shade600),
          ),
          SizedBox(height: 20),
          Text('Demo User', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Paris, France', style: TextStyle(color: Colors.grey.shade600)),
          SizedBox(height: 30),
          
          _buildProfileOption(Icons.edit, 'Modifier le profil'),
          _buildProfileOption(Icons.settings, 'Paramètres'),
          _buildProfileOption(Icons.help, 'Aide'),
          _buildProfileOption(Icons.logout, 'Déconnexion'),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink.shade600),
          SizedBox(width: 16),
          Text(title, style: TextStyle(fontSize: 16)),
          Spacer(),
          Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
        ],
      ),
    );
  }
}

class FullSwipeScreen extends StatefulWidget {
  @override
  _FullSwipeScreenState createState() => _FullSwipeScreenState();
}

class _FullSwipeScreenState extends State<FullSwipeScreen> with TickerProviderStateMixin {
  int _currentProfileIndex = 0;
  late AnimationController _animationController;
  
  final List<Map<String, dynamic>> _profiles = [
    {
      'name': 'Alex',
      'age': 26,
      'city': 'Paris',
      'profession': 'Designer',
      'interests': ['Musique', 'Voyage', 'Photo'],
      'description': 'Passionné de musique et de voyages. J\'aime découvrir de nouveaux endroits.',
      'color': Colors.blue.shade300,
    },
    {
      'name': 'Sophie',
      'age': 24,
      'city': 'Lyon',
      'profession': 'Chef',
      'interests': ['Cuisine', 'Danse', 'Nature'],
      'description': 'Chef passionnée qui aime créer de nouveaux plats.',
      'color': Colors.green.shade300,
    },
    {
      'name': 'Marc',
      'age': 28,
      'city': 'Marseille',
      'profession': 'Développeur',
      'interests': ['Tech', 'Sport', 'Cinéma'],
      'description': 'Développeur tech et sportif. Fan de sci-fi.',
      'color': Colors.purple.shade300,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.pink.shade50, Colors.white],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Découvrir', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_profiles.length - _currentProfileIndex} profils',
                      style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _currentProfileIndex < _profiles.length
                  ? _buildProfileCard(_profiles[_currentProfileIndex])
                  : _buildNoMoreProfiles(),
            ),
            
            if (_currentProfileIndex < _profiles.length) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: profile['color'],
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: profile['color']),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${profile['name']}, ${profile['age']} ans',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    '${profile['city']} • ${profile['profession']}',
                    style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('À propos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(profile['description'], style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  SizedBox(height: 16),
                  
                  Text('Centres d\'intérêt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: (profile['interests'] as List<String>).map((interest) {
                      return Chip(
                        label: Text(interest, style: TextStyle(fontSize: 12)),
                        backgroundColor: profile['color'].withOpacity(0.2),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreProfiles() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text('Plus de profils !', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Revenez plus tard pour découvrir de nouveaux profils', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _currentProfileIndex = 0),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade600),
            child: Text('Recommencer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSwipeButton(Icons.close, Colors.red.shade400, () => _swipeLeft()),
          _buildSwipeButton(Icons.star, Colors.blue.shade400, () => _superLike()),
          _buildSwipeButton(Icons.favorite, Colors.green.shade400, () => _swipeRight()),
        ],
      ),
    );
  }

  Widget _buildSwipeButton(IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  void _swipeLeft() {
    setState(() => _currentProfileIndex++);
  }

  void _swipeRight() {
    setState(() => _currentProfileIndex++);
    _showMatchDialog();
  }

  void _superLike() {
    _swipeRight();
  }

  void _showMatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎉 C\'est un Match !'),
        content: Text('Vous pouvez maintenant discuter avec ${_profiles[_currentProfileIndex - 1]['name']} !'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Super !')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class FullBarsScreen extends StatefulWidget {
  @override
  _FullBarsScreenState createState() => _FullBarsScreenState();
}

class _FullBarsScreenState extends State<FullBarsScreen> {
  String? _selectedBar;

  final Map<String, Map<String, dynamic>> _bars = {
    'romantic': {
      'name': 'Bar Romantique',
      'icon': Icons.favorite,
      'color': Colors.pink,
      'description': 'Ambiance tamisée pour les cœurs passionnés',
      'status': '💕 24 personnes connectées',
      'activities': ['Quiz Amour', 'Poème Collaboratif', 'Sérénade'],
      'people': [
        {'name': 'Sophie', 'status': 'En ligne', 'activity': 'Écrit un poème'},
        {'name': 'Marc', 'status': 'En ligne', 'activity': 'Répond au quiz'},
        {'name': 'Emma', 'status': 'Hors ligne', 'activity': 'Dernière activité: 2h'},
      ],
    },
    'humor': {
      'name': 'Bar Humoristique',
      'icon': Icons.sentiment_very_satisfied,
      'color': Colors.orange,
      'description': 'Éclats de rire garantis',
      'status': '😂 18 personnes connectées',
      'activities': ['Concours Blagues', 'Mime Party', 'Stand-up Amateur'],
      'people': [
        {'name': 'Alex', 'status': 'En ligne', 'activity': 'Raconte une blague'},
        {'name': 'Julie', 'status': 'En ligne', 'activity': 'Fait du mime'},
        {'name': 'Paul', 'status': 'En ligne', 'activity': 'Prépare son stand-up'},
      ],
    },
    'pirates': {
      'name': 'Bar Pirates',
      'icon': Icons.sailing,
      'color': Colors.brown,
      'description': 'Chasse au trésor et aventures maritimes',
      'status': '🏴‍☠️ 12 personnes connectées',
      'activities': ['Chasse au Trésor', 'Combat Naval', 'Navigation'],
      'people': [
        {'name': 'Capitaine Jack', 'status': 'En ligne', 'activity': 'Cherche le trésor'},
        {'name': 'Anne Bonny', 'status': 'En ligne', 'activity': 'Prépare la bataille'},
        {'name': 'Barbe Noire', 'status': 'Hors ligne', 'activity': 'Navigation'},
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    if (_selectedBar != null) {
      return _buildBarDetail(_bars[_selectedBar]!);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.pink.shade100]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.local_bar, size: 40, color: Colors.orange.shade600),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bars Thématiques', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Choisissez votre ambiance', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          Text('Bars Disponibles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          
          ..._bars.entries.map((entry) => _buildBarCard(entry.key, entry.value)).toList(),
        ],
      ),
    );
  }

  Widget _buildBarCard(String barId, Map<String, dynamic> bar) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => setState(() => _selectedBar = barId),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: bar['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(bar['icon'], color: bar['color'], size: 30),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bar['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(bar['description'], style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    SizedBox(height: 8),
                    Text(bar['status'], style: TextStyle(fontSize: 12, color: bar['color'], fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [bar['color'], bar['color'].withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('ENTRER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarDetail(Map<String, dynamic> bar) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bar['name']),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedBar = null),
        ),
        backgroundColor: bar['color'],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bar['color'].withOpacity(0.1), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(bar['icon'], color: bar['color'], size: 40),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bar['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Text(bar['description'], style: TextStyle(color: Colors.grey.shade600)),
                              SizedBox(height: 8),
                              Text(bar['status'], style: TextStyle(color: bar['color'], fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              Text('Activités Disponibles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              
              ...bar['activities'].map<Widget>((activity) => _buildActivityCard(activity, bar['color'])).toList(),
              
              SizedBox(height: 24),
              Text('Personnes Connectées', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              
              ...bar['people'].map<Widget>((person) => _buildPersonCard(person)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(String activity, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.play_arrow, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(activity, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () => _joinActivity(activity),
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: Text('Rejoindre', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(Map<String, dynamic> person) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: person['status'] == 'En ligne' ? Colors.green.shade100 : Colors.grey.shade100,
            child: Text(person['name'][0], style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(person['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: person['status'] == 'En ligne' ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Text(person['activity'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          if (person['status'] == 'En ligne')
            IconButton(
              onPressed: () => _sendMessage(person['name']),
              icon: Icon(Icons.message, color: Colors.blue.shade600),
            ),
        ],
      ),
    );
  }

  void _joinActivity(String activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎯 Rejoindre l\'activité'),
        content: Text('Vous participez maintenant à: $activity'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Super !'))],
      ),
    );
  }

  void _sendMessage(String personName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('💬 Message à $personName'),
        content: TextField(
          decoration: InputDecoration(hintText: 'Tapez votre message...', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('✅ Message envoyé'),
                  content: Text('Votre message a été envoyé à $personName !'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
                ),
              );
            },
            child: Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
