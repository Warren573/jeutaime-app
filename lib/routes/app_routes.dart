import 'package:flutter/material.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/bars/romantic_bar_screen.dart';
import '../screens/bars/humor_bar_screen.dart';
import '../screens/bars/weekly_bar_screen.dart';
import '../screens/bars/mystery_bar_screen.dart';
import '../screens/bars/random_bar_screen.dart';
import '../screens/messages/letters_inbox_screen.dart';
import '../screens/memories/memory_box_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/quiz/quiz_selection_screen.dart';
import '../screens/shop/shop_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String romanticBar = '/romantic_bar';
  static const String humorBar = '/humor_bar';
  static const String weeklyBar = '/weekly_bar';
  static const String mysteryBar = '/mystery_bar';
  static const String randomBar = '/random_bar';
  static const String lettersInbox = '/letters_inbox';
  static const String memoryBox = '/memory_box';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String quizSelection = '/quiz_selection';
  static const String shop = '/shop';

  static Map<String, WidgetBuilder> get routes => {
    welcome: (context) => WelcomeScreen(),
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(),
    main: (context) => MainNavigationScreen(),
    romanticBar: (context) => RomanticBarScreen(),
    humorBar: (context) => HumorBarScreen(),
    weeklyBar: (context) => WeeklyBarScreen(),
    mysteryBar: (context) => MysteryBarScreen(),
    randomBar: (context) => RandomBarScreen(),
    lettersInbox: (context) => LettersInboxScreen(),
    memoryBox: (context) => MemoryBoxScreen(),
    profile: (context) => ProfileScreen(),
    settings: (context) => SettingsScreen(),
    quizSelection: (context) => QuizSelectionScreen(),
    shop: (context) => ShopScreen(),
  };
}
