import 'package:flutter/material.dart';
import '../widgets/modern_ui_components.dart';
import '../theme/app_animations.dart';
import '../theme/app_themes.dart';
import '../models/bar_model.dart';
import 'bars/romantic_bar_screen.dart';
import 'bars/humor_bar_screen.dart';
import 'bars/weekly_bar_screen.dart';
import 'bars/mystery_bar_screen.dart';
import 'bars/random_bar_screen.dart';
import 'profile/profile_screen.dart';
import 'messages/messages_screen.dart';

class ModernHomeScreen extends StatefulWidget {
  @override
  _ModernHomeScreenState createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _userCoins = 245; // Simulated user coins
  bool _isDarkMode = false;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  final List<BarModel> bars = [
    BarModel(
      id: 'romantic',
      name: 'Bar Romantique',
      description: 'Ambiance tamisée pour les cœurs passionnés',
      icon: Icons.favorite,
      color: Colors.pink[400]!,
      illustration: 'assets/bars/romantic_bar.png',
    ),
    BarModel(
      id: 'humor',
      name: 'Bar Humoristique',
      description: 'Défi du jour et éclats de rire',
      icon: Icons.sentiment_very_satisfied,
      color: Colors.orange[400]!,
      illustration: 'assets/bars/humor_bar.png',
    ),
    BarModel(
      id: 'pirates',
      name: 'Bar Pirates',
      description: 'Chasse au trésor et aventures',
      icon: Icons.sailing,
      color: Colors.brown[600]!,
      illustration: 'assets/bars/pirates_bar.png',
    ),
    BarModel(
      id: 'weekly',
      name: 'Bar Hebdomadaire',
      description: 'Groupe de 4 personnes (2H/2F)',
      icon: Icons.groups,
      color: Colors.blue[400]!,
      illustration: 'assets/bars/weekly_bar.png',
    ),
    BarModel(
      id: 'mystery',
      name: 'Bar Caché',
      description: 'Accès par énigmes et défis',
      icon: Icons.lock,
      color: Colors.purple[400]!,
      illustration: 'assets/bars/mystery_bar.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Theme(
      data: _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isDarkMode
                  ? [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                      const Color(0xFF0F3460),
                    ]
                  : [
                      const Color(0xFFFFF0F5),
                      const Color(0xFFFFE4E6),
                      const Color(0xFFFFC1CC),
                    ],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar moderne avec dégradé
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppThemes.primaryPink,
                            AppThemes.secondaryPink,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: _buildModernHeader(),
                    ),
                  ),
                ),
                
                // Contenu principal
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsSection(),
                        const SizedBox(height: 24),
                        _buildBarsSection(),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildModernBottomNav(),
        floatingActionButton: _buildAnimatedFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildModernHeader() {
    return AppAnimations.fadeIn(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'JeuTaime',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Trouvez l\'amour autrement',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                AnimatedCounter(
                  value: _userCoins,
                  label: 'Coins',
                  icon: Icons.monetization_on,
                  color: Colors.amber,
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isDarkMode = !_isDarkMode;
                    });
                  },
                  icon: Icon(
                    _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return AppAnimations.slideInFromBottom(
      child: Row(
        children: [
          Expanded(
            child: AnimatedCounter(
              value: 12,
              label: 'Matchs',
              icon: Icons.favorite,
              color: Colors.pink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedCounter(
              value: 8,
              label: 'Messages',
              icon: Icons.message,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedCounter(
              value: 5,
              label: 'Bars visités',
              icon: Icons.explore,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAnimations.fadeIn(
          child: Text(
            'Bars Disponibles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: bars.length,
          itemBuilder: (context, index) {
            return AppAnimations.scaleIn(
              child: _buildModernBarCard(bars[index], index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildModernBarCard(BarModel bar, int index) {
    return GradientCard(
      colors: [
        bar.color,
        bar.color.withOpacity(0.7),
      ],
      onTap: () => _navigateToBar(bar),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              bar.icon,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            bar.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            bar.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (bar.id == 'mystery')
            PulsingIcon(
              icon: Icons.lock,
              color: Colors.amber,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAnimations.fadeIn(
          child: Text(
            'Actions Rapides',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ModernButton(
                text: 'Messages',
                icon: Icons.chat_bubble,
                onPressed: () {
                  Navigator.push(
                    context,
                    AppAnimations.createRoute(page: MessagesScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernButton(
                text: 'Profil',
                icon: Icons.person,
                backgroundColor: AppThemes.accentOrange,
                onPressed: () {
                  Navigator.push(
                    context,
                    AppAnimations.createRoute(page: ProfileScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemes.primaryPink,
            AppThemes.secondaryPink,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppThemes.primaryPink.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explorer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Matchs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFAB() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton(
        onPressed: () {
          // Action pour le bouton central
          _showRandomMatch();
        },
        backgroundColor: AppThemes.accentOrange,
        child: const Icon(Icons.shuffle, color: Colors.white),
      ),
    );
  }

  void _navigateToBar(BarModel bar) {
    Widget screen;
    switch (bar.id) {
      case 'romantic':
        screen = RomanticBarScreen();
        break;
      case 'humor':
        screen = HumorBarScreen();
        break;
      case 'weekly':
        screen = WeeklyBarScreen();
        break;
      case 'mystery':
        screen = MysteryBarScreen();
        break;
      default:
        screen = RandomBarScreen();
    }

    Navigator.push(
      context,
      AppAnimations.createRoute(page: screen),
    );
  }

  void _showRandomMatch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            PulsingIcon(
              icon: Icons.favorite,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Match Aléatoire'),
          ],
        ),
        content: const Text('Voulez-vous découvrir votre match du jour ?'),
        actions: [
          ModernButton(
            text: 'Annuler',
            isOutlined: true,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          ModernButton(
            text: 'Découvrir',
            onPressed: () {
              Navigator.pop(context);
              // Logique de match aléatoire
            },
          ),
        ],
      ),
    );
  }
}