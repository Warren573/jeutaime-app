import 'package:flutter/material.dart';
import 'dart:math';

class QuizGameScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const QuizGameScreen({
    super.key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  });

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen>
    with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  int correctAnswers = 0;
  bool quizCompleted = false;
  List<int> shuffledIndices = [];
  
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;
  
  late AnimationController _correctController;
  late Animation<double> _correctAnimation;

  final List<QuizQuestion> questions = [
    QuizQuestion(
      question: "Quel geste montre le mieux l'amour au quotidien ?",
      options: ["Des cadeaux coûteux", "De l'attention sincère", "Des sorties luxueuses", "Des compliments physiques"],
      correctIndex: 1,
      explanation: "L'attention sincère crée une vraie connexion émotionnelle ❤️"
    ),
    QuizQuestion(
      question: "Qu'est-ce qui compte le plus dans une relation ?",
      options: ["L'attraction physique", "La communication", "L'argent", "Les loisirs communs"],
      correctIndex: 1,
      explanation: "La communication est la base de toute relation durable 💬"
    ),
    QuizQuestion(
      question: "Comment résoudre un conflit de couple ?",
      options: ["Éviter le sujet", "Écouter et comprendre", "Avoir raison à tout prix", "Bouder"],
      correctIndex: 1,
      explanation: "L'écoute active permet de vraiment se comprendre 👂"
    ),
    QuizQuestion(
      question: "Quelle est la meilleure surprise romantique ?",
      options: ["Un voyage surprise", "Un moment d'intimité partagé", "Un bijou précieux", "Un dîner au restaurant"],
      correctIndex: 1,
      explanation: "Les moments intimes et personnels sont les plus mémorables 🌟"
    ),
    QuizQuestion(
      question: "Comment maintenir la passion dans une relation ?",
      options: ["Changer de partenaire", "Cultiver la nouveauté ensemble", "Se voir moins souvent", "Éviter les discussions"],
      correctIndex: 1,
      explanation: "Découvrir de nouvelles expériences ensemble renforce les liens 🌈"
    ),
    QuizQuestion(
      question: "Qu'est-ce qui rend une relation épanouissante ?",
      options: ["La perfection", "L'acceptation mutuelle", "La compétition", "L'indépendance totale"],
      correctIndex: 1,
      explanation: "S'accepter mutuellement avec ses défauts crée l'harmonie 💕"
    ),
    QuizQuestion(
      question: "Le secret d'un couple qui dure ?",
      options: ["Ne jamais se disputer", "Grandir ensemble", "Rester identiques", "Éviter les changements"],
      correctIndex: 1,
      explanation: "Évoluer ensemble tout en gardant sa complicité 🌱"
    ),
    QuizQuestion(
      question: "Comment exprimer son amour au mieux ?",
      options: ["Par des mots uniquement", "Par des actes concrets", "Par des cadeaux", "Par les réseaux sociaux"],
      correctIndex: 1,
      explanation: "Les actes valent mille mots en amour 💫"
    ),
    QuizQuestion(
      question: "Qu'est-ce qui tue l'amour dans un couple ?",
      options: ["La routine", "Le manque de respect", "Les différences", "Le temps"],
      correctIndex: 1,
      explanation: "Le respect mutuel est fondamental, sans lui rien ne peut durer 🛡️"
    ),
    QuizQuestion(
      question: "La clé du bonheur à deux ?",
      options: ["Être toujours d'accord", "Se compléter mutuellement", "Être identiques", "Ne jamais changer"],
      correctIndex: 1,
      explanation: "Se compléter permet de créer un équilibre parfait ⚖️"
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut)
    );
    
    _correctController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _correctAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _correctController, curve: Curves.elasticOut)
    );
    
    _initializeQuiz();
  }

  @override
  void dispose() {
    _cardController.dispose();
    _correctController.dispose();
    super.dispose();
  }

  void _initializeQuiz() {
    // Mélanger les questions
    shuffledIndices = List.generate(questions.length, (index) => index);
    shuffledIndices.shuffle(Random());
    
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      correctAnswers = 0;
      quizCompleted = false;
    });
    
    _cardController.forward();
  }

  void _answerQuestion(int selectedIndex) {
    QuizQuestion currentQuestion = questions[shuffledIndices[currentQuestionIndex]];
    bool isCorrect = selectedIndex == currentQuestion.correctIndex;
    
    if (isCorrect) {
      correctAnswers++;
      score += 20;
      _correctController.forward().then((_) => _correctController.reverse());
    }
    
    _showAnswerDialog(isCorrect, currentQuestion.explanation);
  }

  void _showAnswerDialog(bool isCorrect, String explanation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: Text(
          isCorrect ? '✅ Correct!' : '❌ Pas tout à fait...',
          style: TextStyle(
            color: isCorrect ? Colors.green : Colors.red,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              explanation,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (isCorrect) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🪙 +20 points!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextQuestion();
            },
            child: const Text('Continuer', style: TextStyle(color: Color(0xFFE91E63))),
          ),
        ],
      ),
    );
  }

  void _nextQuestion() {
    if (currentQuestionIndex < shuffledIndices.length - 1) {
      _cardController.reverse().then((_) {
        setState(() {
          currentQuestionIndex++;
        });
        _cardController.forward();
      });
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    setState(() {
      quizCompleted = true;
    });
    
    // Calculer les récompenses
    int percentage = ((correctAnswers / questions.length) * 100).round();
    int coinReward = (score * 0.1).round();
    
    if (coinReward > 0) {
      widget.onCoinsUpdated(coinReward);
    }
    
    _showResultDialog(percentage, coinReward);
  }

  void _showResultDialog(int percentage, int coinReward) {
    String message;
    String emoji;
    
    if (percentage >= 80) {
      message = "Expert en amour ! 💕 Vous connaissez vraiment les secrets des relations épanouies.";
      emoji = "🏆";
    } else if (percentage >= 60) {
      message = "Très bien ! 😊 Vous avez de bonnes bases pour une relation harmonieuse.";
      emoji = "🌟";
    } else if (percentage >= 40) {
      message = "Pas mal ! 🤔 Vous apprenez encore sur l'art d'aimer.";
      emoji = "📚";
    } else {
      message = "Continuez à explorer ! 💪 L'amour s'apprend avec l'expérience.";
      emoji = "🌱";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: Text('$emoji Quiz Terminé!', 
          style: const TextStyle(color: Colors.white, fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('✅ $correctAnswers/${questions.length} bonnes réponses',
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                  Text('📊 Score: $percentage%',
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                  if (coinReward > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('🪙 +$coinReward pièces gagnées!',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeQuiz();
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

  @override
  Widget build(BuildContext context) {
    if (quizCompleted) {
      return Scaffold(
        backgroundColor: const Color(0xFF0a0a0a),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1a1a1a),
          title: const Text('💕 Quiz de Couple', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFE91E63)),
        ),
      );
    }

    QuizQuestion currentQuestion = questions[shuffledIndices[currentQuestionIndex]];

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('💕 Quiz de Couple', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1a1a1a),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Question ${currentQuestionIndex + 1}/${questions.length}',
                      style: const TextStyle(color: Colors.grey)),
                    Text('💎 Score: $score',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _cardAnimation.value,
                  child: Opacity(
                    opacity: _cardAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Question card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Text(
                            currentQuestion.question,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Options
                        ...currentQuestion.options.asMap().entries.map((entry) {
                          int index = entry.key;
                          String option = entry.value;
                          
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 15),
                            child: ElevatedButton(
                              onPressed: () => _answerQuestion(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E2E2E),
                                padding: const EdgeInsets.all(20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                ),
                              ),
                              child: AnimatedBuilder(
                                animation: _correctAnimation,
                                builder: (context, child) => Transform.scale(
                                  scale: _correctAnimation.value,
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
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

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}