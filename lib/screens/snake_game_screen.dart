import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class SnakeGameScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const SnakeGameScreen({
    super.key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  });

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen>
    with TickerProviderStateMixin {
  static const int gridWidth = 15;
  static const int gridHeight = 20;
  
  List<Position> snake = [Position(7, 10)];
  Position food = Position(7, 5);
  Direction direction = Direction.up;
  Direction nextDirection = Direction.up;
  
  Timer? gameTimer;
  bool gameRunning = false;
  bool gameOver = false;
  int score = 0;
  int highScore = 0;
  int speed = 300; // milliseconds
  
  late AnimationController _eatController;
  late Animation<double> _eatAnimation;
  
  late AnimationController _gameOverController;
  late Animation<double> _gameOverAnimation;

  @override
  void initState() {
    super.initState();
    _eatController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _eatAnimation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(parent: _eatController, curve: Curves.elasticOut)
    );
    
    _gameOverController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _gameOverAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _gameOverController, curve: Curves.easeOut)
    );
    
    _generateFood();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _eatController.dispose();
    _gameOverController.dispose();
    super.dispose();
  }

  void _startGame() {
    if (gameRunning) return;
    
    setState(() {
      gameRunning = true;
      gameOver = false;
      score = 0;
      speed = 300;
      snake = [Position(7, 10)];
      direction = Direction.up;
      nextDirection = Direction.up;
    });
    
    _generateFood();
    
    gameTimer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      _updateGame();
    });
  }

  void _updateGame() {
    if (!gameRunning) return;
    
    direction = nextDirection;
    
    Position newHead = Position(
      snake.first.x + direction.deltaX,
      snake.first.y + direction.deltaY,
    );
    
    // Vérifier les collisions avec les murs
    if (newHead.x < 0 || newHead.x >= gridWidth ||
        newHead.y < 0 || newHead.y >= gridHeight) {
      _endGame();
      return;
    }
    
    // Vérifier les collisions avec le serpent lui-même
    if (snake.contains(newHead)) {
      _endGame();
      return;
    }
    
    setState(() {
      snake.insert(0, newHead);
      
      // Vérifier si le serpent mange la nourriture
      if (newHead.x == food.x && newHead.y == food.y) {
        score += 10;
        _eatController.forward().then((_) => _eatController.reverse());
        _generateFood();
        _increaseSpeed();
      } else {
        snake.removeLast();
      }
    });
  }

  void _generateFood() {
    Random random = Random();
    Position newFood;
    
    do {
      newFood = Position(
        random.nextInt(gridWidth),
        random.nextInt(gridHeight),
      );
    } while (snake.contains(newFood));
    
    setState(() {
      food = newFood;
    });
  }

  void _increaseSpeed() {
    if (speed > 150) {
      speed = (speed * 0.95).round();
      gameTimer?.cancel();
      gameTimer = Timer.periodic(Duration(milliseconds: speed), (timer) {
        _updateGame();
      });
    }
  }

  void _endGame() {
    gameTimer?.cancel();
    setState(() {
      gameRunning = false;
      gameOver = true;
      if (score > highScore) {
        highScore = score;
      }
    });
    
    _gameOverController.forward();
    
    // Récompenses basées sur le score
    int reward = (score / 10).round();
    if (reward > 0) {
      widget.onCoinsUpdated(reward);
    }
    
    _showGameOverDialog(reward);
  }

  void _showGameOverDialog(int reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('🐍 Game Over!', 
          style: TextStyle(color: Colors.white, fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Le serpent s\'est cogné !',
              style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Text('🏆 Score: $score',
              style: const TextStyle(color: Colors.white, fontSize: 18)),
            Text('👑 Meilleur: $highScore',
              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16)),
            if (reward > 0) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('🪙 +$reward pièces!',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _gameOverController.reset();
              _startGame();
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

  void _changeDirection(Direction newDirection) {
    // Empêcher de faire demi-tour
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    
    nextDirection = newDirection;
  }

  Widget _buildCell(int x, int y) {
    bool isSnakeHead = snake.isNotEmpty && snake.first.x == x && snake.first.y == y;
    bool isSnakeBody = snake.skip(1).any((pos) => pos.x == x && pos.y == y);
    bool isFood = food.x == x && food.y == y;
    
    Color cellColor = const Color(0xFF2E2E2E);
    Widget content = Container();
    
    if (isFood) {
      cellColor = const Color(0xFFFF5722);
      content = AnimatedBuilder(
        animation: _eatAnimation,
        builder: (context, child) => Transform.scale(
          scale: _eatAnimation.value,
          child: const Text('🍎', style: TextStyle(fontSize: 16)),
        ),
      );
    } else if (isSnakeHead) {
      cellColor = const Color(0xFF4CAF50);
      content = const Text('🐍', style: TextStyle(fontSize: 16));
    } else if (isSnakeBody) {
      cellColor = const Color(0xFF66BB6A);
    }
    
    return Container(
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Center(child: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('🐍 Snake Game', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Score bar
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1a1a1a),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('🏆 $score', 
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Score', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Text('👑 $highScore', 
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16)),
                    const Text('Meilleur', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Text('🐍 ${snake.length}', 
                      style: const TextStyle(color: Colors.green, fontSize: 16)),
                    const Text('Taille', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          
          // Zone de jeu
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridWidth,
                ),
                itemCount: gridWidth * gridHeight,
                itemBuilder: (context, index) {
                  int x = index % gridWidth;
                  int y = index ~/ gridWidth;
                  return _buildCell(x, y);
                },
              ),
            ),
          ),
          
          // Contrôles
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (!gameRunning && !gameOver)
                  ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('🚀 Commencer', 
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                
                const SizedBox(height: 20),
                
                // D-pad
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => _changeDirection(Direction.up),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(Icons.keyboard_arrow_up, 
                          color: Colors.white, size: 30),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _changeDirection(Direction.left),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(Icons.keyboard_arrow_left, 
                              color: Colors.white, size: 30),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => _changeDirection(Direction.right),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(Icons.keyboard_arrow_right, 
                              color: Colors.white, size: 30),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _changeDirection(Direction.down),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(Icons.keyboard_arrow_down, 
                          color: Colors.white, size: 30),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Position {
  final int x;
  final int y;

  Position(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

enum Direction {
  up(0, -1),
  down(0, 1),
  left(-1, 0),
  right(1, 0);

  const Direction(this.deltaX, this.deltaY);

  final int deltaX;
  final int deltaY;
}