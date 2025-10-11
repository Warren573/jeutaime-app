import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ContinueHistoireScreen extends StatefulWidget {
  final int playersCount;
  final int maxRounds;
  final int timePerSentence;
  final Function(int)? onCoinsUpdated;
  final int? currentCoins;
  final bool isBarMode; // pour différencier bar vs match privé
  final String? opponentName; // nom de l'adversaire en mode privé

  const ContinueHistoireScreen({
    Key? key,
    this.playersCount = 2,
    this.maxRounds = 8,
    this.timePerSentence = 30,
    this.onCoinsUpdated,
    this.currentCoins,
    this.isBarMode = false,
    this.opponentName,
  }) : super(key: key);

  @override
  State<ContinueHistoireScreen> createState() => _ContinueHistoireScreenState();
}

class _ContinueHistoireScreenState extends State<ContinueHistoireScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<String> _story = [];
  final ScrollController _scrollController = ScrollController();

  int _currentPlayer = 1;
  int _round = 1;
  bool _gameOver = false;
  bool _canWrite = false;

  int _remainingSeconds = 0;
  Timer? _timer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _romanticPrompts = [
    "Ce soir-là, nos regards se sont croisés et plus rien n'a été pareil...",
    "Dans ce petit café, deux cœurs ont commencé à battre au même rythme.",
    "Sous les étoiles, une conversation a changé le cours de nos vies...",
    "Ce message inattendu a tout bouleversé en quelques mots...",
    "Dans la foule, une main a effleuré la mienne par hasard..."
  ];

  final List<String> _barPrompts = [
    "Ce soir-là, tout a commencé dans un petit bar oublié...",
    "Personne ne se doutait que cette rencontre changerait tout.",
    "Sur la table, deux verres à moitié vides et beaucoup de non-dits.",
    "Le DJ venait de lancer la chanson préférée de tout le monde...",
    "Un orage grondait au loin, comme un présage.",
    "L'ambiance était électrique ce soir-là au bar...",
    "Entre deux rires, quelque chose d'inattendu s'est passé...",
    "Cette soirée entre amis allait prendre une tournure surprenante..."
  ];

  final List<String> _playerNames = [
    "Vous", "Emma", "Lucas", "Sofia", "Nathan", "Chloé", "Dylan", "Léa"
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    final prompts = widget.isBarMode ? _barPrompts : _romanticPrompts;
    _story.add(prompts[Random().nextInt(prompts.length)]);
    _startReadingPhase();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startReadingPhase() {
    final totalTime = _story.length * widget.timePerSentence;
    _remainingSeconds = totalTime;

    // Animation de lecture
    Future.delayed(const Duration(milliseconds: 500), () {
      _scrollToBottom();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!_gameOver) {
        setState(() => _canWrite = true);
        _startTimer();
        _pulseController.repeat(reverse: true);
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _handleTimeout();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _handleTimeout() {
    if (_gameOver) return;
    
    final playerName = _getPlayerName(_currentPlayer);
    setState(() {
      _story.add("💭 $playerName n'a rien écrit à temps... Le silence était éloquent.");
      _nextTurn();
    });
  }

  String _getPlayerName(int playerNumber) {
    if (widget.isBarMode) {
      if (playerNumber == 1) return "Vous";
      return _playerNames[min(playerNumber, _playerNames.length - 1)];
    } else {
      if (playerNumber == 1) return "Vous";
      return widget.opponentName ?? "Votre partenaire";
    }
  }

  void _nextTurn() {
    _controller.clear();
    _timer?.cancel();
    _pulseController.stop();

    if (_round >= widget.maxRounds) {
      _gameOver = true;
      _showEndGameDialog();
      return;
    }

    _currentPlayer = _currentPlayer % widget.playersCount + 1;
    if (_currentPlayer == 1) _round++;

    _canWrite = false;
    _scrollToBottom();
    _startReadingPhase();
  }

  void _submitSentence() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final playerName = _getPlayerName(_currentPlayer);
    setState(() {
      _story.add("✍️ $playerName : $text");
      _nextTurn();
    });
  }

  void _showEndGameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.auto_stories, color: Color(0xFFE91E63)),
            const SizedBox(width: 10),
            Text(
              widget.isBarMode ? '🎭 Histoire terminée !' : '💕 Votre histoire !',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isBarMode 
                  ? 'Bravo ! Vous avez créé une histoire ensemble !'
                  : 'Quelle belle histoire vous avez écrite ensemble ! 💖',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            if (widget.onCoinsUpdated != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on, color: Colors.white),
                    SizedBox(width: 8),
                    Text('+25 pièces pour cette créativité !', 
                         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            child: const Text('📖 Nouvelle histoire', style: TextStyle(color: Color(0xFFE91E63))),
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.onCoinsUpdated != null) {
                widget.onCoinsUpdated!(25); // Bonus créativité
              }
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E63)),
            child: const Text('✨ Terminer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _story.clear();
      final prompts = widget.isBarMode ? _barPrompts : _romanticPrompts;
      _story.add(prompts[Random().nextInt(prompts.length)]);
      _controller.clear();
      _currentPlayer = 1;
      _round = 1;
      _gameOver = false;
      _canWrite = false;
    });
    _startReadingPhase();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final currentPlayerName = _getPlayerName(_currentPlayer);

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        title: Text(
          widget.isBarMode ? '🎭 Continue l\'Histoire' : '💕 Notre Histoire',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1e1e1e),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // En-tête avec informations
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isBarMode 
                      ? [const Color(0xFF9C27B0), const Color(0xFF673AB7)]
                      : [const Color(0xFFE91E63), const Color(0xFFAD1457)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isBarMode 
                            ? '🍻 Joueurs: ${widget.playersCount}'
                            : '👫 Mode couple',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tour $_round/${widget.maxRounds}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  if (!_gameOver && _canWrite) ...[
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _remainingSeconds <= 10 ? Colors.red : Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '⏱️ $minutes:$seconds',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Histoire affichée
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e1e1e),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFE91E63), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_stories, color: Color(0xFFE91E63)),
                        SizedBox(width: 8),
                        Text(
                          'Histoire en cours...',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _story.length,
                        itemBuilder: (context, index) {
                          final sentence = _story[index];
                          final isIntro = index == 0;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isIntro 
                                  ? const Color(0xFFE91E63).withOpacity(0.1)
                                  : const Color(0xFF2a2a2a),
                              borderRadius: BorderRadius.circular(10),
                              border: isIntro 
                                  ? Border.all(color: const Color(0xFFE91E63), width: 1)
                                  : null,
                            ),
                            child: Text(
                              sentence,
                              style: TextStyle(
                                fontSize: 16,
                                color: isIntro ? const Color(0xFFE91E63) : Colors.white,
                                fontStyle: isIntro ? FontStyle.italic : FontStyle.normal,
                                fontWeight: isIntro ? FontWeight.bold : FontWeight.normal,
                                height: 1.4,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Zone de saisie
            if (!_gameOver) ...[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e1e1e),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_canWrite) ...[
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFE91E63),
                            radius: 15,
                            child: Text(
                              _currentPlayer.toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'À $currentPlayerName d\'écrire la suite...',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: widget.isBarMode 
                              ? "Ajoutez votre phrase à l'histoire..."
                              : "Continuez votre histoire d'amour...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF2a2a2a),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2),
                          ),
                        ),
                        onSubmitted: (_) => _submitSentence(),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitSentence,
                          icon: const Icon(Icons.send),
                          label: const Text('Envoyer ma phrase'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFFE91E63),
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Lecture de l\'histoire en cours...',
                            style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.isBarMode 
                        ? [const Color(0xFF9C27B0), const Color(0xFF673AB7)]
                        : [const Color(0xFFE91E63), const Color(0xFFAD1457)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Icon(
                      widget.isBarMode ? Icons.celebration : Icons.favorite,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.isBarMode ? '🎉 Histoire terminée !' : '💕 Votre histoire est finie !',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _restartGame,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Nouvelle histoire'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}