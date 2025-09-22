import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Écran de profil utilisateur avec informations personnelles et paramètres
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Text('Mon Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigation vers édition du profil
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Photo de profil
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.funPrimary,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 16),
            
            // Informations utilisateur
            Text(
              'Utilisateur JeuTaime',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.funText,
              ),
            ),
            Text(
              'Membre depuis janvier 2024',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Options du profil
            _buildProfileCard(
              title: 'Mes informations',
              icon: Icons.person_outline,
              onTap: () {},
            ),
            _buildProfileCard(
              title: 'Paramètres de confidentialité',
              icon: Icons.privacy_tip_outlined,
              onTap: () {},
            ),
            _buildProfileCard(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: AppColors.funPrimary,
              ),
            ),
            _buildProfileCard(
              title: 'Mode sombre',
              icon: Icons.dark_mode_outlined,
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
                activeColor: AppColors.funPrimary,
              ),
            ),
            _buildProfileCard(
              title: 'Aide et support',
              icon: Icons.help_outline,
              onTap: () {},
            ),
            _buildProfileCard(
              title: 'À propos',
              icon: Icons.info_outline,
              onTap: () {},
            ),
            
            SizedBox(height: 32),
            
            // Bouton de déconnexion
            ElevatedButton.icon(
              onPressed: () {
                // Logique de déconnexion
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Déconnexion'),
                    content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.popAndPushNamed(context, '/welcome');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('Déconnexion'),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout),
              label: Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.funPrimary),
        title: Text(title),
        trailing: trailing ?? Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}