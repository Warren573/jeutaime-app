import 'package:flutter/material.dart';

class ThemeEventManagementScreen extends StatefulWidget {
  const ThemeEventManagementScreen({super.key});

  @override
  State<ThemeEventManagementScreen> createState() => _ThemeEventManagementScreenState();
}

class _ThemeEventManagementScreenState extends State<ThemeEventManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  List<AppThemeData> _themes = [];
  List<EventData> _events = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    // Load existing themes
    _themes = [
      AppThemeData(
        id: 'valentine',
        name: 'Saint-Valentin',
        description: 'Thème romantique pour la Saint-Valentin',
        primaryColor: Colors.red,
        secondaryColor: Colors.pink,
        backgroundColor: Color(0xFF2D1B38),
        isActive: false,
        dateRange: DateTimeRange(
          start: DateTime(2025, 2, 10),
          end: DateTime(2025, 2, 16),
        ),
        customEmojis: ['💖', '💕', '💘', '💝'],
        specialEffects: ['hearts_rain', 'romantic_glow'],
      ),
      AppThemeData(
        id: 'christmas',
        name: 'Noël',
        description: 'Ambiance festive de Noël',
        primaryColor: Colors.green,
        secondaryColor: Colors.red,
        backgroundColor: Color(0xFF1A2E1A),
        isActive: false,
        dateRange: DateTimeRange(
          start: DateTime(2024, 12, 20),
          end: DateTime(2024, 12, 26),
        ),
        customEmojis: ['🎄', '🎅', '❄️', '🎁'],
        specialEffects: ['snow_fall', 'christmas_lights'],
      ),
      AppThemeData(
        id: 'summer',
        name: 'Été',
        description: 'Thème estival et chaleureux',
        primaryColor: Colors.orange,
        secondaryColor: Colors.yellow,
        backgroundColor: Color(0xFF2E2E1A),
        isActive: true,
        dateRange: DateTimeRange(
          start: DateTime(2025, 6, 21),
          end: DateTime(2025, 9, 22),
        ),
        customEmojis: ['☀️', '🏖️', '🌊', '🍹'],
        specialEffects: ['sun_rays', 'beach_waves'],
      ),
    ];

    // Load existing events
    _events = [
      EventData(
        id: 'speed_dating',
        name: 'Speed Dating Virtuel',
        description: 'Événement de rencontres rapides dans les bars',
        type: EventType.special,
        startDate: DateTime(2025, 1, 15, 19, 0),
        endDate: DateTime(2025, 1, 15, 22, 0),
        isActive: true,
        maxParticipants: 50,
        currentParticipants: 23,
        rewards: {
          'coins': 100,
          'xp': 50,
          'badge': 'speed_dater',
        },
        requirements: {
          'minLevel': 3,
          'premium': false,
        },
        affectedBars: ['romantic_001', 'humor_001'],
        specialRules: [
          '3 minutes par conversation',
          'Maximum 10 conversations',
          'Vote pour votre match préféré',
        ],
      ),
      EventData(
        id: 'game_tournament',
        name: 'Tournoi de Jeux',
        description: 'Compétition sur tous les jeux disponibles',
        type: EventType.tournament,
        startDate: DateTime(2025, 1, 20, 14, 0),
        endDate: DateTime(2025, 1, 22, 23, 59),
        isActive: false,
        maxParticipants: 100,
        currentParticipants: 0,
        rewards: {
          'coins': 500,
          'xp': 200,
          'badge': 'tournament_winner',
          'premium_days': 7,
        },
        requirements: {
          'minLevel': 5,
          'premium': false,
        },
        affectedBars: ['all'],
        specialRules: [
          'Points basés sur les performances',
          'Classement en temps réel',
          'Prix pour le top 10',
        ],
      ),
      EventData(
        id: 'valentines_special',
        name: 'Spécial Saint-Valentin',
        description: 'Événement romantique avec récompenses exclusives',
        type: EventType.seasonal,
        startDate: DateTime(2025, 2, 14, 0, 0),
        endDate: DateTime(2025, 2, 14, 23, 59),
        isActive: false,
        maxParticipants: 200,
        currentParticipants: 0,
        rewards: {
          'coins': 300,
          'xp': 100,
          'badge': 'cupid',
          'exclusive_emoji': '💘',
        },
        requirements: {
          'minLevel': 1,
          'premium': false,
        },
        affectedBars: ['romantic_001'],
        specialRules: [
          'Double XP pour les jeux romantiques',
          'Nouveau jeu exclusif disponible',
          'Messages d\'amour anonymes',
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          '🎨 Thèmes & Événements',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF16213E),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(icon: Icon(Icons.palette), text: 'Thèmes'),
            Tab(icon: Icon(Icons.event), text: 'Événements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildThemesTab(),
          _buildEventsTab(),
        ],
      ),
    );
  }

  Widget _buildThemesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🎨 Gestion des Thèmes',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateThemeDialog(),
                icon: Icon(Icons.add),
                label: Text('Nouveau Thème'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Active Theme
          if (_themes.any((t) => t.isActive))
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.withOpacity(0.3), Colors.purple.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.purple),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.purple),
                      SizedBox(width: 8),
                      Text(
                        'Thème Actuel',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ..._themes.where((t) => t.isActive).map((theme) => 
                    _buildThemeCard(theme, isActive: true)
                  ),
                ],
              ),
            ),
          
          SizedBox(height: 20),
          
          // All Themes
          Text(
            'Tous les Thèmes',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
            ),
            itemCount: _themes.length,
            itemBuilder: (context, index) {
              return _buildThemeCard(_themes[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📅 Gestion des Événements',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateEventDialog(),
                icon: Icon(Icons.add),
                label: Text('Nouvel Événement'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Event Statistics
          Row(
            children: [
              Expanded(
                child: _buildEventStatCard(
                  'Événements Actifs',
                  _events.where((e) => e.isActive).length.toString(),
                  Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildEventStatCard(
                  'Participants Total',
                  _events.fold<int>(0, (sum, e) => sum + e.currentParticipants).toString(),
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Events List
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              return _buildEventCard(_events[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(AppThemeData theme, {bool isActive = false}) {
    return Card(
      color: Color(0xFF16213E),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isActive
              ? LinearGradient(
                  colors: [theme.primaryColor.withOpacity(0.3), Colors.transparent],
                )
              : null,
        ),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                theme.customEmojis.first,
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            theme.name,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                theme.description,
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  ...theme.customEmojis.map((emoji) => 
                    Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Text(emoji, style: TextStyle(fontSize: 16)),
                    )
                  ),
                ],
              ),
              Text(
                '${_formatDate(theme.dateRange.start)} - ${_formatDate(theme.dateRange.end)}',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          trailing: PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'activate',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Activer'),
                  ],
                ),
              ),
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
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 16),
                    SizedBox(width: 8),
                    Text('Dupliquer'),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleThemeAction(value, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(EventData event) {
    final isUpcoming = event.startDate.isAfter(DateTime.now());
    final isOngoing = event.isActive && 
        DateTime.now().isAfter(event.startDate) &&
        DateTime.now().isBefore(event.endDate);
    
    Color statusColor = Colors.grey;
    String statusText = 'Terminé';
    
    if (isOngoing) {
      statusColor = Colors.green;
      statusText = 'En cours';
    } else if (isUpcoming) {
      statusColor = Colors.blue;
      statusText = 'À venir';
    }

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
                Row(
                  children: [
                    Icon(_getEventTypeIcon(event.type), color: Colors.orange, size: 24),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => _editEvent(event),
                  icon: Icon(Icons.edit, color: Colors.white70),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            Text(
              event.description,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 10),
            
            // Event Details
            Row(
              children: [
                Expanded(
                  child: _buildEventDetail('📅', 'Date', _formatDateTime(event.startDate)),
                ),
                Expanded(
                  child: _buildEventDetail('👥', 'Participants', '${event.currentParticipants}/${event.maxParticipants}'),
                ),
              ],
            ),
            SizedBox(height: 10),
            
            // Rewards
            Text(
              'Récompenses:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: event.rewards.entries.map((entry) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_getRewardIcon(entry.key)} ${entry.value}',
                    style: TextStyle(color: Colors.orange, fontSize: 10),
                  ),
                );
              }).toList(),
            ),
            
            if (event.specialRules.isNotEmpty) ...[
              SizedBox(height: 10),
              Text(
                'Règles spéciales:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              ...event.specialRules.take(2).map((rule) => 
                Padding(
                  padding: EdgeInsets.only(left: 8, top: 2),
                  child: Text(
                    '• $rule',
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                )
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetail(String icon, String label, String value) {
    return Row(
      children: [
        Text(icon, style: TextStyle(fontSize: 16)),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white60, fontSize: 10)),
            Text(value, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.tournament:
        return Icons.emoji_events;
      case EventType.seasonal:
        return Icons.celebration;
      case EventType.special:
        return Icons.star;
      case EventType.weekly:
        return Icons.calendar_view_week;
    }
  }

  String _getRewardIcon(String rewardType) {
    switch (rewardType) {
      case 'coins':
        return '🪙';
      case 'xp':
        return '⭐';
      case 'badge':
        return '🏆';
      case 'premium_days':
        return '💎';
      case 'exclusive_emoji':
        return '😍';
      default:
        return '🎁';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showCreateThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateThemeDialog(
        onThemeCreated: (theme) {
          setState(() {
            _themes.add(theme);
          });
        },
      ),
    );
  }

  void _showCreateEventDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateEventDialog(
        onEventCreated: (event) {
          setState(() {
            _events.add(event);
          });
        },
      ),
    );
  }

  void _handleThemeAction(String action, AppThemeData theme) {
    switch (action) {
      case 'activate':
        setState(() {
          // Deactivate all themes
          _themes = _themes.map((t) => t.copyWith(isActive: false)).toList();
          // Activate selected theme
          final index = _themes.indexWhere((t) => t.id == theme.id);
          if (index != -1) {
            _themes[index] = theme.copyWith(isActive: true);
          }
        });
        break;
      case 'edit':
        // Show edit dialog
        break;
      case 'duplicate':
        // Duplicate theme
        break;
    }
  }

  void _editEvent(EventData event) {
    // Show edit event dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modification de l\'événement ${event.name}')),
    );
  }
}

// Theme Data Class
class AppThemeData {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final bool isActive;
  final DateTimeRange dateRange;
  final List<String> customEmojis;
  final List<String> specialEffects;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.isActive,
    required this.dateRange,
    required this.customEmojis,
    required this.specialEffects,
  });

  AppThemeData copyWith({
    String? id,
    String? name,
    String? description,
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    bool? isActive,
    DateTimeRange? dateRange,
    List<String>? customEmojis,
    List<String>? specialEffects,
  }) {
    return AppThemeData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isActive: isActive ?? this.isActive,
      dateRange: dateRange ?? this.dateRange,
      customEmojis: customEmojis ?? this.customEmojis,
      specialEffects: specialEffects ?? this.specialEffects,
    );
  }
}

// Event Data Class
enum EventType { tournament, seasonal, special, weekly }

class EventData {
  final String id;
  final String name;
  final String description;
  final EventType type;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int maxParticipants;
  final int currentParticipants;
  final Map<String, dynamic> rewards;
  final Map<String, dynamic> requirements;
  final List<String> affectedBars;
  final List<String> specialRules;

  const EventData({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.rewards,
    required this.requirements,
    required this.affectedBars,
    required this.specialRules,
  });
}

// Create Theme Dialog
class _CreateThemeDialog extends StatefulWidget {
  final Function(AppThemeData) onThemeCreated;

  const _CreateThemeDialog({required this.onThemeCreated});

  @override
  State<_CreateThemeDialog> createState() => _CreateThemeDialogState();
}

class _CreateThemeDialogState extends State<_CreateThemeDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Color _primaryColor = Colors.purple;
  Color _secondaryColor = Colors.pink;
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xFF16213E),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎨 Créer un Nouveau Thème',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Form fields for theme creation
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nom du thème',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            
            Spacer(),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Annuler'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Create theme logic
                    Navigator.of(context).pop();
                  },
                  child: Text('Créer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Create Event Dialog
class _CreateEventDialog extends StatefulWidget {
  final Function(EventData) onEventCreated;

  const _CreateEventDialog({required this.onEventCreated});

  @override
  State<_CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<_CreateEventDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  EventType _selectedType = EventType.special;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(hours: 2));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xFF16213E),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📅 Créer un Nouvel Événement',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Form fields for event creation
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nom de l\'événement',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            
            Spacer(),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Annuler'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Create event logic
                    Navigator.of(context).pop();
                  },
                  child: Text('Créer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}