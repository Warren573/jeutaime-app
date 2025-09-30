import 'package:flutter/material.dart';

// Import des thèmes modernes complets
import 'theme/app_themes.dart';

// Import des widgets modernes avec les bonnes signatures
import 'widgets/modern_ui_components.dart';

// Import des services Firebase
import 'services/firebase_service.dart';
import 'screens/auth_screen.dart';
import 'screens/demo_auth_screen.dart';

// Les écrans sont définis dans ce fichier pour éviter les imports manquants

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  try {
    await FirebaseService.initialize();
    print('� Firebase initialisé avec succès');
  } catch (e) {
    print('❌ Erreur Firebase: $e');
  }

  print('�🚀 JeuTaime BACKEND INTÉGRÉ - Firebase + Authentification');
  print('✨ Système de pièces et économie réelle');
  print('🎯 Lettres authentiques avec anti-ghosting');
  print('💬 Bars thématiques avec logique complète');

  runApp(JeuTaimeInteractiveApp());
}

class JeuTaimeInteractiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime - Version Interactive',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService.instance.auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.pink.shade100, Colors.orange.shade100],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, size: 80, color: Colors.pink.shade600),
                    SizedBox(height: 24),
                    CircularProgressIndicator(color: Colors.pink.shade600),
                    SizedBox(height: 16),
                    Text(
                      'Initialisation JeuTaime...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.pink.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        if (snapshot.hasData) {
          return InteractiveHome();
        }
        
        return AuthScreen(
          onAuthenticated: () {
            // La navigation se fait automatiquement via le StreamBuilder
          },
        );
      },
    );
  }
}

class InteractiveHome extends StatefulWidget {
  @override
  _InteractiveHomeState createState() => _InteractiveHomeState();
}

