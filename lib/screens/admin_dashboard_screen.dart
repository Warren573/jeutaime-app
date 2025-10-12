import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/firebase_service.dart';
import '../models/user.dart';
import '../models/bar.dart';
import '../services/user_data_manager.dart';
import 'admin/analytics_dashboard_screen.dart';
import 'admin/bar_management_screen.dart';
import 'admin/theme_event_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isAdmin = false;
  
  // Statistics
  Map<String, dynamic> _stats = {
    'totalUsers': 0,
    'activeUsers': 0,
    'totalBars': 0,
    'activeBars': 0,
    'totalGames': 0,
    'gamesPlayedToday': 0,
    'totalRevenue': 0,
    'averageSessionTime': 0,
  };
  
  List<Map<String, dynamic>> _users = [];
  List<Bar> _bars = [];
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _gameStats = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _checkAdminAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminAccess() async {
    setState(() => _isLoading = true);
    
    try {
      // Check if current user is admin (you'll need to implement this)
      final isAdmin = await FirebaseService.instance.checkAdminAccess();
      if (isAdmin) {
        setState(() => _isAdmin = true);
        await _loadDashboardData();
      } else {
        _showAccessDenied();
      }
    } catch (e) {
      _showError('Erreur lors de la vérification admin: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadDashboardData() async {
    try {
      await Future.wait([
        _loadStatistics(),
        _loadUsers(),
        _loadBars(),
        _loadReports(),
        _loadGameStatistics(),
      ]);
    } catch (e) {
      _showError('Erreur lors du chargement: $e');
    }
  }

  Future<void> _loadStatistics() async {
    // Implementation to load app statistics
    setState(() {
      _stats = {
        'totalUsers': 1247,
        'activeUsers': 89,
        'totalBars': 12,
        'activeBars': 8,
        'totalGames': 8,
        'gamesPlayedToday': 156,
        'totalRevenue': 2450.30,
        'averageSessionTime': 14.5,
      };
    });
  }

  Future<void> _loadUsers() async {
    // Implementation to load users list
    setState(() {
      _users = [
        {
          'id': 'user1',
          'name': 'Marie Dupont',
          'email': 'marie@example.com',
          'level': 5,
          'coins': 245,
          'gamesPlayed': 23,
          'isActive': true,
          'joinedAt': DateTime.now().subtract(Duration(days: 15)),
          'lastActive': DateTime.now().subtract(Duration(hours: 2)),
        },
        // Add more mock users...
      ];
    });
  }

  Future<void> _loadBars() async {
    // Implementation to load bars
    setState(() {
      _bars = [
        Bar(
          barId: 'romantic_001',
          name: 'Bar des Amoureux',
          type: BarType.romantic,
          activeUsers: 4,
          maxParticipants: 8,
          isActive: true,
          ambiance: 'Tamisée et romantique',
        ),
        // Add more bars...
      ];
    });
  }

  Future<void> _loadReports() async {
    // Implementation to load user reports
    setState(() {
      _reports = [
        {
          'id': 'report1',
          'type': 'user',
          'targetId': 'user123',
          'reason': 'Contenu inapproprié',
          'status': 'open',
          'createdAt': DateTime.now().subtract(Duration(hours: 3)),
          'reportedBy': 'user456',
        },
        // Add more reports...
      ];
    });
  }

  Future<void> _loadGameStatistics() async {
    // Implementation to load game statistics
    setState(() {
      _gameStats = [
        {
          'name': 'Memory Game',
          'icon': '🧠',
          'totalPlays': 1234,
          'averageScore': 850,
          'completionRate': 78.5,
          'popularityRank': 1,
        },
        {
          'name': 'Snake Game',
          'icon': '🐍', 
          'totalPlays': 987,
          'averageScore': 1250,
          'completionRate': 65.2,
          'popularityRank': 2,
        },
        {
          'name': 'Quiz Couple',
          'icon': '💕',
          'totalPlays': 756,
          'averageScore': 7.2,
          'completionRate': 89.1,
          'popularityRank': 3,
        },
        // Add more games...
      ];
    });
  }

  void _showAccessDenied() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.red),
            SizedBox(width: 10),
            Text('Accès Refusé'),
          ],
        ),
        content: Text('Vous n\'avez pas les permissions administrateur requises.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.pink),
              SizedBox(height: 20),
              Text(
                'Vérification des permissions...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, color: Colors.red, size: 80),
              SizedBox(height: 20),
              Text(
                'Accès Refusé',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Permissions administrateur requises',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          '🔧 Administration JeuTaime',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF16213E),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.pink,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: 'Tableau de Bord'),
            Tab(icon: Icon(Icons.people), text: 'Utilisateurs'),
            Tab(icon: Icon(Icons.local_bar), text: 'Bars'),
            Tab(icon: Icon(Icons.videogame_asset), text: 'Jeux'),
            Tab(icon: Icon(Icons.report), text: 'Signalements'),
            Tab(icon: Icon(Icons.settings), text: 'Configuration'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildUsersTab(),
          _buildBarsTab(),
          _buildGamesTab(),
          _buildReportsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Vue d\'ensemble',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          
          // Statistics Cards
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('👥 Utilisateurs Total', _stats['totalUsers'].toString(), Colors.blue),
              _buildStatCard('🟢 Utilisateurs Actifs', _stats['activeUsers'].toString(), Colors.green),
              _buildStatCard('🍺 Bars Total', _stats['totalBars'].toString(), Colors.orange),
              _buildStatCard('🎮 Parties Aujourd\'hui', _stats['gamesPlayedToday'].toString(), Colors.purple),
              _buildStatCard('💰 Revenus', '${_stats['totalRevenue']}€', Colors.pink),
              _buildStatCard('⏱️ Session Moyenne', '${_stats['averageSessionTime']}min', Colors.teal),
            ],
          ),
          
          SizedBox(height: 30),
          
          // Recent Activity
          Text(
            '📈 Activité Récente',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF16213E),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                _buildActivityItem('🎮', 'Nouveau record Memory Game: 2450 points', '2 min'),
                _buildActivityItem('👥', '5 nouveaux utilisateurs inscrits', '15 min'),
                _buildActivityItem('🍺', 'Bar Romantique complet (8/8)', '23 min'),
                _buildActivityItem('💰', 'Achat Premium par Marie D.', '1h'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String icon, String title, String time) {
    return ListTile(
      leading: Text(icon, style: TextStyle(fontSize: 20)),
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: Text(time, style: TextStyle(color: Colors.white60)),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '👥 Gestion des Utilisateurs',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateUserDialog(),
                icon: Icon(Icons.add),
                label: Text('Nouvel Utilisateur'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Users List
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                color: Color(0xFF16213E),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user['isActive'] ? Colors.green : Colors.grey,
                    child: Text(user['name'][0]),
                  ),
                  title: Text(user['name'], style: TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${user['email']} • Niveau ${user['level']}', 
                           style: TextStyle(color: Colors.white70)),
                      Text('${user['coins']} pièces • ${user['gamesPlayed']} parties',
                           style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'ban',
                        child: Row(
                          children: [
                            Icon(Icons.block, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Bannir', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleUserAction(value, user),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBarsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🍺 Gestion des Bars',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateBarDialog(),
                icon: Icon(Icons.add),
                label: Text('Nouveau Bar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Bars Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: _bars.length,
            itemBuilder: (context, index) {
              final bar = _bars[index];
              return Card(
                color: Color(0xFF16213E),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(bar.type.displayName.split(' ')[0], 
                               style: TextStyle(fontSize: 24)),
                          Icon(
                            bar.isActive ? Icons.circle : Icons.circle_outlined,
                            color: bar.isActive ? Colors.green : Colors.grey,
                            size: 12,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        bar.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        bar.type.description,
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${bar.activeUsers}/${bar.maxParticipants}',
                            style: TextStyle(color: Colors.white60),
                          ),
                          IconButton(
                            onPressed: () => _editBar(bar),
                            icon: Icon(Icons.edit, color: Colors.white60, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGamesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎮 Statistiques des Jeux',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          
          // Games Statistics
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _gameStats.length,
            itemBuilder: (context, index) {
              final game = _gameStats[index];
              return Card(
                color: Color(0xFF16213E),
                child: ListTile(
                  leading: Text(game['icon'], style: TextStyle(fontSize: 30)),
                  title: Text(game['name'], style: TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${game['totalPlays']} parties • Rang #${game['popularityRank']}',
                           style: TextStyle(color: Colors.white70)),
                      LinearProgressIndicator(
                        value: game['completionRate'] / 100,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      Text('${game['completionRate']}% de complétion',
                           style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => _showGameDetails(game),
                    icon: Icon(Icons.analytics, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 Signalements',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          
          // Reports List
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _reports.length,
            itemBuilder: (context, index) {
              final report = _reports[index];
              return Card(
                color: Color(0xFF16213E),
                child: ListTile(
                  leading: Icon(
                    Icons.report_problem,
                    color: report['status'] == 'open' ? Colors.red : Colors.green,
                  ),
                  title: Text('${report['reason']}', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'Type: ${report['type']} • ${_formatDate(report['createdAt'])}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: report['status'] == 'open'
                      ? ElevatedButton(
                          onPressed: () => _resolveReport(report['id']),
                          child: Text('Traiter'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        )
                      : Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚙️ Configuration',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          
          // Quick Actions
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildQuickActionCard(
                'Analytics Avancées',
                '📊',
                'Métriques détaillées',
                Colors.blue,
                () => _navigateToAnalytics(),
              ),
              _buildQuickActionCard(
                'Gestion des Bars',
                '🍺',
                'Créer et configurer',
                Colors.orange,
                () => _navigateToBarManagement(),
              ),
              _buildQuickActionCard(
                'Thèmes & Événements',
                '🎨',
                'Personnalisation',
                Colors.purple,
                () => _navigateToThemeEvents(),
              ),
              _buildQuickActionCard(
                'Exportation',
                '💾',
                'Données utilisateurs',
                Colors.green,
                () => _showBackupOptions(),
              ),
            ],
          ),
          
          SizedBox(height: 30),
          
          // Settings Cards
          Card(
            color: Color(0xFF16213E),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.monetization_on, color: Colors.green),
                  title: Text('Système Économique', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Régler les prix et récompenses', style: TextStyle(color: Colors.white70)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onTap: () => _showEconomySettings(),
                ),
                Divider(color: Colors.white24),
                ListTile(
                  leading: Icon(Icons.notifications, color: Colors.blue),
                  title: Text('Notifications Push', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Configurer les notifications', style: TextStyle(color: Colors.white70)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onTap: () => _showNotificationSettings(),
                ),
                Divider(color: Colors.white24),
                ListTile(
                  leading: Icon(Icons.security, color: Colors.red),
                  title: Text('Sécurité & Modération', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Paramètres de sécurité', style: TextStyle(color: Colors.white70)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onTap: () => _showSecuritySettings(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String emoji, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF16213E),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 32)),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white60, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  void _showCreateUserDialog() {
    // Implementation to create new user
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Créer un Utilisateur'),
        content: Text('Fonctionnalité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    // Implementation for user actions (edit, ban, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action $action sur ${user['name']}')),
    );
  }

  void _showCreateBarDialog() {
    // Implementation to create new bar
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Créer un Bar'),
        content: Text('Fonctionnalité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _editBar(Bar bar) {
    // Implementation to edit bar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Édition de ${bar.name}')),
    );
  }

  void _showGameDetails(Map<String, dynamic> game) {
    // Implementation to show detailed game statistics
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${game['icon']} ${game['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parties totales: ${game['totalPlays']}'),
            Text('Score moyen: ${game['averageScore']}'),
            Text('Taux de complétion: ${game['completionRate']}%'),
            Text('Rang de popularité: #${game['popularityRank']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _resolveReport(String reportId) {
    // Implementation to resolve report
    setState(() {
      final reportIndex = _reports.indexWhere((r) => r['id'] == reportId);
      if (reportIndex != -1) {
        _reports[reportIndex]['status'] = 'resolved';
      }
    });
  }

  // Navigation Methods
  void _navigateToAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalyticsDashboardScreen(),
      ),
    );
  }

  void _navigateToBarManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarManagementScreen(),
      ),
    );
  }

  void _navigateToThemeEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ThemeEventManagementScreen(),
      ),
    );
  }

  void _showEconomySettings() {
    // Implementation for economy settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Paramètres économiques à implémenter')),
    );
  }

  void _showNotificationSettings() {
    // Implementation for notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Paramètres notifications à implémenter')),
    );
  }

  void _showSecuritySettings() {
    // Implementation for security settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Paramètres sécurité à implémenter')),
    );
  }

  void _showBackupOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF16213E),
        title: Text('💾 Sauvegarde des Données', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.download, color: Colors.blue),
              title: Text('Exporter Utilisateurs', style: TextStyle(color: Colors.white)),
              subtitle: Text('CSV/JSON', style: TextStyle(color: Colors.white70)),
              onTap: () {
                Navigator.pop(context);
                _exportUsers();
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: Colors.green),
              title: Text('Exporter Statistiques', style: TextStyle(color: Colors.white)),
              subtitle: Text('Données analytiques', style: TextStyle(color: Colors.white70)),
              onTap: () {
                Navigator.pop(context);
                _exportAnalytics();
              },
            ),
            ListTile(
              leading: Icon(Icons.cloud_upload, color: Colors.orange),
              title: Text('Sauvegarde Cloud', style: TextStyle(color: Colors.white)),
              subtitle: Text('Backup complet', style: TextStyle(color: Colors.white70)),
              onTap: () {
                Navigator.pop(context);
                _createCloudBackup();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _exportUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export utilisateurs en cours...')),
    );
  }

  void _exportAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export analytics en cours...')),
    );
  }

  void _createCloudBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sauvegarde cloud en cours...')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) {
      return 'Il y a ${diff.inDays}j';
    } else if (diff.inHours > 0) {
      return 'Il y a ${diff.inHours}h';
    } else {
      return 'Il y a ${diff.inMinutes}min';
    }
  }
}