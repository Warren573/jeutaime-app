import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/quiz_card.dart';

class QuizSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Text('Quiz Personnalité'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Découvre ta personnalité !',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
                fontFamily: 'Nunito',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Des quiz amusants pour mieux te connaître',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'Nunito',
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  QuizCard(
                    title: 'Personnalité MBTI',
                    description: 'Introverti/extraverti, rationnel/émotionnel... Découvre ton type de personnalité',
                    icon: Icons.psychology_outlined,
                    color: Colors.purple,
                    onTap: () {
                      // TODO: Navigator.pushNamed(context, '/personality_quiz');
                    },
                  ),
                  SizedBox(height: 16),
                  QuizCard(
                    title: 'Langages de l\'Amour',
                    description: 'Paroles, gestes, cadeaux, temps ou contact ? Découvre comment tu exprimes l\'amour',
                    icon: Icons.favorite_border,
                    color: Colors.red,
                    onTap: () {
                      // TODO: Navigator.pushNamed(context, '/love_languages_quiz');
                    },
                  ),
                  SizedBox(height: 16),
                  QuizCard(
                    title: 'Compatibilité Astrologique',
                    description: 'Balance, Lion, Scorpion... Découvre avec quels signes tu es le plus compatible',
                    icon: Icons.star_border,
                    color: Colors.purple,
                    onTap: () {
                      // TODO: Navigator.pushNamed(context, '/astro_quiz');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
