import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'mini_game_joke_or_truth.dart';

class HumorChallengeScreen extends StatelessWidget {
  const HumorChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.emoji_emotions, color: AppColors.humorBar),
            SizedBox(width: 8),
            Text('Défis Humoristiques', style: TextStyle(color: AppColors.humorBar)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.auto_awesome, color: AppColors.humorBar),
            tooltip: 'Boîte à souvenirs',
            onPressed: () => Navigator.pushNamed(context, '/memory_box'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.humorBar.withOpacity(0.08),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Prêt à faire rire ou à relever le défi ?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.humorBar,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Choisis un défi humoristique ou lance-toi dans un mini-jeu pour briser la glace !',
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 26),
            Text(
              'Défis populaires du Bar :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.humorBar,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 12),
            _buildChallengeTile(
              context,
              icon: Icons.mic,
              title: 'Blague en 15 secondes',
              description: 'Fais rire l’autre avec une blague originale (audio ou texte)',
              onTap: () {
                // Navigue vers un écran d’envoi de blague
                // Navigator.push(context, MaterialPageRoute(builder: (_) => JokeSubmissionScreen()));
              },
            ),
            _buildChallengeTile(
              context,
              icon: Icons.emoji_objects,
              title: 'Défi “Qui est le plus drôle ?”',
              description: 'Partagez chacun une vanne et laissez le public voter !',
              onTap: () {
                // Navigue vers un écran de défi duel
                // Navigator.push(context, MaterialPageRoute(builder: (_) => DuelJokeScreen()));
              },
            ),
            _buildChallengeTile(
              context,
              icon: Icons.question_answer,
              title: 'Impro à la demande',
              description: 'On te donne un thème, tu dois sortir une vanne improvisée !',
              onTap: () {
                // Navigue vers l’impro
                // Navigator.push(context, MaterialPageRoute(builder: (_) => JokeImproScreen()));
              },
            ),
            SizedBox(height: 30),
            Text(
              'Mini-jeu d’échauffement',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.humorBar,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            _buildMiniGameButton(
              context,
              icon: Icons.casino,
              label: 'Blague ou Vérité',
              color: Colors.deepOrange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MiniGameJokeOrTruth()),
                );
              },
            ),
            SizedBox(height: 18),
            _buildMiniGameButton(
              context,
              icon: Icons.shuffle,
              label: 'Jeu du Mot Interdit',
              color: Colors.lightGreen,
              onTap: () {
                // TODO: Ajouter un autre mini-jeu
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Bientôt disponible !"), backgroundColor: AppColors.humorBar),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeTile(BuildContext context,
      {required IconData icon, required String title, required String description, required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.humorBar, size: 30),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        onTap: onTap,
        trailing: Icon(Icons.arrow_forward_ios, color: AppColors.humorBar, size: 16),
      ),
    );
  }

  Widget _buildMiniGameButton(BuildContext context,
      {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size.fromHeight(46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 3,
      ),
    );
  }
}
