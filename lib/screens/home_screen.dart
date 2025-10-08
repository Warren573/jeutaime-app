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
      backgroundColor: const Color(0xFFB8A082), // Couleur de fond comme dans vos captures
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              Expanded(child: _buildBarsGrid()),
            ],
          ),
        ),
      ),
    );
  }

  /**
   * Header avec titre "JeuTaime" + profil utilisateur comme dans vos captures
   */
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5A3C), Color(0xFFA67C52)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo et titre
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🏛️', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Text(
                'JeuTaime',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'L\'art de la rencontre authentique',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 14,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          // Profil utilisateur
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('👤', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Warren',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Profil : Nouvel arrivant',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('💰', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 4),
                      Text(
                        '1000 pièces',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
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
   * Grille des bars et section lettres comme dans vos captures
   */
  Widget _buildBarsGrid() {
    return Column(
      children: [
        // Bars thématiques
        _buildBarCard({
          'name': 'Bar Romantique',
          'emoji': '🌹',
          'description': 'Discussions profondes et poésie',
          'participants': '12 personnes • 3 groupes actifs',
          'color': Colors.pink,
        }),
        const SizedBox(height: 12),
        _buildBarCard({
          'name': 'Bar Humoristique',
          'emoji': '😄',
          'description': 'Bonne humeur et éclats de rire',
          'participants': '18 personnes • Défi du jour actif',
          'color': Colors.orange,
        }),
        const SizedBox(height: 12),
        _buildBarCard({
          'name': 'Bar Pirates',
          'emoji': '🏴‍☠️',
          'description': 'Aventures et camaraderie',
          'participants': '15 personnes • Chasse au trésor',
          'color': Colors.brown,
        }),
        const SizedBox(height: 12),
        // Section Mes Lettres
        _buildBarCard({
          'name': 'Mes Lettres',
          'emoji': '📧',
          'description': 'Correspondances authentiques',
          'participants': '',
          'color': Colors.blue,
        }),
      ],
    );
  }

  /**
   * Carte de bar thématique comme dans vos captures
   */
  Widget _buildBarCard(Map<String, dynamic> bar) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC), // Beige clair
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji du bar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: bar['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                bar['emoji'],
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Informations du bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bar['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bar['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8D6E63),
                  ),
                ),
                if (bar['participants'].isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    bar['participants'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF8A65),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }


}