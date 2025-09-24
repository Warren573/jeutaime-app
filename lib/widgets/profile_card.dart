import "package:flutter/material.dart";
import "../models/user.dart";

class ProfileCard extends StatelessWidget {
  final User user;

  const ProfileCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(user.displayName),
            Text("${user.age} ans"),
            if (user.bio != null) Text(user.bio!),
          ],
        ),
      ),
    );
  }
}
