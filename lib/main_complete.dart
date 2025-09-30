import 'package:flutter/material.dart';

// Import des services offline
import 'services/offline_auth_service.dart';

// Import des thèmes modernes
import 'theme/app_themes.dart';

// Import des widgets modernes
import 'widgets/modern_ui_components.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 JeuTaime MODERN - Version Complete');
  print('✨ Tous les composants modernes activés');

  runApp(JeuTaimeModernApp());
}

class JeuTaimeModernApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime - Complete Modern',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: CompleteModernHome(),
    );
  }
}

class CompleteModernHome extends StatefulWidget {
  @override
  _CompleteModernHomeState createState() => _CompleteModernHomeState();
}

class _CompleteModernHomeState extends State<CompleteModernHome> 
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
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
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildModernHomePage();
      case 1:
        return _buildDiscoverPage();
      case 2:
        return _buildBarsPage();
      case 3:
        return _buildMessagesPage();
      case 4:
        return _buildProfilePage();
      default:
        return _buildModernHomePage();
    }
  }

  Widget _buildModernHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header moderne avec animation
            _buildAnimatedHeader(),
            SizedBox(height: 30),
            
            // Stats modernes avec GradientCard
            _buildModernStats(),
            SizedBox(height: 30),
            
            // Actions rapides avec ModernButton
            _buildQuickActions(),
            SizedBox(height: 30),
            
            // Section bars recommandés
            _buildRecommendedBars(),
            SizedBox(height: 30),
            
            // Section activité récente
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white.withOpacity(0.8)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              color: AppThemes.primaryPink,
              size: 30,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salut Emma! ✨',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Découvrez l\'amour autrement',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStats() {
    return Row(
      children: [
        Expanded(
          child: GradientCard(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white.withOpacity(0.9)],
            ),
            child: Column(
              children: [
                Icon(Icons.favorite, color: AppThemes.primaryPink, size: 30),
                SizedBox(height: 8),
                AnimatedCounter(targetNumber: 24, label: 'Nouveaux\nMatches'),
              ],
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: GradientCard(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white.withOpacity(0.9)],
            ),
            child: Column(
              children: [
                Icon(Icons.message, color: AppThemes.accentOrange, size: 30),
                SizedBox(height: 8),
                AnimatedCounter(targetNumber: 8, label: 'Messages\nNon lus'),
              ],
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: GradientCard(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white.withOpacity(0.9)],
            ),
            child: Column(
              children: [
                Icon(Icons.local_bar, color: AppThemes.accentPurple, size: 30),
                SizedBox(height: 8),
                AnimatedCounter(targetNumber: 5, label: 'Bars\nProches'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        ModernButton(
          text: '🔍 Découvrir des profils',
          onPressed: () => setState(() => _selectedIndex = 1),
          icon: Icons.search,
          width: double.infinity,
        ),
        SizedBox(height: 15),
        ModernButton(
          text: '🍸 Explorer les bars',
          onPressed: () => setState(() => _selectedIndex = 2),
          icon: Icons.local_bar,
          width: double.infinity,
          backgroundColor: AppThemes.accentOrange,
        ),
        SizedBox(height: 15),
        ModernButton(
          text: '💬 Mes conversations',
          onPressed: () => setState(() => _selectedIndex = 3),
          icon: Icons.message,
          width: double.infinity,
          backgroundColor: AppThemes.accentPurple,
        ),
      ],
    );
  }

  Widget _buildRecommendedBars() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bars Recommandés 🌟',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 15),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              final bars = [
                {'name': 'Bar Romantique', 'icon': Icons.favorite, 'color': Colors.pink},
                {'name': 'Bar Humoristique', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.orange},
                {'name': 'Bar Pirates', 'icon': Icons.sailing, 'color': Colors.brown},
                {'name': 'Bar Mystère', 'icon': Icons.help, 'color': Colors.purple},
              ];
              
              return Container(
                width: 100,
                margin: EdgeInsets.only(right: 15),
                child: GradientCard(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white.withOpacity(0.9)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        bars[index]['icon'] as IconData,
                        color: bars[index]['color'] as Color,
                        size: 30,
                      ),
                      SizedBox(height: 8),
                      Text(
                        bars[index]['name'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
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

  Widget _buildRecentActivity() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activité Récente 📈',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          _buildActivityItem('💕 Nouveau match avec Alex', '2 min'),
          _buildActivityItem('🍸 Visite du Bar Romantique', '1h'),
          _buildActivityItem('⭐ Profil mis à jour', '3h'),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text, String time) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 100, color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Découvrir des Profils',
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Swipez pour trouver votre match parfait',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildBarsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_bar, size: 100, color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Explorer les Bars',
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            '5 bars thématiques vous attendent',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message, size: 100, color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Mes Conversations',
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            '8 nouveaux messages non lus',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            'Profil vérifié ✅',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppThemes.primaryPink,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
}