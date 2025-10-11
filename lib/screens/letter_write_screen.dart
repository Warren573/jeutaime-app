import 'package:flutter/material.dart';

class LetterWriteScreen extends StatefulWidget {
  final String recipientName;
  final String recipientAvatar;
  final Function(int) onCoinsUpdated;
  final int currentCoins;

  const LetterWriteScreen({
    super.key,
    required this.recipientName,
    required this.recipientAvatar,
    required this.onCoinsUpdated,
    required this.currentCoins,
  });

  @override
  State<LetterWriteScreen> createState() => _LetterWriteScreenState();
}

class _LetterWriteScreenState extends State<LetterWriteScreen> {
  final TextEditingController _letterController = TextEditingController();
  int _wordCount = 0;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _letterController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _letterController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _letterController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    
    setState(() {
      _wordCount = words;
      _isValid = words >= 10 && words <= 500;
    });
  }

  void _sendLetter() {
    if (!_isValid) {
      String message = _wordCount < 10 
          ? 'Votre lettre doit contenir au moins 10 mots pour être sincère et authentique.'
          : 'Votre lettre ne peut pas dépasser 500 mots. Actuellement : $_wordCount mots.';
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1e1e1e),
          title: const Text('❌ Lettre invalide', style: TextStyle(color: Colors.white)),
          content: Text(message, style: const TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFFE91E63))),
            ),
          ],
        ),
      );
      return;
    }

    if (widget.currentCoins < 30) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1e1e1e),
          title: const Text('❌ Pièces insuffisantes', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Il vous faut 30 pièces pour envoyer une lettre.\nVous pouvez en acheter dans la boutique.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFFE91E63))),
            ),
          ],
        ),
      );
      return;
    }

    // Confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('📤 Envoyer cette lettre ?', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📖 $_wordCount mots', style: const TextStyle(color: Colors.grey)),
            const Text('💰 Coût : 30 pièces', style: TextStyle(color: Colors.orange)),
            const SizedBox(height: 8),
            Text('✨ La lettre sera envoyée à ${widget.recipientName}', 
                 style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close confirmation
              _processLetterSending();
            },
            child: const Text('Envoyer', style: TextStyle(color: Color(0xFFE91E63))),
          ),
        ],
      ),
    );
  }

  void _processLetterSending() {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFE91E63)),
      ),
    );

    // Simulate sending
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context); // Close loading
      widget.onCoinsUpdated(-30);
      
      // Success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1e1e1e),
          title: const Text('✅ Lettre envoyée avec succès !', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📬 ${widget.recipientName} recevra votre lettre.', 
                   style: const TextStyle(color: Colors.grey)),
              const Text('💰 -30 pièces', style: TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              Text('⏰ Vous recevrez une notification quand ${widget.recipientName} vous répondra.',
                   style: const TextStyle(color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close success dialog
                Navigator.pop(context); // Go back to previous screen
              },
              child: const Text('Super !', style: TextStyle(color: Color(0xFFE91E63))),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('✍️ Écrire à ${widget.recipientName}', 
                    style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Recipient info
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.recipientAvatar,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'À : ${widget.recipientName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Correspondance privée',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Letter writing area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1e1e1e),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Votre lettre (max 500 mots)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: TextField(
                        controller: _letterController,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Cher/Chère ${widget.recipientName},\n\nCommencez votre lettre ici...\n\nN\'oubliez pas d\'être authentique et sincère. Les meilleures correspondances naissent de l\'honnêteté et du respect mutuel.\n\nBien à vous,',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$_wordCount / 500 mots',
                          style: TextStyle(
                            color: _wordCount > 500 ? Colors.red : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          '💰 Coût : 30 pièces',
                          style: TextStyle(color: Colors.orange, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Rules card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: const Border(left: BorderSide(color: Color(0xFFE91E63), width: 4)),
              ),
              padding: const EdgeInsets.all(15),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Règles de correspondance :',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Maximum 500 mots par lettre\n'
                    '• Attendez la réponse avant d\'envoyer une nouvelle lettre\n'
                    '• Après 10 lettres, les photos sont débloquées\n'
                    '• Soyez respectueux et authentique',
                    style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.8),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Send button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid ? _sendLetter : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isValid ? const Color(0xFFE91E63) : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  '📤 Envoyer la lettre (30 🪙)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}