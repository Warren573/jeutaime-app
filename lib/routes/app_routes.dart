import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/bars/random_bar_screen.dart';
// Ajoute ici les autres imports d'écrans si nécessaire

class AppRoutes {
  static const String welcome = '/welcome';
  static const String randomBar = '/random-bar';

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => WelcomeScreen(),
    randomBar: (context) => RandomBarScreen(),
    // Ajoute ici les autres routes
  };
}
