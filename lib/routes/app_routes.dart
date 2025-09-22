// ...imports existants...
import '../screens/quiz/compatibility_quiz_screen.dart';
import '../screens/quiz/love_languages_quiz_screen.dart';
import '../screens/quiz/relationship_style_quiz_screen.dart';
import '../screens/quiz/mystery_quiz_screen.dart';
import '../screens/games/love_roulette_screen.dart';
import '../screens/games/relationship_barometer_screen.dart';
import '../screens/auth/verification_screen.dart';
// etc.

class AppRoutes {
  // ...
  static const String compatibilityQuiz = '/compatibility_quiz';
  static const String loveLanguagesQuiz = '/love_languages_quiz';
  static const String relationshipStyleQuiz = '/relationship_style_quiz';
  static const String mysteryQuiz = '/mystery_quiz';
  static const String loveRoulette = '/love_roulette';
  static const String barometer = '/relationship_barometer';
  static const String verification = '/verification';
  // ...

  static Map<String, WidgetBuilder> get routes => {
    // ...routes existantes...
    compatibilityQuiz: (context) => CompatibilityQuizScreen(),
    loveLanguagesQuiz: (context) => LoveLanguagesQuizScreen(),
    relationshipStyleQuiz: (context) => RelationshipStyleQuizScreen(),
    mysteryQuiz: (context) => MysteryQuizScreen(),
    loveRoulette: (context) => LoveRouletteScreen(),
    barometer: (context) => RelationshipBarometerScreen(partnerId: '', partnerName: ''),
    verification: (context) => VerificationScreen(),
    // ...
  };
}
