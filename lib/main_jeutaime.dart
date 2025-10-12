import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/swipeable_card.dart';
import 'widgets/optimized_widgets.dart';
import 'utils/performance_optimizer.dart';
import 'utils/feedback_system.dart';
import 'utils/error_handler.dart';
import 'utils/responsive_helper.dart';
import 'screens/shop_screen.dart';
import 'screens/letter_write_screen.dart';
import 'screens/letters_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/romantic_bar_screen.dart';
import 'screens/humorous_bar_screen.dart';
import 'screens/pirates_bar_screen.dart';
import 'screens/pet_mode_selection_screen.dart';
import 'screens/weekly_bar_screen.dart';
import 'screens/secret_bar_screen.dart';
import 'screens/reactivity_game_screen.dart';
import 'screens/puzzle_challenge_screen.dart';
import 'screens/precision_master_screen.dart';
import 'screens/tic_tac_toe_screen.dart';
import 'screens/breakout_screen.dart';
import 'screens/adoption_screen.dart';
import 'screens/card_game_screen.dart';
import 'screens/continue_histoire_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/advanced_filters_screen.dart';
import 'screens/gamification_screen.dart';
import 'services/matching_algorithm.dart';
import 'services/location_service.dart';
import 'services/gamification_service.dart';
import 'widgets/progress_widget.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const JeuTaimeApp());
}

class JeuTaimeApp extends StatelessWidget {
  const JeuTaimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime - Rencontres authentiques',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0a0a0a),
        fontFamily: '-apple-system',
      ),
      home: const JeuTaimeHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class JeuTaimeHomePage extends StatefulWidget {
  const JeuTaimeHomePage({super.key});

  @override
  State<JeuTaimeHomePage> createState() => _JeuTaimeHomePageState();
}

