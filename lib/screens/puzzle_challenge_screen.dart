import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class PuzzleChallengeScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const PuzzleChallengeScreen({
    Key? key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  }) : super(key: key);

  @override
  State<PuzzleChallengeScreen> createState() => _PuzzleChallengeScreenState();
}

class _PuzzleChallengeScreenState extends State<PuzzleChallengeScreen> {
  List<int> puzzle = [];
  List<int> solution = [1, 2, 3, 4, 5, 6, 7, 8, 0]; // 0 = case vide
  int moves = 0;
  int level = 1;
  bool gameStarted = false;
  DateTime? startTime;
  
  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializePuzzle();
  }

  void _initializePuzzle() {
    // Commencer avec la solution
    puzzle = List.from(solution);
    // Mélanger en faisant des mouvements valides
    _shufflePuzzle();
    setState(() {
      moves = 0;
      gameStarted = false;
    });
  }

  void _shufflePuzzle() {
    // Faire 50 mouvements aléatoires valides pour mélanger
    for (int i = 0; i < 50; i++) {
      List<int> possibleMoves = _getPossibleMoves();
      if (possibleMoves.isNotEmpty) {
        int randomMove = possibleMoves[random.nextInt(possibleMoves.length)];
        _makeMove(randomMove, false); // false = ne pas compter comme move utilisateur
      }
    }
  }

  List<int> _getPossibleMoves() {
    int emptyIndex = puzzle.indexOf(0);
    int row = emptyIndex ~/ 3;
    int col = emptyIndex % 3;
    List<int> possibleMoves = [];

    // Vérifier les 4 directions
    if (row > 0) possibleMoves.add(emptyIndex - 3); // Haut
    if (row < 2) possibleMoves.add(emptyIndex + 3); // Bas
    if (col > 0) possibleMoves.add(emptyIndex - 1); // Gauche
    if (col < 2) possibleMoves.add(emptyIndex + 1); // Droite

    return possibleMoves;
  }

  void _makeMove(int tileIndex, bool countMove) {
    int emptyIndex = puzzle.indexOf(0);
    
    // Vérifier si le mouvement est valide
    if (_getPossibleMoves().contains(tileIndex)) {
      setState(() {
        // Échanger la tuile avec la case vide
        puzzle[emptyIndex] = puzzle[tileIndex];
        puzzle[tileIndex] = 0;
        
        if (countMove) {
          moves++;
          if (!gameStarted) {
            gameStarted = true;
            startTime = DateTime.now();
          }
        }
      });

      // Vérifier si le puzzle est résolu
      if (_isPuzzleSolved()) {
        _onPuzzleSolved();
      }
    }
  }

  bool _isPuzzleSolved() {
    for (int i = 0; i < puzzle.length; i++) {
      if (puzzle[i] != solution[i]) {
        return false;
      }
    }
    return true;
  }

  void _onPuzzleSolved() {
    int timeBonus = 0;
    if (startTime != null) {
      int seconds = DateTime.now().difference(startTime!).inSeconds;
      timeBonus = math.max(0, 60 - seconds); // Bonus si résolu en moins de 60s
    }
    
    int baseCoins = level * 5; // 5 pièces par niveau
    int totalCoins = baseCoins + timeBonus;
    
    widget.onCoinsUpdated(totalCoins);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          '🧩 Puzzle résolu !',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Niveau $level complété !',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Moves: $moves',
              style: const TextStyle(color: Colors.grey),
            ),
            if (timeBonus > 0) ...[
              const SizedBox(height: 5),
              Text(
                'Bonus temps: +$timeBonus sec',
                style: const TextStyle(color: Colors.green),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              '🪙 +$totalCoins pièces gagnées !',
              style: const TextStyle(color: Color(0xFFE91E63), fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextLevel();
            },
            child: const Text(
              'Niveau suivant',
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

  void _nextLevel() {
    setState(() {
      level++;
    });
    _initializePuzzle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text(
          '🧩 Puzzle Challenge',
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
                    '🧩 Remettez les chiffres dans l\'ordre de 1 à 8\n'
                    '👆 Tapez sur une tuile pour la déplacer\n'
                    '⚡ Plus vite vous résolvez, plus vous gagnez !',
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
                        const Text(
                          'Niveau',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '$level',
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
                        const Text(
                          'Moves',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '$moves',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (gameStarted && startTime != null)
                      StreamBuilder<DateTime>(
                        stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            int elapsed = snapshot.data!.difference(startTime!).inSeconds;
                            return Column(
                              children: [
                                const Text(
                                  'Temps',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  '${elapsed}s',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Grille de puzzle
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a1a1a),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        int number = puzzle[index];
                        bool isEmpty = number == 0;
                        bool canMove = !isEmpty && _getPossibleMoves().contains(index);
                        
                        return GestureDetector(
                          onTap: isEmpty ? null : () => _makeMove(index, true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isEmpty 
                                  ? Colors.transparent 
                                  : canMove 
                                      ? const Color(0xFF2a2a2a)
                                      : const Color(0xFF1e1e1e),
                              borderRadius: BorderRadius.circular(10),
                              border: isEmpty ? null : Border.all(
                                color: canMove ? const Color(0xFF444444) : const Color(0xFF333333)
                              ),
                            ),
                            child: isEmpty ? null : Center(
                              child: Text(
                                '$number',
                                style: TextStyle(
                                  color: canMove ? Colors.white : Colors.grey,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bouton nouveau puzzle
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _initializePuzzle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F4F4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '🔄 NOUVEAU PUZZLE',
                  style: TextStyle(
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