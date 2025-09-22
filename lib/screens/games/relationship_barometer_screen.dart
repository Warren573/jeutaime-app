import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class RelationshipBarometerScreen extends StatefulWidget {
  final String partnerId;
  final String partnerName;

  RelationshipBarometerScreen({required this.partnerId, required this.partnerName});

  @override
  _RelationshipBarometerScreenState createState() => _RelationshipBarometerScreenState();
}

class _RelationshipBarometerScreenState extends State<RelationshipBarometerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  double _compatibilityScore = 0.0;
  Map<String, double> _categoryScores = {
    'Communication': 0.0,
    'Valeurs': 0.0,
    'Humour': 0.0,
    'Ambitions': 0.0,
    'Lifestyle': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _calculateCompatibility();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Text('Baromètre avec ${widget.partnerName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Baromètre principal
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.purple.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Score de Compatibilité',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Gauge circulaire
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: CompatibilityGaugePainter(
                                _compatibilityScore * _animation.value,
                              ),
                              size: Size(180, 180),
                            );
                          },
                        ),
                      ),
                      Column(
                        children: [
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Text(
                                '${(_compatibilityScore * _animation.value).round()}%',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: _getScoreColor(_compatibilityScore),
                                ),
                              );
                            },
                          ),
                          Text(
                            _getScoreLabel(_compatibilityScore),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Détail par catégorie
            Text(
              'Détails de Compatibilité',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.seriousAccent,
              ),
            ),
            SizedBox(height: 16),
            
            ..._categoryScores.entries.map((entry) => 
              _buildCategoryScore(entry.key, entry.value)
            ).toList(),
            
            SizedBox(height: 30),
            
            // Conseils
            _buildAdviceCard(),
            
            SizedBox(height: 20),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startConversation(),
                    icon: Icon(Icons.chat),
                    label: Text('Commencer à discuter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.romanticBar,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareResult(),
                    icon: Icon(Icons.share),
                    label: Text('Partager'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.romanticBar,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryScore(String category, double score) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${score.round()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(score),
                  ),
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(_getScoreColor(score)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard() {
    String advice = _getPersonalizedAdvice();
    IconData adviceIcon = _getAdviceIcon();
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(adviceIcon, color: Colors.amber.shade700),
              SizedBox(width: 8),
              Text(
                'Conseil Personnalisé',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            advice,
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber.shade800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _calculateCompatibility() {
    // Simulation d'un calcul basé sur les réponses aux quiz
    _categoryScores = {
      'Communication': 78.0,
      'Valeurs': 85.0,
      'Humour': 92.0,
      'Ambitions': 71.0,
      'Lifestyle': 66.0,
    };
    
    _compatibilityScore = _categoryScores.values.reduce((a, b) => a + b) / _categoryScores.length;
    
    Future.delayed(Duration(milliseconds: 500), () {
      _animationController.forward();
    });
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 85) return 'Excellente affinité';
    if (score >= 70) return 'Bonne compatibilité';
    if (score >= 50) return 'Compatibilité moyenne';
    return 'Différences notables';
  }

  String _getPersonalizedAdvice() {
    if (_compatibilityScore >= 80) {
      return 'Vous avez une excellente compatibilité ! Votre sens de l\'humour partagé est un atout majeur. N\'hésitez pas à explorer vos différences en douceur.';
    } else if (_compatibilityScore >= 60) {
      return 'Vous avez une bonne base pour vous entendre. Votre point fort : la communication. Travaillez ensemble sur vos ambitions communes.';
    } else {
      return 'Vos différences peuvent être enrichissantes ! Prenez le temps de découvrir les valeurs de l\'autre avec curiosité et respect.';
    }
  }

  IconData _getAdviceIcon() {
    if (_compatibilityScore >= 80) return Icons.favorite;
    if (_compatibilityScore >= 60) return Icons.lightbulb;
    return Icons.explore;
  }

  void _startConversation() {
    Navigator.pushNamed(
      context, 
      '/compose_letter',
      arguments: {
        'recipientId': widget.partnerId,
        'recipientName': widget.partnerName,
      },
    );
  }

  void _shareResult() {
    // Logique de partage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Résultat partagé !'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class CompatibilityGaugePainter extends CustomPainter {
  final double percentage;
  
  CompatibilityGaugePainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    // Fond du gauge
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      backgroundPaint,
    );
    
    // Gauge de progression
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.red, Colors.orange, Colors.green],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      (percentage / 100) * math.pi * 1.5,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
