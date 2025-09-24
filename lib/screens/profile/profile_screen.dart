import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFunMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isFunMode ? AppColors.funBackground : AppColors.seriousBackground,
      appBar: AppBar(
        title: Text(
          'Mon Profil',
          style: TextStyle(
            fontFamily: _isFunMode ? 'ComicSans' : 'Montserrat',
            fontWeight: FontWeight.bold,
            color: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Photo de profil
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Nom et informations de base
            Text(
              'Utilisateur',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _isFunMode ? AppColors.funText : AppColors.seriousText,
                fontFamily: _isFunMode ? 'ComicSans' : 'Montserrat',
              ),
            ),
            
            SizedBox(height: 8),
            
            Text(
              AuthService.currentUser?.email ?? 'Email non disponible',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: _isFunMode ? 'ComicSans' : 'Montserrat',
              ),
            ),
            
            SizedBox(height: 30),
            
            // Options du profil
            _buildProfileOption(
              icon: Icons.edit,
              title: 'Modifier le profil',
              onTap: () {
                // TODO: Navigate to edit profile
              },
            ),

            _buildProfileOption(
              icon: Icons.photo_library,
              title: 'Mes photos',
              subtitle: 'Gérer mes photos de profil',
              onTap: () {
                Navigator.pushNamed(context, '/photo-management');
              },
            ),
            
            _buildProfileOption(
              icon: Icons.favorite,
              title: 'Découvrir',
              subtitle: 'Trouver de nouveaux matchs',
              onTap: () {
                Navigator.pushNamed(context, '/matching');
              },
            ),
            
            _buildProfileOption(
              icon: Icons.message,
              title: 'Mes conversations',
              subtitle: 'Messages et chats',
              onTap: () {
                Navigator.pushNamed(context, '/chat');
              },
            ),

            _buildProfileOption(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Paramètres de notifications',
              onTap: () {
                Navigator.pushNamed(context, '/notification-settings');
              },
            ),
            
            _buildProfileOption(
              icon: Icons.star,
              title: 'Mes badges',
              onTap: () {
                // TODO: Navigate to badges
              },
            ),
            
            _buildProfileOption(
              icon: Icons.monetization_on,
              title: 'Mes coins',
              subtitle: '100 coins disponibles', // TODO: Get from user data
              onTap: () {
                Navigator.pushNamed(context, '/shop');
              },
            ),
            
            SizedBox(height: 30),
            
            // Bouton de déconnexion
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_isFunMode ? 25 : 12),
                  ),
                ),
                child: Text(
                  'Se déconnecter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        color: _isFunMode ? AppColors.funCardBackground : AppColors.seriousCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_isFunMode ? 15 : 8),
        ),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (_isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _isFunMode ? AppColors.funText : AppColors.seriousText,
              fontFamily: _isFunMode ? 'ComicSans' : 'Montserrat',
            ),
          ),
          subtitle: subtitle != null 
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: _isFunMode ? 'ComicSans' : 'Montserrat',
                ),
              ) 
            : null,
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[400],
            size: 16,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}