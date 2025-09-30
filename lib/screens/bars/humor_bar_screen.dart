import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_header.dart';

class HumorBarScreen extends StatefulWidget {
  const HumorBarScreen({Key? key}) : super(key: key);

  @override
  State<HumorBarScreen> createState() => _HumorBarScreenState();
}

class _HumorBarScreenState extends State<HumorBarScreen> {
  bool _isLoading = false;
  List<dynamic> _users = [];

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
                title: "😄 Bar Humoristique",
                subtitle: "Ambiance festive • Bonne humeur garantie",
              ),
              
              // Contenu du bar
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Défi du jour
                    _buildChallengeCard(),
                    
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
  
  Widget _buildChallengeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.humorousBar, width: 2),
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
          const Text(
            "🎪 Défi du Jour",
            style: TextStyle(
              color: Color(0xFFF57C00),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          const Text(
            "\"Racontez votre pire blague avec le plus de sérieux possible\"",
            style: TextStyle(
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
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.humorousBar.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                _showChallengeDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                "Participer au Défi ! 🎭",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
        border: Border.all(color: AppColors.humorousBar, width: 2),
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
          const Text(
            "🎭 Activités du Bar",
            style: TextStyle(
              color: Color(0xFFF57C00),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // Liste des activités
          _buildActivityItem("😂 Blagues du Jour", "+20 pièces", Icons.lightbulb),
          _buildActivityItem("🎪 Défi Comédie", "+40 pièces", Icons.theater_comedy),
          _buildActivityItem("🤪 Mime Challenge", "+30 pièces", Icons.face),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem(String title, String reward, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.humorousBar.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.humorousBar, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  Text(
                    reward,
                    style: TextStyle(
                      color: AppColors.humorousBar,
                      fontSize: 14,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.humorousBar,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showChallengeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.beige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.humorousBar, width: 2),
          ),
          title: const Text(
            "🎪 Défi du Jour",
            style: TextStyle(
              color: Color(0xFFF57C00),
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
            textAlign: TextAlign.center,
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Félicitations ! Vous participez au défi du jour.",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Georgia',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                "Récompense: +50 pièces",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF57C00),
                  fontSize: 16,
                  fontFamily: 'Georgia',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.humorousBar,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                "Parfait !",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _fetchUsers() {
    setState(() {
      _isLoading = true;
    });
    // Simulation de chargement - remplacer par BarService.getUsersInBar('humor')
    setState(() {
      _users = [];
      _isLoading = false;
    });
  }
}