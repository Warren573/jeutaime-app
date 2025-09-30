import "package:flutter/material.dart";
import "../models/user_profile.dart";

class ProfileCard extends StatelessWidget {
  final UserProfile user;

  const ProfileCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool showPhoto = (user.relation?.messagesCount ?? 0) >= 10;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    user.photos.isNotEmpty ? user.photos[0] : 'assets/default_avatar.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                if (!showPhoto)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock, color: Colors.white, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'Photo dévoilée après 10 lettres échangées',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Georgia',
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Text(user.name, style: TextStyle(fontFamily: 'Georgia', fontSize: 20, fontWeight: FontWeight.bold)),
            Text("${user.age} ans • ${user.city}", style: TextStyle(fontFamily: 'Georgia', fontSize: 15)),
            SizedBox(height: 8),
            Text(user.bio, style: TextStyle(fontFamily: 'Georgia', fontSize: 14)),
            SizedBox(height: 10),
            // Activités communes
            if (user.relation != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user.relation!.activitiesShared)
                    _activityChip('Activités partagées', '🤝'),
                  if (user.relation!.barWeeklyCompleted)
                    _activityChip('Bar hebdo terminé', '📅'),
                  if (user.relation!.compatibility80)
                    _activityChip('Compatibilité 80%+', '💞'),
                  if (user.relation!.heartConnection)
                    _activityChip('Connexion spéciale', '💖'),
                ],
              ),
              SizedBox(height: 8),
              // Badges
              if (user.relation!.messagesCount >= 10)
                _badgeChip('Correspondant', '💌'),
              if (user.relation!.compatibilityScore >= 90)
                _badgeChip('Âme sœur potentielle', '🌹'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _activityChip(String label, String emoji) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 4),
          Text(label, style: TextStyle(fontFamily: 'Georgia', fontSize: 13)),
        ],
      ),
    );
  }

  Widget _badgeChip(String label, String emoji) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 4),
          Text(label, style: TextStyle(fontFamily: 'Georgia', fontSize: 13)),
        ],
      ),
    );
  }
}
