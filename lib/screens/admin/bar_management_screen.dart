import 'package:flutter/material.dart';
import '../../models/bar.dart';
import '../../services/firebase_service.dart';

class BarManagementScreen extends StatefulWidget {
  const BarManagementScreen({super.key});

  @override
  State<BarManagementScreen> createState() => _BarManagementScreenState();
}

class _BarManagementScreenState extends State<BarManagementScreen> {
  List<Bar> _bars = [];
  bool _isLoading = false;

  // Available games in the app
  final List<Map<String, dynamic>> _availableGames = [
    {
      'id': 'memory_game',
      'name': 'Memory Game',
      'icon': '🧠',
      'description': 'Jeu de mémoire avec cartes romantiques',
      'minPlayers': 1,
      'maxPlayers': 2,
      'category': 'puzzle',
    },
    {
      'id': 'snake_game',
      'name': 'Snake Game',
      'icon': '🐍',
      'description': 'Snake classique avec bonus romantiques',
      'minPlayers': 1,
      'maxPlayers': 1,
      'category': 'arcade',
    },
    {
      'id': 'quiz_couple',
      'name': 'Quiz Couple',
      'icon': '💕',
      'description': 'Quiz éducatif sur les relations',
      'minPlayers': 1,
      'maxPlayers': 4,
      'category': 'educational',
    },
    {
      'id': 'breakout',
      'name': 'Casse-Briques',
      'icon': '🧱',
      'description': 'Casse-briques avec thème romantique',
      'minPlayers': 1,
      'maxPlayers': 1,
      'category': 'arcade',
    },
    {
      'id': 'tic_tac_toe',
      'name': 'Tic-Tac-Toe',
      'icon': '⚡',
      'description': 'Morpion stratégique entre amoureux',
      'minPlayers': 2,
      'maxPlayers': 2,
      'category': 'strategy',
    },
    {
      'id': 'card_game',
      'name': 'Jeu de Cartes',
      'icon': '🃏',
      'description': 'Jeu de cartes romantique corrigé',
      'minPlayers': 1,
      'maxPlayers': 1,
      'category': 'card',
    },
    {
      'id': 'continue_histoire',
      'name': 'Continue l\'Histoire',
      'icon': '📖',
      'description': 'Storytelling collaboratif',
      'minPlayers': 2,
      'maxPlayers': 8,
      'category': 'social',
    },
    {
      'id': 'precision_master',
      'name': 'Precision Master',
      'icon': '🎯',
      'description': 'Jeu de précision et réflexes',
      'minPlayers': 1,
      'maxPlayers': 1,
      'category': 'skill',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadBars();
  }

  Future<void> _loadBars() async {
    setState(() => _isLoading = true);
    
    try {
      // Load bars from Firebase (mocked for now)
      await Future.delayed(Duration(milliseconds: 500));
      
      setState(() {
        _bars = [
          Bar(
            barId: 'romantic_001',
            name: 'Bar des Cœurs',
            type: BarType.romantic,
            activeUsers: 6,
            maxParticipants: 8,
            isActive: true,
            ambiance: 'Tamisée et romantique avec bougies',
            settings: {
              'allowedGames': ['memory_game', 'quiz_couple', 'continue_histoire'],
              'musicVolume': 0.7,
              'lightingMode': 'romantic',
            },
          ),
          Bar(
            barId: 'humor_001',
            name: 'Bar du Rire',
            type: BarType.humorous,
            activeUsers: 4,
            maxParticipants: 12,
            isActive: true,
            ambiance: 'Festive et colorée',
            settings: {
              'allowedGames': ['snake_game', 'breakout', 'tic_tac_toe', 'continue_histoire'],
              'musicVolume': 0.9,
              'lightingMode': 'party',
            },
          ),
          Bar(
            barId: 'pirate_001',
            name: 'Taverne des Pirates',
            type: BarType.pirate,
            activeUsers: 3,
            maxParticipants: 10,
            isActive: true,
            ambiance: 'Aventure maritime',
            settings: {
              'allowedGames': ['card_game', 'precision_master', 'continue_histoire'],
              'musicVolume': 0.8,
              'lightingMode': 'adventure',
            },
          ),
        ];
      });
    } catch (e) {
      _showError('Erreur lors du chargement des bars: $e');
    }
    
    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showCreateBarDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateBarDialog(
        availableGames: _availableGames,
        onBarCreated: (bar) {
          setState(() {
            _bars.add(bar);
          });
        },
      ),
    );
  }

