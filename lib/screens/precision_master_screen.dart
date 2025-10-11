import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class PrecisionMasterScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const PrecisionMasterScreen({
    Key? key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  }) : super(key: key);

  @override
  State<PrecisionMasterScreen> createState() => _PrecisionMasterScreenState();
}

class _PrecisionMasterScreenState extends State<PrecisionMasterScreen>
    with TickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 1000),
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
      // Position aléatoire mais gardant la cible dans l'écran
      targetX = 0.15 + random.nextDouble() * 0.7;
      targetY = 0.25 + random.nextDouble() * 0.5;
      totalTargets++;
    });

    // Augmenter la difficulté
    if (totalTargets % 3 == 0 && targetSize > 40) {
      setState(() {
        targetSize -= 5;
        level++;
      });
    }

    // Programmer la prochaine cible
    targetTimer = Timer(Duration(milliseconds: 2000 - (level * 100)), () {
      if (gameActive) {
        generateTarget();
      }
    });
  }

  void hitTarget(Offset tapPosition) {
    if (!gameActive) return;

    // Calculer la position de la cible sur l'écran
    final screenSize = MediaQuery.of(context).size;
    final targetScreenX = targetX * screenSize.width;
    final targetScreenY = targetY * screenSize.height;
    
    // Calculer la distance
    final distance = math.sqrt(
      math.pow(tapPosition.dx - targetScreenX, 2) + 
      math.pow(tapPosition.dy - targetScreenY, 2)
    );
    
    // Vérifier si le tap est dans la cible
    if (distance <= targetSize / 2) {
      setState(() {
        targetsHit++;
        // Points basés sur la précision et le niveau
        int points = ((targetSize / 2 - distance) * 10).round() + (level * 10);
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

    // Calculer les pièces gagnées
    double accuracy = totalTargets > 0 ? (targetsHit / totalTargets) * 100 : 0;
    int coinsEarned = (score / 50).round() + (accuracy > 70 ? 15 : 0);
    
    if (coinsEarned > 0) {
      widget.onCoinsUpdated(coinsEarned);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          '🎯 Fin du jeu !',
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
              'Cibles touchées: $targetsHit/$totalTargets',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              'Précision: ${accuracy.toStringAsFixed(1)}%',
              style: TextStyle(
                color: accuracy > 70 ? Colors.green : Colors.grey,
              ),
            ),
            if (accuracy > 70) ...[
              const SizedBox(height: 5),
              const Text(
                'Bonus précision: +15 pièces !',
                style: TextStyle(color: Colors.green),
              ),
            ],
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
          '🎯 Précision Master',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Instructions et stats
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Instructions
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e1e1e),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    '🎯 Tapez au centre des cibles qui apparaissent !\n'
                    '⚡ Plus vous êtes précis, plus vous gagnez de points\n'
                    '📈 Les cibles deviennent plus petites avec le niveau',
                    style: TextStyle(color: Colors.grey),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Niveau', style: TextStyle(color: Colors.grey)),
                        Text(
                          '$level',
                          style: const TextStyle(
                            color: Color(0xFFE91E63),
                            fontSize: 18,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Précision', style: TextStyle(color: Colors.grey)),
                        Text(
                          totalTargets > 0 
                              ? '${((targetsHit / totalTargets) * 100).toStringAsFixed(0)}%'
                              : '0%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                        // Zone tactile complète
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.transparent,
                        ),
                        // Cible animée
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
                                      colors: [
                                        Colors.red,
                                        Colors.orange,
                                        Colors.yellow,
                                        Colors.transparent,
                                      ],
                                      stops: [0.0, 0.3, 0.6, 1.0],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.5),
                                        blurRadius: 15,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '🎯',
                                      style: TextStyle(fontSize: 24),
                                    ),
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
                        const Text(
                          '🎯',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Meilleur score: $bestScore',
                          style: const TextStyle(
                            color: Color(0xFFE91E63),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),

          // Bouton de jeu
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: gameActive ? null : startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F4F4F),
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
          ),
        ],
      ),
    );
  }
}
