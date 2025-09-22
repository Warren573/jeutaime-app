import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    setState(() {
      _memoriesFuture = _fetchMemories();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchMemories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('memory_box')
      .where('userId', isEqualTo: user.uid)
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
              if (memory['type'] == 'letter_received' || memory['type'] == 'letter_sent') {
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.mail, color: AppColors.romanticBar),
                    title: Text(memory['title'] ?? 'Lettre'),
                    subtitle: Text(memory['description'] ?? ''),
                    onTap: () {
                      _showLetterDetail(context, memory['data']);
                    },
                  ),
                );
              }
              // ...autres types de souvenirs (matchs, défis, etc.)...
              return SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  void _showLetterDetail(BuildContext context, Map<String, dynamic>? data) {
    if (data == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['subject'] ?? '(Sans sujet)'),
        content: Text(data['content'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
