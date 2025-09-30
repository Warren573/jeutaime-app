import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bars/bar_card.dart';
import '../../models/bar.dart';

class BarsHubScreen extends StatelessWidget {
  const BarsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bars Thématiques'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BarCard(
            bar: Bar(
              barId: 'romantic_bar',
              name: 'Bar Romantique',
              type: BarType.romantic,
              activeUsers: 12,
              maxParticipants: 50,
            ),
            onJoin: () => Navigator.pushNamed(context, '/romantic_bar'),
          ),
          const SizedBox(height: 16),
          BarCard(
            bar: Bar(
              barId: 'humorous_bar',
              name: 'Bar Humoristique',
              type: BarType.humorous,
              activeUsers: 25,
              maxParticipants: 100,
            ),
            onJoin: () => Navigator.pushNamed(context, '/casual_bar'),
          ),
          const SizedBox(height: 16),
          BarCard(
            bar: Bar(
              barId: 'pirate_bar',
              name: 'Bar des Pirates',
              type: BarType.pirate,
              activeUsers: 8,
              maxParticipants: 30,
            ),
            onJoin: () => Navigator.pushNamed(context, '/party_bar'),
          ),
          const SizedBox(height: 16),
          BarCard(
            bar: Bar(
              barId: 'weekly_bar',
              name: 'Bar Hebdomadaire',
              type: BarType.weekly,
              activeUsers: 15,
              maxParticipants: 40,
            ),
            onJoin: () => Navigator.pushNamed(context, '/intellectual_bar'),
          ),
        ],
      ),
    );
  }
}
