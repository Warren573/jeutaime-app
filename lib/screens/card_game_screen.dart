import 'dart:math';
import 'package:flutter/material.dart';

enum Suit { heart, diamond, club, spade }

class GameCard {
  final Suit suit;
  bool revealed;
  GameCard({required this.suit, this.revealed = false});
}

class CardGameScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  /// Paramètres configurables (faciles à adapter)
  final int totalCards;
  final int heartsCount;
  final int diamondsCount;
  final int clubsCount;
  final int spadesCount;

  /// Règles monétaires (modifiable si tu veux d'autres valeurs)
  final int costPerGame; // coût de la partie
  final int rewardPerHeart; // gain par cœur

  const CardGameScreen({
    Key? key,
    required this.onCoinsUpdated,
    required this.currentCoins,
    this.totalCards = 10,
    this.heartsCount = 3,
    this.diamondsCount = 3,
    this.clubsCount = 2,
    this.spadesCount = 2,
    this.costPerGame = 20,
    this.rewardPerHeart = 15,
  }) : assert(heartsCount + diamondsCount + clubsCount + spadesCount == totalCards,
            'La somme des cartes par couleur doit être égale à totalCards'),
        super(key: key);

  @override
  State<CardGameScreen> createState() => _CardGameScreenState();
}

