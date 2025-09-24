import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  Map<String, bool> _settings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final settings = NotificationService.getNotificationSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erreur de chargement: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildHeader(),
                SizedBox(height: 24),
                _buildNotificationSection(
                  'Messages et Matchs',
                  'Restez informé de vos nouvelles interactions',
                  [
                    _NotificationTile(
                      type: NotificationService.TYPE_NEW_MESSAGE,
                      title: 'Nouveaux messages',
                      subtitle: 'Notifications pour les messages reçus',
                      icon: Icons.message,
                      color: AppColors.primary,
                      enabled: _settings[NotificationService.TYPE_NEW_MESSAGE] ?? true,
                      onChanged: _updateSetting,
                    ),
                    _NotificationTile(
                      type: NotificationService.TYPE_NEW_MATCH,
                      title: 'Nouveaux matchs',
                      subtitle: 'Notifications pour les nouveaux matchs',
                      icon: Icons.favorite,
                      color: Colors.pink,
                      enabled: _settings[NotificationService.TYPE_NEW_MATCH] ?? true,
                      onChanged: _updateSetting,
                    ),
                    _NotificationTile(
                      type: NotificationService.TYPE_GIFT_RECEIVED,
                      title: 'Cadeaux reçus',
                      subtitle: 'Notifications pour les cadeaux',
                      icon: Icons.card_giftcard,
                      color: Colors.orange,
                      enabled: _settings[NotificationService.TYPE_GIFT_RECEIVED] ?? true,
                      onChanged: _updateSetting,
                    ),
                  ],
                ),
                SizedBox(height: 32),
                _buildNotificationSection(
                  'Activité Sociale',
                  'Suivez l\'intérêt des autres utilisateurs',
                  [
                    _NotificationTile(
                      type: NotificationService.TYPE_LIKE_RECEIVED,
                      title: 'Likes reçus',
                      subtitle: 'Notifications quand quelqu\'un vous like',
                      icon: Icons.thumb_up,
                      color: Colors.red,
                      enabled: _settings[NotificationService.TYPE_LIKE_RECEIVED] ?? true,
                      onChanged: _updateSetting,
                    ),
                    _NotificationTile(
                      type: NotificationService.TYPE_PROFILE_VISIT,
                      title: 'Visites de profil',
                      subtitle: 'Notifications pour les visites de votre profil',
                      icon: Icons.visibility,
                      color: Colors.blue,
                      enabled: _settings[NotificationService.TYPE_PROFILE_VISIT] ?? false,
                      onChanged: _updateSetting,
                    ),
                  ],
                ),
                SizedBox(height: 32),
                _buildNotificationSection(
                  'Application',
                  'Notifications système et rappels',
                  [
                    _NotificationTile(
                      type: NotificationService.TYPE_GAME_REWARD,
                      title: 'Récompenses jeux',
                      subtitle: 'Notifications pour les récompenses gagnées',
                      icon: Icons.sports_esports,
                      color: Colors.green,
                      enabled: _settings[NotificationService.TYPE_GAME_REWARD] ?? true,
                      onChanged: _updateSetting,
                    ),
                    _NotificationTile(
                      type: NotificationService.TYPE_DAILY_REMINDER,
                      title: 'Rappels quotidiens',
                      subtitle: 'Rappels pour utiliser l\'application',
                      icon: Icons.schedule,
                      color: Colors.purple,
                      enabled: _settings[NotificationService.TYPE_DAILY_REMINDER] ?? true,
                      onChanged: _updateSetting,
                    ),
                    _NotificationTile(
                      type: NotificationService.TYPE_SUBSCRIPTION_EXPIRY,
                      title: 'Abonnement',
                      subtitle: 'Notifications d\'expiration d\'abonnement',
                      icon: Icons.star,
                      color: Colors.amber,
                      enabled: _settings[NotificationService.TYPE_SUBSCRIPTION_EXPIRY] ?? true,
                      onChanged: _updateSetting,
                    ),
                  ],
                ),
                SizedBox(height: 32),
                _buildAdvancedOptions(),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement des paramètres...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications, color: Colors.white, size: 32),
              SizedBox(width: 16),
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Personnalisez vos notifications pour ne rien manquer d\'important.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(String title, String subtitle, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: tiles,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Options avancées',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.notifications_off, color: Colors.red),
            ),
            title: Text('Désactiver toutes les notifications'),
            subtitle: Text('Arrêter temporairement toutes les notifications'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            onTap: _showDisableAllDialog,
          ),
          Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.settings, color: AppColors.primary),
            ),
            title: Text('Paramètres système'),
            subtitle: Text('Ouvrir les paramètres de notifications du système'),
            trailing: Icon(Icons.open_in_new, size: 16, color: AppColors.textSecondary),
            onTap: _openSystemSettings,
          ),
        ],
      ),
    );
  }

  Future<void> _updateSetting(String type, bool enabled) async {
    setState(() {
      _settings[type] = enabled;
    });

    try {
      await NotificationService.updateNotificationSettings(type, enabled);
      
      // Feedback visuel
      String message = enabled 
          ? 'Notifications activées' 
          : 'Notifications désactivées';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: enabled ? Colors.green : Colors.grey,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      // Rollback en cas d'erreur
      setState(() {
        _settings[type] = !enabled;
      });
      _showError('Erreur lors de la sauvegarde');
    }
  }

  void _showDisableAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Désactiver toutes les notifications'),
        content: Text('Voulez-vous vraiment désactiver toutes les notifications ? Vous pourrez les réactiver individuellement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _disableAllNotifications();
            },
            child: Text('Désactiver', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _disableAllNotifications() async {
    final Map<String, bool> newSettings = {};
    for (String key in _settings.keys) {
      newSettings[key] = false;
      await NotificationService.updateNotificationSettings(key, false);
    }
    
    setState(() {
      _settings = newSettings;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Toutes les notifications ont été désactivées'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _openSystemSettings() {
    // TODO: Ouvrir les paramètres système de notifications
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture des paramètres système...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool enabled;
  final Function(String, bool) onChanged;

  const _NotificationTile({
    Key? key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SwitchListTile(
        value: enabled,
        onChanged: (value) => onChanged(type, value),
        secondary: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        activeColor: AppColors.primary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}