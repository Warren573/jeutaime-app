import 'package:flutter/material.dart';
import 'theme/app_themes.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(JeuTaimeApp());
}

class JeuTaimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
    );
  }
}
