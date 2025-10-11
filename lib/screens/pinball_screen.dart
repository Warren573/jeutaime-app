import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

class PinballScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const PinballScreen({
    Key? key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  }) : super(key: key);

  @override
  State<PinballScreen> createState() => _PinballScreenState();
}

class _PinballScreenState extends State<PinballScreen>
    with TickerProviderStateMixin {
  // Configuration du jeu
  static const double tableWidth = 380;
  static const double tableHeight = 650;
  static const double ballRadius = 10;

  // État du jeu
  double ballX = tableWidth / 2;
  double ballY = tableHeight - 50;
  double ballVx = 0;
  double ballVy = 0;
  
    // Angles des flippers (en radians)
  double leftFlipperAngle = -math.pi / 3;     // -60 degrés (repos)
  double rightFlipperAngle = -2 * math.pi / 3; // -120 degrés (repos)
  bool leftFlipperActive = false;
  bool rightFlipperActive = false;
  double flipperLength = 80.0;
  double flipperWidth = 12.0;
  
  // Bumpers (obstacles qui donnent des points)
  List<Bumper> bumpers = [];
  
  // Score et état
  int score = 0;
  int bestScore = 0;
  int lives = 3;
  bool gameStarted = false;
  bool gameOver = false;
  
  Timer? gameTimer;
  final FocusNode _focusNode = FocusNode();
  
  // Constantes physiques
  static const double gravity = 0.15;
  static const double friction = 0.99;
  static const double bounceDamping = 0.8;

  @override
  void initState() {
    super.initState();
    _initializeBumpers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeBumpers() {
    bumpers = [
      // Triangle du haut
      Bumper(x: 120, y: 180, radius: 30, points: 100),
      Bumper(x: 260, y: 180, radius: 30, points: 100),
      Bumper(x: 190, y: 120, radius: 30, points: 150),
      
      // Bumpers centraux
      Bumper(x: 90, y: 320, radius: 25, points: 75),
      Bumper(x: 290, y: 320, radius: 25, points: 75),
      Bumper(x: 190, y: 260, radius: 35, points: 200),
      
      // Bumpers latéraux
      Bumper(x: 60, y: 450, radius: 20, points: 50),
      Bumper(x: 320, y: 450, radius: 20, points: 50),
      
      // Bumper bonus au centre-bas
      Bumper(x: 190, y: 380, radius: 25, points: 300),
    ];
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      gameOver = false;
      score = 0;
      lives = 3;
      _resetBall();
    });
    
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateGame();
    });
  }

  void _resetBall() {
    ballX = tableWidth / 2;
    ballY = tableHeight - 50;
    ballVx = 0;
    ballVy = -8; // Lancer vers le haut
  }

  void _launchBall() {
    if (ballY > tableHeight - 60) {
      ballVx = (math.Random().nextDouble() - 0.5) * 4;
      ballVy = -12;
    }
  }

  void _updateGame() {
    if (gameOver || !gameStarted) return;

    setState(() {
      // Appliquer la gravité
      ballVy += gravity;
      
      // Appliquer le mouvement
      ballX += ballVx;
      ballY += ballVy;
      
      // Friction
      ballVx *= friction;
      ballVy *= friction;

      // Collisions avec les murs
      _checkWallCollisions();
      
      // Collisions avec les flippers
      _checkFlipperCollisions();
      
      // Collisions avec les bumpers
      _checkBumperCollisions();
      
      // Vérifier si la balle est tombée
      if (ballY > tableHeight + 20) {
        _ballLost();
      }
      
      // Animation des flippers
      _updateFlippers();
    });
  }

  void _checkWallCollisions() {
    // Murs gauche et droit
    if (ballX <= ballRadius || ballX >= tableWidth - ballRadius) {
      ballVx = -ballVx * bounceDamping;
      ballX = ballX <= ballRadius ? ballRadius : tableWidth - ballRadius;
    }
    
    // Mur du haut
    if (ballY <= ballRadius) {
      ballVy = -ballVy * bounceDamping;
      ballY = ballRadius;
    }
  }

  void _checkFlipperCollisions() {
    // Position des flippers - exactement où ils sont dessinés
    double leftFlipperX = 100;
    double leftFlipperY = tableHeight - 60;
    double rightFlipperX = tableWidth - 100;
    double rightFlipperY = tableHeight - 60;
    
    // Zone de collision plus précise et réactive
    double collisionRadius = 50.0; // Zone de détection plus grande
    
    // Flipper gauche
    double leftDist = math.sqrt(
      math.pow(ballX - leftFlipperX, 2) + math.pow(ballY - leftFlipperY, 2)
    );
    if (leftDist < collisionRadius) {
      if (leftFlipperActive) {
        // Frappe TRÈS puissante avec effet vers le haut
        ballVx = 15.0; // Force vers la droite
        ballVy = -18.0; // Force vers le haut
        score += 25; // Bonus pour utiliser les flippers
        
        // Éloigner la balle pour éviter les collisions multiples
        ballX = leftFlipperX + collisionRadius + 5;
        ballY = leftFlipperY - collisionRadius - 5;
      } else {
        // Rebond doux si le flipper n'est pas activé
        ballVx = 8.0;
        ballVy = -6.0;
      }
    }
    
    // Flipper droit
    double rightDist = math.sqrt(
      math.pow(ballX - rightFlipperX, 2) + math.pow(ballY - rightFlipperY, 2)
    );
    if (rightDist < collisionRadius) {
      if (rightFlipperActive) {
        // Frappe TRÈS puissante avec effet vers le haut
        ballVx = -15.0; // Force vers la gauche
        ballVy = -18.0; // Force vers le haut
        score += 25; // Bonus pour utiliser les flippers
        
        // Éloigner la balle pour éviter les collisions multiples
        ballX = rightFlipperX - collisionRadius - 5;
        ballY = rightFlipperY - collisionRadius - 5;
      } else {
        // Rebond doux si le flipper n'est pas activé
        ballVx = -8.0;
        ballVy = -6.0;
      }
    }
  }

  void _checkBumperCollisions() {
    for (Bumper bumper in bumpers) {
      double dist = math.sqrt(
        math.pow(ballX - bumper.x, 2) + math.pow(ballY - bumper.y, 2)
      );
      
      if (dist < ballRadius + bumper.radius) {
        // Calculer l'angle de rebond
        double angle = math.atan2(ballY - bumper.y, ballX - bumper.x);
        double speed = math.max(8.0, math.sqrt(ballVx * ballVx + ballVy * ballVy));
        
        ballVx = math.cos(angle) * speed;
        ballVy = math.sin(angle) * speed;
        
        // Repositionner la balle
        ballX = bumper.x + math.cos(angle) * (bumper.radius + ballRadius);
        ballY = bumper.y + math.sin(angle) * (bumper.radius + ballRadius);
        
        // Ajouter des points
        score += bumper.points;
        
        // Animation du bumper
        bumper.hit = true;
        Timer(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              bumper.hit = false;
            });
          }
        });
      }
    }
  }

  void _updateFlippers() {
    // Animation des flippers - plus rapide et plus étendue
    if (leftFlipperActive) {
      leftFlipperAngle = math.min(leftFlipperAngle + 0.3, 0.5);
    } else {
      leftFlipperAngle = math.max(leftFlipperAngle - 0.15, -0.4);
    }
    
    if (rightFlipperActive) {
      rightFlipperAngle = math.max(rightFlipperAngle - 0.3, -0.5);
    } else {
      rightFlipperAngle = math.min(rightFlipperAngle + 0.15, 0.4);
    }
  }

  void _ballLost() {
    lives--;
    if (lives <= 0) {
      _endGame();
    } else {
      _resetBall();
    }
  }

  void _endGame() {
    gameTimer?.cancel();
    setState(() {
      gameOver = true;
      gameStarted = false;
    });

    if (score > bestScore) {
      bestScore = score;
    }

    // Calculer les pièces gagnées
    int coinsEarned = (score / 100).floor();
    if (coinsEarned > 0) {
      widget.onCoinsUpdated(coinsEarned);
    }

    // Afficher le résultat
    _showGameResult(coinsEarned);
  }

  void _showGameResult(int coinsEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          '🎯 Partie Terminée',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $score',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              'Meilleur: $bestScore',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            if (coinsEarned > 0) ...[
              const SizedBox(height: 10),
              Text(
                '💰 +$coinsEarned pièces',
                style: const TextStyle(color: Color(0xFFE91E63), fontSize: 16),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
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

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        leftFlipperActive = true;
        leftFlipperAngle = -math.pi / 4; // -45 degrés (actif)
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        rightFlipperActive = true;
        rightFlipperAngle = -3 * math.pi / 4; // -135 degrés (actif)
      }
      if (event.logicalKey == LogicalKeyboardKey.space) {
        _launchBall();
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        leftFlipperActive = false;
        leftFlipperAngle = -math.pi / 3; // -60 degrés (repos)
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        rightFlipperActive = false;
        rightFlipperAngle = -2 * math.pi / 3; // -120 degrés (repos)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('🕹️ Flipper', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '💰 ${widget.currentCoins}',
                style: const TextStyle(color: Colors.amber, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _onKeyEvent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scores et vies
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Score', style: TextStyle(color: Colors.grey)),
                        Text(
                          '$score',
                          style: const TextStyle(
                            color: Color(0xFFE91E63),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Vies', style: TextStyle(color: Colors.grey)),
                        Text(
                          '$lives',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 24,
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
                            color: Colors.orange,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Table de flipper
              Container(
                width: tableWidth,
                height: tableHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a2e),
                  border: Border.all(color: Colors.amber, width: 3),
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1e)],
                  ),
                ),
                child: CustomPaint(
                  painter: PinballPainter(
                    ballX: ballX,
                    ballY: ballY,
                    ballRadius: ballRadius,
                    leftFlipperAngle: leftFlipperAngle,
                    rightFlipperAngle: rightFlipperAngle,
                    leftFlipperActive: leftFlipperActive,
                    rightFlipperActive: rightFlipperActive,
                    bumpers: bumpers,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Bouton de jeu
              if (!gameStarted)
                ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    gameOver ? 'Rejouer' : 'Jouer',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Instructions
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      '← → ou A/D : Flippers',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      'ESPACE : Lancer la balle',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Bumper {
  final double x, y, radius;
  final int points;
  bool hit = false;

  Bumper({
    required this.x,
    required this.y,
    required this.radius,
    required this.points,
  });
}

class PinballPainter extends CustomPainter {
  final double ballX, ballY, ballRadius;
  final double leftFlipperAngle, rightFlipperAngle;
  final bool leftFlipperActive, rightFlipperActive;
  final List<Bumper> bumpers;
  
  static const double flipperLength = 80.0;
  static const double flipperWidth = 12.0;

  PinballPainter({
    required this.ballX,
    required this.ballY,
    required this.ballRadius,
    required this.leftFlipperAngle,
    required this.rightFlipperAngle,
    required this.leftFlipperActive,
    required this.rightFlipperActive,
    required this.bumpers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner les bumpers
    _drawBumpers(canvas);
    
    // Dessiner les flippers
    _drawFlippers(canvas, size);
    
    // Dessiner la balle
    _drawBall(canvas);
  }

  void _drawBumpers(Canvas canvas) {
    for (Bumper bumper in bumpers) {
      // Couleur selon les points
      Color bumperColor;
      if (bumper.points >= 300) {
        bumperColor = bumper.hit ? Colors.yellow : Colors.amber;
      } else if (bumper.points >= 150) {
        bumperColor = bumper.hit ? Colors.orange : Colors.deepOrange;
      } else if (bumper.points >= 100) {
        bumperColor = bumper.hit ? Colors.lightBlue : Colors.blue;
      } else {
        bumperColor = bumper.hit ? Colors.lightGreen : Colors.green;
      }
      
      final paint = Paint()
        ..color = bumperColor
        ..style = PaintingStyle.fill;
      
      // Effet de lueur si touché
      if (bumper.hit) {
        final glowPaint = Paint()
          ..color = bumperColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(bumper.x, bumper.y), bumper.radius + 8, glowPaint);
      }
      
      // Cercle principal
      canvas.drawCircle(Offset(bumper.x, bumper.y), bumper.radius, paint);
      
      // Bordure
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(bumper.x, bumper.y), bumper.radius, borderPaint);
      
      // Points avec meilleure lisibilité
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${bumper.points}',
          style: TextStyle(
            color: Colors.white,
            fontSize: bumper.radius > 30 ? 14 : 10,
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(
                blurRadius: 2,
                color: Colors.black,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          bumper.x - textPainter.width / 2,
          bumper.y - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawFlippers(Canvas canvas, Size size) {
    // Couleurs différentes selon l'état activé/repos
    final leftFlipperPaint = Paint()
      ..color = leftFlipperActive ? Colors.yellow : Colors.grey.shade100
      ..style = PaintingStyle.fill;
      
    final rightFlipperPaint = Paint()
      ..color = rightFlipperActive ? Colors.yellow : Colors.grey.shade100
      ..style = PaintingStyle.fill;
    
    final flipperBorderPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Flippers BEAUCOUP plus grands et visibles
    double bigFlipperLength = 100.0;  // Plus long
    double bigFlipperWidth = 20.0;    // Plus large

    // Flipper gauche - GROS et bien visible
    canvas.save();
    canvas.translate(100, size.height - 60);
    canvas.rotate(leftFlipperAngle);
    
    final leftFlipperRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, -bigFlipperWidth/2, bigFlipperLength, bigFlipperWidth), // Partir du pivot
      const Radius.circular(10),
    );
    canvas.drawRRect(leftFlipperRect, leftFlipperPaint);
    canvas.drawRRect(leftFlipperRect, flipperBorderPaint);
    
    // Point de pivot bien visible
    canvas.drawCircle(const Offset(0, 0), 10, Paint()..color = Colors.red.shade400);
    canvas.restore();

    // Flipper droit - GROS et bien visible  
    canvas.save();
    canvas.translate(size.width - 100, size.height - 60);
    canvas.rotate(rightFlipperAngle);
    
    final rightFlipperRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-bigFlipperLength, -bigFlipperWidth/2, bigFlipperLength, bigFlipperWidth), // Partir du pivot vers la gauche
      const Radius.circular(10),
    );
    canvas.drawRRect(rightFlipperRect, rightFlipperPaint);
    canvas.drawRRect(rightFlipperRect, flipperBorderPaint);
    
    // Point de pivot bien visible
    canvas.drawCircle(const Offset(0, 0), 10, Paint()..color = Colors.red.shade400);
    canvas.restore();
  }

  void _drawBall(Canvas canvas) {
    final ballPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    // Ombre
    canvas.drawCircle(Offset(ballX + 2, ballY + 2), ballRadius, shadowPaint);
    
    // Balle
    canvas.drawCircle(Offset(ballX, ballY), ballRadius, ballPaint);
    
    // Reflet
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(ballX - 2, ballY - 2), ballRadius * 0.3, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}