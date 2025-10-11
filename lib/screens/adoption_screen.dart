import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/pet.dart';

class AdoptionScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;
  
  const AdoptionScreen({
    super.key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  });

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> with TickerProviderStateMixin {
  List<Pet> adoptedPets = [];
  List<Pet> availablePets = [];
  Pet? selectedPet;
  bool isLoading = true;
  late TabController _tabController;
  Timer? _updateTimer;

  // Animation controllers
  late AnimationController _bounceController;
  late AnimationController _glowController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Animations
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _loadData();
    _startUpdateTimer();
    
    // Démarrer les animations
    _bounceController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _updateTimer?.cancel();
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updatePetsState();
    });
  }

  void _updatePetsState() {
    setState(() {
      for (var pet in adoptedPets) {
        pet.updateState();
      }
    });
  }

  void _loadData() {
    // Simuler le chargement des données
    Timer(const Duration(seconds: 1), () {
      setState(() {
        // Générer des animaux disponibles à l'adoption
        availablePets = List.generate(6, (index) => Pet.generateRandomPet());
        isLoading = false;
      });
    });
  }

  void _adoptPet(Pet pet) {
    if (widget.currentCoins >= pet.adoptionCost) {
      setState(() {
        // Déduire les pièces
        widget.onCoinsUpdated(-pet.adoptionCost);
        
        // Ajouter à la liste des adoptés
        adoptedPets.add(pet);
        
        // Retirer de la liste disponible
        availablePets.remove(pet);
        
        // Générer un nouvel animal disponible
        availablePets.add(Pet.generateRandomPet());
      });

      // Changer vers l'onglet "Mes Animaux"
      _tabController.animateTo(0);

      // Animation de succès
      _showSuccessMessage('🎉 Félicitations ! Vous avez adopté ${pet.name} !');
    } else {
      _showErrorMessage('💰 Pas assez de pièces ! Il vous faut ${pet.adoptionCost} pièces.');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('💝 Adoption', style: TextStyle(color: Colors.white)),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.pink,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏠'),
                  const SizedBox(width: 8),
                  Text('Mes Animaux (${adoptedPets.length})'),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🛒'),
                  SizedBox(width: 8),
                  Text('Adopter'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.pink),
                  SizedBox(height: 20),
                  Text(
                    'Chargement des animaux...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMyPetsTab(),
                _buildAdoptionTab(),
              ],
            ),
    );
  }

  Widget _buildMyPetsTab() {
    if (adoptedPets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: const Text('🏠', style: TextStyle(fontSize: 80)),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun animal adopté',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Visitez l\'onglet \"Adopter\" pour accueillir votre premier compagnon !',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                '🛒 Adopter maintenant',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: adoptedPets.length,
      itemBuilder: (context, index) {
        final pet = adoptedPets[index];
        return _buildPetCard(pet, isOwned: true);
      },
    );
  }

  Widget _buildAdoptionTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1e1e1e),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.pink.withOpacity(0.3)),
          ),
          child: const Column(
            children: [
              Text(
                '🌟 Centre d\'adoption JeuTaime',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Adoptez un compagnon virtuel et créez un lien unique ! Chaque animal a sa personnalité et ses besoins.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: availablePets.length,
            itemBuilder: (context, index) {
              final pet = availablePets[index];
              return _buildPetCard(pet, isOwned: false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPetCard(Pet pet, {required bool isOwned}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOwned ? Colors.green.withOpacity(0.5) : Colors.pink.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOwned ? Colors.green : Colors.pink).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar de l'animal
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(int.parse(pet.color.replaceFirst('#', '0xFF'))).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      pet.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Informations de base
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            pet.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pet.moodEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.typeName,
                        style: TextStyle(
                          color: Colors.pink.shade300,
                          fontSize: 16,
                        ),
                      ),
                      if (isOwned) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Niveau ${pet.level}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Prix ou statut
                if (!isOwned) ...[
                  Column(
                    children: [
                      Container(
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
                              '${pet.adoptionCost}',
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
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✓ Adopté',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Barres de stats pour les animaux adoptés
            if (isOwned) ...[
              _buildStatBar('💖 Bonheur', pet.happiness, Colors.pink),
              const SizedBox(height: 8),
              _buildStatBar('🍽️ Satiété', 100 - pet.hunger, Colors.orange),
              const SizedBox(height: 8),
              _buildStatBar('⚡ Énergie', pet.energy, Colors.blue),
              const SizedBox(height: 8),
              _buildStatBar('📈 Niveau ${pet.level}', (pet.levelProgress * 100).toInt(), Colors.amber),
              const SizedBox(height: 16),
            ],
            
            // Description de l'humeur
            Text(
              pet.moodDescription,
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Boutons d'action
            Row(
              children: [
                if (isOwned) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _openPetCareScreen(pet),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        '🎮 S\'occuper',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.currentCoins >= pet.adoptionCost
                          ? () => _adoptPet(pet)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: Text(
                        widget.currentCoins >= pet.adoptionCost
                            ? '💝 Adopter'
                            : '💰 Pas assez de pièces',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
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
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              '$value%',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 100.0,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openPetCareScreen(Pet pet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetCareScreen(
          pet: pet,
          onCoinsUpdated: widget.onCoinsUpdated,
          currentCoins: widget.currentCoins,
          onPetUpdated: (updatedPet) {
            setState(() {
              final index = adoptedPets.indexWhere((p) => p.id == updatedPet.id);
              if (index != -1) {
                adoptedPets[index] = updatedPet;
              }
            });
          },
        ),
      ),
    );
  }
}

// Écran de soins pour un animal spécifique
class PetCareScreen extends StatefulWidget {
  final Pet pet;
  final Function(int) onCoinsUpdated;
  final int currentCoins;
  final Function(Pet) onPetUpdated;

  const PetCareScreen({
    super.key,
    required this.pet,
    required this.onCoinsUpdated,
    required this.currentCoins,
    required this.onPetUpdated,
  });

  @override
  State<PetCareScreen> createState() => _PetCareScreenState();
}

class _PetCareScreenState extends State<PetCareScreen> with TickerProviderStateMixin {
  late Pet pet;
  late AnimationController _petAnimationController;
  late AnimationController _heartController;
  late Animation<double> _petBounce;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    pet = widget.pet;
    
    _petAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _petBounce = Tween<double>(
      begin: 0.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _petAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _heartScale = Tween<double>(
      begin: 0.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticOut,
    ));

    _petAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _petAnimationController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _performAction(String action, int cost, String foodOrGameType) {
    if (widget.currentCoins >= cost) {
      Map<String, dynamic> result;
      
      if (action == 'feed') {
        result = pet.feed(foodOrGameType);
      } else {
        result = pet.play(foodOrGameType);
      }
      
      if (result['success']) {
        setState(() {
          widget.onCoinsUpdated(-cost);
          widget.onPetUpdated(pet);
        });
        
        // Animation de bonheur
        _heartController.forward().then((_) {
          _heartController.reverse();
        });
        
        // Message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Message de montée de niveau
        if (result['leveledUp']) {
          Future.delayed(const Duration(seconds: 1), () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 ${pet.name} est passé au niveau ${result['newLevel']} !'),
                backgroundColor: Colors.amber,
                duration: const Duration(seconds: 3),
              ),
            );
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💰 Pas assez de pièces !'),
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
        title: Text(
          '${pet.emoji} ${pet.name}',
          style: const TextStyle(color: Colors.white),
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar de l'animal avec animation
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _petBounce,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_petBounce.value),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Color(int.parse(pet.color.replaceFirst('#', '0xFF'))).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(75),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Color(int.parse(pet.color.replaceFirst('#', '0xFF'))).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            pet.emoji,
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Coeurs d'animation
                AnimatedBuilder(
                  animation: _heartScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _heartScale.value,
                      child: const Text(
                        '💖',
                        style: TextStyle(fontSize: 30),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Informations de l'animal
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        pet.moodEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${pet.typeName} • Niveau ${pet.level}',
                    style: TextStyle(
                      color: Colors.pink.shade300,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pet.moodDescription,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Barres de statistiques
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 Statistiques',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatBar('💖 Bonheur', pet.happiness, Colors.pink),
                  const SizedBox(height: 12),
                  _buildStatBar('🍽️ Satiété', 100 - pet.hunger, Colors.orange),
                  const SizedBox(height: 12),
                  _buildStatBar('⚡ Énergie', pet.energy, Colors.blue),
                  const SizedBox(height: 12),
                  _buildStatBar('📈 Niveau ${pet.level}', (pet.levelProgress * 100).toInt(), Colors.amber),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Actions de soin
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎮 Actions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Section Nourriture
                  const Text(
                    '🍽️ Nourrir',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          '🥙 Basique',
                          '10 🪙',
                          Colors.brown,
                          () => _performAction('feed', 10, 'basic_food'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          '🥩 Premium',
                          '25 🪙',
                          Colors.red,
                          () => _performAction('feed', 25, 'premium_food'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          '🍪 Friandise',
                          '15 🪙',
                          Colors.orange,
                          () => _performAction('feed', 15, 'treat'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Section Jeux
                  const Text(
                    '🎾 Jouer',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          '🎾 Rapporter',
                          '20 🪙',
                          Colors.green,
                          () => _performAction('play', 20, 'fetch'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          '🤗 Câlin',
                          '5 🪙',
                          Colors.pink,
                          () => _performAction('play', 5, 'cuddle'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          '🎯 Entraîner',
                          '30 🪙',
                          Colors.purple,
                          () => _performAction('play', 30, 'training'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Repos
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(
                      '😴 Laisser se reposer (Gratuit)',
                      '',
                      Colors.blue,
                      () {
                        final result = pet.rest();
                        setState(() {
                          widget.onPetUpdated(pet);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message']),
                            backgroundColor: result['success'] ? Colors.blue : Colors.orange,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Statistiques détaillées
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📈 Historique',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('🍽️', 'Repas', pet.totalFoodEaten.toString()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('🎮', 'Jeux', pet.totalGamesPlayed.toString()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('📅', 'Âge', '${pet.age} jours'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            color: Colors.grey[800],
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

  Widget _buildActionButton(String title, String price, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          if (price.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}