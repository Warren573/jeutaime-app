import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

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
  // Configuration du jeu
  static const double canvasWidth = 400;
  static const double canvasHeight = 500;
  static const int brickRows = 3;
  static const int brickColumns = 5;
  static const double brickWidth = 70;
  static const double brickHeight = 20;
  static const double brickPadding = 8;
  static const double brickOffsetTop = 60;

  // État du jeu
  List<List<bool>> bricks = [];
  double ballX = canvasWidth / 2;
  double ballY = canvasHeight - 100;
  double ballDx = 3.0;
  double ballDy = -3.0;
  double ballRadius = 10;
  
  double paddleX = canvasWidth / 2 - 40;
  double paddleY = canvasHeight - 30;
  double paddleWidth = 80;
  double paddleHeight = 10;
  
  int score = 0;
  int bestScore = 0;
  double ballSpeed = 1.0;
  
  bool gameStarted = false;
  bool gameOver = false;
  bool gameWon = false;
  
  Timer? gameTimer;
  bool leftPressed = false;
  bool rightPressed = false;
  
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeBricks();
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
      score = 0;
      ballSpeed = 1.0;
      _resetBall();
      _resetPaddle();
      _initializeBricks();
    });
    
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateGame();
    });
  }

  void _resetBall() {
    ballX = canvasWidth / 2;
    ballY = canvasHeight - 100;
    ballDx = 3.0;
    ballDy = -3.0;
  }

  void _resetPaddle() {
    paddleX = canvasWidth / 2 - paddleWidth / 2;
    paddleY = canvasHeight - 30;
  }

  void _updateGame() {
    if (gameOver || gameWon) return;

    setState(() {
      // Déplacer la balle
      ballX += ballDx * ballSpeed;
      ballY += ballDy * ballSpeed;

      // Déplacer la raquette
      if (leftPressed && paddleX > 0) {
        paddleX -= 6;
      }
      if (rightPressed && paddleX + paddleWidth < canvasWidth) {
        paddleX += 6;
      }

      // Collisions avec les murs
      if (ballX <= ballRadius || ballX >= canvasWidth - ballRadius) {
        ballDx = -ballDx;
      }
      if (ballY <= ballRadius) {
        ballDy = -ballDy;
      }

      // Collision avec la raquette
      if (ballY >= paddleY - ballRadius &&
          ballX >= paddleX &&
          ballX <= paddleX + paddleWidth) {
        ballDy = -ballDy;
        // Angle de rebond selon la position sur la raquette
        double paddleCenter = paddleX + paddleWidth / 2;
        double offset = (ballX - paddleCenter) / (paddleWidth / 2);
        ballDx = offset * 3;
      }

      // Game over si la balle tombe
      if (ballY > canvasHeight) {
        _endGame(false);
        return;
      }

      // Collision avec les briques
      _checkBrickCollisions();

      // Vérifier victoire
      if (_allBricksDestroyed()) {
        _endGame(true);
      }
    });
  }

  void _checkBrickCollisions() {
    double brickOffsetLeft = (canvasWidth - (brickColumns * (brickWidth + brickPadding))) / 2;
    
    for (int c = 0; c < brickColumns; c++) {
      for (int r = 0; r < brickRows; r++) {
        if (!bricks[c][r]) continue;

        double brickX = c * (brickWidth + brickPadding) + brickOffsetLeft;
        double brickY = r * (brickHeight + brickPadding) + brickOffsetTop;

        if (ballX >= brickX &&
            ballX <= brickX + brickWidth &&
            ballY >= brickY &&
            ballY <= brickY + brickHeight) {
          ballDy = -ballDy;
          bricks[c][r] = false;
          score++;
          ballSpeed += 0.05; // Augmenter légèrement la vitesse
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
    int coinsEarned = won ? 20 : (score * 2);
    if (coinsEarned > 0) {
      widget.onCoinsUpdated(coinsEarned);
    }

    // Afficher le résultat
    _showGameResult(won, coinsEarned);
  }

  void _showGameResult(bool won, int coinsEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: Text(
          won ? '🎉 Victoire !' : '💥 Game Over',
          style: const TextStyle(color: Colors.white),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scores
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
              
              // Zone de jeu
              Container(
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
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Instructions
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '← → Utilisez les flèches pour déplacer la raquette',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
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

  BreakoutPainter({
    required this.bricks,
    required this.ballX,
    required this.ballY,
    required this.ballRadius,
    required this.paddleX,
    required this.paddleY,
    required this.paddleWidth,
    required this.paddleHeight,
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
    const double brickWidth = _BreakoutScreenState.brickWidth;
    const double brickHeight = _BreakoutScreenState.brickHeight;
    const double brickPadding = _BreakoutScreenState.brickPadding;
    const double brickOffsetTop = _BreakoutScreenState.brickOffsetTop;
    
    double brickOffsetLeft = (size.width - (_BreakoutScreenState.brickColumns * (brickWidth + brickPadding))) / 2;
    
    final paint = Paint()..color = const Color(0xFFf5f5f5);
    
    for (int c = 0; c < _BreakoutScreenState.brickColumns; c++) {
      for (int r = 0; r < _BreakoutScreenState.brickRows; r++) {
        if (bricks[c][r]) {
          double brickX = c * (brickWidth + brickPadding) + brickOffsetLeft;
          double brickY = r * (brickHeight + brickPadding) + brickOffsetTop;
          
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