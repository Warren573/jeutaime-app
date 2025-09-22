import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoveRouletteScreen extends StatefulWidget {
  @override
  _LoveRouletteScreenState createState() => _LoveRouletteScreenState();
}

class _LoveRouletteScreenState extends State<LoveRouletteScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isSpinning = false;
  String _result = '';

  final List<String> _options = [
    'Compliment sincère',
    'Question mystère',
    'Défi amusant',
    'Confidence',
    'Souvenir d\'enfance',
    'Rêve secret',
    'Talent caché',
    'Peur rigolote',
  ];

  final List<Color> _colors = [
    Colors.red, Colors.pink, Colors.purple, Colors.blue,
    Colors.green, Colors.orange, Colors.amber, Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade900,
      appBar: AppBar(
        title: Text('Roulette de l\'Amour', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Roulette
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _animation.value * 4 * math.pi,
                          child: CustomPaint(
                            size: Size(300, 300),
                            painter: RoulettePainter(_options, _colors),
                          ),
                        );
                      },
                    ),
                    // Flèche centrale
                    Container(
                      width: 20,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Résultat
          if (_result.isNotEmpty)
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '🎯 Ton défi :',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _result,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          
          // Bouton spin
          Container(
            margin: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _isSpinning ? null : _spinRoulette,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: Text(
                  _isSpinning ? 'En cours...' : 'Faire tourner !',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _spinRoulette() {
    setState(() {
      _isSpinning = true;
      _result = '';
    });

    _controller.forward().then((_) {
      setState(() {
        _isSpinning = false;
        _result = _options[math.Random().nextInt(_options.length)];
      });
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class RoulettePainter extends CustomPainter {
  final List<String> options;
  final List<Color> colors;

  RoulettePainter(this.options, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sectionAngle = 2 * math.pi / options.length;

    for (int i = 0; i < options.length; i++) {
      final paint = Paint()..color = colors[i];
      final startAngle = i * sectionAngle;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Dessiner le texte
      final textPainter = TextPainter(
        text: TextSpan(
          text: options[i],
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textAngle = startAngle + sectionAngle / 2;
      final textRadius = radius * 0.7;
      final textOffset = Offset(
        center.dx + math.cos(textAngle) * textRadius - textPainter.width / 2,
        center.dy + math.sin(textAngle) * textRadius - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
