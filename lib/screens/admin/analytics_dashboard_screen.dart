import 'package:flutter/material.dart';
import 'dart:math';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  String _selectedPeriod = '7d';
  final List<String> _periods = ['24h', '7d', '30d', '90d', '1y'];
  
  Map<String, dynamic> _analytics = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    
    // Simulate API call with mock data
    await Future.delayed(Duration(milliseconds: 800));
    
    setState(() {
      _analytics = {
        'users': {
          'total': 2847,
          'new': 156,
          'active': 423,
          'retained': 78.5,
          'growth': 12.3,
          'chartData': _generateChartData(30),
          'demographics': {
            'age': {'18-25': 35, '26-35': 45, '36-50': 20},
            'gender': {'male': 52, 'female': 46, 'other': 2},
            'location': {'France': 78, 'Belgique': 12, 'Canada': 6, 'Autre': 4},
          },
        },
        'engagement': {
          'sessionsPerUser': 4.2,
          'averageSessionTime': 18.7, // minutes
          'dailyActiveUsers': 423,
          'weeklyActiveUsers': 1247,
          'monthlyActiveUsers': 2156,
          'bounceRate': 23.4,
          'chartData': _generateChartData(30),
          'mostUsedFeatures': [
            {'name': 'Bars', 'usage': 89.2},
            {'name': 'Jeux', 'usage': 76.8},
            {'name': 'Chat', 'usage': 65.4},
            {'name': 'Profil', 'usage': 54.3},
          ],
        },
        'games': {
          'totalPlays': 15847,
          'averageScore': 1250,
          'completionRate': 72.5,
          'topGames': [
            {'name': 'Memory Game', 'plays': 3421, 'score': 850, 'completion': 78.5},
            {'name': 'Snake Game', 'plays': 2987, 'score': 1250, 'completion': 65.2},
            {'name': 'Quiz Couple', 'plays': 2156, 'score': 7.2, 'completion': 89.1},
            {'name': 'Continue Histoire', 'plays': 1876, 'score': 95, 'completion': 82.3},
            {'name': 'Casse-Briques', 'plays': 1654, 'score': 2150, 'completion': 58.7},
          ],
          'chartData': _generateChartData(30),
          'timeDistribution': {
            '6h-12h': 15,
            '12h-18h': 35,
            '18h-21h': 28,
            '21h-24h': 22,
          },
        },
        'revenue': {
          'totalRevenue': 12450.75,
          'monthlyRevenue': 3245.60,
          'averageRevenuePerUser': 4.37,
          'conversionRate': 8.9,
          'subscriptions': {
            'premium': 247,
            'vip': 89,
            'total': 336,
          },
          'chartData': _generateRevenueData(30),
          'sources': [
            {'name': 'Premium', 'amount': 8750.40, 'percentage': 70.3},
            {'name': 'VIP', 'amount': 2890.15, 'percentage': 23.2},
            {'name': 'In-App', 'amount': 810.20, 'percentage': 6.5},
          ],
        },
        'bars': {
          'totalBars': 12,
          'activeBars': 8,
          'averageOccupancy': 67.8,
          'mostPopular': [
            {'name': 'Bar Romantique', 'users': 156, 'occupancy': 78.5},
            {'name': 'Bar Humoristique', 'users': 134, 'occupancy': 67.2},
            {'name': 'Bar Pirates', 'users': 98, 'occupancy': 49.1},
            {'name': 'Bar Caché', 'users': 45, 'occupancy': 90.0},
          ],
          'peakHours': {
            '19h-20h': 89,
            '20h-21h': 95,
            '21h-22h': 87,
            '22h-23h': 76,
          },
        },
      };
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _generateChartData(int days) {
    final random = Random();
    return List.generate(days, (index) {
      return {
        'day': DateTime.now().subtract(Duration(days: days - index - 1)),
        'value': 50 + random.nextInt(100),
      };
    });
  }

  List<Map<String, dynamic>> _generateRevenueData(int days) {
    final random = Random();
    return List.generate(days, (index) {
      return {
        'day': DateTime.now().subtract(Duration(days: days - index - 1)),
        'value': 50.0 + random.nextDouble() * 200.0,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          '📊 Analytics Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF16213E),
        elevation: 0,
        actions: [
          // Period Selector
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                dropdownColor: Color(0xFF16213E),
                style: TextStyle(color: Colors.white),
                items: _periods.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(period, style: TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedPeriod = value!);
                  _loadAnalytics();
                },
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.people), text: 'Utilisateurs'),
            Tab(icon: Icon(Icons.videogame_asset), text: 'Jeux'),
            Tab(icon: Icon(Icons.monetization_on), text: 'Revenus'),
            Tab(icon: Icon(Icons.local_bar), text: 'Bars'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 20),
                  Text(
                    'Chargement des analytics...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUsersAnalytics(),
                _buildGamesAnalytics(),
                _buildRevenueAnalytics(),
                _buildBarsAnalytics(),
              ],
            ),
    );
  }

  Widget _buildUsersAnalytics() {
    final usersData = _analytics['users'] ?? {};
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics
          Text(
            '👥 Métriques Utilisateurs',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                'Total Utilisateurs',
                _formatNumber(usersData['total']),
                '+${usersData['growth']}%',
                Colors.blue,
                Icons.people,
              ),
              _buildMetricCard(
                'Nouveaux',
                _formatNumber(usersData['new']),
                'Cette période',
                Colors.green,
                Icons.person_add,
              ),
              _buildMetricCard(
                'Utilisateurs Actifs',
                _formatNumber(usersData['active']),
                'En ligne',
                Colors.orange,
                Icons.online_prediction,
              ),
              _buildMetricCard(
                'Rétention',
                '${usersData['retained']}%',
                'Taux moyen',
                Colors.purple,
                Icons.trending_up,
              ),
            ],
          ),
          
          SizedBox(height: 30),
          
          // User Growth Chart
          Text(
            '📈 Évolution des Utilisateurs',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Color(0xFF16213E),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                '📊 Graphique de croissance\n(${usersData['chartData']?.length ?? 0} points de données)',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          SizedBox(height: 30),
          
          // Demographics
          Text(
            '🎯 Démographiques',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildDemographicCard(
                  'Âge',
                  usersData['demographics']?['age'] ?? {},
                  Icons.cake,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildDemographicCard(
                  'Répartition',
                  usersData['demographics']?['gender'] ?? {},
                  Icons.people_outline,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          _buildDemographicCard(
            'Localisation',
            usersData['demographics']?['location'] ?? {},
            Icons.location_on,
            isWide: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGamesAnalytics() {
    final gamesData = _analytics['games'] ?? {};
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎮 Performance des Jeux',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          // Games Metrics
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                'Parties Totales',
                _formatNumber(gamesData['totalPlays']),
                'Toutes périodes',
                Colors.purple,
                Icons.videogame_asset,
              ),
              _buildMetricCard(
                'Score Moyen',
                _formatNumber(gamesData['averageScore']),
                'Global',
                Colors.orange,
                Icons.star,
              ),
              _buildMetricCard(
                'Complétion',
                '${gamesData['completionRate']}%',
                'Taux moyen',
                Colors.green,
                Icons.check_circle,
              ),
              _buildMetricCard(
                'Pic d\'activité',
                '18h-21h',
                '${gamesData['timeDistribution']?['18h-21h']}%',
                Colors.blue,
                Icons.access_time,
              ),
            ],
          ),
          
          SizedBox(height: 30),
          
          // Top Games
          Text(
            '🏆 Jeux les Plus Populaires',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          ...((gamesData['topGames'] as List<dynamic>?) ?? []).map((game) {
            return _buildGameCard(game);
          }),
          
          SizedBox(height: 30),
          
          // Time Distribution
          Text(
            '⏰ Répartition Horaire',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF16213E),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: (gamesData['timeDistribution'] as Map<String, dynamic>?)
                  ?.entries
                  .map((entry) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          entry.key,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: entry.value / 100,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${entry.value}%',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList() ?? [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueAnalytics() {
    final revenueData = _analytics['revenue'] ?? {};
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💰 Analyse des Revenus',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          // Revenue Metrics
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                'Revenus Totaux',
                '${_formatNumber(revenueData['totalRevenue'])}€',
                'Cumulé',
                Colors.green,
                Icons.euro,
              ),
              _buildMetricCard(
                'Ce Mois',
                '${_formatNumber(revenueData['monthlyRevenue'])}€',
                '+15.2%',
                Colors.blue,
                Icons.trending_up,
              ),
              _buildMetricCard(
                'ARPU',
                '${revenueData['averageRevenuePerUser']}€',
                'Par utilisateur',
                Colors.orange,
                Icons.person,
              ),
              _buildMetricCard(
                'Conversion',
                '${revenueData['conversionRate']}%',
                'Taux moyen',
                Colors.purple,
                Icons.transform,
              ),
            ],
          ),
          
          SizedBox(height: 30),
          
          // Revenue Sources
          Text(
            '📊 Sources de Revenus',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          ...((revenueData['sources'] as List<dynamic>?) ?? []).map((source) {
            return Card(
              color: Color(0xFF16213E),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getSourceColor(source['name']),
                  child: Text(
                    '${source['percentage']}%',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(source['name'], style: TextStyle(color: Colors.white)),
                trailing: Text(
                  '${_formatNumber(source['amount'])}€',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
          
          SizedBox(height: 30),
          
          // Subscriptions
          Text(
            '💎 Abonnements',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSubscriptionCard(
                  'Premium',
                  revenueData['subscriptions']?['premium'] ?? 0,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSubscriptionCard(
                  'VIP',
                  revenueData['subscriptions']?['vip'] ?? 0,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarsAnalytics() {
    final barsData = _analytics['bars'] ?? {};
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🍺 Performance des Bars',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          // Bars Metrics
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                'Bars Totaux',
                _formatNumber(barsData['totalBars']),
                'Disponibles',
                Colors.orange,
                Icons.local_bar,
              ),
              _buildMetricCard(
                'Bars Actifs',
                _formatNumber(barsData['activeBars']),
                'En service',
                Colors.green,
                Icons.check_circle,
              ),
              _buildMetricCard(
                'Occupation Moy.',
                '${barsData['averageOccupancy']}%',
                'Globale',
                Colors.blue,
                Icons.people,
              ),
              _buildMetricCard(
                'Pic d\'affluence',
                '20h-21h',
                '95 utilisateurs',
                Colors.purple,
                Icons.trending_up,
              ),
            ],
          ),
          
          SizedBox(height: 30),
          
          // Popular Bars
          Text(
            '🏆 Bars les Plus Populaires',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          ...((barsData['mostPopular'] as List<dynamic>?) ?? []).map((bar) {
            return Card(
              color: Color(0xFF16213E),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getBarColor(bar['name']),
                  child: Text(
                    '${bar['occupancy'].toStringAsFixed(0)}%',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(bar['name'], style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${bar['users']} utilisateurs actifs',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getOccupancyColor(bar['occupancy']),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getOccupancyStatus(bar['occupancy']),
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            );
          }),
          
          SizedBox(height: 30),
          
          // Peak Hours
          Text(
            '⏰ Heures de Pointe',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF16213E),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: (barsData['peakHours'] as Map<String, dynamic>?)
                  ?.entries
                  .map((entry) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          entry.key,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: entry.value / 100,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${entry.value} users',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList() ?? [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicCard(String title, Map<String, dynamic> data, IconData icon, {bool isWide = false}) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...data.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: entry.value / 100,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${entry.value}%',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGameCard(Map<String, dynamic> game) {
    return Card(
      color: Color(0xFF16213E),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple,
          child: Text(
            '${game['plays']}',
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(game['name'], style: TextStyle(color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score moyen: ${game['score']} • ${game['plays']} parties',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: game['completion'] / 100,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            Text(
              '${game['completion']}% de complétion',
              style: TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(String type, int count, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.diamond, color: color, size: 30),
          SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            type,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    if (number is double) {
      return number.toStringAsFixed(1);
    }
    return number.toString();
  }

  Color _getSourceColor(String source) {
    switch (source) {
      case 'Premium':
        return Colors.orange;
      case 'VIP':
        return Colors.purple;
      case 'In-App':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getBarColor(String barName) {
    if (barName.contains('Romantique')) return Colors.pink;
    if (barName.contains('Humoristique')) return Colors.yellow;
    if (barName.contains('Pirates')) return Colors.brown;
    if (barName.contains('Caché')) return Colors.purple;
    return Colors.blue;
  }

  Color _getOccupancyColor(double occupancy) {
    if (occupancy >= 80) return Colors.red;
    if (occupancy >= 60) return Colors.orange;
    if (occupancy >= 40) return Colors.yellow;
    return Colors.green;
  }

  String _getOccupancyStatus(double occupancy) {
    if (occupancy >= 80) return 'Plein';
    if (occupancy >= 60) return 'Occupé';
    if (occupancy >= 40) return 'Moyen';
    return 'Libre';
  }
}