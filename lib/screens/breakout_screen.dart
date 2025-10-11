import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../utils/responsive_helper.dart';

class BreakoutScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const BreakoutScreen({
    Key? key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  }) : super(key: key);

  @override
  State<BreakoutScreen> createState() => _BreakoutScreenState();
}

class _BreakoutScreenState extends State<BreakoutScreen>
    with TickerProviderStateMixin {
  // Configuration du jeu - responsive selon la taille d'écran
  double get canvasWidth => ResponsiveHelper.isMobile(context) ? 320 : 500;
  double get canvasHeight => ResponsiveHelper.isMobile(context) ? 400 : 500;
  static const int brickRows = 3;
  static const int brickColumns = 5;
  double get brickWidth => (canvasWidth - 100) / brickColumns - brickPadding;
  static const double brickHeight = 20;
  static const double brickPadding = 10;
  static const double brickOffsetTop = 30;

  // État du jeu
  List<List<bool>> bricks = [];
  late double ballX;
  late double ballY;
  double ballDx = 2.0;
  double ballDy = -2.0;
  double ballRadius = 10;
  
  late double paddleX;
  late double paddleY;
  double get paddleWidth => ResponsiveHelper.isMobile(context) ? 60 : 80;
  double paddleHeight = 10;
  
  int score = 0;
  int bestScore = 0;
  double ballSpeed = 0.7; // Vitesse plus lente initialement
  
  bool gameStarted = false;
  bool gameOver = false;
  bool gameWon = false;
  bool checkCollision = true;
  
  Timer? gameTimer;
  bool leftPressed = false;
  bool rightPressed = false;
  
  final FocusNode _focusNode = FocusNode();
  
  // Variables pour les contrôles tactiles
  double? touchStartX;
  double? touchCurrentX;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
      _focusNode.requestFocus();
    });
  }
  
  void _initializeGame() {
    ballX = canvasWidth / 2;
    ballY = canvasHeight - 180;
    paddleX = canvasWidth / 2 - paddleWidth / 2;
    paddleY = canvasHeight - 20;
    _initializeBricks();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeBricks() {
    bricks = List.generate(
      brickColumns,
      (c) => List.generate(brickRows, (r) => true),
    );
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      gameOver = false;
      gameWon = false;
      checkCollision = true;
      score = 0;
      ballSpeed = 0.7;
      _resetBall();
      _resetPaddle();
      _initializeBricks();
    });
    
    gameTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      _updateGame();
    });
  }

  void _resetBall() {
    ballX = canvasWidth / 2;
    ballY = canvasHeight - 180;
    ballDx = 2.0;
    ballDy = 2.0; // Changement: vers le bas initialement
  }

  void _resetPaddle() {
    paddleX = canvasWidth / 2 - paddleWidth / 2;
    paddleY = canvasHeight - 20;
  }

  void _updateGame() {
    if (gameOver || gameWon || !checkCollision) return;

    setState(() {
      // Déplacer la balle
      ballX += ballDx * ballSpeed;
      ballY += ballDy * ballSpeed;

      // Déplacer la raquette (clavier)
      if (leftPressed && paddleX > 0) {
        paddleX -= 6;
      }
      if (rightPressed && paddleX + paddleWidth < canvasWidth) {
        paddleX += 6;
      }
      
      // Déplacer la raquette (tactile)
      if (touchCurrentX != null && touchStartX != null) {
        double deltaX = touchCurrentX! - touchStartX!;
        double newPaddleX = paddleX + deltaX * 0.1;
        if (newPaddleX >= 0 && newPaddleX + paddleWidth <= canvasWidth) {
          paddleX = newPaddleX;
        }
        touchStartX = touchCurrentX;
      }

      _checkCollisions();
      
      // Vérifier victoire
      if (_allBricksDestroyed()) {
        gameWon = true;
        checkCollision = false;
        gameTimer?.cancel();
        _showVictoryDialog();
      }
    });
  }
  
  void _checkCollisions() {
    if (!checkCollision) return;
    
    // Collisions avec les murs latéraux
    if (ballX + ballDx > canvasWidth - ballRadius || ballX + ballDx < ballRadius) {
      ballDx = -ballDx;
    }
    
    // Collision avec le mur du haut
    if (ballY + ballDy < ballRadius) {
      ballDy = -ballDy;
    }
    
    // Collision avec la raquette
    if (ballY + ballDy > canvasHeight - ballRadius - paddleHeight + 10) {
      if (ballX > paddleX && ballX < paddleX + paddleWidth) {
        double paddleCenter = paddleX + paddleWidth / 2;
        double ballOffsetFromCenter = ballX - paddleCenter;
        ballDy = -ballDy;
        ballDx = ballOffsetFromCenter / (paddleWidth / 2);
      } else {
        // Game over si la balle tombe
        _endGame(false);
        return;
      }
    }
    
    // Collision avec les briques
    _checkBrickCollisions();
  }

  void _checkBrickCollisions() {
    double brickOffsetLeft = (canvasWidth - (brickColumns * (brickWidth + brickPadding))) / 2;
    
    for (int c = 0; c < brickColumns; c++) {
      for (int r = 0; r < brickRows; r++) {
        if (!bricks[c][r]) continue;

        double brickX = c * (brickWidth + brickPadding) + brickOffsetLeft;
        double brickY = r * (brickHeight + brickPadding) + brickOffsetTop;

        if (ballX > brickX &&
            ballX < brickX + brickWidth &&
            ballY > brickY &&
            ballY < brickY + brickHeight) {
          ballDy = -ballDy;
          bricks[c][r] = false;
          score++;
          
          // Augmenter la vitesse de façon progressive
          ballSpeed += 0.15;
          
          HapticFeedback.lightImpact(); // Feedback tactile
          break;
        }
      }
    }
  }

  bool _allBricksDestroyed() {
    for (int c = 0; c < brickColumns; c++) {
      for (int r = 0; r < brickRows; r++) {
        if (bricks[c][r]) return false;
      }
    }
    return true;
  }

  void _endGame(bool won) {
    gameTimer?.cancel();
    setState(() {
      gameOver = !won;
      gameWon = won;
      gameStarted = false;
    });

    if (score > bestScore) {
      bestScore = score;
    }

    // Calculer les pièces gagnées
    int coinsEarned = won ? score * 5 : (score * 2);
    if (coinsEarned > 0) {
      widget.onCoinsUpdated(coinsEarned);
    }

    // Afficher le résultat
    if (!won) {
      _showGameOverDialog(coinsEarned);
    }
  }
  
  void _showVictoryDialog() {
    int coinsEarned = score * 5;
    widget.onCoinsUpdated(coinsEarned);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          '🎉 Bravo, vous avez gagné !',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $score',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '💰 +$coinsEarned pièces',
              style: const TextStyle(color: Color(0xFFE91E63), fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text(
              'Rejouer',
              style: TextStyle(color: Color(0xFFE91E63)),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showGameOverDialog(int coinsEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          '💥 Partie terminée !',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $score',
              style: const TextStyle(color: Colors.white, fontSize: 18),
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
              _resetGame();
            },
            child: const Text(
              'Rejouer',
              style: TextStyle(color: Color(0xFFE91E63)),
            ),
          ),
        ],
      ),
    );
  }
  
  void _resetGame() {
    setState(() {
      gameWon = false;
      gameOver = false;
      gameStarted = false;
      checkCollision = true;
      score = 0;
      ballSpeed = 0.7;
      _initializeGame();
    });
  }



  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        leftPressed = true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        rightPressed = true;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        leftPressed = false;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        rightPressed = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('🧱 Casse-Briques', style: TextStyle(color: Colors.white)),
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
        onKeyEvent: _handleKeyEvent,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Scores
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Score', style: TextStyle(color: Colors.grey)),
                          Text(
                            '$score',
                            style: TextStyle(
                              color: const Color(0xFFE91E63),
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
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
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Zone de jeu avec contrôles tactiles
                GestureDetector(
                  onPanStart: (details) {
                    if (gameStarted) {
                      touchStartX = details.localPosition.dx;
                    }
                  },
                  onPanUpdate: (details) {
                    if (gameStarted) {
                      touchCurrentX = details.localPosition.dx;
                    }
                  },
                  onPanEnd: (details) {
                    touchStartX = null;
                    touchCurrentX = null;
                  },
                  child: Container(
                    width: canvasWidth,
                    height: canvasHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF101010),
                      border: Border.all(color: const Color(0xFFfdd33c), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomPaint(
                      painter: BreakoutPainter(
                        bricks: bricks,
                        ballX: ballX,
                        ballY: ballY,
                        ballRadius: ballRadius,
                        paddleX: paddleX,
                        paddleY: paddleY,
                        paddleWidth: paddleWidth,
                        paddleHeight: paddleHeight,
                        canvasWidth: canvasWidth,
                        canvasHeight: canvasHeight,
                        brickWidth: brickWidth,
                      ),
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
                      gameOver || gameWon ? 'Rejouer' : 'Jouer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // Instructions adaptées selon le dispositif
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getResponsivePadding(context),
                  ),
                  child: Text(
                    isMobile 
                      ? '👆 Glissez horizontalement pour déplacer la raquette'
                      : '← → Utilisez les flèches pour déplacer la raquette',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Contrôles virtuels pour mobile
                if (isMobile && gameStarted) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTapDown: (_) {
                          leftPressed = true;
                          HapticFeedback.lightImpact();
                        },
                        onTapUp: (_) => leftPressed = false,
                        onTapCancel: () => leftPressed = false,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Icon(
                            Icons.arrow_left,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTapDown: (_) {
                          rightPressed = true;
                          HapticFeedback.lightImpact();
                        },
                        onTapUp: (_) => rightPressed = false,
                        onTapCancel: () => rightPressed = false,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Icon(
                            Icons.arrow_right,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BreakoutPainter extends CustomPainter {
  final List<List<bool>> bricks;
  final double ballX, ballY, ballRadius;
  final double paddleX, paddleY, paddleWidth, paddleHeight;
  final double canvasWidth, canvasHeight, brickWidth;

  BreakoutPainter({
    required this.bricks,
    required this.ballX,
    required this.ballY,
    required this.ballRadius,
    required this.paddleX,
    required this.paddleY,
    required this.paddleWidth,
    required this.paddleHeight,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.brickWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner les briques
    _drawBricks(canvas, size);
    
    // Dessiner la balle
    _drawBall(canvas);
    
    // Dessiner la raquette
    _drawPaddle(canvas);
  }

  void _drawBricks(Canvas canvas, Size size) {
    const double brickHeight = _BreakoutScreenState.brickHeight;
    const double brickPadding = _BreakoutScreenState.brickPadding;
    const double brickOffsetTop = _BreakoutScreenState.brickOffsetTop;
    
    double brickOffsetLeft = (size.width - (_BreakoutScreenState.brickColumns * (brickWidth + brickPadding))) / 2;
    
    final paint = Paint()..color = const Color(0xFFf5f5f5);
    
    // Couleurs différentes par ligne pour plus de variété
    final List<Color> brickColors = [
      const Color(0xFFE91E63), // Rose
      const Color(0xFF9C27B0), // Violet
      const Color(0xFF2196F3), // Bleu
    ];
    
    for (int c = 0; c < _BreakoutScreenState.brickColumns; c++) {
      for (int r = 0; r < _BreakoutScreenState.brickRows; r++) {
        if (bricks[c][r]) {
          double brickX = c * (brickWidth + brickPadding) + brickOffsetLeft;
          double brickY = r * (brickHeight + brickPadding) + brickOffsetTop;
          
          paint.color = brickColors[r % brickColors.length];
          
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(brickX, brickY, brickWidth, brickHeight),
              const Radius.circular(4),
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawBall(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFfdd33c);
    canvas.drawCircle(Offset(ballX, ballY), ballRadius, paint);
  }

  void _drawPaddle(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFf5f5f5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(paddleX, paddleY, paddleWidth, paddleHeight),
        const Radius.circular(5),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}