import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';

enum GameMode { local, online }

class TicTacToeScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const TicTacToeScreen({
    Key? key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  }) : super(key: key);

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  // État du jeu
  List<List<String>> board = [
    ["", "", ""],
    ["", "", ""],
    ["", "", ""]
  ];
  
  bool player1Turn = true; // true = joueur 1, false = joueur 2
  String currentPlayerSymbol = "X";
  String player1Symbol = "X";
  String player2Symbol = "O";
  
  // Scores
  int player1Wins = 0;
  int draws = 0;
  int player2Wins = 0;
  
  // Mode de jeu
  GameMode gameMode = GameMode.local;
  bool gameActive = true;
  
  // Multiplayer
  String? roomCode;
  String? playerId;
  bool isHost = false;
  bool waitingForPlayer = false;
  String opponentName = "Adversaire";
  Timer? connectionTimer;

  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    playerId = 'player_${DateTime.now().millisecondsSinceEpoch}';
    startGame();
  }

  @override
  void dispose() {
    connectionTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    setState(() {
      board = [
        ["", "", ""],
        ["", "", ""],
        ["", "", ""]
      ];
      player1Turn = true;
      currentPlayerSymbol = player1Symbol;
      gameActive = true;
    });
  }

  void playerMove(int row, int col) {
    if (!gameActive || board[row][col] != "") return;
    
    // Déterminer le symbole à utiliser selon le mode et le joueur
    String symbolToUse;
    if (gameMode == GameMode.local) {
      symbolToUse = currentPlayerSymbol;
    } else {
      // Mode online - plus simple : toujours permettre de jouer, l'IA se débrouillera
      symbolToUse = isHost ? player1Symbol : player2Symbol;
    }
    
    setState(() {
      board[row][col] = symbolToUse;
    });

    // Vérifier la victoire
    if (checkWinner(symbolToUse)) {
      String winner = "";
      if (gameMode == GameMode.local) {
        winner = player1Turn ? "Joueur 1 (X) a gagné !" : "Joueur 2 (O) a gagné !";
      } else {
        winner = "Tu as gagné !";
      }
      endGame(winner, true);
      return;
    } 
    
    if (checkDraw()) {
      endGame("Match nul !", false);
      return;
    }

    // Gérer le tour suivant selon le mode
    if (gameMode == GameMode.local) {
      // Alterner entre les joueurs locaux
      setState(() {
        player1Turn = !player1Turn;
        currentPlayerSymbol = player1Turn ? player1Symbol : player2Symbol;
      });
    } else {
      // Mode online - envoyer le mouvement à l'adversaire (simplifié)
      sendMoveToOpponent(row, col);
    }
  }



  bool checkWinner(String symbol) {
    // Vérification des lignes
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == symbol && board[i][1] == symbol && board[i][2] == symbol) {
        return true;
      }
    }
    
    // Vérification des colonnes
    for (int j = 0; j < 3; j++) {
      if (board[0][j] == symbol && board[1][j] == symbol && board[2][j] == symbol) {
        return true;
      }
    }
    
    // Vérification des diagonales
    if (board[0][0] == symbol && board[1][1] == symbol && board[2][2] == symbol) {
      return true;
    }
    if (board[0][2] == symbol && board[1][1] == symbol && board[2][0] == symbol) {
      return true;
    }
    
    return false;
  }

  bool checkDraw() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == "") {
          return false;
        }
      }
    }
    return true;
  }

  void endGame(String message, bool playerWon) {
    setState(() {
      gameActive = false;
      if (playerWon) {
        player1Wins++;
      } else if (message.contains("bot") || message.contains("Joueur 2")) {
        player2Wins++;
      } else {
        draws++;
      }
    });

    // Calculer les pièces gagnées
    int coinsEarned = 0;
    if (playerWon) {
      coinsEarned = gameMode == GameMode.local ? 5 : 15;
    } else if (message.contains("nul")) {
      coinsEarned = 2; // Pièces pour match nul
    }

    if (coinsEarned > 0) {
      widget.onCoinsUpdated(coinsEarned);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: Text(
          '🎮 $message',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Partie terminée !',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (coinsEarned > 0) ...[
              const SizedBox(height: 10),
              Text(
                '🪙 +$coinsEarned pièces gagnées !',
                style: const TextStyle(color: Color(0xFFE91E63), fontSize: 16),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame();
            },
            child: const Text(
              'Nouvelle partie',
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

  void switchGameMode() {
    setState(() {
      gameMode = gameMode == GameMode.local ? GameMode.online : GameMode.local;
      player1Symbol = "X";
      player2Symbol = "O";
      currentPlayerSymbol = player1Symbol;
      roomCode = null;
      waitingForPlayer = false;
    });
    startGame();
  }

  // Fonctions multijoueur simulées
  void createRoom() {
    setState(() {
      roomCode = 'ROOM${random.nextInt(9999).toString().padLeft(4, '0')}';
      isHost = true;
      player1Symbol = "X";
      player2Symbol = "O";
      currentPlayerSymbol = player1Symbol;
      player1Turn = true;
      waitingForPlayer = true;
    });
    
    // Simuler l'attente d'un joueur
    connectionTimer = Timer(Duration(seconds: 3 + random.nextInt(5)), () {
      if (waitingForPlayer) {
        setState(() {
          waitingForPlayer = false;
          opponentName = "Joueur${random.nextInt(999)}";
          gameActive = true;
        });
        showSnackBar("$opponentName a rejoint la partie ! Vous commencez (X).");
      }
    });
  }

  void joinRoom(String code) {
    setState(() {
      roomCode = code;
      isHost = false;
      player1Symbol = "X"; // Hôte
      player2Symbol = "O"; // Vous
      currentPlayerSymbol = player1Symbol;
      waitingForPlayer = false;
      opponentName = "Hôte";
      gameActive = true;
      player1Turn = false; // L'hôte commence
    });
    showSnackBar("Partie rejointe ! L'hôte commence (X).");
  }

  void sendMoveToOpponent(int row, int col) {
    // Simuler l'envoi et la réception du mouvement adverse
    Timer(Duration(milliseconds: 1000 + random.nextInt(2000)), () {
      if (gameActive) {
        receiveOpponentMove();
      }
    });
  }

  void receiveOpponentMove() {
    if (!gameActive) return;
    
    // Trouver une case vide pour simuler le mouvement adverse (avec stratégie simple)
    List<Map<String, int>> emptyCells = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == "") {
          emptyCells.add({'row': i, 'col': j});
        }
      }
    }
    
    if (emptyCells.isNotEmpty) {
      // Stratégie simple : d'abord essayer de gagner, puis bloquer, sinon aléatoire
      String opponentSymbol = isHost ? player2Symbol : player1Symbol;
      String mySymbol = isHost ? player1Symbol : player2Symbol;
      
      Map<String, int>? bestMove;
      
      // Essayer de gagner
      for (var move in emptyCells) {
        board[move['row']!][move['col']!] = opponentSymbol;
        if (checkWinner(opponentSymbol)) {
          bestMove = move;
          board[move['row']!][move['col']!] = "";
          break;
        }
        board[move['row']!][move['col']!] = "";
      }
      
      // Si pas de coup gagnant, essayer de bloquer
      if (bestMove == null) {
        for (var move in emptyCells) {
          board[move['row']!][move['col']!] = mySymbol;
          if (checkWinner(mySymbol)) {
            bestMove = move;
            board[move['row']!][move['col']!] = "";
            break;
          }
          board[move['row']!][move['col']!] = "";
        }
      }
      
      // Sinon coup aléatoire
      bestMove ??= emptyCells[random.nextInt(emptyCells.length)];
      
      setState(() {
        board[bestMove!['row']!][bestMove['col']!] = opponentSymbol;
      });
      
      if (checkWinner(opponentSymbol)) {
        endGame("$opponentName a gagné !", false);
      } else if (checkDraw()) {
        endGame("Match nul !", false);
      }
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2a2a2a),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('Multijoueur en ligne', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                createRoom();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F4F4F),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('🏠 Créer une salle', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                showJoinDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF333333),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('🚪 Rejoindre une salle', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void showJoinDialog() {
    TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('Rejoindre une salle', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Code de la salle (ex: ROOM1234)',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE91E63)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (codeController.text.isNotEmpty) {
                Navigator.of(context).pop();
                joinRoom(codeController.text.toUpperCase());
              }
            },
            child: const Text('Rejoindre', style: TextStyle(color: Color(0xFFE91E63))),
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
          '⭕ Morpion',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              gameMode == GameMode.local ? Icons.people : Icons.wifi,
              color: Colors.white,
            ),
            onPressed: switchGameMode,
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions et mode de jeu
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e1e1e),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        gameMode == GameMode.local ? '👥 Mode: 2 Joueurs Local' :
                        '🌐 Mode: Multijoueur en ligne',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        gameMode == GameMode.local
                            ? 'X et O alternent - jouez à tour de rôle'
                            : roomCode != null 
                            ? 'Salle: $roomCode'
                            : 'Créez ou rejoignez une salle',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (gameActive && roomCode != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Vous jouez ${isHost ? player1Symbol : player2Symbol} - $opponentName joue ${isHost ? player2Symbol : player1Symbol}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else if (gameActive && gameMode == GameMode.local)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Tour du joueur $currentPlayerSymbol',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (waitingForPlayer)
                        const Text(
                          'En attente d\'un adversaire...',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                        )
                      else if (gameMode == GameMode.online && roomCode == null)
                        ElevatedButton(
                          onPressed: showRoomDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F4F4F),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: const Text('🎮 Commencer une partie', style: TextStyle(color: Colors.white)),
                        )
                      else
                        Text(
                          gameMode == GameMode.online
                              ? (player1Turn ? 'Votre tour' : 'Tour de $opponentName')
                              : 'Tour de $currentPlayerSymbol',
                          style: TextStyle(
                            color: player1Turn ? const Color(0xFFE91E63) : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                // Scores
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          gameMode == GameMode.local ? 'Joueur X' : 'Vous',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '$player1Wins',
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
                        const Text('Matchs nuls', style: TextStyle(color: Colors.grey)),
                        Text(
                          '$draws',
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
                        Text(
                          gameMode == GameMode.local ? 'Joueur O' : opponentName,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '$player2Wins',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
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

          // Grille de Morpion
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF101010),
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
                        int row = index ~/ 3;
                        int col = index % 3;
                        String symbol = board[row][col];
                        
                        return GestureDetector(
                          onTap: () => playerMove(row, col),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1a1a1a),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF333333)),
                            ),
                            child: Center(
                              child: Text(
                                symbol,
                                style: TextStyle(
                                  color: symbol == "X" 
                                      ? const Color(0xFFE91E63) 
                                      : Colors.orange,
                                  fontSize: 48,
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

          // Boutons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Bouton changer de mode
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: switchGameMode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      gameMode == GameMode.local ? '🌐 Mode En ligne' :
                      '👥 Mode Local',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Bouton nouvelle partie
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4F4F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      '🔄 NOUVELLE PARTIE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}