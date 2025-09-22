import 'package:flutter/material.dart';
// Écrans principaux
import '../screens/welcome_screen.dart';
import '../screens/home_screen.dart';
// Écrans d'authentification
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/verification_screen.dart';
// Écrans de bars
import '../screens/bars/romantic_bar_screen.dart';
import '../screens/bars/humor_bar_screen.dart';
import '../screens/bars/weekly_bar_screen.dart';
import '../screens/bars/mystery_bar_screen.dart';
import '../screens/bars/random_bar_screen.dart';
import '../screens/bars/bars_hub_screen.dart';
import '../screens/bars/humor_challenge_screen.dart';
// Écrans de quiz et jeux
import '../screens/quiz/quiz_selection_screen.dart';
import '../screens/games/love_roulette_screen.dart';
import '../screens/games/relationship_barometer_screen.dart';
// Écrans de messages
import '../screens/messages/letters_inbox_screen.dart';
import '../screens/messages/compose_letter_screen.dart';
import '../screens/messages/letter_composer_screen.dart';
import '../screens/messages/letters_inbox_humor_screen.dart';
// Écrans de boutique
import '../screens/shop/shop_screen.dart';
// Écrans de souvenirs
import '../screens/memories/memory_box_screen.dart';
// Écrans de profil
import '../screens/profile/profile_screen.dart';

/// Gestionnaire de routes pour l'application JeuTaime
/// Centralise toutes les routes et facilite la navigation
class AppRoutes {
  // Routes principales
  static const String welcome = '/welcome';
  static const String home = '/home';
  
  // Routes d'authentification
  static const String login = '/login';
  static const String register = '/register';
  static const String verification = '/verification';
  
  // Routes des bars thématiques
  static const String romanticBar = '/romantic-bar';
  static const String humorBar = '/humor-bar';
  static const String weeklyBar = '/weekly-bar';
  static const String mysteryBar = '/mystery-bar';
  static const String randomBar = '/random-bar';
  static const String barsHub = '/bars-hub';
  static const String humorChallenge = '/humor-challenge';
  
  // Routes des quiz et jeux
  static const String quizSelection = '/quiz-selection';
  static const String loveRoulette = '/love-roulette';
  static const String relationshipBarometer = '/relationship-barometer';
  
  // Routes des messages
  static const String lettersInbox = '/letters-inbox';
  static const String composeLetter = '/compose-letter';
  static const String letterComposer = '/letter-composer';
  static const String lettersInboxHumor = '/letters-inbox-humor';
  
  // Routes de la boutique
  static const String shop = '/shop';
  
  // Routes des souvenirs
  static const String memoryBox = '/memory-box';
  
  // Routes du profil
  static const String profile = '/profile';

  /// Map contenant toutes les routes de l'application
  static Map<String, WidgetBuilder> routes = {
    // Routes principales
    welcome: (context) => WelcomeScreen(),
    home: (context) => HomeScreen(),
    
    // Routes d'authentification
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(),
    verification: (context) => VerificationScreen(),
    
    // Routes des bars thématiques
    romanticBar: (context) => RomanticBarScreen(),
    humorBar: (context) => HumorBarScreen(),
    weeklyBar: (context) => WeeklyBarScreen(),
    mysteryBar: (context) => MysteryBarScreen(),
    randomBar: (context) => RandomBarScreen(),
    barsHub: (context) => BarsHubScreen(),
    humorChallenge: (context) => HumorChallengeScreen(),
    
    // Routes des quiz et jeux
    quizSelection: (context) => QuizSelectionScreen(),
    loveRoulette: (context) => LoveRouletteScreen(),
    
    // Routes des messages
    lettersInbox: (context) => LettersInboxScreen(),
    composeLetter: (context) => ComposeLetterScreen(),
    letterComposer: (context) => LetterComposerScreen(),
    lettersInboxHumor: (context) => LettersInboxHumorScreen(),
    
    // Routes de la boutique
    shop: (context) => ShopScreen(),
    
    // Routes des souvenirs
    memoryBox: (context) => MemoryBoxScreen(),
    
    // Routes du profil
    profile: (context) => ProfileScreen(),
  };

  /// Génère une route dynamique avec paramètres
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case relationshipBarometer:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => RelationshipBarometerScreen(
            partnerId: args?['partnerId'] ?? '',
            partnerName: args?['partnerName'] ?? 'Utilisateur',
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Erreur')),
            body: Center(
              child: Text('Route ${settings.name} non trouvée'),
            ),
          ),
        );
    }
  }
}