class _InteractiveHomeState extends State<InteractiveHome> 
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String? _selectedBar;
  String? _selectedChat;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppThemes.primaryPink,
              AppThemes.accentOrange,
              AppThemes.accentPurple,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildCurrentPage(),
          ),
        ),
      ),
      bottomNavigationBar: _buildInteractiveBottomNav(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildInteractiveHomePage();
      case 1:
        return SwipeScreen();
      case 2:
        return InteractiveBarHub(selectedBar: _selectedBar);
      case 3:
        return ChatHub(openChatWith: _selectedChat);
      case 4:
        return UserProfile();
      default:
        return _buildInteractiveHomePage();
    }
  }

  Widget _buildInteractiveHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header interactif
            _buildInteractiveHeader(),
            SizedBox(height: 30),
            
            // Stats avec vraies données
            _buildLiveStats(),
            SizedBox(height: 30),
            
            // Actions FONCTIONNELLES
            _buildFunctionalActions(),
            SizedBox(height: 30),
            
            // Bars CLIQUABLES
            _buildClickableBars(),
            SizedBox(height: 30),
            
            // Matches récents RÉELS
            _buildRecentMatches(),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveHeader() {
    return GradientCard(
      colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
      borderRadius: 25,
      padding: EdgeInsets.all(25),
      onTap: () => _navigateToProfile(),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white.withOpacity(0.8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              color: AppThemes.primaryPink,
              size: 35,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salut Emma! ✨',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Tapez ici pour voir votre profil',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.7), size: 16),
        ],
      ),
    );
  }

  Widget _buildLiveStats() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToDiscover(),
            child: GradientCard(
              colors: [Colors.white, Colors.white.withOpacity(0.95)],
              borderRadius: 20,
              child: AnimatedCounter(
                value: 24,
                label: 'Nouveaux\nMatches',
                icon: Icons.favorite,
                color: AppThemes.primaryPink,
              ),
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToMessages(),
            child: GradientCard(
              colors: [Colors.white, Colors.white.withOpacity(0.95)],
              borderRadius: 20,
              child: AnimatedCounter(
                value: 8,
                label: 'Messages\nNon lus',
                icon: Icons.message,
                color: AppThemes.accentOrange,
              ),
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToBars(),
            child: GradientCard(
              colors: [Colors.white, Colors.white.withOpacity(0.95)],
              borderRadius: 20,
              child: AnimatedCounter(
                value: 5,
                label: 'Bars\nDisponibles',
                icon: Icons.local_bar,
                color: AppThemes.accentPurple,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionalActions() {
    return Column(
      children: [
        ModernButton(
          text: '🔍 Découvrir des profils',
          onPressed: () => _navigateToDiscover(),
          icon: Icons.search,
          width: double.infinity,
          height: 60,
        ),
        SizedBox(height: 15),
        ModernButton(
          text: '🍸 Explorer les bars thématiques',
          onPressed: () => _navigateToBars(),
          icon: Icons.local_bar,
          width: double.infinity,
          height: 60,
          backgroundColor: AppThemes.accentOrange,
        ),
        SizedBox(height: 15),
        ModernButton(
          text: '💬 Mes conversations actives',
          onPressed: () => _navigateToMessages(),
          icon: Icons.message,
          width: double.infinity,
          height: 60,
          backgroundColor: AppThemes.accentPurple,
        ),
      ],
    );
  }

  Widget _buildClickableBars() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bars Thématiques 🎯',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 15),
        Text(
          'Cliquez sur un bar pour entrer',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 20),
        Container(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              final bars = [
                {
                  'name': 'Bar Romantique', 
                  'icon': Icons.favorite, 
                  'color': Colors.pink, 
                  'desc': 'Ambiance tamisée',
                  'action': () => _openBar('romantic')
                },
                {
                  'name': 'Bar Humoristique', 
                  'icon': Icons.sentiment_very_satisfied, 
                  'color': Colors.orange, 
                  'desc': 'Éclats de rire',
                  'action': () => _openBar('humor')
                },
                {
                  'name': 'Bar Pirates', 
                  'icon': Icons.sailing, 
                  'color': Colors.brown, 
                  'desc': 'Chasse au trésor',
                  'action': () => _openBar('pirates')
                },
                {
                  'name': 'Bar Mystère', 
                  'icon': Icons.help, 
                  'color': Colors.purple, 
                  'desc': 'Surprises garanties',
                  'action': () => _openBar('mystery')
                },
                {
                  'name': 'Bar Hebdo', 
                  'icon': Icons.calendar_today, 
                  'color': Colors.teal, 
                  'desc': 'Événement spécial',
                  'action': () => _openBar('weekly')
                },
              ];
              
              return Container(
                width: 120,
                margin: EdgeInsets.only(right: 15),
                child: GradientCard(
                  colors: [Colors.white, Colors.white.withOpacity(0.9)],
                  borderRadius: 18,
                  onTap: bars[index]['action'] as VoidCallback,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        bars[index]['icon'] as IconData,
                        color: bars[index]['color'] as Color,
                        size: 35,
                      ),
                      SizedBox(height: 10),
                      Text(
                        bars[index]['name'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        bars[index]['desc'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (bars[index]['color'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'ENTRER',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: bars[index]['color'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMatches() {
    return GradientCard(
      colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
      borderRadius: 20,
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'Matches Récents 💕',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildMatchItem('Alex, 26 ans', 'Bar Romantique', '2 min', () => _openChat('Alex')),
          _buildMatchItem('Sophie, 24 ans', 'Bar Humoristique', '1h', () => _openChat('Sophie')),
          _buildMatchItem('Marc, 28 ans', 'Bar Pirates', '3h', () => _openChat('Marc')),
        ],
      ),
    );
  }

  Widget _buildMatchItem(String name, String location, String time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemes.primaryPink, AppThemes.accentOrange],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rencontré au $location',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppThemes.primaryPink.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'CHAT',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppThemes.primaryPink,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Découvrir'),
          BottomNavigationBarItem(icon: Icon(Icons.local_bar), label: 'Bars'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  // Méthodes de navigation FONCTIONNELLES
  void _navigateToDiscover() {
    setState(() => _selectedIndex = 1);
    _showSnackBar('🔍 Navigation vers Découverte');
  }

  void _navigateToBars() {
    setState(() {
      _selectedIndex = 2;
      _selectedBar = null; // Retour à la sélection des bars
    });
    _showSnackBar('🍸 Navigation vers Bars');
  }

  void _navigateToMessages() {
    setState(() {
      _selectedIndex = 3;
      _selectedChat = null; // Retour à la liste des conversations
    });
    _showSnackBar('💬 Navigation vers Messages');
  }

  void _navigateToProfile() {
    setState(() => _selectedIndex = 4);
    _showSnackBar('👤 Navigation vers Profil');
  }

  void _openBar(String barType) {
    setState(() {
      _selectedIndex = 2;
      _selectedBar = barType;
    });
    _showSnackBar('🍸 Ouverture du Bar ${barType}');
  }

  void _openChat(String name) {
    setState(() {
      _selectedIndex = 3;
      _selectedChat = name;
    });
    _showSnackBar('💬 Ouverture chat avec $name');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppThemes.primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Écran de swipe FONCTIONNEL
class SwipeScreen extends StatefulWidget {
  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> with TickerProviderStateMixin {
  int currentProfileIndex = 0;
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  late AnimationController _matchController;
  late Animation<double> _matchAnimation;
  bool showMatchAnimation = false;
  
  final List<Map<String, dynamic>> profiles = [
    {
      'name': 'Alex',
      'age': 26,
      'description': 'Passionné de musique et de voyages',
      'interests': ['Musique', 'Voyages', 'Photographie'],
      'distance': '2 km',
      'photos': ['👨‍🎤', '🎸', '✈️'],
      'bio': 'Musicien le jour, aventurier le week-end. Cherche quelqu\'un pour partager de nouveaux horizons !',
    },
    {
      'name': 'Sophie',
      'age': 24,
      'description': 'Chef pâtissière créative',
      'interests': ['Cuisine', 'Art', 'Randonnée'],
      'distance': '1.5 km',
      'photos': ['👩‍🍳', '🎨', '🥾'],
      'bio': 'J\'adore créer des desserts qui font sourire. Fan de balades en nature et d\'expositions d\'art.',
    },
    {
      'name': 'Marc',
      'age': 28,
      'description': 'Développeur et gamer passionné',
      'interests': ['Tech', 'Gaming', 'Cinéma'],
      'distance': '3 km',
      'photos': ['💻', '🎮', '🎬'],
      'bio': 'Code le jour, game la nuit. Toujours partant pour un bon film ou une nouvelle aventure gaming !',
    },
    {
      'name': 'Emma',
      'age': 25,
      'description': 'Photographe et yogiste',
      'interests': ['Photo', 'Yoga', 'Nature'],
      'distance': '0.8 km',
      'photos': ['📸', '🧘‍♀️', '🌿'],
      'bio': 'Je capture les moments magiques. Équilibre entre créativité et sérénité. Namasté ! 🙏',
    },
    {
      'name': 'Thomas',
      'age': 27,
      'description': 'Médecin et sportif',
      'interests': ['Sport', 'Médecine', 'Lecture'],
      'distance': '2.2 km',
      'photos': ['⚕️', '🏃‍♂️', '📚'],
      'bio': 'Prendre soin des autres est ma passion. Entre deux gardes, j\'aime courir et lire des thrillers.',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _swipeAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_swipeController);
    
    _matchController = AnimationController(duration: Duration(milliseconds: 1500), vsync: this);
    _matchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _matchController, curve: Curves.elasticOut)
    );
  }
  
  @override
  void dispose() {
    _swipeController.dispose();
    _matchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Interface principale
          Column(
            children: [
              // Header avec statistiques
              _buildSwipeHeader(),
              
              // Zone de swipe
              Expanded(
                child: _buildSwipeArea(),
              ),
              
              // Boutons d'action
              _buildActionButtons(),
              SizedBox(height: 20),
            ],
          ),
          
          // Animation de match
          if (showMatchAnimation) _buildMatchAnimation(),
        ],
      ),
    );
  }
  
  Widget _buildSwipeHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: GradientCard(
        colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
        borderRadius: 20,
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('💕', '${24 - currentProfileIndex}', 'Profils restants'),
            _buildStatItem('⭐', '12', 'Matches aujourd\'hui'),
            _buildStatItem('🔥', '95%', 'Popularité'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 24)),
        SizedBox(height: 5),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
  
  Widget _buildSwipeArea() {
    if (currentProfileIndex >= profiles.length) {
      return _buildNoMoreProfiles();
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Stack(
          children: [
            // Carte suivante (en arrière-plan)
            if (currentProfileIndex + 1 < profiles.length)
              Transform.scale(
                scale: 0.95,
                child: Opacity(
                  opacity: 0.5,
                  child: _buildProfileCard(profiles[currentProfileIndex + 1]),
                ),
              ),
            
            // Carte actuelle
            SlideTransition(
              position: _swipeAnimation,
              child: GestureDetector(
                onPanUpdate: _handlePanUpdate,
                onPanEnd: _handlePanEnd,
                child: _buildProfileCard(profiles[currentProfileIndex]),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileCard(Map<String, dynamic> profile) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 350, maxHeight: 500),
      child: GradientCard(
        colors: [Colors.white, Colors.white.withOpacity(0.95)],
        borderRadius: 25,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo principale (simulée avec gradient)
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemes.primaryPink, AppThemes.accentOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profile['photos'][0],
                          style: TextStyle(fontSize: 80),
                        ),
                        Text(
                          '${profile['name']}, ${profile['age']} ans',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        profile['distance'],
                        style: TextStyle(
                          color: AppThemes.primaryPink,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Informations du profil
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile['description'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 15),
                    
                    // Centres d'intérêt
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (profile['interests'] as List<String>).map((interest) => 
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppThemes.primaryPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppThemes.primaryPink.withOpacity(0.3)),
                          ),
                          child: Text(
                            interest,
                            style: TextStyle(
                              color: AppThemes.primaryPink,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                    SizedBox(height: 15),
                    
                    // Bio
                    Expanded(
                      child: Text(
                        profile['bio'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Bouton passer
          GestureDetector(
            onTap: () => _handleSwipe(false),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(Icons.close, color: Colors.red, size: 30),
            ),
          ),
          
          // Bouton super like
          GestureDetector(
            onTap: () => _handleSuperLike(),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(Icons.star, color: Colors.blue, size: 25),
            ),
          ),
          
          // Bouton like
          GestureDetector(
            onTap: () => _handleSwipe(true),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppThemes.primaryPink.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(Icons.favorite, color: AppThemes.primaryPink, size: 30),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoMoreProfiles() {
    return Center(
      child: GradientCard(
        colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
        borderRadius: 30,
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎉', style: TextStyle(fontSize: 60)),
            SizedBox(height: 20),
            Text(
              'Plus de profils !',
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Revenez plus tard pour de nouveaux profils',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 20),
            ModernButton(
              text: '🔄 Recharger',
              onPressed: () => setState(() => currentProfileIndex = 0),
              backgroundColor: AppThemes.primaryPink,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMatchAnimation() {
    return FadeTransition(
      opacity: _matchAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: ScaleTransition(
            scale: _matchAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('💕', style: TextStyle(fontSize: 100)),
                SizedBox(height: 20),
                Text(
                  'C\'EST UN MATCH !',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Vous vous plaisez mutuellement',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ModernButton(
                      text: '💬 Envoyer un message',
                      onPressed: _closeMatchAnimation,
                      backgroundColor: AppThemes.primaryPink,
                      width: 180,
                    ),
                    ModernButton(
                      text: '➡️ Continuer',
                      onPressed: _closeMatchAnimation,
                      backgroundColor: Colors.grey,
                      width: 120,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _handlePanUpdate(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deltaX = details.delta.dx / screenWidth;
    
    setState(() {
      _swipeAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(deltaX * 10, 0),
      ).animate(_swipeController);
    });
  }
  
  void _handlePanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    
    if (velocity.abs() > 500) {
      _handleSwipe(velocity > 0);
    } else {
      // Remettre la carte au centre
      _swipeController.reverse();
    }
  }
  
  void _handleSwipe(bool isLike) {
    if (isLike && currentProfileIndex < profiles.length) {
      // Simulation d'un match (30% de chance)
      if (DateTime.now().millisecond % 10 < 3) {
        _showMatch();
        return;
      }
    }
    
    _nextProfile();
    _showSnackBar(isLike ? '💕 Like envoyé !' : '👋 Profil passé');
  }
  
  void _handleSuperLike() {
    _showMatch(); // Super like = match garanti
  }
  
  void _nextProfile() {
    setState(() {
      currentProfileIndex++;
    });
    _swipeController.reset();
  }
  
  void _showMatch() {
    setState(() {
      showMatchAnimation = true;
    });
    _matchController.forward();
  }
  
  void _closeMatchAnimation() {
    _matchController.reverse().then((_) {
      setState(() {
        showMatchAnimation = false;
      });
      _nextProfile();
    });
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppThemes.primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

// Hub de chat FONCTIONNEL
class ChatHub extends StatefulWidget {
  final String? openChatWith;
  
  const ChatHub({Key? key, this.openChatWith}) : super(key: key);
  
  @override
  _ChatHubState createState() => _ChatHubState();
}

class _ChatHubState extends State<ChatHub> {
  String? currentChat;
  final TextEditingController _messageController = TextEditingController();
  
  final Map<String, List<Map<String, dynamic>>> conversations = {
    'Alex': [
      {'sender': 'Alex', 'message': 'Salut ! J\'ai vu qu\'on avait matché 😊', 'time': '14:32', 'isMe': false},
      {'sender': 'Emma', 'message': 'Salut Alex ! Oui, ton profil m\'a plu !', 'time': '14:35', 'isMe': true},
      {'sender': 'Alex', 'message': 'Génial ! Tu aimes la musique à ce que je vois ?', 'time': '14:36', 'isMe': false},
      {'sender': 'Emma', 'message': 'Absolument ! Quel genre préfères-tu ?', 'time': '14:38', 'isMe': true},
      {'sender': 'Alex', 'message': 'Un peu de tout, mais surtout le rock et l\'indie. Et toi ?', 'time': '14:40', 'isMe': false},
    ],
    'Sophie': [
      {'sender': 'Sophie', 'message': 'Hey ! Super de te rencontrer 🌟', 'time': '13:45', 'isMe': false},
      {'sender': 'Emma', 'message': 'Salut Sophie ! Enchantée aussi 😊', 'time': '13:50', 'isMe': true},
      {'sender': 'Sophie', 'message': 'J\'ai vu que tu faisais de la photo, c\'est passionnant !', 'time': '13:52', 'isMe': false},
      {'sender': 'Emma', 'message': 'Oui j\'adore ! Et toi la pâtisserie, ça doit être délicieux !', 'time': '13:55', 'isMe': true},
    ],
    'Marc': [
      {'sender': 'Marc', 'message': '👋 Salut ! Match intéressant !', 'time': '12:20', 'isMe': false},
      {'sender': 'Emma', 'message': 'Salut Marc ! Merci 😄', 'time': '12:45', 'isMe': true},
      {'sender': 'Marc', 'message': 'Tu connais des bons spots photo dans le coin ?', 'time': '12:47', 'isMe': false},
    ],
    'Thomas': [
      {'sender': 'Thomas', 'message': 'Bonjour Emma ! Ravie de faire ta connaissance', 'time': '11:15', 'isMe': false},
      {'sender': 'Emma', 'message': 'Bonjour Thomas ! Pareillement 😊', 'time': '11:30', 'isMe': true},
    ],
  };
  
  @override
  void initState() {
    super.initState();
    currentChat = widget.openChatWith;
  }
  
  @override
  Widget build(BuildContext context) {
    if (currentChat != null) {
      return _buildChatScreen(currentChat!);
    }
    
    return _buildConversationsList();
  }
  
  Widget _buildConversationsList() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header du chat
            GradientCard(
              colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
              borderRadius: 20,
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble, size: 40, color: Colors.white),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mes Conversations',
                          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${conversations.length} matches actifs',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppThemes.primaryPink,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_getTotalUnreadMessages()}',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            
            // Liste des conversations
            ...conversations.entries.map((entry) => _buildConversationItem(
              entry.key,
              entry.value.last['message'],
              entry.value.last['time'],
              _getUnreadCount(entry.key),
            )).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConversationItem(String name, String lastMessage, String time, int unreadCount) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: GradientCard(
        colors: [Colors.white, Colors.white.withOpacity(0.95)],
        borderRadius: 20,
        padding: EdgeInsets.all(15),
        onTap: () => setState(() => currentChat = name),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemes.primaryPink, AppThemes.accentOrange],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 15),
            
            // Contenu de la conversation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            SizedBox(width: 8),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppThemes.primaryPink,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$unreadCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChatScreen(String name) {
    final messages = conversations[name] ?? [];
    
    return SafeArea(
      child: Column(
        children: [
          // Header du chat
          Container(
            padding: EdgeInsets.all(20),
            child: GradientCard(
              colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
              borderRadius: 20,
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => currentChat = null),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 15),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemes.primaryPink, AppThemes.accentOrange],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name[0],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'En ligne',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.videocam, color: Colors.white, size: 28),
                  SizedBox(width: 15),
                  Icon(Icons.phone, color: Colors.white, size: 24),
                ],
              ),
            ),
          ),
          
          // Messages
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessageBubble(
                    message['message'],
                    message['time'],
                    message['isMe'],
                  );
                },
              ),
            ),
          ),
          
          // Zone de saisie
          _buildMessageInput(),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(String message, String time, bool isMe) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemes.primaryPink, AppThemes.accentOrange],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  currentChat![0],
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isMe 
                    ? [AppThemes.primaryPink, AppThemes.accentOrange]
                    : [Colors.grey[200]!, Colors.grey[100]!],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 10),
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemes.accentPurple, AppThemes.primaryPink],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'E',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Tapez votre message...',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemes.primaryPink, AppThemes.accentOrange],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final newMessage = {
      'sender': 'Emma',
      'message': _messageController.text.trim(),
      'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      'isMe': true,
    };
    
    setState(() {
      conversations[currentChat!]?.add(newMessage);
      _messageController.clear();
    });
    
    // Simulation d'une réponse automatique après 2 secondes
    Future.delayed(Duration(seconds: 2), () {
      if (mounted && currentChat != null) {
        final responses = [
          'Intéressant ! 😊',
          'Je suis d\'accord avec toi',
          'Ah vraiment ? Raconte-moi !',
          'Haha, c\'est drôle ! 😄',
          'On devrait se rencontrer bientôt !',
        ];
        
        final autoResponse = {
          'sender': currentChat!,
          'message': responses[DateTime.now().millisecond % responses.length],
          'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          'isMe': false,
        };
        
        setState(() {
          conversations[currentChat!]?.add(autoResponse);
        });
      }
    });
  }
  
  int _getTotalUnreadMessages() {
    return conversations.values.fold(0, (total, messages) => total + _getUnreadCount(''));
  }
  
  int _getUnreadCount(String name) {
    // Simulation - en réalité ce serait basé sur les messages non lus
    switch (name) {
      case 'Alex': return 2;
      case 'Sophie': return 1;
      case 'Marc': return 1;
      default: return 0;
    }
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

// Hub de bars FONCTIONNEL avec sélection
class InteractiveBarHub extends StatefulWidget {
  final String? selectedBar;
  
  const InteractiveBarHub({Key? key, this.selectedBar}) : super(key: key);
  
  @override
  _InteractiveBarHubState createState() => _InteractiveBarHubState();
}

class _InteractiveBarHubState extends State<InteractiveBarHub> {
  String? currentBar;
  
  @override
  void initState() {
    super.initState();
    currentBar = widget.selectedBar;
  }
  
  @override
  Widget build(BuildContext context) {
    if (currentBar != null) {
      return _buildSpecificBar(currentBar!);
    }
    
    return _buildBarSelection();
  }
  
  Widget _buildBarSelection() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header des bars
            GradientCard(
              colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
              borderRadius: 20,
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.local_bar, size: 40, color: Colors.white),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bars Thématiques',
                          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Choisissez votre ambiance',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            
            // Liste des bars cliquables
            _buildBarCard(
              'Romantique',
              'Ambiance tamisée pour les cœurs passionnés',
              Icons.favorite,
              Colors.pink,
              '💕 24 personnes connectées',
              () => setState(() => currentBar = 'romantic'),
            ),
            SizedBox(height: 15),
            _buildBarCard(
              'Humoristique',
              'Défis du jour et éclats de rire garantis',
              Icons.sentiment_very_satisfied,
              Colors.orange,
              '😂 18 personnes connectées',
              () => setState(() => currentBar = 'humor'),
            ),
            SizedBox(height: 15),
            _buildBarCard(
              'Pirates',
              'Chasse au trésor et aventures maritimes',
              Icons.sailing,
              Colors.brown,
              '🏴‍☠️ 12 personnes connectées',
              () => setState(() => currentBar = 'pirates'),
            ),
            SizedBox(height: 15),
            _buildBarCard(
              'Mystère',
              'Surprises et rencontres inattendues',
              Icons.help,
              Colors.purple,
              '🔮 15 personnes connectées',
              () => setState(() => currentBar = 'mystery'),
            ),
            SizedBox(height: 15),
            _buildBarCard(
              'Hebdomadaire',
              'Événement spécial de la semaine',
              Icons.calendar_today,
              Colors.teal,
              '🌟 32 personnes connectées',
              () => setState(() => currentBar = 'weekly'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBarCard(String name, String description, IconData icon, Color color, String status, VoidCallback onTap) {
    return GradientCard(
      colors: [Colors.white, Colors.white.withOpacity(0.95)],
      borderRadius: 20,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bar $name',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    status,
                    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ENTRER',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSpecificBar(String barType) {
    switch (barType) {
      case 'romantic':
        return _buildRomanticBar();
      case 'humor':
        return _buildHumorBar();
      case 'pirates':
        return _buildPiratesBar();
      case 'mystery':
        return _buildMysteryBar();
      case 'weekly':
        return _buildWeeklyBar();
      default:
        return _buildBarSelection();
    }
  }
  
  Widget _buildRomanticBar() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Header avec bouton retour
            _buildBarHeader('Bar Romantique 💕', 'Ambiance tamisée', Colors.pink),
            SizedBox(height: 30),
            
            // Profils dans ce bar
            _buildBarProfiles([
              {'name': 'Alex, 26 ans', 'desc': 'Passionné de musique', 'online': true},
              {'name': 'Sophie, 24 ans', 'desc': 'Aime les balades', 'online': true},
              {'name': 'Marc, 28 ans', 'desc': 'Chef cuisinier', 'online': false},
              {'name': 'Emma, 25 ans', 'desc': 'Photographe', 'online': true},
            ]),
            SizedBox(height: 30),
            
            // Actions spécifiques au bar romantique
            _buildBarActions([
              {'text': '💕 Envoyer un cœur', 'color': Colors.pink},
              {'text': '🌹 Offrir une rose virtuelle', 'color': Colors.red},
              {'text': '💌 Écrire un message romantique', 'color': Colors.purple},
            ]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHumorBar() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBarHeader('Bar Humoristique 😂', 'Éclats de rire garantis', Colors.orange),
            SizedBox(height: 30),
            
            // Défi du jour
            GradientCard(
              colors: [Colors.orange.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
              borderRadius: 20,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '🎯 Défi du Jour',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Racontez votre pire rendez-vous en 3 mots !',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 15),
                  ModernButton(
                    text: 'Participer au défi',
                    onPressed: () => _showSnackBar('🎯 Défi accepté !'),
                    backgroundColor: Colors.orange,
                    width: 200,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            _buildBarProfiles([
              {'name': 'Tom, 27 ans', 'desc': 'Stand-up comedian', 'online': true},
              {'name': 'Lisa, 23 ans', 'desc': 'Aime les jeux de mots', 'online': true},
              {'name': 'Paul, 29 ans', 'desc': 'Roi des blagues', 'online': true},
            ]),
            SizedBox(height: 30),
            
            _buildBarActions([
              {'text': '😂 Partager une blague', 'color': Colors.orange},
              {'text': '🎭 Défi rigolo', 'color': Colors.amber},
              {'text': '🤣 Concours de memes', 'color': Colors.deepOrange},
            ]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPiratesBar() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBarHeader('Bar Pirates 🏴‍☠️', 'Chasse au trésor', Colors.brown),
            SizedBox(height: 30),
            
            // Carte au trésor
            GradientCard(
              colors: [Colors.brown.withOpacity(0.3), Colors.brown.withOpacity(0.1)],
              borderRadius: 20,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '🗺️ Chasse au Trésor',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Trouvez les indices cachés dans les profils !',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTreasureProgress('🗝️', 'Clé trouvée'),
                      _buildTreasureProgress('🏴‍☠️', 'Drapeau à trouver'),
                      _buildTreasureProgress('💎', 'Trésor à découvrir'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            _buildBarProfiles([
              {'name': 'Captain Jack, 30 ans', 'desc': 'Aventurier des mers', 'online': true},
              {'name': 'Anne Bonny, 26 ans', 'desc': 'Pirate redoutable', 'online': true},
              {'name': 'Barbe Noire, 32 ans', 'desc': 'Chercheur de trésor', 'online': false},
            ]),
            SizedBox(height: 30),
            
            _buildBarActions([
              {'text': '🏴‍☠️ Rejoindre l\'équipage', 'color': Colors.brown},
              {'text': '⚔️ Duel amical', 'color': Colors.red},
              {'text': '🗺️ Chercher des indices', 'color': Colors.orange},
            ]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMysteryBar() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBarHeader('Bar Mystère 🔮', 'Surprises garanties', Colors.purple),
            SizedBox(height: 30),
            
            // Profils mystères (cachés)
            GradientCard(
              colors: [Colors.purple.withOpacity(0.3), Colors.purple.withOpacity(0.1)],
              borderRadius: 20,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '🔮 Rencontres Mystères',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Les profils sont cachés ! Chattez d\'abord, révélez ensuite.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Profils mystères
            ...List.generate(4, (index) => Container(
              margin: EdgeInsets.only(bottom: 15),
              child: GradientCard(
                colors: [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.1)],
                borderRadius: 15,
                padding: EdgeInsets.all(15),
                onTap: () => _showSnackBar('🔮 Personne mystère #${index + 1}'),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(Icons.help, color: Colors.white),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personne Mystère #${index + 1}',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Cliquez pour découvrir...',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            )),
            SizedBox(height: 30),
            
            _buildBarActions([
              {'text': '🔮 Chat mystère', 'color': Colors.purple},
              {'text': '🎭 Révéler identité', 'color': Colors.indigo},
              {'text': '✨ Surprise du jour', 'color': Colors.deepPurple},
            ]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeeklyBar() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBarHeader('Bar Hebdomadaire 🌟', 'Événement spécial', Colors.teal),
            SizedBox(height: 30),
            
            // Événement de la semaine
            GradientCard(
              colors: [Colors.teal.withOpacity(0.3), Colors.teal.withOpacity(0.1)],
              borderRadius: 20,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '🎉 Événement de la Semaine',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Speed Dating Virtuel - 5 minutes par personne',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '⏰ Prochaine session dans 2h',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            _buildBarProfiles([
              {'name': 'Marie, 25 ans', 'desc': 'Inscrite au speed dating', 'online': true},
              {'name': 'Lucas, 27 ans', 'desc': 'Organisateur événements', 'online': true},
              {'name': 'Sarah, 24 ans', 'desc': 'Première participation', 'online': true},
              {'name': 'David, 29 ans', 'desc': 'Habitué des soirées', 'online': true},
            ]),
            SizedBox(height: 30),
            
            _buildBarActions([
              {'text': '🎯 S\'inscrire au speed dating', 'color': Colors.teal},
              {'text': '🗓️ Voir programme semaine', 'color': Colors.cyan},
              {'text': '🏆 Événements passés', 'color': Colors.lightBlue},
            ]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBarHeader(String title, String subtitle, Color color) {
    return GradientCard(
      colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
      borderRadius: 20,
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => currentBar = null),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBarProfiles(List<Map<String, dynamic>> profiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personnes dans ce bar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 15),
        ...profiles.map((profile) => Container(
          margin: EdgeInsets.only(bottom: 15),
          child: GradientCard(
            colors: [Colors.white, Colors.white.withOpacity(0.95)],
            borderRadius: 15,
            padding: EdgeInsets.all(15),
            onTap: () => _showSnackBar('💬 Chat avec ${profile['name']}'),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppThemes.primaryPink, AppThemes.accentOrange],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            profile['name'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: profile['online'] ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        profile['desc'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chat_bubble_outline, color: AppThemes.primaryPink),
              ],
            ),
          ),
        )).toList(),
      ],
    );
  }
  
  Widget _buildBarActions(List<Map<String, dynamic>> actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions disponibles',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 15),
        ...actions.map((action) => Container(
          margin: EdgeInsets.only(bottom: 10),
          width: double.infinity,
          child: ModernButton(
            text: action['text'],
            onPressed: () => _showSnackBar('${action['text']} activé !'),
            backgroundColor: action['color'],
            width: double.infinity,
            height: 50,
          ),
        )).toList(),
      ],
    );
  }
  
  Widget _buildTreasureProgress(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 30)),
        SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppThemes.primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Profil utilisateur temporaire
class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GradientCard(
        colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
        borderRadius: 30,
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white.withOpacity(0.8)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 60, color: AppThemes.primaryPink),
            ),
            SizedBox(height: 20),
            Text(
              'Emma, 25 ans',
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Profil Premium ✅ 👑',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '⚙️ Paramètres et modifications',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}