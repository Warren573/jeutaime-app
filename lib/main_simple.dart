import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SimpleTestScreen(),
    );
  }
}

class SimpleTestScreen extends StatelessWidget {
  const SimpleTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 100,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              'JeuTaime Test',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Si vous voyez ceci, Flutter fonctionne !',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Test réussi !')),
                );
              },
              child: Text('Tester'),
            ),
          ],
        ),
      ),
    );
  }
}