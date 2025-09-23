import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MiniGameJokeOrTruth extends StatefulWidget {
  const MiniGameJokeOrTruth({Key? key}) : super(key: key);

  @override
  State<MiniGameJokeOrTruth> createState() => _MiniGameJokeOrTruthState();
}

class _MiniGameJokeOrTruthState extends State<MiniGameJokeOrTruth> {
  final List<Map<String, String>> _questions = [
    {
      'type': 'joke',
      'prompt': 'Raconte une blague qui te fait rire à chaque fois.'
    },
    {
      'type': 'truth',
      'prompt': 'Avoue un truc drôle que personne ne sait sur toi.'
    },
    {
      'type': 'joke',
      'prompt': 'Fais une imitation d’une star (en vocal ou texte).'
    },
    {
      'type': 'truth',
      'prompt': 'Quelle est ta honte la plus rigolote en public ?'
    },
    {
      'type': 'joke',
      'prompt': 'Place le mot “camembert” dans une phrase sérieuse.'
    },
    {
      'type': 'truth',
      'prompt': 'As-tu déjà ri dans une situation inappropriée ? Raconte.'
    },
    {
      'type': 'joke',
      'prompt': 'Fais une devinette sur les app de rencontres.'
    },
    {
      'type': 'truth',
      'prompt': 'Le message le plus gênant que tu aies jamais envoyé ?'
    },
  ];

  int _currentIndex = 0;
  bool _showResponseField = false;
  final _controller = TextEditingController();
  final List<String> _responses = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    setState(() {
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _showResponseField = false;
      _controller.clear();
    });
  }

  void _saveResponse() {
    setState(() {
      _responses.add(_controller.text.trim());
      _showResponseField = false;
      _controller.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Réponse sauvegardée !'), backgroundColor: AppColors.humorBar),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentIndex];
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.casino, color: AppColors.humorBar),
            SizedBox(width: 8),
            Text('Blague ou Vérité', style: TextStyle(color: AppColors.humorBar)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              current['type'] == 'joke' ? '😆 Blague' : '🙊 Vérité',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.humorBar,
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  current['prompt']!,
                  style: TextStyle(fontSize: 20, color: Colors.grey[800]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 30),
            if (_showResponseField)
              Column(
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Ta réponse ici...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _saveResponse,
                        icon: Icon(Icons.save),
                        label: Text('Sauvegarder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.humorBar,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 14),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _showResponseField = false);
                        },
                        icon: Icon(Icons.close),
                        label: Text('Annuler'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.humorBar),
                        ),
                      )
                    ],
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _showResponseField = true);
                },
                icon: Icon(Icons.edit, color: Colors.white),
                label: Text('Répondre', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.humorBar,
                  minimumSize: Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            SizedBox(height: 30),
            OutlinedButton.icon(
              onPressed: _nextQuestion,
              icon: Icon(Icons.arrow_forward, color: AppColors.humorBar),
              label: Text('Question Suivante', style: TextStyle(color: AppColors.humorBar)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.humorBar),
              ),
            )
          ],
        ),
      ),
    );
  }
}
