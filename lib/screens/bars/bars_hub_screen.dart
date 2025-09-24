import 'package:flutter/material.dart';
import '../../widgets/bars/bar_card.dart';
import '../../theme/app_colors.dart';

class BarsHubScreen extends StatelessWidget {
  const BarsHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Les Bars JeuTaime'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BarCard(
            icon: '💝',
            title: 'Bar Romantique',
            description: 'Pour les âmes sensibles',
            stats: '12 personnes connectées',
            accentColor: AppColors.romanticBar,
            hoverGradient: AppColors.romanticGradient,
            onTap: () => Navigator.pushNamed(context, '/romantic_bar'),
          ),
          BarCard(
            icon: '😄',
            title: 'Bar Humoristique', 
            description: 'Pour ceux qui aiment rire',
            stats: '8 comiques en ligne',
            accentColor: AppColors.humorousBar,
            hoverGradient: AppColors.humorousGradient,
            onTap: () => Navigator.pushNamed(context, '/humor_bar'),
          ),
          BarCard(
            icon: '📅',
            title: 'Bar Hebdomadaire',
            description: 'Nouveaux thèmes chaque semaine',
            stats: '4 thèmes en cours',
            accentColor: AppColors.weeklyBar,
            hoverGradient: AppColors.weeklyGradient,
            onTap: () => Navigator.pushNamed(context, '/weekly_bar'),
          ),
          BarCard(
            icon: '🏴‍☠️',
            title: 'Bar Pirate',
            description: 'Aventures et trésors',
            stats: '6 pirates en ligne',
            accentColor: AppColors.pirateBar,
            hoverGradient: AppColors.pirateGradient,
            onTap: () => Navigator.pushNamed(context, '/pirate_bar'),
          ),
          BarCard(
            icon: '🎭',
            title: 'Bar Mystère',
            description: 'Rencontres imprévues',
            stats: 'Surprise garantie',
            accentColor: AppColors.mysteryBar,
            onTap: () => Navigator.pushNamed(context, '/mystery_bar'),
          ),
        ],
      ),
    );
  }
}
