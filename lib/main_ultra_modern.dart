import 'package:flutter/material.dart';

// Import des thèmes modernes complets
import 'theme/app_themes.dart';

// Import des widgets modernes avec les bonnes signatures
import 'widgets/modern_ui_components.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 JeuTaime ULTRA MODERNE - Version COMPLÈTE');
  print('✨ Tous les composants modernes réels activés');
  print('🎨 GradientCard, ModernButton, AnimatedCounter');
  print('🌟 Interface premium avec animations');

  runApp(JeuTaimeUltraModernApp());
}

class JeuTaimeUltraModernApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime - Ultra Modern Complete',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: UltraModernHome(),
    );
  }
}

class UltraModernHome extends StatefulWidget {
  @override
  _UltraModernHomeState createState() => _UltraModernHomeState();
}

class _UltraModernHomeState extends State<UltraModernHome> 
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
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
      bottomNavigationBar: _buildUltraModernBottomNav(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildUltraModernHomePage();
      case 1:
        return _buildDiscoverPage();
      case 2:
        return _buildBarsPage();
      case 3:
        return _buildMessagesPage();
      case 4:
        return _buildProfilePage();
      default:
        return _buildUltraModernHomePage();
    }
  }

  Widget _buildUltraModernHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header ultra moderne avec GradientCard
            _buildUltraModernHeader(),
            SizedBox(height: 30),
            
            // Stats avec AnimatedCounter (vrais composants)
            _buildRealModernStats(),
            SizedBox(height: 30),
            
            // Actions avec ModernButton (vrais composants)
            _buildRealQuickActions(),
            SizedBox(height: 30),
            
            // Section bars avec GradientCard
            _buildModernBarsSection(),
            SizedBox(height: 30),
            
            // Section notifications modernes
            _buildModernNotifications(),
          ],
        ),
      ),
    );
  }

  Widget _buildUltraModernHeader() {
    return GradientCard(
      colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
      borderRadius: 25,
      padding: EdgeInsets.all(25),
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
              Icons.favorite,
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
                  'Trouvez l\'amour avec style',
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

  Widget _buildRealModernStats() {
    return Row(
      children: [
        Expanded(
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
        SizedBox(width: 15),
        Expanded(
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
        SizedBox(width: 15),
        Expanded(
          child: GradientCard(
            colors: [Colors.white, Colors.white.withOpacity(0.95)],
            borderRadius: 20,
            child: AnimatedCounter(
              value: 5,
              label: 'Bars\nProches',
              icon: Icons.local_bar,
              color: AppThemes.accentPurple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealQuickActions() {
    return Column(
      children: [
        ModernButton(
          text: '🔍 Découvrir des profils',
          onPressed: () {
            setState(() => _selectedIndex = 1);
            _showSnackBar('Navigation vers Découvrir');
          },
          icon: Icons.search,
          width: double.infinity,
          height: 60,
        ),
        SizedBox(height: 15),
        ModernButton(
          text: '🍸 Explorer les bars thématiques',
          onPressed: () {
            setState(() => _selectedIndex = 2);
            _showSnackBar('Navigation vers Bars');
          },
          icon: Icons.local_bar,
          width: double.infinity,
          height: 60,
          backgroundColor: AppThemes.accentOrange,
        ),
        SizedBox(height: 15),
        ModernButton(
          text: '💬 Mes conversations actives',
          onPressed: () {
            setState(() => _selectedIndex = 3);
            _showSnackBar('Navigation vers Messages');
          },
          icon: Icons.message,
          width: double.infinity,
          height: 60,
          backgroundColor: AppThemes.accentPurple,
        ),
      ],
    );
  }

  Widget _buildModernBarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bars Thématiques Premium 🌟',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
                {'name': 'Bar Romantique', 'icon': Icons.favorite, 'color': Colors.pink, 'desc': 'Ambiance tamisée'},
                {'name': 'Bar Humoristique', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.orange, 'desc': 'Éclats de rire'},
                {'name': 'Bar Pirates', 'icon': Icons.sailing, 'color': Colors.brown, 'desc': 'Chasse au trésor'},
                {'name': 'Bar Mystère', 'icon': Icons.help, 'color': Colors.purple, 'desc': 'Surprises garanties'},
                {'name': 'Bar Hebdo', 'icon': Icons.calendar_today, 'color': Colors.teal, 'desc': 'Événement spécial'},
              ];
              
              return Container(
                width: 120,
                margin: EdgeInsets.only(right: 15),
                child: GradientCard(
                  colors: [Colors.white, Colors.white.withOpacity(0.9)],
                  borderRadius: 18,
                  onTap: () => _showSnackBar('Ouverture ${bars[index]['name']}'),
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

  Widget _buildModernNotifications() {
    return GradientCard(
      colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
      borderRadius: 20,
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'Activité Récente 📈',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildNotificationItem('💕 Nouveau match avec Alex', '2 min', Icons.favorite),
          _buildNotificationItem('🍸 Visite du Bar Romantique', '1h', Icons.local_bar),
          _buildNotificationItem('⭐ Profil mis à jour', '3h', Icons.star),
          _buildNotificationItem('🎯 Défi complété au Bar Humour', '5h', Icons.emoji_events),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String text, String time, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 15,
              ),
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
          GradientCard(
            colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
            borderRadius: 30,
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(Icons.search, size: 80, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'Découvrir des Profils',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Swipez pour trouver votre match parfait',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
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
          GradientCard(
            colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
            borderRadius: 30,
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(Icons.local_bar, size: 80, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'Explorer les Bars',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '5 bars thématiques uniques vous attendent',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
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
          GradientCard(
            colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
            borderRadius: 30,
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(Icons.message, size: 80, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'Mes Conversations',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '8 nouveaux messages non lus',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
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
          GradientCard(
            colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
            borderRadius: 30,
            padding: EdgeInsets.all(40),
            child: Column(
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
                  'Profil vérifié ✅ Premium 👑',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltraModernBottomNav() {
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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