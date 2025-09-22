import 'package:flutter/material.dart';

// Importe ici tous tes écrans principaux (crée-les si besoin, même vides au début)
import '../screens/bars/bars_hub_screen.dart';
import '../screens/bars/romantic_bar_screen.dart';
import '../screens/bars/humor_bar_screen.dart';
import '../screens/bars/weekly_bar_screen.dart';
import '../screens/bars/mystery_bar_screen.dart';
import '../screens/bars/random_bar_screen.dart';
import '../screens/quiz/quiz_selection_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/games/love_roulette_screen.dart';
import '../screens/games/relationship_barometer_screen.dart';
import '../screens/auth/verification_screen.dart';
import '../screens/messages/compose_letter_screen.dart';

// Ajoute d'autres imports ici au fur et à mesure que tu ajoutes des écrans

class AppRoutes {
  // Noms des routes (utilise-les avec Navigator.pushNamed)
  static const String barsHub = '/bars_hub';
  static const String romanticBar = '/romantic_bar';
  static const String humorBar = '/humor_bar';
  static const String weeklyBar = '/weekly_bar';
  static const String mysteryBar = '/mystery_bar';
  static const String randomBar = '/random_bar';
  static const String quizSelection = '/quiz_selection';
  static const String shop = '/shop';
  static const String loveRoulette = '/love_roulette';
  static const String barometer = '/relationship_barometer';
  static const String verification = '/verification';
  static const String composeLetter = '/compose_letter';

  // Map des routes (relie le nom à l'écran)
  static Map<String, WidgetBuilder> get routes => {
    barsHub: (context) => BarsHubScreen(),
    romanticBar: (context) => RomanticBarScreen(),
    humorBar: (context) => HumorBarScreen(),
    weeklyBar: (context) => WeeklyBarScreen(),
    mysteryBar: (context) => MysteryBarScreen(),
    randomBar: (context) => RandomBarScreen(),
    quizSelection: (context) => QuizSelectionScreen(),
    shop: (context) => ShopScreen(),
    loveRoulette: (context) => LoveRouletteScreen(),
    barometer: (context) => RelationshipBarometerScreen(
      partnerId: '', // à remplacer par l’id réel si besoin
      partnerName: '',
    ),
    verification: (context) => VerificationScreen(),
    composeLetter: (context) => ComposeLetterScreen(
      recipientId: '', // à remplacer par l’id réel si besoin
      recipientName: '',
    ),
    // Ajoute ici tes autres routes au fur et à mesure
  };
}
