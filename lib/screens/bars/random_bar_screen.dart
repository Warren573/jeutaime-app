import 'package:flutter/material.dart';

class RandomBarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bar Aléatoire')),
      body: const Center(child: Text('Bienvenue dans le Bar Aléatoire !')),
    );
  }
}
