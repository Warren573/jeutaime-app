import 'package:flutter/material.dart';
import '../../services/bar_service.dart';

class MysteryBarScreen extends StatefulWidget {
  @override
  _MysteryBarScreenState createState() => _MysteryBarScreenState();
}

class _MysteryBarScreenState extends State<MysteryBarScreen> {
  bool _hasAccess = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    // Remplace 'demoUserId' par l'id réel de l'utilisateur connecté si besoin
    _hasAccess = await BarService.canAccessMysteryBar('demoUserId');
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Bar Mystère')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Bar Mystère')),
      body: Center(
        child: _hasAccess
            ? Text('Bienvenue dans le Bar Mystère !')
            : Text('Accès refusé. Résous l’énigme pour entrer !'),
      ),
    );
  }
}
