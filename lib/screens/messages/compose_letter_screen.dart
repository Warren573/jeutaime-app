import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ComposeLetterScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;

  ComposeLetterScreen({required this.recipientId, required this.recipientName});

  @override
  _ComposeLetterScreenState createState() => _ComposeLetterScreenState();
}

class _ComposeLetterScreenState extends State<ComposeLetterScreen> {
  final TextEditingController _controller = TextEditingController();
  final int MAX_CHARACTERS = 500;
  String _selectedPaper = 'classic';
  String _selectedInk = 'black';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Text('Lettre à ${widget.recipientName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _controller.text.length >= 50 ? _sendLetter : null,
            child: Text('Envoyer', style: TextStyle(color: AppColors.romanticBar)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélection du papier
            Text('Style de papier :', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                _buildPaperOption('classic', 'Classique', Colors.white),
                _buildPaperOption('romantic', 'Romantique', Colors.pink.shade50),
                _buildPaperOption('vintage', 'Vintage', Colors.brown.shade50),
              ],
            ),
            SizedBox(height: 20),
            
            // Zone de texte
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _getPaperColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  maxLength: MAX_CHARACTERS,
                  style: TextStyle(
                    fontSize: 16,
                    color: _getInkColor(),
                    fontFamily: _selectedPaper == 'vintage' ? 'serif' : null,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Écris ta lettre ici...\n\nPrends ton temps, choisis tes mots avec soin. Cette lettre sera précieuse pour ${widget.recipientName}.',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                  ),
                  onChanged: (text) => setState(() {}),
                ),
              ),
            ),
            
            // Compteur et conseils
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Caractères: ${_controller.text.length}/$MAX_CHARACTERS',
                        style: TextStyle(
                          color: _controller.text.length > MAX_CHARACTERS * 0.9 
                              ? Colors.red : Colors.grey[600],
                        ),
                      ),
                      Text(
                        _controller.text.length < 50 ? 'Min. 50 caractères' : '✓ Prête',
                        style: TextStyle(
                          color: _controller.text.length < 50 ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '💡 Conseil : Une belle lettre sincère vaut mieux qu\'un message rapide !',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperOption(String type, String name, Color color) {
    bool isSelected = _selectedPaper == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaper = type),
        child: Container(
          margin: EdgeInsets.only(right: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.romanticBar : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Color _getPaperColor() {
    switch (_selectedPaper) {
      case 'romantic': return Colors.pink.shade50;
      case 'vintage': return Colors.brown.shade50;
      default: return Colors.white;
    }
  }

  Color _getInkColor() {
    switch (_selectedInk) {
      case 'blue': return Colors.blue.shade800;
      case 'brown': return Colors.brown;
      default: return Colors.black;
    }
  }

  void _sendLetter() {
    // Logique d'envoi de lettre
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lettre envoyée à ${widget.recipientName} !'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
