import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Import des services offline
import 'services/offline_auth_service.dart';

// Import des thèmes
import 'theme/app_themes.dart';

// Import des écrans modernes
import 'screens/modern_home_screen.dart';

// Import des modèles
import 'models/user.dart' as app_user;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mode offline - pas de Firebase
  print('🔧 JeuTaime démarré en MODE OFFLINE');
  print('✅ Pas de Firebase requis');

  // Initialiser les utilisateurs de test
  await OfflineAuthService.initializeTestUsers();

  runApp(JeuTaimeOfflineApp());
}

class JeuTaimeOfflineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime - Mode Offline',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
                home: ModernHomeScreen(), // Utiliser l'écran moderne directement
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  app_user.User? currentUser;

  @override
  void initState() {
    super.initState();
    // Écouter les changements d'état d'authentification
    _checkAuthState();
  }

  void _checkAuthState() {
    setState(() {
      currentUser = OfflineAuthService.currentUser;
    });

    // Ajouter un listener pour les changements
    OfflineAuthService.addAuthStateListener((user) {
      if (mounted) {
        setState(() {
          currentUser = user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Écran de chargement pendant la vérification
    if (currentUser == null) {
      return WelcomeScreen();
    }

    // Utilisateur connecté - aller à l'écran principal
    return MainScreen();
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF1493), // Deep Pink moderne
              Color(0xFFFF69B4), // Hot Pink
              Color(0xFF9D4EDD), // Purple moderne
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo et titre
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 80,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'JeuTaime',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mode Offline - Test',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 60),

                // Description
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Découvrez l\'amour dans des bars thématiques uniques !\n\n'
                    '🏛️ Bar Romantique\n'
                    '😄 Bar Humoristique\n'
                    '🏴‍☠️ Bar des Pirates\n'
                    '📅 Bar Hebdomadaire\n'
                    '🔍 Bar Mystérieux',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: 40),

                // Boutons de connexion
                Column(
                  children: [
                    // Connexion rapide de test
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _quickTestLogin(context),
                        icon: Icon(Icons.flash_on, color: Colors.white),
                        label: Text(
                          'Connexion Test Rapide',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF1493), // Deep Pink moderne
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Connexion Google simulée
                    Container(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _googleLogin(context),
                        icon: Icon(Icons.login, color: Colors.white),
                        label: Text(
                          'Test Connexion Google',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    // Info mode offline
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.white70,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Mode développement sans Firebase',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Future<void> _quickTestLogin(BuildContext context) async {
    try {
      // Se connecter avec le premier utilisateur de test
      await OfflineAuthService.signInWithEmail(
        email: 'emma@test.com',
        password: 'test123',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Connexion test réussie !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _googleLogin(BuildContext context) async {
    try {
      await OfflineAuthService.signInWithGoogle();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Connexion Google simulée !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(), // Écran original fonctionnel
    BarsScreen(),
    LettersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFFFF1493), // Deep Pink moderne
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_bar),
            label: 'Bars',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Lettres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// Écrans simplifiés pour le test
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = OfflineAuthService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenue ${user?.displayName ?? 'Utilisateur'}'),
        backgroundColor: Color(0xFFFF6B9D),
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Ressources utilisateur
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFFB74D)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildResourceItem(Icons.monetization_on, '${user?.coins ?? 0}', 'Coins'),
                  _buildResourceItem(Icons.favorite, '${user?.badges.length ?? 0}', 'Badges'),
                  _buildResourceItem(Icons.diamond, user?.isPremium == true ? '1' : '0', 'Premium'),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Actions rapides
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    context,
                    Icons.local_bar,
                    'Bars Thématiques',
                    'Découvrir',
                    Color(0xFF4ECDC4),
                    () {},
                  ),
                  _buildActionCard(
                    context,
                    Icons.mail,
                    'Mes Lettres',
                    'Lire',
                    Color(0xFFFF6B9D),
                    () {},
                  ),
                  _buildActionCard(
                    context,
                    Icons.person,
                    'Mon Profil',
                    'Voir',
                    Color(0xFF9C27B0),
                    () {},
                  ),
                  _buildActionCard(
                    context,
                    Icons.settings,
                    'Déconnexion',
                    'Test',
                    Color(0xFF757575),
                    () => _logout(context),
                  ),
                ],
              ),
            ),

            // Info mode offline
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode offline actif - Toutes les fonctionnalités disponibles !',
                      style: TextStyle(color: Colors.green[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(IconData icon, String amount, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await OfflineAuthService.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Déconnexion réussie'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Écrans de base pour la navigation
class BarsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bars Thématiques'),
        backgroundColor: Color(0xFF4ECDC4),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_bar, size: 80, color: Color(0xFF4ECDC4)),
            SizedBox(height: 16),
            Text(
              'Bars Thématiques',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Mode offline - Fonctionnalités complètes disponibles',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class LettersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Lettres'),
        backgroundColor: Color(0xFFFF6B9D),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail, size: 80, color: Color(0xFFFF6B9D)),
            SizedBox(height: 16),
            Text(
              'Système de Lettres',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Mode offline - 6 templates disponibles',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = OfflineAuthService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil'),
        backgroundColor: Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF9C27B0),
                    backgroundImage: user.avatarUrl != null 
                        ? NetworkImage(user.avatarUrl!) 
                        : null,
                    child: user.avatarUrl == null 
                        ? Text(
                            user.displayName.isNotEmpty ? user.displayName[0] : 'U',
                            style: TextStyle(fontSize: 32, color: Colors.white),
                          )
                        : null,
                  ),

                  SizedBox(height: 16),

                  // Infos utilisateur
                  Text(
                    user.displayName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  
                  if (user.bio != null) ...[
                    SizedBox(height: 8),
                    Text(
                      user.bio!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Statistiques
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildStatRow('Email', user.email),
                        _buildStatRow('Âge', '${user.age} ans'),
                        if (user.city != null) _buildStatRow('Ville', user.city!),
                        _buildStatRow('Membre depuis', _formatDate(user.createdAt)),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Ressources
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildResourceChip(Icons.monetization_on, '${user.coins}', 'Coins'),
                      _buildResourceChip(Icons.favorite, '${user.badges.length}', 'Badges'),
                      _buildResourceChip(Icons.diamond, user.isPremium ? '✅' : '❌', 'Premium'),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildResourceChip(IconData icon, String amount, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF9C27B0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Color(0xFF9C27B0)),
          SizedBox(width: 4),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 2),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
                   'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}