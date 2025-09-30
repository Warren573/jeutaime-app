import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/user_model.dart';

class DemoScreen extends StatelessWidget {
  final List<UserModel> demoProfiles = [
    UserModel(
      uid: 'demo1',
      name: 'Alice',
      age: 27,
      mainPhoto: 'https://randomuser.me/api/portraits/women/1.jpg',
      bio: 'Aime les bars romantiques et les quiz.',
      interests: ['Bars', 'Quiz', 'Lettres'],
      isOnline: true,
      onlineStatus: 'En ligne',
      isVerified: true,
    ),
    UserModel(
      uid: 'demo2',
      name: 'Bob',
      age: 31,
      mainPhoto: 'https://randomuser.me/api/portraits/men/2.jpg',
      bio: 'Fan de jeux et de défis.',
      interests: ['Jeux', 'Défis', 'Bars'],
      isOnline: false,
      onlineStatus: 'Vu il y a 2h',
      isVerified: false,
    ),
    UserModel(
      uid: 'demo3',
      name: 'Chloé',
      age: 24,
      mainPhoto: 'https://randomuser.me/api/portraits/women/3.jpg',
      bio: 'Passionnée de lettres et de rencontres.',
      interests: ['Lettres', 'Rencontres', 'Bars'],
      isOnline: true,
      onlineStatus: 'En ligne',
      isVerified: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Démo - Profils d\'essai'),
        backgroundColor: AppColors.funPrimary,
      ),
      backgroundColor: AppColors.funBackground,
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: demoProfiles.length,
        itemBuilder: (context, index) {
          final user = demoProfiles[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.mainPhoto),
                radius: 28,
              ),
              title: Text('${user.name}, ${user.age}'),
              subtitle: Text(user.bio),
              trailing: user.isOnline
                  ? Icon(Icons.circle, color: Colors.green, size: 14)
                  : Icon(Icons.circle, color: Colors.grey, size: 14),
            ),
          );
        },
      ),
    );
  }
}
