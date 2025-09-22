import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/quiz_card.dart';

class QuizSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Text('Quiz & Tests', style: TextStyle(color: AppColors.seriousAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade100, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.psychology, size: 40, color: Colors.purple),
                  SizedBox(height: 8),
                  Text(
                    'Découvre ton profil amoureux',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'et trouve des affinités uniques !',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            QuizCard(
              title: 'Quiz de Compatibilité',
              subtitle: 'Découvre ton pourcentage de compatibilité',
              icon: Icons.favorite_border,
              color: Colors.red,
              duration: '5 min',
              route: '/compatibility_quiz',
            ),
            SizedBox(height: 12),
            QuizCard(
              title: 'Langages de l\'Amour',
              subtitle: 'Paroles, gestes, cadeaux, temps ou contact ?',
              icon: Icons.chat_bubble_outline,
              color: Colors.pink,
              duration: '3 min',
              route: '/love_languages_quiz',
            ),
            SizedBox(height: 12),
            QuizCard(
              title: 'Style Relationnel',
              subtitle: 'Romantique, aventurier, traditionnel ?',
              icon: Icons.style,
              color: Colors.purple,
              duration: '4 min',
              route: '/relationship_style_quiz',
            ),
            SizedBox(height: 12),
            QuizCard(
              title: 'Test Mystère du Jour',
              subtitle: 'Quiz surprise pour débloquer des bonus',
              icon: Icons.lock,
              color: Colors.indigo,
              duration: '2 min',
              route: '/mystery_quiz',
            ),
          ],
        ),
      ),
    );
  }
}
