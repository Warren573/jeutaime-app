import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class PrecisionMasterScreenSimple extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const PrecisionMasterScreenSimple({
    Key? key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  }) : super(key: key);

  @override
  State<PrecisionMasterScreenSimple> createState() => _PrecisionMasterScreenSimpleState();
}

class _PrecisionMasterScreenSimpleState extends State<PrecisionMasterScreenSimple>
    with SingleTickerProviderStateMixin {
  int score = 0;
  int bestScore = 0;
  int level = 1;
  bool gameActive = false;
  Timer? gameTimer;
  Timer? targetTimer;
  
  double targetX = 0.5;
  double targetY = 0.5;
  double targetSize = 80.0;
  int timeLeft = 30;
  int targetsHit = 0;
  int totalTargets = 0;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    gameTimer?.cancel();
    targetTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    setState(() {
      gameActive = true;
      score = 0;
      timeLeft = 30;
      level = 1;
      targetsHit = 0;
      totalTargets = 0;
      targetSize = 80.0;
    });

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
      });
      if (timeLeft <= 0) {
        endGame();
      }
    });

    generateTarget();
  }

  void generateTarget() {
    if (!gameActive) return;

    setState(() {
      targetX = 0.15 + random.nextDouble() * 0.7;
      targetY = 0.25 + random.nextDouble() * 0.5;
      totalTargets++;
    });

    // Augmenter la difficulté
    if (totalTargets % 3 == 0 && targetSize > 50) {
      setState(() {
        targetSize -= 5;
        level++;
      });
    }

    targetTimer = Timer(const Duration(milliseconds: 1500), () {
      if (gameActive) {
        generateTarget();
      }
    });
  }

  void hitTarget(Offset globalPosition) {
    if (!gameActive) return;

    // Obtenir la taille de l'écran
    final screenSize = MediaQuery.of(context).size;
    
    // Position relative de la cible sur l'écran
    final targetScreenX = targetX * screenSize.width;
    final targetScreenY = targetY * screenSize.height;
    
    // Distance entre le tap et la cible
    final distance = math.sqrt(
      math.pow(globalPosition.dx - targetScreenX, 2) + 
      math.pow(globalPosition.dy - targetScreenY, 2)
    );
    
    // Vérifier si le tap est dans la cible
    if (distance <= targetSize / 2) {
      setState(() {
        targetsHit++;
        int points = (100 - distance.round()) + (level * 10);
        score += math.max(10, points);
      });
      
      generateTarget(); // Nouvelle cible immédiatement
    }
  }

  void endGame() {
    gameTimer?.cancel();
    targetTimer?.cancel();
    
    setState(() {
      gameActive = false;
      if (score > bestScore) {
        bestScore = score;
      }
    });

    // Calculer les pièces
    double accuracy = totalTargets > 0 ? (targetsHit / totalTargets) * 100 : 0;
    int coinsEarned = (score / 50).round() + (accuracy > 70 ? 15 : 0);
    
    if (coinsEarned > 0) {
      widget.onCoinsUpdated(coinsEarned);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('🎯 Fin du jeu!', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $score', style: const TextStyle(color: Colors.white, fontSize: 18)),
            Text('Précision: ${accuracy.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text('🪙 +$coinsEarned pièces!', style: const TextStyle(color: Color(0xFFE91E63))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame();
            },
            child: const Text('Rejouer', style: TextStyle(color: Color(0xFFE91E63))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer', style: TextStyle(color: Colors.grey)),
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
        title: const Text('🎯 Précision Master', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Stats
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Score', style: TextStyle(color: Colors.grey)),
                    Text('$score', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Niveau', style: TextStyle(color: Colors.grey)),
                    Text('$level', style: const TextStyle(color: Color(0xFFE91E63), fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Temps', style: TextStyle(color: Colors.grey)),
                    Text('${timeLeft}s', style: TextStyle(color: timeLeft <= 10 ? Colors.red : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Précision', style: TextStyle(color: Colors.grey)),
                    Text(
                      totalTargets > 0 ? '${((targetsHit / totalTargets) * 100).toStringAsFixed(0)}%' : '0%',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Zone de jeu
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: gameActive 
                ? GestureDetector(
                    onTapDown: (details) => hitTarget(details.globalPosition),
                    child: Stack(
                      children: [
                        // Zone de jeu complète
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.transparent,
                        ),
                        // Cible
                        Positioned(
                          left: targetX * MediaQuery.of(context).size.width - targetSize / 2,
                          top: targetY * (MediaQuery.of(context).size.height * 0.6) - targetSize / 2,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: targetSize,
                                  height: targetSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const RadialGradient(
                                      colors: [Colors.red, Colors.orange, Colors.transparent],
                                      stops: [0.0, 0.7, 1.0],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text('🎯', style: TextStyle(fontSize: 24)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 20),
                        Text('Meilleur: $bestScore', style: const TextStyle(color: Color(0xFFE91E63), fontSize: 18)),
                      ],
                    ),
                  ),
            ),
          ),

          // Bouton de jeu
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: gameActive ? null : startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F4F4F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text(
                  gameActive ? 'Jeu en cours...' : '🎮 JOUER',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}