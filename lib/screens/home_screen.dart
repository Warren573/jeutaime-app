/**
 * RÉFÉRENCE OBLIGATOIRE: https://jeutaime-warren.web.app/
 * 
 * Cet écran d'accueil doit avoir EXACTEMENT:
 * - Header avec titre "JeuTaime" + solde pièces (ex: "245 pièces")
 * - Grille de 5 bars avec icônes spécifiques:
 *   🌹 Bar Romantique - ambiance tamisée
 *   😄 Bar Humoristique - défi du jour  
 *   🏴‍☠️ Bar Pirates - chasse au trésor
 *   📅 Bar Hebdomadaire - groupe de 4 (2H/2F)
 *   👑 Bar Caché - accès par énigmes
 * - Navigation bottom : 6 onglets comme dans la référence
 */

import 'package:flutter/material.dart';
import '../config/ui_reference.dart';
import '../widgets/common/progression_widget.dart';
import '../services/progression_service.dart';

// Reproduit https://jeutaime-warren.web.app/ (accueil)
class HomeScreen extends StatelessWidget {
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
              UIReference.colors['accent']!.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildProgressionSection(context),
                _buildBarsGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /**
   * Header avec titre "JeuTaime" + solde pièces comme sur https://jeutaime-warren.web.app/
   */
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UIReference.colors['primary']!,
            UIReference.colors['secondary']!,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Titre JeuTaime en Georgia
          Text(
            'JeuTaime',
            style: UIReference.titleStyle.copyWith(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
          // Solde pièces comme sur le site
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text('💰', style: TextStyle(fontSize: 18)),
                SizedBox(width: 5),
                Text(
                  '245 pièces',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Grille des 5 bars thématiques EXACTEMENT comme sur https://jeutaime-warren.web.app/
   */
  Widget _buildBarsGrid() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisissez votre bar',
            style: UIReference.titleStyle.copyWith(fontSize: 24),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: UIReference.bars.length,
              itemBuilder: (context, index) {
                final bar = UIReference.bars[index];
                return _buildBarCard(bar);
              },
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Carte de bar thématique avec style bois chaleureux
   */
  Widget _buildBarCard(Map<String, dynamic> bar) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UIReference.colors['cardBackground'],
        borderRadius: BorderRadius.circular(20), // border-radius 15-20px comme spécifié
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: UIReference.colors['accent']!.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Emoji du bar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bar['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                bar['emoji'],
                style: TextStyle(fontSize: 28),
              ),
            ),
          ),
          SizedBox(width: 20),
          // Informations du bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bar['name'],
                  style: UIReference.subtitleStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  bar['description'],
                  style: UIReference.bodyStyle.copyWith(
                    color: UIReference.colors['textSecondary'],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Flèche d'accès
          Icon(
            Icons.arrow_forward_ios,
            color: UIReference.colors['primary'],
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Section de progression utilisateur
  Widget _buildProgressionSection(BuildContext context) {
    // Données de progression simulées pour la démo
    UserProgressData mockUserData = UserProgressData(
      points: 850,
      level: 4,
      messagesCount: 23,
      matchesFound: 7,
      humorActivitiesCompleted: 3,
      barsCompleted: 2,
      profileCompletion: 85,
      sphinxRiddleSolved: false,
      unlockedAchievements: ['first_match', 'level_3', 'social_starter'],
      unlockedRewards: ['custom_avatar', 'premium_filters'],
    );

    return Column(
      children: [
        ProgressionWidget(
          progress: 0.7,
          title: 'Progression générale',
          subtitle: 'Niveau 5 - 70% vers le niveau suivant',
        ),
        
        // Bouton de test du système d'économie
        Container(
          margin: EdgeInsets.only(top: 16),
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/economy-test');
            },
            icon: Icon(Icons.science_outlined),
            label: Text('🧪 Test Système d\'Économie'),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIReference.colors['accent'],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}