import 'package:flutter/material.dart';
import '../../widgets/bar_card.dart';

class BarsHubScreen extends StatelessWidget {
  const BarsHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Les Bars JeuTaime'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          BarCard(
            title: 'Bar Romantique',
            subtitle: 'Pour les âmes sensibles',
            icon: Icons.favorite,
            color: Colors.pink,
            route: '/romantic_bar',
            stats: '12 personnes connectées',
          ),
          BarCard(
            title: 'Bar Humoristique',
            subtitle: 'Pour ceux qui aiment rire',
            icon: Icons.emoji_emotions,
            color: Colors.orange,
            route: '/humor_bar',
            stats: '8 comiques en ligne',
          ),
          BarCard(
            title: 'Bar Hebdomadaire',
            subtitle: 'Nouveaux thèmes chaque semaine',
            icon: Icons.calendar_today,
            color: Colors.green,
            route: '/weekly_bar',
            stats: '4 thèmes en cours',
          ),
          BarCard(
            title: 'Bar Mystère',
            subtitle: 'Accès via une énigme',
            icon: Icons.lock,
            color: Colors.blue,
            route: '/mystery_bar',
            stats: 'Réservé aux curieux',
          ),
          BarCard(
            title: 'Bar Aléatoire',
            subtitle: 'Rencontres imprévues',
            icon: Icons.shuffle,
            color: Colors.purple,
            route: '/random_bar',
            stats: 'Surprise garantie',
          ),
        ],
      ),
    );
  }
}
