/**
 * RÉFÉRENCE OBLIGATOIRE: https://jeutaime-warren.web.app/
 * 
 * Reproduit l'onglet Journal de la référence
 * Badges + historique activités
 */

import 'package:flutter/material.dart';
import '../config/ui_reference.dart';

class JournalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIReference.colors['background'],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              UIReference.colors['background']!,
              UIReference.colors['accent']!.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildJournalContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Text('📖', style: TextStyle(fontSize: 28)),
          SizedBox(width: 15),
          Text(
            'Mon Journal',
            style: UIReference.titleStyle.copyWith(fontSize: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalContent() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes badges',
            style: UIReference.subtitleStyle.copyWith(fontSize: 20),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBadge('🏆', 'Premier match'),
              _buildBadge('💝', 'Première lettre'),
              _buildBadge('🎯', 'Visiteur assidu'),
            ],
          ),
          SizedBox(height: 30),
          Text(
            'Historique des activités',
            style: UIReference.subtitleStyle.copyWith(fontSize: 20),
          ),
          SizedBox(height: 15),
          Expanded(
            child: ListView(
              children: [
                _buildActivityItem('Visite du Bar Romantique', '2h'),
                _buildActivityItem('Nouvelle lettre de Sophie', '1j'),
                _buildActivityItem('Badge "Première lettre" obtenu', '2j'),
                _buildActivityItem('Inscription à JeuTaime', '3j'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String emoji, String title) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: UIReference.colors['accent']!.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: UIReference.colors['primary']!, width: 2),
          ),
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: 24)),
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Georgia',
            color: UIReference.colors['textPrimary'],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: UIReference.colors['cardBackground'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: UIReference.colors['accent']!.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: UIReference.colors['primary'],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: UIReference.bodyStyle.copyWith(fontSize: 14),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: UIReference.colors['textSecondary'],
              fontFamily: 'Georgia',
            ),
          ),
        ],
      ),
    );
  }
}