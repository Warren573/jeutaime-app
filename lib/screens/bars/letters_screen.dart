import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_header.dart';

class LettersScreen extends StatelessWidget {
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
                title: "💌 Mes Lettres",
                subtitle: "Messages personnalisés • Conversations authentiques",
              ),
              
              // Contenu du bar
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Section explication
                    _buildExplanationCard(context),
                    
                    const SizedBox(height: 20),
                    
                    // Section règles
                    _buildRulesCard(),
                    
                    const SizedBox(height: 20),
                    
                    // Section conversations (vide pour l'instant)
                    _buildConversationsCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.weeklyBar, width: 2),
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
            "📜 L'art de la correspondance",
            style: TextStyle(
              color: const Color(0xFFAD1457),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            "Chez JeuTaime, les échanges se font par lettres authentiques. Prenez le temps d'écrire des messages sincères et profonds.",
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
              gradient: AppColors.weeklyGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.weeklyBar.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                _showLetterFeaturesDialog(context);
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
                "Découvrir les fonctionnalités",
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

  Widget _buildRulesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0x1A4169E1), // Bleu avec transparence
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📋 Règles de correspondance :",
            style: TextStyle(
              color: AppColors.weeklyBar.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 10),
          _buildRuleItem("💌", "Maximum 500 mots par lettre"),
          _buildRuleItem("🔄", "Tour par tour : attendez la réponse"),
          _buildRuleItem("💰", "30 pièces par lettre envoyée"),
          _buildRuleItem("⚠️", "Anti-ghosting : soyez respectueux"),
          _buildRuleItem("📦", "Boîte à souvenirs incluse"),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF5D4E37),
                fontSize: 14,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.weeklyBar, width: 2),
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
            "💬 Vos conversations",
            style: TextStyle(
              color: const Color(0xFFAD1457),
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Icon(
                  Icons.mail_outline,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 15),
                Text(
                  "Aucune conversation pour l'instant",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontFamily: 'Georgia',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Commencez par découvrir des profils dans les bars pour créer des connexions !",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontFamily: 'Georgia',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLetterFeaturesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "💌 Fonctionnalités des lettres",
          style: TextStyle(fontFamily: 'Georgia'),
        ),
        content: const Text(
          "• Écrire des lettres authentiques (500 mots max)\n"
          "• Système tour par tour respectueux\n"
          "• Papier premium pour abonnés\n"
          "• Pièces jointes et cadeaux virtuels\n"
          "• Protection anti-ghosting\n"
          "• Boîte à souvenirs personnelle\n\n"
          "📮 Bientôt disponible !",
          style: TextStyle(fontFamily: 'Georgia'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Compris",
              style: TextStyle(
                color: AppColors.weeklyBar,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ],
      ),
    );
  }
}