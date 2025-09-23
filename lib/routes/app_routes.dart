import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/bars/random_bar_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/messages/messages_screen.dart';
import '../screens/shop/shop_screen.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String messages = '/messages';
  static const String shop = '/shop';
  static const String randomBar = '/random-bar';
  static const String memoryBox = '/memory_box';

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => WelcomeScreen(),
    login: (context) => LoginScreen(),
    home: (context) => HomeScreen(),
    profile: (context) => ProfileScreen(),
    messages: (context) => MessagesScreen(),
    shop: (context) => ShopScreen(),
    randomBar: (context) => RandomBarScreen(),
    memoryBox: (context) => _MemoryBoxPlaceholder(),
  };
}

// Placeholder widget for memory box functionality
class _MemoryBoxPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Boîte à souvenirs')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 80, color: Colors.grey[400]),
            SizedBox(height: 20),
            Text(
              'Boîte à souvenirs',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
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
