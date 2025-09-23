import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.funPrimary.withOpacity(0.1),
              AppColors.funBackground,
              AppColors.funSecondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo et titre principal
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.funPrimary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: 80,
                    color: AppColors.funPrimary,
                  ),
                ),
                SizedBox(height: 40),
                
                // Titre principal
                Text(
                  'JeuTaime',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppColors.funPrimary,
                    fontFamily: 'ComicSans',
                  ),
                ),
                SizedBox(height: 12),
                
                // Sous-titre
                Text(
                  'L\'app de rencontre immersive',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.funText,
                    fontFamily: 'ComicSans',
                  ),
                ),
                SizedBox(height: 8),
                
                Text(
                  'Découvrez l\'amour dans nos bars thématiques uniques',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 60),
                
                // Bouton principal
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.funPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.funPrimary.withOpacity(0.3),
                    ),
                    child: Text(
                      'Découvrir les bars',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ComicSans',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                // Bouton secondaire
                Container(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.funPrimary,
                      side: BorderSide(color: AppColors.funPrimary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'J\'ai déjà un compte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ComicSans',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                
                // Petites icônes décoratives
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFeatureIcon(Icons.group, 'Rencontres'),
                    SizedBox(width: 40),
                    _buildFeatureIcon(Icons.games, 'Jeux'),
                    SizedBox(width: 40),
                    _buildFeatureIcon(Icons.star, 'Premium'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.funSecondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.funSecondary,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
