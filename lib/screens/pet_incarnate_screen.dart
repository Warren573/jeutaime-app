import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/pet_social.dart';

class PetIncarnateScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;
  
  const PetIncarnateScreen({
    super.key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  });

  @override
  State<PetIncarnateScreen> createState() => _PetIncarnateScreenState();
}

class _PetIncarnateScreenState extends State<PetIncarnateScreen> 
    with TickerProviderStateMixin {
  
  Pet? myIncarnatedPet;
  List<Pet> nearbyPets = [];
  List<PetInteraction> pendingInteractions = [];
  bool hasCreatedPet = false;
  
  late AnimationController _avatarController;
  late AnimationController _needsController;
  late Animation<double> _avatarBounce;
  late Animation<double> _needsPulse;
  
  Timer? _updateTimer;
  Timer? _socialTimer;

  @override
  void initState() {
    super.initState();
    
    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _needsController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _avatarBounce = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _avatarController,
      curve: Curves.easeInOut,
    ));
    
    _needsPulse = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _needsController,
      curve: Curves.easeInOut,
    ));

    _avatarController.repeat(reverse: true);
    _needsController.repeat(reverse: true);
    
    _loadData();
    _startUpdateTimer();
    _startSocialTimer();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _needsController.dispose();
    _updateTimer?.cancel();
    _socialTimer?.cancel();
    super.dispose();
  }

  void _loadData() {
    // Simuler le chargement
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _generateNearbyPets();
      }
    });
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (myIncarnatedPet != null) {
        setState(() {
          myIncarnatedPet!.updateState();
        });
      }
    });
  }

  void _startSocialTimer() {
    _socialTimer = Timer.periodic(const Duration(seconds: 45), (timer) {
      _generateRandomInteraction();
      _generateNearbyPets();
    });
  }

  void _generateNearbyPets() {
    setState(() {
      // Générer des adopteurs et leurs animaux nearby
      nearbyPets = List.generate(4, (index) {
        final types = PetType.values;
        final names = ['Max', 'Luna', 'Charlie', 'Bella', 'Rocky', 'Mimi'];
        
        return Pet.generateAnimal(
          'adopter_${index}', 
          UserMode.adopter,
          types[Random().nextInt(types.length)],
          names[Random().nextInt(names.length)],
        );
      });
      
      // Ajouter quelques animaux incarnés
      nearbyPets.addAll(List.generate(2, (index) {
        final types = PetType.values;
        final names = ['Shadow', 'Whiskers', 'Fluffy', 'Buddy'];
        
        return Pet.generateAnimal(
          'incarnated_${index}',
          UserMode.incarnate,
          types[Random().nextInt(types.length)],
          names[Random().nextInt(names.length)],
        );
      }));
    });
  }

  void _generateRandomInteraction() {
    if (myIncarnatedPet == null || nearbyPets.isEmpty) return;
    
    final random = Random();
    final fromPet = nearbyPets[random.nextInt(nearbyPets.length)];
    
    // Les adopteurs peuvent proposer des interactions
    if (fromPet.ownerMode == UserMode.adopter) {
      final interactions = [
        InteractionType.offerTreat,
        InteractionType.requestPlay,
        InteractionType.giveCuddle,
        InteractionType.offerToy,
      ];
      
      final interaction = PetInteraction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fromUserId: fromPet.ownerId,
        toUserId: myIncarnatedPet!.ownerId,
        type: interactions[random.nextInt(interactions.length)],
        timestamp: DateTime.now(),
        data: {
          'fromPetName': fromPet.name,
          'fromPetEmoji': fromPet.emoji,
        },
      );
      
      setState(() {
        pendingInteractions.add(interaction);
      });
    }
  }

  void _createIncarnatedPet() {
    showDialog(
      context: context,
      builder: (context) => _PetCreationDialog(
        onPetCreated: (pet) {
          setState(() {
            myIncarnatedPet = pet;
            hasCreatedPet = true;
          });
        },
      ),
    );
  }

  void _respondToInteraction(PetInteraction interaction, bool accept) {
    if (myIncarnatedPet == null) return;
    
    setState(() {
      pendingInteractions.remove(interaction);
      
      if (accept) {
        final result = myIncarnatedPet!.reactToInteraction(interaction);
        
        if (result['accepted']) {
          // Mettre à jour les stats
          myIncarnatedPet!.totalInteractions++;
          myIncarnatedPet!.lastSocialInteraction = DateTime.now();
          
          // Gagner des pièces sociales
          widget.onCoinsUpdated(5);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${myIncarnatedPet!.name} a refusé l\'interaction.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  void _initiateInteraction(Pet targetPet, InteractionType type) {
    if (myIncarnatedPet == null) return;
    
    final result = myIncarnatedPet!.initiateInteraction(type, targetPet);
    
    if (result['success']) {
      // Coûter de l'énergie pour initier une interaction
      if (myIncarnatedPet!.energy >= 10) {
        setState(() {
          myIncarnatedPet!.energy -= 10;
          myIncarnatedPet!.totalInteractions++;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous êtes trop fatigué pour cette interaction !'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('🎭 Mon Animal Incarné', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${widget.currentCoins}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: myIncarnatedPet == null 
          ? _buildWelcomeScreen()
          : _buildMainScreen(),
      
      // Notifications flottantes pour les interactions
      floatingActionButton: pendingInteractions.isNotEmpty 
          ? _buildInteractionNotification()
          : null,
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎭', style: TextStyle(fontSize: 120)),
            const SizedBox(height: 30),
            const Text(
              'Incarnez votre Animal !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Devenez l\'animal de votre choix et vivez une expérience sociale unique ! Interagissez avec d\'autres joueurs, exprimez vos besoins et créez des liens.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _createIncarnatedPet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                '✨ Créer mon Animal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar et état de l'animal
          _buildPetStatus(),
          
          const SizedBox(height: 30),
          
          // Actions d'auto-soin
          _buildSelfCareActions(),
          
          const SizedBox(height: 30),
          
          // Animaux à proximité
          _buildNearbyPets(),
        ],
      ),
    );
  }

  Widget _buildPetStatus() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade800],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar animé
              AnimatedBuilder(
                animation: _avatarBounce,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_avatarBounce.value),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          myIncarnatedPet!.emoji,
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 20),
              
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      myIncarnatedPet!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${myIncarnatedPet!.type.toString().split('.').last} • Niveau ${myIncarnatedPet!.level}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _getCurrentMoodText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getMoodEmoji(),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 25),
          
          // Barres de stats
          _buildStatBar('💖 Bonheur', myIncarnatedPet!.happiness, Colors.pink),
          const SizedBox(height: 12),
          _buildStatBar('🍽️ Satiété', 100 - myIncarnatedPet!.hunger, Colors.orange),
          const SizedBox(height: 12),
          _buildStatBar('⚡ Énergie', myIncarnatedPet!.energy, Colors.blue),
          const SizedBox(height: 12),
          _buildStatBar('🤝 Social', myIncarnatedPet!.social, Colors.green),
        ],
      ),
    );
  }

  Widget _buildSelfCareActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🛀 Auto-soins',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  '😴 Se reposer',
                  'Récupérer de l\'énergie',
                  Colors.blue,
                  myIncarnatedPet!.energy < 90,
                  () {
                    setState(() {
                      myIncarnatedPet!.energy = 
                          (myIncarnatedPet!.energy + 30).clamp(0, 100).toInt();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vous vous sentez plus reposé !'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  '🧘 Méditer',
                  'Améliorer le moral',
                  Colors.purple,
                  myIncarnatedPet!.happiness < 80,
                  () {
                    if (widget.currentCoins >= 10) {
                      setState(() {
                        myIncarnatedPet!.happiness = 
                            (myIncarnatedPet!.happiness + 20).clamp(0, 100).toInt();
                      });
                      widget.onCoinsUpdated(-10);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Moment de paix et de sérénité...'),
                          backgroundColor: Colors.purple,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pas assez de pièces !'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🌍 Animaux à proximité',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (nearbyPets.isEmpty)
          const Text(
            'Aucun animal à proximité pour le moment...',
            style: TextStyle(color: Colors.grey),
          )
        else
          ...nearbyPets.map((pet) => _buildNearbyPetCard(pet)),
      ],
    );
  }

  Widget _buildNearbyPetCard(Pet pet) {
    final isAdopterPet = pet.ownerMode == UserMode.adopter;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isAdopterPet 
              ? Colors.green.withOpacity(0.5)
              : Colors.purple.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(pet.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${pet.type.toString().split('.').last} • ${pet.roleDescription}',
                      style: TextStyle(
                        color: isAdopterPet ? Colors.green : Colors.purple,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAdopterPet 
                      ? Colors.green.withOpacity(0.2)
                      : Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isAdopterPet ? '🏠' : '🎭',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Actions possibles
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildInteractionButtons(pet),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInteractionButtons(Pet targetPet) {
    final actions = <Widget>[];
    
    if (targetPet.ownerMode == UserMode.adopter) {
      // Interactions avec un animal de compagnie
      actions.addAll([
        _buildSmallActionButton(
          '🍖 Demander nourriture',
          Colors.orange,
          () => _initiateInteraction(targetPet, InteractionType.askForFood),
        ),
        _buildSmallActionButton(
          '🎾 Proposer jeu',
          Colors.green,
          () => _initiateInteraction(targetPet, InteractionType.playTogether),
        ),
        _buildSmallActionButton(
          '💕 Montrer affection',
          Colors.pink,
          () => _initiateInteraction(targetPet, InteractionType.showAffection),
        ),
      ]);
    } else {
      // Interactions avec un animal incarné
      actions.addAll([
        _buildSmallActionButton(
          '🎾 Jouer ensemble',
          Colors.blue,
          () => _initiateInteraction(targetPet, InteractionType.playTogether),
        ),
        _buildSmallActionButton(
          '🤝 Saluer',
          Colors.green,
          () => _initiateInteraction(targetPet, InteractionType.friendly),
        ),
        _buildSmallActionButton(
          '✨ Toilettage',
          Colors.purple,
          () => _initiateInteraction(targetPet, InteractionType.socialGroom),
        ),
      ]);
    }
    
    return actions;
  }

  Widget _buildInteractionNotification() {
    final interaction = pendingInteractions.first;
    
    return AnimatedBuilder(
      animation: _needsPulse,
      builder: (context, child) {
        return Transform.scale(
          scale: _needsPulse.value,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      interaction.data['fromPetEmoji'] ?? '🐾',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${interaction.data['fromPetName']} ${_getInteractionMessage(interaction.type)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _respondToInteraction(interaction, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          '✅ Accepter',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _respondToInteraction(interaction, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          '❌ Refuser',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              '$value%',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 100.0,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    Color color,
    bool enabled,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(enabled ? 1.0 : 0.3),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallActionButton(String title, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: myIncarnatedPet!.energy >= 10 ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(myIncarnatedPet!.energy >= 10 ? 1.0 : 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
        ),
      ),
    );
  }

  String _getCurrentMoodText() {
    switch (myIncarnatedPet!.mood) {
      case PetMood.happy:
        return 'Je suis très heureux !';
      case PetMood.playful:
        return 'J\'ai envie de jouer !';
      case PetMood.content:
        return 'Je me sens bien.';
      case PetMood.neutral:
        return 'Ça va.';
      case PetMood.sad:
        return 'Je suis un peu triste...';
      case PetMood.angry:
        return 'Je suis frustré !';
      case PetMood.sleeping:
        return 'Je suis fatigué...';
      case PetMood.hungry:
        return 'J\'ai très faim !';
      case PetMood.lonely:
        return 'Je me sens seul...';
      case PetMood.excited:
        return 'Je suis excité !';
    }
  }

  String _getMoodEmoji() {
    switch (myIncarnatedPet!.mood) {
      case PetMood.happy:
        return '😄';
      case PetMood.playful:
        return '🤩';
      case PetMood.content:
        return '😊';
      case PetMood.neutral:
        return '😐';
      case PetMood.sad:
        return '😢';
      case PetMood.angry:
        return '😠';
      case PetMood.sleeping:
        return '😴';
      case PetMood.hungry:
        return '🤤';
      case PetMood.lonely:
        return '🥺';
      case PetMood.excited:
        return '🤗';
    }
  }

  String _getInteractionMessage(InteractionType type) {
    switch (type) {
      case InteractionType.offerTreat:
        return 'vous offre une friandise !';
      case InteractionType.requestPlay:
        return 'veut jouer avec vous !';
      case InteractionType.giveCuddle:
        return 'veut vous faire un câlin !';
      case InteractionType.offerToy:
        return 'vous offre un jouet !';
      default:
        return 'veut interagir avec vous !';
    }
  }
}

class _PetCreationDialog extends StatefulWidget {
  final Function(Pet) onPetCreated;
  
  const _PetCreationDialog({required this.onPetCreated});

  @override
  State<_PetCreationDialog> createState() => _PetCreationDialogState();
}

class _PetCreationDialogState extends State<_PetCreationDialog> {
  String petName = '';
  PetType selectedType = PetType.cat;
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1e1e1e),
      title: const Text(
        '✨ Créer mon Animal Incarné',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nom de votre animal',
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.purple),
              ),
            ),
            onChanged: (value) => petName = value,
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            'Choisissez votre type :',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PetType.values.map((type) {
              final pet = Pet.generateAnimal('temp', UserMode.incarnate, type, 'Temp');
              final isSelected = selectedType == type;
              
              return GestureDetector(
                onTap: () => setState(() => selectedType = type),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.purple : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Colors.purple : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(pet.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(
                        pet.type.toString().split('.').last,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: petName.trim().isNotEmpty ? () {
            final pet = Pet.generateAnimal(
              'user_${DateTime.now().millisecondsSinceEpoch}',
              UserMode.incarnate,
              selectedType,
              petName.trim(),
            );
            widget.onPetCreated(pet);
            Navigator.pop(context);
          } : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: const Text('Créer', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}