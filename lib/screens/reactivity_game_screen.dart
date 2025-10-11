import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class ReactivityGameScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const ReactivityGameScreen({
    Key? key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  }) : super(key: key);

  @override
  State<ReactivityGameScreen> createState() => _ReactivityGameScreenState();
}

class _ReactivityGameScreenState extends State<ReactivityGameScreen> {
  int score = 0;
  int bestScore = 0;
  int timeLeft = 30;
  bool gameActive = false;
  
  Timer? gameTimer;
  Timer? moleTimeout;
  List<int> activeMoles = [];
  int initialMoleInterval = 1500;
  
  final Random random = Random();

  @override
  void dispose() {
    gameTimer?.cancel();
    moleTimeout?.cancel();
    super.dispose();
  }

  void moleClicked(int index) {
    if (!gameActive) return;
    
    if (activeMoles.contains(index)) {
      // Touché !
      setState(() {
        score++;
        activeMoles.remove(index);
      });
      moleTimeout?.cancel();
      
      // Réinitialiser le timer de timeout
      moleTimeout = Timer(const Duration(milliseconds: 1500), () {
        endGame("Trop lent");
      });
    } else {
      // Raté !
      endGame("Il faut améliorer ta précision !");
      moleTimeout?.cancel();
    }
  }

  void generateMole() {
    if (!gameActive) return;
    
    if (activeMoles.length < 2) {
      int randomIndex = random.nextInt(16); // 4x4 grid = 16 cases
      
      if (!activeMoles.contains(randomIndex)) {
        setState(() {
          activeMoles.add(randomIndex);
        });
        
        // Augmenter la vitesse d'apparition
        initialMoleInterval -= 200;
        if (initialMoleInterval < 300) {
          initialMoleInterval = 300;
        }
      }
    }
    
    Timer(Duration(milliseconds: initialMoleInterval), generateMole);
  }

  void startGame() {
    setState(() {
      gameActive = true;
      score = 0;
      timeLeft = 30;
      activeMoles.clear();
      initialMoleInterval = 1500;
    });

    // Timer principal du jeu
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
      });
      if (timeLeft <= 0) {
        endGame("Temps écoulé");
      }
    });

    // Générer la première taupe
    generateMole();
    
    // Timer de timeout initial
    moleTimeout = Timer(const Duration(milliseconds: 1500), () {
      endGame("Trop lent");
    });
  }

  void endGame(String reason) {
    gameTimer?.cancel();
    moleTimeout?.cancel();
    
    setState(() {
      gameActive = false;
      activeMoles.clear();
      if (score > bestScore) {
        bestScore = score;
      }
    });

    // Calculer les pièces gagnées (2 pièces par point)
    int coinsEarned = score * 2;
    if (coinsEarned > 0) {
      widget.onCoinsUpdated(coinsEarned);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          '⚡ Fin du jeu de réactivité !',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score final: $score',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Raison: $reason',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              '🪙 +$coinsEarned pièces gagnées !',
              style: const TextStyle(color: Color(0xFFE91E63), fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame();
            },
            child: const Text(
              'Rejouer',
              style: TextStyle(color: Color(0xFFE91E63)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Quitter',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text(
          '⚡ Jeu de Réactivité',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e1e1e),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '⚡ Tapez sur les cercles BLANCS le plus vite possible !\n'
                  '🚫 Évitez les cercles jaunes\n'
                  '⏱️ Vous avez 30 secondes',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 20),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Score', style: TextStyle(color: Colors.grey)),
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Meilleur', style: TextStyle(color: Colors.grey)),
                      Text(
                        '$bestScore',
                        style: const TextStyle(
                          color: Color(0xFFE91E63),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Temps', style: TextStyle(color: Colors.grey)),
                      Text(
                        '${timeLeft}s',
                        style: TextStyle(
                          color: timeLeft <= 10 ? Colors.red : Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Grille de jeu 4x4
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF101010),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    bool isActive = activeMoles.contains(index);
                    
                    return GestureDetector(
                      onTap: () => moleClicked(index),
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : const Color(0xFFfdd33c),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Bouton de jeu
              Container(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: gameActive ? null : startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    gameActive ? 'Jeu en cours...' : '🎮 JOUER',
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
      ),
    );
  }
}