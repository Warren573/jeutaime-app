import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class MemoryGameScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const MemoryGameScreen({
    super.key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  });

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen>
    with TickerProviderStateMixin {
  static const int gridSize = 4; // 4x4 grid = 16 cartes
  static const int totalPairs = 8;
  
  List<int> cardValues = [];
  List<bool> flippedCards = [];
  List<bool> matchedCards = [];
  List<int> flippedIndices = [];
  
  int moves = 0;
  int matches = 0;
  int score = 0;
  bool gameStarted = false;
  bool gameWon = false;
  Timer? gameTimer;
  int elapsedSeconds = 0;
  
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  
  late AnimationController _winController;
  late Animation<double> _winAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut)
    );
    
    _winController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _winAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _winController, curve: Curves.elasticOut)
    );
    
    _initializeGame();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _winController.dispose();
    gameTimer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    // Créer les paires d'emojis
    List<String> emojis = ['💝', '🌹', '💌', '💕', '💖', '🎭', '🍷', '🎈'];
    
    cardValues.clear();
    for (int i = 0; i < totalPairs; i++) {
      cardValues.add(i);
      cardValues.add(i); // Ajouter la paire
    }
    
    // Mélanger les cartes
    cardValues.shuffle(Random());
    
    // Initialiser les états
    flippedCards = List.filled(gridSize * gridSize, false);
    matchedCards = List.filled(gridSize * gridSize, false);
    flippedIndices.clear();
    
    moves = 0;
    matches = 0;
    score = 0;
    gameStarted = false;
    gameWon = false;
    elapsedSeconds = 0;
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
    });
    
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          elapsedSeconds++;
        });
      }
    });
  }

  void _flipCard(int index) {
    if (!gameStarted) _startGame();
    
    // Empêcher de retourner une carte déjà retournée ou trouvée
    if (flippedCards[index] || matchedCards[index] || flippedIndices.length >= 2) {
      return;
    }
    
    setState(() {
      flippedCards[index] = true;
      flippedIndices.add(index);
      moves++;
    });
    
    _flipController.forward();
    
    // Si deux cartes sont retournées, vérifier la correspondance
    if (flippedIndices.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        int firstIndex = flippedIndices[0];
        int secondIndex = flippedIndices[1];
        
        if (cardValues[firstIndex] == cardValues[secondIndex]) {
          // C'est une paire !
          setState(() {
            matchedCards[firstIndex] = true;
            matchedCards[secondIndex] = true;
            matches++;
            score += (100 - elapsedSeconds ~/ 2).clamp(10, 100); // Bonus de rapidité
          });
          
          // Vérifier si le jeu est terminé
          if (matches == totalPairs) {
            _winGame();
          }
        } else {
          // Pas de correspondance, retourner les cartes
          setState(() {
            flippedCards[firstIndex] = false;
            flippedCards[secondIndex] = false;
          });
        }
        
        setState(() {
          flippedIndices.clear();
        });
        
        _flipController.reset();
      }
    });
  }

  void _winGame() {
    gameTimer?.cancel();
    setState(() {
      gameWon = true;
    });
    
    _winController.forward();
    
    // Calculer les récompenses
    int timeBonus = (120 - elapsedSeconds).clamp(0, 120);
    int moveBonus = (20 - moves).clamp(0, 20);
    int totalReward = score + timeBonus + moveBonus;
    
    widget.onCoinsUpdated(totalReward);
    
    // Afficher la victoire
    _showWinDialog(totalReward);
  }

  void _showWinDialog(int reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('🎉 Victoire!', 
          style: TextStyle(color: Colors.white, fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bravo ! Toutes les paires trouvées !',
              style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Text('⏱️ Temps: ${elapsedSeconds}s',
              style: const TextStyle(color: Colors.white)),
            Text('🔄 Mouvements: $moves',
              style: const TextStyle(color: Colors.white)),
            Text('💎 Score: $score',
              style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('🪙 +$reward pièces gagnées!',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeGame();
              setState(() {});
            },
            child: const Text('Rejouer', style: TextStyle(color: Color(0xFFE91E63))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Retour', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  String _getEmojiForValue(int value) {
    List<String> emojis = ['💝', '🌹', '💌', '💕', '💖', '🎭', '🍷', '🎈'];
    return emojis[value % emojis.length];
  }

  Widget _buildCard(int index) {
    bool isFlipped = flippedCards[index] || matchedCards[index];
    bool isMatched = matchedCards[index];
    
    return GestureDetector(
      onTap: () => _flipCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isMatched 
              ? const Color(0xFF4CAF50) 
              : isFlipped 
                  ? const Color(0xFFE91E63) 
                  : const Color(0xFF2E2E2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMatched ? Colors.green : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isFlipped
              ? Text(
                  _getEmojiForValue(cardValues[index]),
                  style: const TextStyle(fontSize: 32),
                )
              : const Text(
                  '❓',
                  style: TextStyle(fontSize: 32, color: Colors.grey),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('🧠 Memory Game', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1a1a1a),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('⏱️ ${elapsedSeconds}s', 
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const Text('Temps', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Text('🔄 $moves', 
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const Text('Mouvements', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Text('💖 $matches/$totalPairs', 
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const Text('Paires', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Text('💎 $score', 
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const Text('Score', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          
          // Grille de jeu
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, index) => _buildCard(index),
              ),
            ),
          ),
          
          // Bouton reset
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                gameTimer?.cancel();
                _initializeGame();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('🔄 Nouvelle Partie', 
                style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}