class _JeuTaimeHomePageState extends State<JeuTaimeHomePage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _coins = 245;
  int _previousCoins = 245;
  
  // Animation controllers optimisés
  late AnimationController _swipeController;
  late AnimationController _pageController;
  late Animation<double> _swipeAnimation;
  late Animation<double> _pageAnimation;
  
  // Profile data & Matching
  int _currentProfileIndex = 0;
  List<MatchedUser> _matchedUsers = [];
  AdvancedFilters? _currentFilters;
  Position? _userPosition;
  UserProfile? _currentUserProfile;
  
  // Données de profils étendues
  final List<Map<String, dynamic>> _profiles = [
    {
      'name': 'Maxime, 31 ans',
      'location': 'Paris 10ème • 2.3 km',
      'job': 'Architecte',
      'interests': 'Art, voyages, jazz, cuisine italienne',
      'compatibility': 89,
    },
    {
      'name': 'Sophie, 27 ans',
      'location': 'Paris 11ème • 2.1 km',
      'job': 'Journaliste',
      'interests': 'Littérature, voyages',
      'compatibility': 92,
    },
    {
      'name': 'Claire, 30 ans',
      'location': 'Paris 9ème • 1.8 km',
      'job': 'Designer graphique',
      'interests': 'Art, yoga',
      'compatibility': 85,
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Animation controllers optimisés
    _swipeController = PerformanceOptimizer.createOptimizedController(
      vsync: this,
      duration: PerformanceConstants.normalAnimation,
    );
    _pageController = PerformanceOptimizer.createOptimizedController(
      vsync: this,
      duration: PerformanceConstants.fastAnimation,
    );
    
    _swipeAnimation = _swipeController.smoothCurve;
    _pageAnimation = _pageController.smoothCurve;
    
    // Animation d'entrée
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.forward();
      _initializeMatchingSystem();
    });
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _updateCoins(int amount) {
    setState(() {
      _previousCoins = _coins;
      _coins += amount;
    });
    
    // Feedback haptique pour les changements de coins
    if (amount > 0) {
      PerformanceOptimizer.hapticFeedback(HapticFeedbackType.selectionClick);
    }
  }

  // === SYSTÈME DE MATCHING AVANCÉ ===

  void _initializeMatchingSystem() async {
    await _initializeUserLocation();
    await _createCurrentUserProfile();
    await _loadAndRankProfiles();
  }

  Future<void> _initializeUserLocation() async {
    try {
      _userPosition = await LocationService.instance.getCurrentPosition();
      if (_userPosition != null) {
        print('Position utilisateur obtenue: ${_userPosition!.latitude}, ${_userPosition!.longitude}');
      }
    } catch (e) {
      print('Erreur localisation: $e');
    }
  }

  Future<void> _createCurrentUserProfile() async {
    // Création du profil utilisateur (normalement depuis Firebase)
    if (_userPosition != null) {
      final userLocation = await _userPosition!.toUserLocation();
      
      _currentUserProfile = UserProfile(
        id: 'current_user',
        name: 'Utilisateur Test',
        age: 28,
        location: userLocation,
        interests: ['Voyage', 'Sport', 'Musique', 'Cuisine', 'Art'],
        lifestyle: const Lifestyle(
          socialActivity: 4,
          fitnessLevel: 3,
          dietType: 'Omnivore',
          smoking: false,
          drinking: true,
        ),
        personality: const Personality(
          extraversion: 4,
          openness: 5,
          conscientiousness: 3,
        ),
        education: 'Master',
        professionCategory: 'Technology',
        preferences: const UserPreferences(
          ageRange: AgeRange(min: 22, max: 35),
          maxDistance: 25.0,
        ),
      );
    }
  }

  Future<void> _loadAndRankProfiles() async {
    if (_currentUserProfile == null) return;

    // Génération de profils de test (normalement depuis Firebase)
    final testProfiles = await _generateTestProfiles();
    
    // Application des filtres si définis
    List<UserProfile> filteredProfiles = testProfiles;
    if (_currentFilters != null) {
      filteredProfiles = MatchingAlgorithm.filterProfiles(
        testProfiles,
        _currentUserProfile!,
        _currentFilters!,
      );
    }

    // Classement par compatibilité
    _matchedUsers = MatchingAlgorithm.rankProfiles(
      filteredProfiles,
      _currentUserProfile!,
    );

    setState(() {});
  }

  Future<List<UserProfile>> _generateTestProfiles() async {
    if (_userPosition == null) return [];

    // Génération de positions aléatoires autour de l'utilisateur
    final positions = LocationService.generateRandomPositionsInRadius(
      _userPosition!,
      50.0, // 50km de rayon
      20, // 20 profils
    );

    final profiles = <UserProfile>[];
    final names = ['Emma', 'Léa', 'Chloé', 'Inès', 'Manon', 'Jade', 'Louise', 'Lina'];
    final interests = [
      ['Voyage', 'Photographie', 'Cuisine'],
      ['Sport', 'Musique', 'Danse'],
      ['Art', 'Lecture', 'Cinéma'],
      ['Nature', 'Randonnée', 'Yoga'],
      ['Tech', 'Gaming', 'Innovation'],
      ['Mode', 'Shopping', 'Beauty'],
      ['Fitness', 'Nutrition', 'Wellness'],
      ['Culture', 'Histoire', 'Musées'],
    ];

    for (int i = 0; i < positions.length && i < names.length; i++) {
      final userLocation = await positions[i].toUserLocation();
      
      profiles.add(UserProfile(
        id: 'user_$i',
        name: '${names[i % names.length]}, ${22 + i % 10} ans',
        age: 22 + i % 10,
        location: userLocation,
        interests: interests[i % interests.length],
        lifestyle: Lifestyle(
          socialActivity: 2 + i % 4,
          fitnessLevel: 1 + i % 5,
          dietType: ['Omnivore', 'Végétarien', 'Végétalien'][i % 3],
          smoking: i % 4 == 0,
          drinking: i % 3 != 0,
        ),
        personality: Personality(
          extraversion: 1 + i % 5,
          openness: 1 + i % 5,
          conscientiousness: 1 + i % 5,
        ),
        education: ['Licence', 'Master', 'BTS/DUT'][i % 3],
        professionCategory: ['Technology', 'Art & Design', 'Santé'][i % 3],
        preferences: const UserPreferences(
          ageRange: AgeRange(min: 25, max: 40),
          maxDistance: 30.0,
        ),
      ));
    }

    return profiles;
  }

  void _openAdvancedFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdvancedFiltersScreen(
          initialFilters: _currentFilters,
          onFiltersChanged: (filters) {
            setState(() {
              _currentFilters = filters;
            });
            _loadAndRankProfiles();
          },
        ),
      ),
    );
  }

  void _refreshMatches() {
    _loadAndRankProfiles();
  }

  void _openAdminInterface() {
    // Vérification simple pour l'exemple (remplacer par vrai check Firebase)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Row(
          children: [
            Text('🔧', style: TextStyle(fontSize: 24)),
            SizedBox(width: 10),
            Text('Accès Administration', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir accéder à l\'interface administrateur ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              OptimizedWidgets.navigateWithTransition(
                context: context,
                destination: const AdminDashboardScreen(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Accéder'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFFE91E63))),
          ),
        ],
      ),
    );
  }

  void _openGamificationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GamificationScreen(),
      ),
    );
  }

  void _showNewLetterDialog() {
    final matches = [
      {'name': 'Emma', 'avatar': 'E', 'compatibility': 92},
      {'name': 'Lucas', 'avatar': 'L', 'compatibility': 88},
      {'name': 'Claire', 'avatar': 'C', 'compatibility': 85},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('✍️ Nouvelle lettre', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choisissez votre destinataire', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const Text('💕 Vos matchs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...matches.map((match) => ListTile(
              dense: true,
              leading: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFC2185B)]),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(match['avatar'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              title: Text('${match['name']}, 27 ans', style: const TextStyle(color: Colors.white)),
              subtitle: Text('💚 Compatibilité : ${match['compatibility']}%', style: const TextStyle(color: Colors.green, fontSize: 12)),
              trailing: const Text('50 🪙', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _openLetterWrite(match['name'] as String, match['avatar'] as String, isFirstLetter: true);
              },
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _openLetterConversation(String name, String avatar) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: Text('💌 Conversation avec $name', style: const TextStyle(color: Colors.white)),
        content: const Text('Fonctionnalité de lecture des lettres en développement...', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openLetterWrite(name, avatar);
            },
            child: const Text('✍️ Répondre', style: TextStyle(color: Color(0xFFE91E63))),
          ),
        ],
      ),
    );
  }

  void _openLetterWrite(String name, String avatar, {bool isFirstLetter = false}) {
    final cost = isFirstLetter ? 50 : 30;
    
    if (_coins < cost) {
      ErrorHandler.handleInsufficientCoinsError(
        context: context,
        required: cost,
        current: _coins,
      );
      return;
    }

    OptimizedWidgets.navigateWithTransition(
      context: context,
      destination: LetterWriteScreen(
        recipientName: name,
        recipientAvatar: avatar,
        currentCoins: _coins,
        onCoinsUpdated: (amount) {
          _updateCoins(amount);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildCurrentScreen(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
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
        border: Border(bottom: BorderSide(color: Color(0xFF333333))),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFFF4081)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'UT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // User info
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Utilisateur, 28 👑',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Paris, France',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions (Progression + Admin)
              Row(
                children: [
                  // Bouton Gamification
                  OptimizedWidgets.smoothButton(
                    text: 'Stats',
                    icon: Icons.trending_up,
                    onPressed: _openGamificationScreen,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B9D), Color(0xFFC147E9)],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  const SizedBox(width: 10),
                  // Admin button optimisé
                  OptimizedWidgets.smoothButton(
                    text: 'Admin',
                    icon: Icons.settings,
                    onPressed: _openAdminInterface,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  const SizedBox(width: 15),
                  // Coins avec animation
                  OptimizedWidgets.buildAnimatedCoinCounter(
                    coins: _coins,
                    previousCoins: _previousCoins,
                  ),
                ],
              ),
            ],
          ),
          
          // Widget de progression
          const SizedBox(height: 16),
          const ProgressWidget(),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    Widget screen;
    
    switch (_currentIndex) {
      case 0:
        screen = _buildHomeScreen();
        break;
      case 1:
        screen = _buildProfilesScreen();
        break;
      case 2:
        screen = _buildSocialScreen();
        break;
      case 3:
        screen = _buildMagicScreen();
        break;
      case 4:
        screen = _buildLettersScreen();
        break;
      case 5:
        screen = _buildSettingsScreen();
        break;
      default:
        screen = _buildHomeScreen();
    }
    
    // Animation d'apparition pour le contenu
    return AnimatedBuilder(
      animation: _pageAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _pageAnimation.value)),
          child: Opacity(
            opacity: _pageAnimation.value,
            child: screen,
          ),
        );
      },
    );
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec solde
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.favorite, color: Color(0xFFE91E63), size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bienvenue sur JeuTaime ! 💕',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.white, size: 18),
                          const SizedBox(width: 5),
                          Text(
                            '$_coins pièces',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Statistiques rapides
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: '👥',
                  title: 'Profils vus',
                  value: '$_currentProfileIndex',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  icon: '💕',
                  title: 'Likes donnés',
                  value: '12',
                  color: Colors.pink,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  icon: '✉️',
                  title: 'Lettres',
                  value: '5',
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Section Matching Avancé
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🎯 Matchs Compatibles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _openAdvancedFilters,
                    icon: const Icon(
                      Icons.tune,
                      color: Color(0xFFE91E63),
                    ),
                    tooltip: 'Filtres avancés',
                  ),
                  IconButton(
                    onPressed: _refreshMatches,
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                    tooltip: 'Actualiser',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Liste des matchs avec compatibilité
          if (_matchedUsers.isNotEmpty) ...[
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _matchedUsers.take(5).length,
                itemBuilder: (context, index) {
                  final match = _matchedUsers[index];
                  return _buildMatchCard(match);
                },
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Text(
                    'Recherche de profils compatibles...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 25),

          // Actions rapides
          const Text(
            '🚀 Actions Rapides',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          // Grille d'actions responsive
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: ResponsiveHelper.responsiveColumns(context),
            crossAxisSpacing: ResponsiveHelper.isMobile(context) ? 10 : 15,
            mainAxisSpacing: ResponsiveHelper.isMobile(context) ? 10 : 15,
            childAspectRatio: ResponsiveHelper.responsiveAspectRatio(context),
            children: [
              _buildQuickActionCard(
                icon: '👥',
                title: 'Découvrir',
                subtitle: 'Nouveaux profils',
                onTap: () => setState(() => _currentIndex = 1),
                gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
              ),
              _buildQuickActionCard(
                icon: '🍻',
                title: 'Les Bars',
                subtitle: 'Ambiances uniques',
                onTap: () => setState(() => _currentIndex = 2),
                gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
              ),
              _buildQuickActionCard(
                icon: '🎮',
                title: 'Mini-Jeux',
                subtitle: 'Gagnez des pièces',
                onTap: () => setState(() => _currentIndex = 3),
                gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
              ),
              _buildQuickActionCard(
                icon: '✉️',
                title: 'Mes Lettres',
                subtitle: 'Conversations',
                onTap: () => setState(() => _currentIndex = 4),
                gradient: const LinearGradient(colors: [Colors.purple, Colors.pink]),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Section nouvelles fonctionnalités
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1e1e1e),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE91E63), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.new_releases, color: Color(0xFFE91E63)),
                    SizedBox(width: 8),
                    Text(
                      '✨ Nouveautés !',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildFeatureItem(
                  icon: '🎴',
                  title: 'Jeu de Cartes',
                  description: 'Nouveau jeu de chance et stratégie !',
                  isNew: true,
                ),
                _buildFeatureItem(
                  icon: '🎭',
                  title: 'Continue l\'Histoire',
                  description: 'Créez des histoires ensemble dans les bars',
                  isNew: true,
                ),
                _buildFeatureItem(
                  icon: '💎',
                  title: 'Système de Bars amélioré',
                  description: 'Plus d\'activités et de récompenses',
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Conseils du jour
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade800, Colors.indigo.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '💡 Conseil du jour',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Participez aux activités des bars pour gagner des pièces et rencontrer des personnes partageant vos centres d\'intérêt !',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _currentIndex = 2),
                  icon: const Icon(Icons.explore),
                  label: const Text('Explorer les bars'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Dev Zone (gardée mais plus discrète)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade700, width: 1),
              borderRadius: BorderRadius.circular(15),
              color: const Color(0xFF2a2a2a),
            ),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🛠️ Outils de Test',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildSmallButton('� Admin', () {
                      _openAdminInterface();
                    }),
                    _buildSmallButton('�👤 Test User', () {
                      _showMessage('✅ Utilisateur test créé !', 'Profil généré');
                    }),
                    _buildSmallButton('⚙️ Profil', () {}),
                    _buildSmallButton('👥 Profils', () {
                      setState(() => _currentIndex = 1);
                    }),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchedUser match) {
    final score = match.compatibilityScore.round();
    final scoreColor = score >= 85 
        ? Colors.green 
        : score >= 70 
            ? Colors.orange 
            : Colors.grey;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: scoreColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Score de compatibilité
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Text(
              '${score}% compatible',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scoreColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar et nom
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFE91E63),
                        child: Text(
                          match.profile.name.substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              match.profile.name.split(',')[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${match.profile.age} ans',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Distance
                  if (_userPosition != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${LocationService.calculateDistance(
                            _userPosition!.latitude,
                            _userPosition!.longitude,
                            match.profile.location.latitude,
                            match.profile.location.longitude,
                          ).toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Raisons du match (première raison)
                  if (match.matchReasons.isNotEmpty)
                    Text(
                      match.matchReasons.first,
                      style: const TextStyle(
                        color: Color(0xFFE91E63),
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String title,
    required String description,
    bool isNew = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isNew) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF444444),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(text),
    );
  }

  Widget _buildProfilesScreen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👤 Découverte',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Profils disponibles : ${_profiles.length - _currentProfileIndex}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          // Profile Stack
          Expanded(
            child: _buildProfileStack(),
          ),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: '😕',
                color: Colors.red,
                onTap: () => _passProfile(),
              ),
              const SizedBox(width: 40),
              _buildActionButton(
                icon: '😊',
                color: Colors.green,
                onTap: () => _likeProfile(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              '💡 Swipez ou utilisez les boutons',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStack() {
    if (_currentProfileIndex >= _profiles.length) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('👤', style: TextStyle(fontSize: 64, color: Colors.grey)),
            SizedBox(height: 20),
            Text(
              'Plus de profils disponibles',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Revenez plus tard pour découvrir de nouvelles personnes !',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Background cards (static)
        for (int i = 2; i >= 1; i--)
          if (_currentProfileIndex + i < _profiles.length)
            Positioned.fill(
              child: Transform.scale(
                scale: 1 - (i * 0.03),
                child: Transform.translate(
                  offset: Offset(0, i * 5.0),
                  child: Opacity(
                    opacity: 1 - (i * 0.15),
                    child: _buildProfileCard(_profiles[_currentProfileIndex + i], false),
                  ),
                ),
              ),
            ),
        // Top card (swipeable)
        if (_currentProfileIndex < _profiles.length)
          Positioned.fill(
            child: SwipeableCard(
              onSwipeLeft: _passProfile,
              onSwipeRight: _likeProfile,
              child: _buildProfileCard(_profiles[_currentProfileIndex], true),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Photo area (blurred)
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD3D3D3), Color(0xFFA9A9A9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('📸', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 10),
                      Text(
                        'Photo visible avec',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '10 lettres échangées ou Premium',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Profile details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '📍 ${profile['location']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '💼 ${profile['job']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  Text(
                    '✨ ${profile['interests']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '✨ Compatibilité : ${profile['compatibility']}%',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(icon, style: const TextStyle(fontSize: 36)),
        ),
      ),
    );
  }

  void _likeProfile() {
    if (_currentProfileIndex < _profiles.length) {
      final profile = _profiles[_currentProfileIndex];
      final name = profile['name'].split(',')[0];
      
      _updateCoins(-25);
      FeedbackSystem.showSuccessAnimation(
        context: context,
        message: '😊 Sourire envoyé à $name !',
      );
      
      setState(() {
        _currentProfileIndex++;
      });
    }
  }

  void _passProfile() {
    if (_currentProfileIndex < _profiles.length) {
      final profile = _profiles[_currentProfileIndex];
      final name = profile['name'].split(',')[0];
      
      FeedbackSystem.showToast(
        context: context,
        message: 'Profil passé : $name',
        icon: '➡️',
      );
      
      setState(() {
        _currentProfileIndex++;
      });
    }
  }

  Widget _buildSocialScreen() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Social',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1e1e1e),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const TabBar(
              indicator: BoxDecoration(
                color: Color(0xFFE91E63),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: '🍸 Bars'),
                Tab(text: '🎮 Jeux'),
                Tab(text: '💝 Adoption'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              children: [
                _buildBarsTab(),
                _buildGamesTab(),
                _buildAdoptionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rejoignez des bars thématiques pour rencontrer d\'autres célibataires dans une ambiance unique !',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildBarCard(
                  title: '🌹 Bar Romantique',
                  description: 'Dîners aux chandelles et soirées poétiques',
                  members: 42,
                  isActive: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B0000), Color(0xFFDC143C)],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RomanticBarScreen(
                          onCoinsUpdated: (amount) => _updateCoins(amount),
                          currentCoins: _coins,
                        ),
                      ),
                    );
                  },
                ),
                
                _buildBarCard(
                  title: '😄 Bar Humoristique',
                  description: 'Rires garantis et jeux de mots douteux',
                  members: 38,
                  isActive: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HumorousBarScreen(
                        onCoinsUpdated: _updateCoins,
                        currentCoins: _coins,
                      ),
                    ),
                  ),
                ),
                
                _buildBarCard(
                  title: '🏴‍☠️ Bar des Pirates',
                  description: 'Aventures et chasses au trésor',
                  members: 29,
                  isActive: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F4F4F), Color(0xFF708090)],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PiratesBarScreen(
                        onCoinsUpdated: _updateCoins,
                        currentCoins: _coins,
                      ),
                    ),
                  ),
                ),
                
                _buildBarCard(
                  title: '📅 Bar Hebdomadaire',
                  description: 'Événement spécial chaque semaine',
                  members: 51,
                  isActive: true,
                  specialBadge: 'SPÉCIAL',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4B0082), Color(0xFF9370DB)],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeeklyBarScreen(
                        onCoinsUpdated: _updateCoins,
                        currentCoins: _coins,
                      ),
                    ),
                  ),
                ),
                
                _buildBarCard(
                  title: '🤫 Bar Secret',
                  description: 'Mystères et surprises exclusives',
                  members: 7,
                  isActive: true,
                  isSecret: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1C1C1C), Color(0xFF333333)],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SecretBarScreen(
                        onCoinsUpdated: _updateCoins,
                        currentCoins: _coins,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarCard({
    required String title,
    required String description,
    required int members,
    required bool isActive,
    required LinearGradient gradient,
    required VoidCallback onTap,
    String? specialBadge,
    bool isSecret = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive 
                  ? Colors.white.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (specialBadge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              specialBadge,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          isActive ? Icons.circle : Icons.pause_circle_outline,
                          color: isActive ? Colors.green : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isActive ? 'Actif' : 'Fermé',
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Icon(Icons.people, color: Colors.white70, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          isSecret ? '?' : '$members membres',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isActive)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStoryModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.auto_stories, color: Color(0xFFE91E63)),
            SizedBox(width: 10),
            Text('🎭 Continue l\'Histoire', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisissez votre mode de jeu :',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            
            // Mode Groupe/Bar
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF9C27B0),
                child: Icon(Icons.groups, color: Colors.white),
              ),
              title: const Text('🍻 Mode Bar/Groupe', style: TextStyle(color: Colors.white)),
              subtitle: const Text('2-8 joueurs - Ambiance détendue', style: TextStyle(color: Colors.white70)),
              onTap: () {
                Navigator.pop(context);
                _showPlayerCountDialog();
              },
            ),
            
            const SizedBox(height: 10),
            
            // Mode Romantique
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE91E63),
                child: Icon(Icons.favorite, color: Colors.white),
              ),
              title: const Text('💕 Mode Romantique', style: TextStyle(color: Colors.white)),
              subtitle: const Text('2 joueurs - Histoire d\'amour', style: TextStyle(color: Colors.white70)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContinueHistoireScreen(
                      playersCount: 2,
                      isBarMode: false,
                      onCoinsUpdated: (coins) {
                        setState(() {
                          _coins += coins;
                        });
                      },
                      currentCoins: _coins,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showPlayerCountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('🍻 Combien de joueurs ?', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [2, 3, 4, 5, 6, 8].map((count) => 
            ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF9C27B0),
                child: Text(count.toString(), style: const TextStyle(color: Colors.white)),
              ),
              title: Text('$count joueurs', style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContinueHistoireScreen(
                      playersCount: count,
                      isBarMode: true,
                      onCoinsUpdated: (coins) {
                        setState(() {
                          _coins += coins;
                        });
                      },
                      currentCoins: _coins,
                    ),
                  ),
                );
              },
            ),
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildGamesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            '🎮 MINI-JEUX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Entraînez votre réactivité et gagnez des pièces !',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                // Jeu de Réactivité (Taupe)
                _buildGameCard(
                  emoji: '⚡',
                  title: 'Jeu de Réactivité',
                  subtitle: 'Tapez sur les cibles blanches !',
                  description: 'Grille 4x4 avec des cibles qui apparaissent. Tapez sur les blanches, évitez les jaunes. 30 secondes pour faire le meilleur score !',
                  gradient: LinearGradient(
                    colors: [const Color(0xFFE91E63), const Color(0xFFAD1457)],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReactivityGameScreen(
                          onCoinsUpdated: (coins) {
                            setState(() {
                              _coins += coins;
                            });
                          },
                          currentCoins: _coins,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 15),
                
                // Puzzle Challenge
                _buildGameCard(
                  emoji: '🧩',
                  title: 'Puzzle Challenge',
                  subtitle: 'Remettez les chiffres dans l\'ordre',
                  description: 'Puzzle coulissant 3x3 avec les chiffres 1-8. Résolvez rapidement pour obtenir des bonus de temps !',
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade800],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PuzzleChallengeScreen(
                          onCoinsUpdated: (coins) {
                            setState(() {
                              _coins += coins;
                            });
                          },
                          currentCoins: _coins,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 15),
                
                // Précision Master
                _buildGameCard(
                  emoji: '🎯',
                  title: 'Précision Master',
                  subtitle: 'Visez au centre des cibles',
                  description: 'Cibles qui apparaissent aléatoirement. Plus vous visez près du centre, plus vous gagnez de points !',
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade600, Colors.orange.shade800],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrecisionMasterScreen(
                          onCoinsUpdated: (coins) {
                            setState(() {
                              _coins += coins;
                            });
                          },
                          currentCoins: _coins,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 15),
                
                // Morpion
                _buildGameCard(
                  emoji: '⭕',
                  title: 'Morpion',
                  subtitle: 'Local ou multijoueur',
                  description: 'Jeu classique du Tic-Tac-Toe. Jouez en mode local à 2 ou en multijoueur en ligne !',
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade800],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicTacToeScreen(
                          onCoinsUpdated: (coins) {
                            setState(() {
                              _coins += coins;
                            });
                          },
                          currentCoins: _coins,
                        ),
                      ),
                    );
                  },
                ),
                
                // Casse-Briques
                _buildGameCard(
                  emoji: '🧱',
                  title: 'Casse-Briques',
                  subtitle: 'Classique rétro',
                  description: 'Cassez toutes les briques avec votre balle ! Contrôlez la raquette et visez la perfection.',
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade600, Colors.orange.shade800],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BreakoutScreen(
                          onCoinsUpdated: (coins) {
                            setState(() {
                              _coins += coins;
                            });
                          },
                          currentCoins: _coins,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 15),
                
                // Jeu de Cartes
                _buildGameCard(
                  emoji: '🎴',
                  title: 'Jeu de Cartes',
                  subtitle: 'Chance et stratégie',
                  description: 'Retournez les cartes pour révéler leurs couleurs. Trouvez les cœurs pour gagner, mais attention aux pièges !',
                  gradient: LinearGradient(
                    colors: [const Color(0xFFE91E63), const Color(0xFFAD1457)],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardGameScreen(
                          onCoinsUpdated: (coins) {
                            setState(() {
                              _coins += coins;
                            });
                          },
                          currentCoins: _coins,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 15),
                
                // Continue l'Histoire
                _buildGameCard(
                  emoji: '🎭',
                  title: 'Continue l\'Histoire',
                  subtitle: 'Créativité collaborative',
                  description: 'Créez ensemble une histoire drôle, romantique ou totalement folle ! Parfait pour briser la glace en groupe.',
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade600, Colors.purple.shade800],
                  ),
                  onTap: () {
                    _showStoryModeDialog();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String emoji,
    required String title,
    required String subtitle,
    required String description,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                description,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '🎮 JOUER',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdoptionTab() {
    return PetModeSelectionScreen(
      onCoinsUpdated: (coins) {
        setState(() {
          _coins += coins;
        });
      },
      currentCoins: _coins,
    );
  }

  Widget _buildMagicScreen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✨ Magie',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Fonctionnalités magiques à venir...',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A148C).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Text('🔮', style: TextStyle(fontSize: 64)),
                      SizedBox(height: 20),
                      Text(
                        'Magie en Préparation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Des fonctionnalités magiques arrivent bientôt pour rendre vos rencontres encore plus spéciales !\n\n� Algorithmes d\'affinité mystiques\n🌟 Suggestions personnalisées\n✨ Expériences immersives',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e1e1e),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: const Column(
                    children: [
                      Text('💡', style: TextStyle(fontSize: 32)),
                      SizedBox(height: 10),
                      Text(
                        'En attendant, explorez les bars thématiques dans l\'onglet Social !',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  void _showBarComingSoon(String barName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('🏗️ $barName', style: const TextStyle(color: Colors.white)),
        content: const Text(
          'Ce bar thématique sera bientôt disponible ! Restez connecté pour ne pas manquer l\'ouverture.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris !', style: TextStyle(color: Color(0xFFE91E63))),
          ),
        ],
      ),
    );
  }

  Widget _buildLettersScreen() {
    return const LettersScreen();
  }



  Widget _buildSettingsScreen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚙️ Paramètres',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Profil
          _buildSettingsCard(
            title: '👤 Profil',
            children: [
              ListTile(
                title: const Text(
                  'Modifier mon profil',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          // Notifications
          _buildSettingsCard(
            title: '🔔 Notifications',
            children: [
              _buildSettingItem('Notifications push', true),
            ],
          ),
          // Privacy
          _buildSettingsCard(
            title: '🛡️ Confidentialité',
            children: [
              _buildSettingItem('Profil visible', true),
            ],
          ),
          // Premium
          _buildSettingsCard(
            title: '💳 Abonnement Premium',
            children: [
              const ListTile(
                title: Text(
                  'Votre abonnement est actif',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: _buildButton('Gérer mon abonnement', () {
                  _showMessage('💳 Abonnement', 'Fonctionnalité en développement...');
                }),
              ),
            ],
          ),
          
          // Admin Section
          _buildSettingsCard(
            title: '🔧 Administration',
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: const Text('🔧', style: TextStyle(fontSize: 20)),
                ),
                title: const Text(
                  'Interface Administrateur',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Gérer l\'application, bars et utilisateurs',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.purple, size: 16),
                onTap: _openAdminInterface,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          _buildButton(
            'Déconnexion',
            () {
              _showMessage('👋 Déconnexion', 'À bientôt sur JeuTaime !');
            },
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, bool value) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          // Handle switch change
        },
        activeColor: const Color(0xFFE91E63),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        border: const Border(top: BorderSide(color: Color(0xFF333333))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _currentIndex,
        onTap: (index) {
          // Animation de navigation avec feedback haptique
          PerformanceOptimizer.hapticFeedback(HapticFeedbackType.selectionClick);
          
          setState(() {
            _currentIndex = index;
          });
          
          // Relancer l'animation de page
          _pageController.reset();
          _pageController.forward();
        },
        selectedItemColor: const Color(0xFFE91E63),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          _buildNavItem('🏠', 'Accueil', 0),
          _buildNavItem('👤', 'Profils', 1),
          _buildNavItem('👥', 'Social', 2),
          _buildNavItem('✨', 'Magie', 3),
          _buildNavItem('�', 'Lettres', 4),
          _buildNavItem('⚙️', 'Paramètres', 5),
        ],
      ),
    );
  }
  
  BottomNavigationBarItem _buildNavItem(String emoji, String label, int index) {
    final isSelected = _currentIndex == index;
    
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: PerformanceConstants.fastAnimation,
        curve: PerformanceConstants.defaultCurve,
        padding: EdgeInsets.all(isSelected ? 8 : 4),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color(0xFFE91E63).withOpacity(0.2)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          emoji, 
          style: TextStyle(
            fontSize: isSelected ? 24 : 22,
          ),
        ),
      ),
      label: label,
    );
  }

  // Utility buttons
  Widget _buildButton(String text, VoidCallback onPressed, {Color? color}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFFE91E63),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE91E63),
          side: const BorderSide(color: Color(0xFFE91E63), width: 2),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2a2a2a),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF444444)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}