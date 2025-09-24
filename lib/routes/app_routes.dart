import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/onboarding_profile_screen.dart';
import '../screens/bars/random_bar_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/messages/messages_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/letters/letters_screen.dart';
import '../screens/letters/compose_letter_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/economy_test_screen.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String onboardingProfile = '/onboarding-profile';
  static const String onboardingInterests = '/onboarding-interests';
  static const String onboardingPhoto = '/onboarding-photo';
  static const String home = '/home';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String messages = '/messages';
  static const String shop = '/shop';
  static const String randomBar = '/random-bar';
  static const String memoryBox = '/memory_box';
  static const String letters = '/letters';
  static const String composeLetter = '/compose-letter';
  static const String mainNavigation = '/main-navigation';
  static const String economyTest = '/economy-test';

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    onboardingProfile: (context) => const OnboardingProfileScreen(),
    home: (context) => HomeScreen(),
    main: (context) => HomeScreen(), // Alias pour main
    profile: (context) => ProfileScreen(),
    messages: (context) => MessagesScreen(),
    shop: (context) => ShopScreen(),
    randomBar: (context) => RandomBarScreen(),
    memoryBox: (context) => const _MemoryBoxPlaceholder(),
    letters: (context) => const LettersScreen(),
    composeLetter: (context) => const ComposeLetterScreen(),
    mainNavigation: (context) => const MainNavigationScreen(),
    economyTest: (context) => const EconomyTestScreen(),
  };
}

// Placeholder widget for memory box functionality
class _MemoryBoxPlaceholder extends StatelessWidget {
  const _MemoryBoxPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boîte à souvenirs')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text(
              'Boîte à souvenirs',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Fonctionnalité à venir !',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
