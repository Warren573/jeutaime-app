import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';

class MemoryBoxScreen extends StatefulWidget {
  @override
  _MemoryBoxScreenState createState() => _MemoryBoxScreenState();
}

class _MemoryBoxScreenState extends State<MemoryBoxScreen> {
  late Future<List<Map<String, dynamic>>> _memoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  void _loadMemories() {
    // À adapter selon votre service Firestore
    setState(() {
      _memoriesFuture = _fetchMemories();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchMemories() async {
    // Exemple basique : à remplacer par appel réel à Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('memory_box')
      .where('userId', isEqualTo: 'CURRENT_USER_ID')
      .orderBy('createdAt', descending: true)
      .get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.seriousAccent),
            SizedBox(width: 8),
            Text('Boîte à souvenirs', style: TextStyle(color: AppColors.seriousAccent)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _memoriesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: AppColors.seriousAccent));
          }
          if (snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun souvenir pour le moment.\nÀ vous de les créer !', style: TextStyle(color: AppColors.seriousAccent)));
          }
          final memories = snapshot.data!;
          return ListView.builder(
            itemCount: memories.length,
            itemBuilder: (context, idx) {
              final memory = memories[idx];
              return Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.bookmark, color: AppColors.seriousAccent),
                  title: Text(memory['title'] ?? 'Souvenir'),
                  subtitle: Text(memory['description'] ?? ''),
                  onTap: () {
                    // Afficher détail du souvenir (lettre, match, défi réussi, etc.)
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
