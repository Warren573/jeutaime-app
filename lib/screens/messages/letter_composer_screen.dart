import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../services/letter_service.dart';port 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../services/letter_service.dart';

class LetterComposerScreen extends StatefulWidget {
  final UserModel recipient;

  const LetterComposerScreen({Key? key, required this.recipient}) : super(key: key);

  @override
  _LetterComposerScreenState createState() => _LetterComposerScreenState();
}

class _LetterComposerScreenState extends State<LetterComposerScreen> with TickerProviderStateMixin {
  final _letterController = TextEditingController();
  final _subjectController = TextEditingController();
  late AnimationController _paperController;
  late AnimationController _inkController;
  
  int _characterCount = 0;
  int _maxCharacters = 500;
  String _selectedPaper = 'classic';
  String _selectedInk = 'black';
  bool _isSending = false;
  bool _isAnonymous = false;

  final List<Map<String, dynamic>> _paperTypes = [
    {'id': 'classic', 'name': '📜 Parchemin', 'color': Color(0xFFF5F5DC), 'cost': 0},
    {'id': 'rose', 'name': '🌹 Papier Rose', 'color': Color(0xFFFFE4E1), 'cost': 5},
    {'id': 'gold', 'name': '✨ Papier Doré', 'color': Color(0xFFFFD700), 'cost': 10},
    {'id': 'vintage', 'name': '🕰️ Vintage', 'color': Color(0xFFDEB887), 'cost': 15},
  ];

  final List<Map<String, dynamic>> _inkColors = [
    {'id': 'black', 'name': '🖤 Encre Noire', 'color': Colors.black, 'cost': 0},
    {'id': 'blue', 'name': '💙 Encre Bleue', 'color': Colors.blue, 'cost': 2},
    {'id': 'red', 'name': '❤️ Encre Rouge', 'color': Colors.red, 'cost': 5},
    {'id': 'gold', 'name': '✨ Encre Dorée', 'color': Color(0xFFDAA520), 'cost': 10},
  ];

