import 'package:flutter/material.dart';
import 'dart:math';
import '../models/pet_social.dart';
import 'pet_incarnate_screen.dart';
import 'pet_adopt_screen.dart';

class PetModeSelectionScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;
  
  const PetModeSelectionScreen({
    super.key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  });

  @override
  State<PetModeSelectionScreen> createState() => _PetModeSelectionScreenState();
}

class _PetModeSelectionScreenState extends State<PetModeSelectionScreen> 
    with TickerProviderStateMixin {
  
  UserMode? selectedMode;
  late AnimationController _incarnateController;
  late AnimationController _adopterController;
  late Animation<double> _incarnateGlow;
  late Animation<double> _adopterGlow;
  
  @override
  void initState() {
    super.initState();
    
    _incarnateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _adopterController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _incarnateGlow = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _incarnateController,
      curve: Curves.easeInOut,
    ));
    
    _adopterGlow = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _adopterController,
      curve: Curves.easeInOut,
    ));

    _incarnateController.repeat(reverse: true);
    _adopterController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _incarnateController.dispose();
    _adopterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('💝 Système d\'Adoption', style: TextStyle(color: Colors.white)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre et description
            const Text(
              '🌟 Choisissez votre expérience',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎭 Deux modes exclusifs',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Vous ne pouvez choisir qu\'un seul mode à la fois. Chaque mode offre une expérience unique avec des interactions différentes entre les joueurs !',
                    style: TextStyle(color: Colors.grey, height: 1.4),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Mode Incarnation
            AnimatedBuilder(
              animation: _incarnateGlow,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(_incarnateGlow.value * 0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: _buildModeCard(
                    mode: UserMode.incarnate,
                    title: '🎭 Incarner un Animal',
                    subtitle: 'DEVENIR l\'animal',
                    description: 'Vous êtes l\'animal ! Interagissez avec d\'autres utilisateurs, demandez de la nourriture, jouez, exprimez vos besoins. Les adopteurs peuvent vous offrir des friandises et jouer avec vous.',
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade600,
                        Colors.purple.shade800,
                        Colors.indigo.shade800,
                      ],
                    ),
                    features: [
                      '🎮 Contrôlez directement votre animal',
                      '🤝 Interagissez avec les adopteurs',
                      '💬 Exprimez vos besoins et émotions',
                      '🎾 Jouez avec d\'autres animaux incarnés',
                      '🏆 Gagnez de l\'expérience sociale',
                    ],
                    examples: [
                      '🍖 "J\'ai faim, quelqu\'un peut me nourrir ?"',
                      '🎾 "Qui veut jouer avec moi ?"',
                      '💕 "Merci pour les câlins !"',
                    ],
                  ),
                );
              },
            ),
            
            // Mode Adoption
            AnimatedBuilder(
              animation: _adopterGlow,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(_adopterGlow.value * 0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: _buildModeCard(
                    mode: UserMode.adopter,
                    title: '🏠 Adopter un Animal',
                    subtitle: 'POSSÉDER un compagnon',
                    description: 'Adoptez et prenez soin d\'un animal virtuel. Nourrissez-le, jouez avec lui, et interagissez avec des animaux incarnés par d\'autres joueurs pour des expériences sociales uniques.',
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade600,
                        Colors.green.shade800,
                        Colors.teal.shade800,
                      ],
                    ),
                    features: [
                      '🐾 Adoptez et soignez votre compagnon',
                      '🍖 Nourrissez et divertissez votre animal',
                      '🤝 Offrez des friandises aux animaux incarnés',
                      '🎪 Organisez des rencontres entre animaux',
                      '📊 Suivez la progression de votre compagnon',
                    ],
                    examples: [
                      '🍪 "Voici une friandise pour toi !"',
                      '🎾 "Mon chien aimerait jouer avec le vôtre"',
                      '🏥 "Comment soigner un animal malade ?"',
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // Interactions possibles
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('✨', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 10),
                      Text(
                        'Interactions Entre Modes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInteractionExample(
                    '🏠 → 🎭',
                    'Adopteur vers Animal incarné',
                    '• Offrir des friandises\n• Proposer des jeux\n• Donner des câlins\n• Offrir des jouets',
                    Colors.green,
                    Colors.purple,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildInteractionExample(
                    '🎭 → 🏠',
                    'Animal incarné vers Adopteur',
                    '• Demander de la nourriture\n• Réclamer de l\'attention\n• Montrer de l\'affection\n• Apporter des "cadeaux"',
                    Colors.purple,
                    Colors.green,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildInteractionExample(
                    '🎭 ↔ 🎭',
                    'Entre Animaux incarnés',
                    '• Jouer ensemble\n• Se toiletter mutuellement\n• Interactions territoriales\n• Comportements sociaux',
                    Colors.purple,
                    Colors.purple,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Bouton de validation
            if (selectedMode != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _confirmSelection(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedMode == UserMode.incarnate 
                        ? Colors.purple 
                        : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    selectedMode == UserMode.incarnate 
                        ? '🎭 INCARNER UN ANIMAL'
                        : '🏠 ADOPTER UN ANIMAL',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required UserMode mode,
    required String title,
    required String subtitle,
    required String description,
    required LinearGradient gradient,
    required List<String> features,
    required List<String> examples,
  }) {
    final isSelected = selectedMode == mode;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32,
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              '✨ Fonctionnalités :',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                feature,
                style: const TextStyle(
                  color: const Color(0xE6FFFFFF),
                  fontSize: 13,
                ),
              ),
            )),
            
            const SizedBox(height: 12),
            
            const Text(
              '💬 Exemples d\'interactions :',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: examples.map((example) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    example,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionExample(
    String direction,
    String title,
    String content,
    Color fromColor,
    Color toColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [fromColor, toColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  direction,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSelection() {
    if (selectedMode == null) return;

    if (selectedMode == UserMode.incarnate) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PetIncarnateScreen(
            onCoinsUpdated: widget.onCoinsUpdated,
            currentCoins: widget.currentCoins,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PetAdoptScreen(
            onCoinsUpdated: widget.onCoinsUpdated,
            currentCoins: widget.currentCoins,
          ),
        ),
      );
    }
  }
}