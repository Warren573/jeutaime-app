import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_header.dart';

class PirateBarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Bouton retour
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppColors.beige.withOpacity(0.2),
                        border: Border.all(
                          color: AppColors.beige.withOpacity(0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: const Text(
                          '←',
                          style: TextStyle(
                            color: AppColors.beige,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              
              // Header du bar
              const AppHeader(
                title: "🏴‍☠️ Bar des Pirates",
                subtitle: "Aventure maritime • Conversations épiques",
              ),
              
              // Contenu du bar
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Chasse au trésor
                    _buildTreasureHuntCard(context),
                    
                    const SizedBox(height: 20),
                    
                    // Section activités
                    _buildActivitiesCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTreasureHuntCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pirateBar, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "🗺️ Chasse au Trésor Quotidienne",
            style: TextStyle(
              color: AppColors.pirateBar.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            "\"L'île mystérieuse\" - Résolvez 3 énigmes de navigation pour découvrir le trésor !",
            style: const TextStyle(
              color: Color(0xFF5D4E37),
              fontSize: 16,
              fontFamily: 'Georgia',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.pirateGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pirateBar.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                _showTreasureHuntDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Partir à l'aventure (+150 pièces)",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pirateBar, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "⚔️ Activités d'aventuriers",
            style: TextStyle(
              color: AppColors.pirateBar.withOpacity(0.9),
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActivityItem("⚔️", "Récit d'aventure", "+40 pièces"),
              _buildActivityItem("🧭", "Énigme de navigation", "+50 pièces"),
              _buildActivityItem("🏴‍☠️", "Défi de courage", "+35 pièces"),
              _buildActivityItem("🗺️", "Carte au trésor", "+45 pièces"),
              _buildActivityItem("🐙", "Légende nautique", "+60 pièces"),
              _buildActivityItem("🚢", "Grande Expédition Premium", "Premium"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String icon, String title, String reward) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF5D4E37),
                fontSize: 15,
                fontFamily: 'Georgia',
              ),
            ),
          ),
          Text(
            reward,
            style: TextStyle(
              color: reward == "Premium" ? AppColors.goldAccent : AppColors.pirateBar,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),
        ],
      ),
    );
  }

  void _showTreasureHuntDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "🗺️ Chasse au Trésor",
          style: TextStyle(fontFamily: 'Georgia'),
        ),
        content: const Text(
          "Équipages disponibles :\n"
          "• Les Corsaires du Rhum (3/4 membres)\n"
          "• Chasseurs de Légendes (2/4 membres)\n\n"
          "Activités d'équipage :\n"
          "• Récits d'aventure\n"
          "• Défis de navigation\n"
          "• Création de légendes\n\n"
          "🚢 Bientôt disponible !",
          style: TextStyle(fontFamily: 'Georgia'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Compris",
              style: TextStyle(
                color: AppColors.pirateBar,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ],
      ),
    );
  }
}