  void _editBar(Bar bar) {
    showDialog(
      context: context,
      builder: (context) => _EditBarDialog(
        bar: bar,
        availableGames: _availableGames,
        onBarUpdated: (updatedBar) {
          setState(() {
            final index = _bars.indexWhere((b) => b.barId == updatedBar.barId);
            if (index != -1) {
              _bars[index] = updatedBar;
            }
          });
        },
      ),
    );
  }

  void _toggleBarStatus(Bar bar) {
    setState(() {
      final index = _bars.indexWhere((b) => b.barId == bar.barId);
      if (index != -1) {
        _bars[index] = Bar(
          barId: bar.barId,
          name: bar.name,
          type: bar.type,
          activeUsers: bar.activeUsers,
          maxParticipants: bar.maxParticipants,
          isActive: !bar.isActive,
          ambiance: bar.ambiance,
          settings: bar.settings,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          '🍺 Gestion des Bars',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF16213E),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showCreateBarDialog,
            icon: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Overview
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Bars',
                          _bars.length.toString(),
                          Colors.orange,
                          Icons.local_bar,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Bars Actifs',
                          _bars.where((b) => b.isActive).length.toString(),
                          Colors.green,
                          Icons.circle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  // Bars Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: _bars.length,
                    itemBuilder: (context, index) {
                      return _buildBarCard(_bars[index]);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 8),
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

  Widget _buildBarCard(Bar bar) {
    final allowedGames = (bar.settings?['allowedGames'] as List<dynamic>?) ?? [];
    
    return Card(
      color: Color(0xFF16213E),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Bar Icon and Status
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(bar.type.displayName.split(' ')[0], style: TextStyle(fontSize: 30)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bar.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    bar.isActive ? 'Actif' : 'Inactif',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
            
            SizedBox(width: 16),
            
            // Bar Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bar.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${bar.activeUsers}/${bar.maxParticipants}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    bar.type.description,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ambiance: ${bar.ambiance}',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  
                  // Games Icons
                  Row(
                    children: [
                      Text(
                        'Jeux: ',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                      ...allowedGames.map((gameId) {
                        final game = _availableGames.firstWhere(
                          (g) => g['id'] == gameId,
                          orElse: () => {'icon': '❓'},
                        );
                        return Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Text(game['icon'], style: TextStyle(fontSize: 16)),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              children: [
                IconButton(
                  onPressed: () => _editBar(bar),
                  icon: Icon(Icons.edit, color: Colors.white70),
                ),
                IconButton(
                  onPressed: () => _toggleBarStatus(bar),
                  icon: Icon(
                    bar.isActive ? Icons.pause : Icons.play_arrow,
                    color: bar.isActive ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateBarDialog extends StatefulWidget {
  final List<Map<String, dynamic>> availableGames;
  final Function(Bar) onBarCreated;

  const _CreateBarDialog({
    required this.availableGames,
    required this.onBarCreated,
  });

  @override
  State<_CreateBarDialog> createState() => _CreateBarDialogState();
}

class _CreateBarDialogState extends State<_CreateBarDialog> {
  final _nameController = TextEditingController();
  final _ambianceController = TextEditingController();
  BarType _selectedType = BarType.romantic;
  int _maxParticipants = 8;
  bool _isPremiumOnly = false;
  List<String> _selectedGames = [];

  @override
  void dispose() {
    _nameController.dispose();
    _ambianceController.dispose();
    super.dispose();
  }

  void _createBar() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le nom du bar est requis')),
      );
      return;
    }

    if (_selectedGames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sélectionnez au moins un jeu')),
      );
      return;
    }

    final newBar = Bar(
      barId: 'bar_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      type: _selectedType,
      maxParticipants: _maxParticipants,
      isPremiumOnly: _isPremiumOnly,
      ambiance: _ambianceController.text.trim(),
      settings: {
        'allowedGames': _selectedGames,
        'musicVolume': 0.7,
        'lightingMode': _selectedType.name,
      },
    );

    widget.onBarCreated(newBar);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xFF16213E),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🍺 Créer un Nouveau Bar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bar Name
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nom du Bar',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Bar Type
                    Text('Type de Bar', style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<BarType>(
                      value: _selectedType,
                      dropdownColor: Color(0xFF16213E),
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: BarType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedType = value!);
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Max Participants
                    Text('Participants Maximum', style: TextStyle(color: Colors.white, fontSize: 16)),
                    Slider(
                      value: _maxParticipants.toDouble(),
                      min: 4,
                      max: 20,
                      divisions: 16,
                      activeColor: Colors.orange,
                      label: _maxParticipants.toString(),
                      onChanged: (value) {
                        setState(() => _maxParticipants = value.round());
                      },
                    ),
                    
                    // Premium Only
                    CheckboxListTile(
                      title: Text('Bar Premium Uniquement', style: TextStyle(color: Colors.white)),
                      value: _isPremiumOnly,
                      activeColor: Colors.orange,
                      onChanged: (value) {
                        setState(() => _isPremiumOnly = value ?? false);
                      },
                    ),
                    
                    // Ambiance
                    TextField(
                      controller: _ambianceController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Description de l\'Ambiance',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Games Selection
                    Text(
                      'Jeux Disponibles dans ce Bar',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    
                    ...widget.availableGames.map((game) {
                      final isSelected = _selectedGames.contains(game['id']);
                      return CheckboxListTile(
                        title: Row(
                          children: [
                            Text(game['icon'], style: TextStyle(fontSize: 20)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    game['name'],
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    game['description'],
                                    style: TextStyle(color: Colors.white60, fontSize: 12),
                                  ),
                                  Text(
                                    '${game['minPlayers']}-${game['maxPlayers']} joueurs',
                                    style: TextStyle(color: Colors.white70, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        value: isSelected,
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedGames.add(game['id']);
                            } else {
                              _selectedGames.remove(game['id']);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Annuler', style: TextStyle(color: Colors.white70)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _createBar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text('Créer le Bar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditBarDialog extends StatefulWidget {
  final Bar bar;
  final List<Map<String, dynamic>> availableGames;
  final Function(Bar) onBarUpdated;

  const _EditBarDialog({
    required this.bar,
    required this.availableGames,
    required this.onBarUpdated,
  });

  @override
  State<_EditBarDialog> createState() => _EditBarDialogState();
}

class _EditBarDialogState extends State<_EditBarDialog> {
  late TextEditingController _nameController;
  late TextEditingController _ambianceController;
  late BarType _selectedType;
  late int _maxParticipants;
  late bool _isPremiumOnly;
  late List<String> _selectedGames;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bar.name);
    _ambianceController = TextEditingController(text: widget.bar.ambiance);
    _selectedType = widget.bar.type;
    _maxParticipants = widget.bar.maxParticipants;
    _isPremiumOnly = widget.bar.isPremiumOnly;
    _selectedGames = List<String>.from(
      (widget.bar.settings?['allowedGames'] as List<dynamic>?) ?? []
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ambianceController.dispose();
    super.dispose();
  }

  void _updateBar() {
    final updatedBar = Bar(
      barId: widget.bar.barId,
      name: _nameController.text.trim(),
      type: _selectedType,
      activeUsers: widget.bar.activeUsers,
      maxParticipants: _maxParticipants,
      isPremiumOnly: _isPremiumOnly,
      isActive: widget.bar.isActive,
      ambiance: _ambianceController.text.trim(),
      settings: {
        ...(widget.bar.settings ?? {}),
        'allowedGames': _selectedGames,
      },
    );

    widget.onBarUpdated(updatedBar);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Similar to _CreateBarDialog but with pre-filled values
    return Dialog(
      backgroundColor: Color(0xFF16213E),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✏️ Modifier le Bar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Similar form fields as create dialog
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nom du Bar',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    // ... rest of the form fields
                  ],
                ),
              ),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Annuler', style: TextStyle(color: Colors.white70)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _updateBar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text('Sauvegarder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}