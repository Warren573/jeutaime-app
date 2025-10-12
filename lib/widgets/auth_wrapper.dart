import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/gamification_service.dart';
import '../screens/auth/login_screen.dart';
import '../main_jeutaime.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialiser les services
      await AuthService.instance.initialize();
      await GamificationService.instance.getUserStats(); // Pré-charger les stats
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Erreur initialisation services: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF0F0F23),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFFFF6B9D),
                ),
                SizedBox(height: 20),
                Text(
                  'Initialisation...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: AuthService.instance.userStream,
      builder: (context, snapshot) {
        // Affichage du loader pendant la vérification
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              backgroundColor: Color(0xFF0F0F23),
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF6B9D),
                ),
              ),
            ),
          );
        }

        // Utilisateur connecté
        if (snapshot.hasData && snapshot.data != null) {
          return const JeuTaimeApp();
        }

        // Utilisateur non connecté
        return MaterialApp(
          title: 'JeuTaime - Connexion',
          theme: ThemeData(
            primarySwatch: Colors.pink,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F0F23),
            fontFamily: '-apple-system',
          ),
          home: const LoginScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// Widget pour vérifier si l'utilisateur a complété son profil
class ProfileCompletionChecker extends StatefulWidget {
  final Widget child;

  const ProfileCompletionChecker({
    super.key,
    required this.child,
  });

  @override
  State<ProfileCompletionChecker> createState() => _ProfileCompletionCheckerState();
}

class _ProfileCompletionCheckerState extends State<ProfileCompletionChecker> {
  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
  }

  Future<void> _checkProfileCompletion() async {
    // Attendre un peu pour que l'interface se charge
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final profile = AuthService.instance.currentProfile;
    if (profile != null && profile.profileCompletionPercentage < 0.5) {
      _showProfileCompletionDialog();
    }
  }

  void _showProfileCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.person_add,
              color: Color(0xFFFF6B9D),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Complétez votre profil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pour profiter pleinement de JeuTaime et obtenir de meilleurs matchs, complétez votre profil :',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.photo_camera, color: Color(0xFFFF6B9D), size: 20),
                SizedBox(width: 12),
                Text('Ajoutez une photo de profil', style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.info, color: Color(0xFFFF6B9D), size: 20),
                SizedBox(width: 12),
                Text('Rédigez une bio', style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.favorite, color: Color(0xFFFF6B9D), size: 20),
                SizedBox(width: 12),
                Text('Sélectionnez vos centres d\'intérêt', style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF6B9D).withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
                  SizedBox(width: 8),
                  Text(
                    '+100 XP pour un profil complet !',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Plus tard',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile-edit');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Compléter',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}