  @override
  void initState() {
    super.initState();
    _paperController = AnimationController(duration: Duration(seconds: 2), vsync: this)..repeat();
    _inkController = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    
    _letterController.addListener(() {
      setState(() {
        _characterCount = _letterController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _paperController.dispose();
    _inkController.dispose();
    _letterController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Color _getPaperColor() {
    return _paperTypes.firstWhere((p) => p['id'] == _selectedPaper)['color'];
  }

  Color _getInkColor() {
    return _inkColors.firstWhere((i) => i['id'] == _selectedInk)['color'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.edit, color: AppColors.romanticBar),
            SizedBox(width: 8),
            Text(
              'Écrire une lettre',
              style: TextStyle(
                color: AppColors.romanticBar,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: AppColors.romanticBar),
            onPressed: _showTips,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destinataire
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.romanticBar.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: widget.recipient.mainPhoto.isNotEmpty
                      ? NetworkImage(widget.recipient.mainPhoto)
                      : null,
                    child: widget.recipient.mainPhoto.isEmpty
                      ? Icon(Icons.person)
                      : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'À: ${widget.recipient.name}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.romanticBar,
                          ),
                        ),
                        Text(
                          '${widget.recipient.age} ans',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Option anonyme
                  Column(
                    children: [
                      Switch(
                        value: _isAnonymous,
                        onChanged: (value) => setState(() => _isAnonymous = value),
                        activeColor: AppColors.romanticBar,
                      ),
                      Text(
                        'Anonyme',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Personnalisation
            Text(
              '✨ Personnalisez votre lettre',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.romanticBar,
              ),
            ),
            
            SizedBox(height: 15),
            
            // Sélection du papier
            Text('Papier:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _paperTypes.length,
                itemBuilder: (context, index) {
                  final paper = _paperTypes[index];
                  bool isSelected = _selectedPaper == paper['id'];
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPaper = paper['id']),
                    child: Container(
                      width: 120,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: paper['color'],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.romanticBar : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            paper['name'],
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          if (paper['cost'] > 0)
                            Text(
                              '${paper['cost']} 🪙',
                              style: TextStyle(fontSize: 10, color: Colors.amber[700]),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 15),

            // Sélection de l'encre
            Text('Encre:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: _inkColors.map((ink) {
                bool isSelected = _selectedInk == ink['id'];
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedInk = ink['id']),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: ink['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? ink['color'] : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ink['name'],
                          style: TextStyle(
                            fontSize: 12,
                            color: ink['color'],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (ink['cost'] > 0)
                          Text(
                            ' ${ink['cost']}🪙',
                            style: TextStyle(fontSize: 10, color: Colors.amber[700]),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            // Aperçu de la lettre
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 300),
              decoration: BoxDecoration(
                color: _getPaperColor(),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: Offset(5, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sujet
                    TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        hintText: 'Sujet de votre lettre...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: _getInkColor().withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getInkColor(),
                        fontFamily: 'serif',
                      ),
                    ),
                    
                    Divider(color: _getInkColor().withOpacity(0.3)),
                    
                    SizedBox(height: 10),
                    
                    // Corps de la lettre
                    TextFormField(
                      controller: _letterController,
                      maxLines: 12,
                      maxLength: _maxCharacters,
                      decoration: InputDecoration(
                        hintText: 'Écrivez votre lettre ici...\n\n💡 Conseil: Soyez authentique et personnel. Parlez de ce qui vous a marqué dans son profil.',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: _getInkColor().withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: _getInkColor(),
                        fontFamily: 'serif',
                        height: 1.5,
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Signature
                    if (!_isAnonymous)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Avec mes sentiments sincères,\n[Votre nom]',
                          style: TextStyle(
                            fontSize: 14,
                            color: _getInkColor(),
                            fontStyle: FontStyle.italic,
                            fontFamily: 'serif',
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Compteur de caractères et validation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_characterCount/$_maxCharacters caractères',
                  style: TextStyle(
                    color: _characterCount > _maxCharacters * 0.9 
                      ? Colors.red 
                      : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                
                // Coût total
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.monetization_on, color: Colors.amber[700], size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${_calculateCost()} coins',
                        style: TextStyle(
                          color: Colors.amber[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 25),

            // Bouton d'envoi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canSend() ? _sendLetter : null,
                icon: _isSending 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(Icons.send, color: Colors.white),
                label: Text(
                  _isSending ? 'Envoi en cours...' : 'Envoyer la lettre 💌',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.romanticBar,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateCost() {
    int paperCost = _paperTypes.firstWhere((p) => p['id'] == _selectedPaper)['cost'];
    int inkCost = _inkColors.firstWhere((i) => i['id'] == _selectedInk)['cost'];
    int baseCost = 1; // Coût de base pour envoyer une lettre
    
    return baseCost + paperCost + inkCost;
  }

  bool _canSend() {
    return _letterController.text.trim().isNotEmpty && 
           _subjectController.text.trim().isNotEmpty &&
           _characterCount <= _maxCharacters &&
           !_isSending;
  }

  Future<void> _sendLetter() async {
    if (!_canSend()) return;

    setState(() => _isSending = true);

    try {
      // Récupérer l'utilisateur actuel
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Créer ou récupérer un thread entre les deux utilisateurs  
      final threadId = await LetterService.createThread(
        userId1: currentUser.uid,
        userId2: widget.recipient.uid,
      );

      // Envoyer le message
      await LetterService.sendMessage(
        threadId: threadId,
        senderId: currentUser.uid,
        content: _letterController.text.trim(),
        theme: _selectedPaper,
        mood: _selectedInk,
        wordCount: _characterCount,
      );

      // Afficher confirmation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Lettre envoyée !'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Votre lettre a été envoyée avec succès à ${widget.recipient.name}.'),
              SizedBox(height: 10),
              Text(
                '💌 Elle sera archivée dans votre boîte à souvenirs.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le dialog
                Navigator.pop(context); // Retourner au bar
              },
              child: Text('Parfait !', style: TextStyle(color: AppColors.romanticBar)),
            ),
          ],
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber),
            SizedBox(width: 8),
            Text('Conseils pour une belle lettre'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💡 Conseils d\'écriture:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Mentionnez un détail précis de son profil'),
              Text('• Posez une question intéressante'),
              Text('• Soyez authentique et personnel'),
              Text('• Évitez les messages génériques'),
              SizedBox(height: 12),
              Text('🎨 Personnalisation:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Le papier et l\'encre coûtent des coins'),
              Text('• Plus c\'est beau, plus ça marque !'),
              Text('• L\'option anonyme ajoute du mystère'),
              SizedBox(height: 12),
              Text('📚 Le saviez-vous ?', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Les lettres bien écrites ont 3x plus de chances de recevoir une réponse !'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Compris !', style: TextStyle(color: AppColors.romanticBar)),
          ),
        ],
      ),
    );
  }
}
