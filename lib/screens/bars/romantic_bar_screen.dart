import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_header.dart';

class RomanticBarScreen extends StatelessWidget {
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
                title: "💕 Bar Romantique",
                subtitle: "Ambiance tendre • Conversations intimes",
              ),
              
              // Contenu du bar
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Section bienvenue
                    _buildContentCard(
                      title: "✨ Bienvenue au Bar Romantique",
                      content: "Rejoignez les groupes \"Poésie & Émotions\" ou \"Voyages Romantiques\" pour des conversations authentiques.",
                      borderColor: AppColors.romanticBar,
                      buttonText: "Rejoindre un groupe",
                      buttonGradient: const LinearGradient(
                        colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                      ),
                      onButtonPressed: () {
                        _showBarFeaturesDialog(context, 'romantic');
                      },
                    ),
                    
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

  Widget _buildContentCard({
    required String title,
    required String content,
    required Color borderColor,
    required String buttonText,
    required LinearGradient buttonGradient,
    required VoidCallback onButtonPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
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
            title,
            style: TextStyle(
              color: borderColor.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            content,
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
              gradient: buttonGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
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
        border: Border.all(color: AppColors.romanticBar, width: 2),
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
            "🎭 Activités disponibles",
            style: TextStyle(
              color: AppColors.romanticBar.withOpacity(0.8),
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
              _buildActivityItem("💝", "Compliments sincères", "+25 pièces"),
              _buildActivityItem("📝", "Poèmes express", "+40 pièces"),
              _buildActivityItem("🌟", "Partage de souvenirs", "+35 pièces"),
              _buildActivityItem("💭", "Citations préférées", "+30 pièces"),
              _buildActivityItem("💌", "Lettres d'amour Premium", "Premium"),
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
              color: reward == "Premium" ? AppColors.goldAccent : AppColors.romanticBar,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),
        ],
      ),
    );
  }

  void _showBarFeaturesDialog(BuildContext context, String barType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "🌹 Fonctionnalités disponibles",
          style: TextStyle(fontFamily: 'Georgia'),
        ),
        content: const Text(
          "• Rejoindre des groupes thématiques\n"
          "• Participer aux activités romantiques\n"
          "• Envoyer des compliments sincères\n"
          "• Partager vos plus beaux souvenirs\n\n"
          "💫 Bientôt disponible !",
          style: TextStyle(fontFamily: 'Georgia'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Compris",
              style: TextStyle(
                color: AppColors.romanticBar,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
