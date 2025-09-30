import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime Debug',
      home: Scaffold(
        appBar: AppBar(
          title: Text('JeuTaime Test'),
        ),
        body: Center(
          child: Text(
            'Hello JeuTaime!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}