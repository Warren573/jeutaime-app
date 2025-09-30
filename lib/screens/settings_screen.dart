/**
 * RÉFÉRENCE OBLIGATOIRE: https://jeutaime-warren.web.app/
 * 
 * Écran Paramètres - contient maintenant la Boutique + paramètres de l'app
 */

import 'package:flutter/material.dart';
import '../config/ui_reference.dart';

class SettingsScreen extends StatelessWidget {
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
                child: _buildSettingsList(),
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
      ),
      child: Row(
        children: [
          Text('⚙️', style: TextStyle(fontSize: 28)),
          SizedBox(width: 15),
          Text(
            'Paramètres & Boutique',
            style: UIReference.titleStyle.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: ListView(
        children: [
          // Section Boutique
          Text('🛍️ Boutique', style: UIReference.titleStyle.copyWith(fontSize: 22)),
          SizedBox(height: 15),
          _buildShopCard('Premium 19,90€/mois', 'Accès illimité aux bars', '👑', Color(0xFFFFD700)),
          _buildShopCard('Pack 100 pièces', 'Pour débloquer les activités', '💰', Color(0xFF4CAF50)),
          _buildShopCard('Pack 500 pièces', 'Le pack populaire', '💎', Color(0xFF2196F3)),
          SizedBox(height: 30),

          // Section Sécurité
          Text('🔒 Sécurité', style: UIReference.titleStyle.copyWith(fontSize: 22)),
          SizedBox(height: 15),
          _buildSettingItem('Changer le mot de passe', Icons.password, () {}),
          _buildSettingItem('Authentification à deux facteurs', Icons.security, () {}),
          _buildSettingItem('Appareils connectés', Icons.devices, () {}),
          SizedBox(height: 30),

          // Section Personnalisation
          Text('🎨 Personnalisation', style: UIReference.titleStyle.copyWith(fontSize: 22)),
          SizedBox(height: 15),
          _buildSettingItem('Thème clair/sombre', Icons.brightness_6, () {}),
          _buildSettingItem('Couleur d’accent', Icons.color_lens, () {}),
          _buildSettingItem('Police d’écriture', Icons.font_download, () {}),
          SizedBox(height: 30),

          // Section Confidentialité
          Text('🕵️ Confidentialité', style: UIReference.titleStyle.copyWith(fontSize: 22)),
          SizedBox(height: 15),
          _buildSettingItem('Masquer mon profil', Icons.visibility_off, () {}),
          _buildSettingItem('Contrôler qui peut m’envoyer des lettres', Icons.mail_lock, () {}),
          _buildSettingItem('Historique de connexion', Icons.history, () {}),
          SizedBox(height: 30),

          // Section Notifications
          Text('🔔 Notifications', style: UIReference.titleStyle.copyWith(fontSize: 22)),
          SizedBox(height: 15),
          _buildSettingItem('Notifications push', Icons.notifications_active, () {}),
          _buildSettingItem('Fréquence des notifications', Icons.schedule, () {}),
          _buildSettingItem('Notifications par email', Icons.email, () {}),
          SizedBox(height: 30),

          // Section Compte
          Text('👤 Compte', style: UIReference.titleStyle.copyWith(fontSize: 22)),
          SizedBox(height: 15),
          _buildSettingItem('Supprimer mon compte', Icons.delete_forever, () {}),
          _buildSettingItem('Exporter mes données', Icons.download, () {}),
          _buildSettingItem('Voir mes données personnelles', Icons.info_outline, () {}),
          SizedBox(height: 30),

          // Section Social
          Text('🤝 Social', style: UIReference.titleStyle.copyWith(fontSize: 22)),
          SizedBox(height: 15),
          _buildSettingItem('Lier un compte Google', Icons.account_circle, () {}),
          _buildSettingItem('Lier un compte Facebook', Icons.facebook, () {}),
          _buildSettingItem('Lier un compte Apple', Icons.apple, () {}),
          _buildSettingItem('Gérer mes contacts bloqués', Icons.block, () {}),
          _buildSettingItem('Gérer mes amis/favoris', Icons.favorite, () {}),
          SizedBox(height: 30),

          // Section Application
          Text('📱 Application', style: UIReference.titleStyle.copyWith(fontSize: 22)),
          SizedBox(height: 15),
          _buildSettingItem('Langue de l’application', Icons.language, () {}),
          _buildSettingItem('Tutoriel/guide de démarrage', Icons.school, () {}),
          _buildSettingItem('Version de l’application', Icons.verified, () {}),
          SizedBox(height: 30),

          // Section Support
          Text('🆘 Support', style: UIReference.titleStyle.copyWith(fontSize: 22)),
          SizedBox(height: 15),
          _buildSettingItem('Signaler un bug', Icons.bug_report, () {}),
          _buildSettingItem('Suggérer une amélioration', Icons.lightbulb, () {}),
          _buildSettingItem('Contacter le support', Icons.support_agent, () {}),
        ],
      ),
    );
  }

  Widget _buildShopCard(String title, String description, String emoji, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: UIReference.colors['cardBackground'],
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: TextStyle(fontSize: 24)),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: UIReference.subtitleStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: UIReference.bodyStyle.copyWith(
                    fontSize: 13,
                    color: UIReference.colors['textSecondary'],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.shopping_cart, color: color, size: 20),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: UIReference.colors['accent']!.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: UIReference.colors['primary'],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: UIReference.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: UIReference.colors['textSecondary'],
          size: 16,
        ),
        onTap: onTap,
        tileColor: UIReference.colors['cardBackground'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}