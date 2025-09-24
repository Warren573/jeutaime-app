import 'package:flutter/material.dart';
import '../config/ui_reference.dart';

class ShopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIReference.colors['background'],
      body: Center(
        child: Text(
          'Boutique déplacée dans Paramètres',
          style: UIReference.subtitleStyle,
        ),
      ),
    );
  }
}