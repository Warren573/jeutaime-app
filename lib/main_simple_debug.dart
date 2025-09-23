import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleApp());
}

class SimpleApp extends StatelessWidget {
  const SimpleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime Debug',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('JeuTaime - Test'),
          backgroundColor: Colors.pink,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, size: 100, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'JeuTaime App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Application fonctionnelle !'),
            ],
          ),
        ),
      ),
    );
  }
}