class _CardGameScreenState extends State<CardGameScreen>
    with SingleTickerProviderStateMixin {
  late List<GameCard> _deck;
  int _currentGain = 0; // gains accumulés pendant la partie (avant encaissement)
  bool _gameOver = false;
  String _message = '';
  int _flips = 0;
  int _heartsFound = 0;
  bool _gameStarted = false;
  
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _initializeGame();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    _deck = _generateShuffledDeck();
    _currentGain = 0;
    _gameOver = false;
    _gameStarted = false;
    _message = 'Prêt à jouer ? Coût de la partie : ${widget.costPerGame} pièces';
    _flips = 0;
    _heartsFound = 0;
    setState(() {});
  }

  void _startNewGame() {
    if (widget.currentCoins < widget.costPerGame) {
      _showMessage('Pas assez de pièces pour jouer !');
      return;
    }

    setState(() {
      _gameStarted = true;
      _deck = _generateShuffledDeck();
      _currentGain = 0;
      _gameOver = false;
      _message = 'Partie lancée — coût : -${widget.costPerGame} pièces';
      _flips = 0;
      _heartsFound = 0;
    });

    // Prélever le coût de la partie
    widget.onCoinsUpdated(-widget.costPerGame);
  }

  List<GameCard> _generateShuffledDeck() {
    final list = <GameCard>[];
    list.addAll(List.generate(widget.heartsCount, (_) => GameCard(suit: Suit.heart)));
    list.addAll(List.generate(widget.diamondsCount, (_) => GameCard(suit: Suit.diamond)));
    list.addAll(List.generate(widget.clubsCount, (_) => GameCard(suit: Suit.club)));
    list.addAll(List.generate(widget.spadesCount, (_) => GameCard(suit: Suit.spade)));
    list.shuffle(Random());
    return list;
  }

  void _revealCard(int index) {
    if (_gameOver || !_gameStarted) return;
    final card = _deck[index];
    if (card.revealed) return;

    _flipController.forward().then((_) {
      setState(() {
        card.revealed = true;
        _flips += 1;
        
        switch (card.suit) {
          case Suit.heart:
            _currentGain += widget.rewardPerHeart;
            _heartsFound += 1;
            _message = 'Tu as trouvé un ❤️ ! +${widget.rewardPerHeart} pièces.';
            // Vérifier si tous les cœurs ont été trouvés = VICTOIRE !
            if (_heartsFound == widget.heartsCount) {
              _message += '\n🎉 VICTOIRE ! Tous les cœurs trouvés ! Tu peux encaisser tes gains !';
              _gameOver = true;
            }
            break;
          case Suit.diamond:
            _message = '💎 Indice :';
            final remainingCounts = _countRemainingUnrevealed();
            _message += ' ❤️:${remainingCounts[Suit.heart]}, 💎:${remainingCounts[Suit.diamond]}, ♣️:${remainingCounts[Suit.club]}, ♠️:${remainingCounts[Suit.spade]}';
            break;
          case Suit.club:
            final before = _currentGain;
            _currentGain = (_currentGain / 2).floor();
            _message = '♣️ Trèfle : tes gains passent de $before à $_currentGain (divisé par 2).';
            break;
          case Suit.spade:
            _currentGain = 0;
            _message = '♠️ Pique : tu perds tous tes gains ! Mais la partie continue... 💥';
            // PAS DE _gameOver = true; ici ! La partie continue
            break;
        }

        // Si on a retourné toutes les cartes SANS avoir trouvé tous les cœurs = DÉFAITE
        if (_deck.every((c) => c.revealed) && _heartsFound < widget.heartsCount) {
          _gameOver = true;
          _message += '\n💔 DÉFAITE ! Tu n\'as pas trouvé tous les cœurs...';
        }
      });

      _flipController.reset();
    });
  }

  Map<Suit, int> _countRemainingUnrevealed() {
    final map = {
      Suit.heart: 0,
      Suit.diamond: 0,
      Suit.club: 0,
      Suit.spade: 0
    };
    for (final c in _deck) {
      if (!c.revealed) {
        map[c.suit] = map[c.suit]! + 1;
      }
    }
    return map;
  }

  void _cashOut() {
    if (_currentGain <= 0) {
      _showMessage('Aucun gain à encaisser.');
      return;
    }

    widget.onCoinsUpdated(_currentGain);
    
    setState(() {
      _message = '💰 Encaissement effectué : $_currentGain pièces !';
      _currentGain = 0;
      _gameOver = true;
    });

    _showMessage('Bravo ! +$_currentGain pièces ajoutées !');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE91E63),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildCardButton(int index, GameCard card) {
    final revealed = card.revealed;

    return GestureDetector(
      onTap: () => _revealCard(index),
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            child: Container(
              margin: const EdgeInsets.all(4),
              width: 65,
              height: 95,
              decoration: BoxDecoration(
                color: revealed 
                    ? _suitColor(card.suit).withOpacity(0.15)
                    : const Color(0xFF2a2a2a),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: revealed ? _suitColor(card.suit) : Colors.grey.shade700,
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
                child: revealed
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _suitIcon(card.suit, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            _suitLabel(card.suit),
                            style: TextStyle(
                              fontSize: 10,
                              color: _suitColor(card.suit),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Icon(
                        Icons.help_outline,
                        size: 32,
                        color: Colors.white60,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _suitColor(Suit s) {
    switch (s) {
      case Suit.heart:
        return const Color(0xFFE91E63);
      case Suit.diamond:
        return const Color(0xFF2196F3);
      case Suit.club:
        return const Color(0xFF4CAF50);
      case Suit.spade:
        return Colors.white;
    }
  }

  Widget _suitIcon(Suit s, {double size = 20}) {
    switch (s) {
      case Suit.heart:
        return Icon(Icons.favorite, color: _suitColor(s), size: size);
      case Suit.diamond:
        return Icon(Icons.diamond, color: _suitColor(s), size: size);
      case Suit.club:
        return Icon(Icons.grass, color: _suitColor(s), size: size);
      case Suit.spade:
        return Icon(Icons.change_history, color: _suitColor(s), size: size);
    }
  }

  String _suitLabel(Suit s) {
    switch (s) {
      case Suit.heart:
        return 'Cœur';
      case Suit.diamond:
        return 'Carreau';
      case Suit.club:
        return 'Trèfle';
      case Suit.spade:
        return 'Pique';
    }
  }

  @override
  Widget build(BuildContext context) {
    final net = _currentGain - (_gameStarted ? widget.costPerGame : 0);

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        title: const Text('🎴 Jeu de Cartes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1e1e1e),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header avec stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Solde: ${widget.currentCoins} 🪙',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Coût: ${widget.costPerGame} 🪙',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Gains: $_currentGain 🪙',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Net: $net 🪙',
                            style: TextStyle(
                              color: net >= 0 ? Colors.greenAccent : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _gameStarted ? null : _startNewGame,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Nouvelle Partie'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: (_gameOver && _currentGain > 0 && _heartsFound == widget.heartsCount) ? _cashOut : null,
                        icon: const Icon(Icons.savings),
                        label: const Text('Encaisser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _heartsFound == widget.heartsCount ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Zone de jeu
            if (_gameStarted) ...[
              // Grille de cartes
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e1e1e),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFE91E63), width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Retournez les cartes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        _deck.length,
                        (i) => _buildCardButton(i, _deck[i]),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a2a),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 15),

              // Statistiques
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Cartes retournées', '$_flips/${widget.totalCards}'),
                  _buildStatCard('Cœurs trouvés', '$_heartsFound/${widget.heartsCount}'),
                ],
              ),
            ] else ...[
              // Instructions de jeu
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e1e1e),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFE91E63),
                      size: 48,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Comment jouer ?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'But : Trouvez TOUS les cœurs pour gagner !\nLe pique fait perdre les gains mais la partie continue.',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildRuleCard('❤️ Cœur', '+${widget.rewardPerHeart} pièces', Colors.red),
                    _buildRuleCard('💎 Carreau', 'Donne un indice', Colors.blue),
                    _buildRuleCard('♣️ Trèfle', 'Divise vos gains par 2', Colors.green),
                    _buildRuleCard('♠️ Pique', 'Perd les gains mais continue', Colors.white),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE91E63), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFE91E63),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(String icon, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              description,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}