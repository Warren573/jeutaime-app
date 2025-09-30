import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Import des services offline
import 'services/offline_auth_service.dart';

// Import des thèmes modernes complets
import 'theme/app_themes.dart';
import 'theme/app_animations.dart';

// Import de l'écran moderne principal avec toutes les fonctionnalités
import 'screens/modern_home_screen.dart';

// Import des modèles
import 'models/user.dart' as app_user;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mode offline avec fonctionnalités modernes complètes
  print('🚀 JeuTaime MODERNE démarré - Toutes fonctionnalités activées');
  print('✨ Interface moderne avec animations');
  print('🎨 Thèmes Material Design 3');
  print('🏠 Écran d\'accueil avec composants avancés');

  // Initialiser les utilisateurs de test
  await OfflineAuthService.initializeTestUsers();

  runApp(JeuTaimeModernApp());
}

class JeuTaimeModernApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime - Version Moderne Complète',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: ModernHomeScreen(), // Écran principal avec toutes les fonctionnalités
    );
  }
}