import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../services/letter_service.dart';
import '../../models/letter_message.dart';

class LettersInboxHumorScreen extends StatefulWidget {
  @override
  _LettersInboxHumorScreenState createState() => _LettersInboxHumorScreenState();
}

class _LettersInboxHumorScreenState extends State<LettersInboxHumorScreen> {
  late Future<List<Map<String, dynamic>>> _lettersFuture;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadReceivedLetters();
  }

  void _loadReceivedLetters() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        LetterService.getReceivedLetters(currentUser.uid).listen((letters) {
          setState(() {
            _receivedLetters = letters;
            _isLoading = false;
          });
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur lors du chargement des lettres: $e');
    }
  }

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> letters) {
    switch (_filter) {
      case 'unread':
        return letters.where((l) => l['isRead'] == false).toList();
      case 'anonymous':
        return letters.where((l) => l['isAnonymous'] == true).toList();
      default:
        return letters;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.emoji_emotions, color: AppColors.humorBar),
            SizedBox(width: 8),
            Text('Lettres humoristiques', style: TextStyle(color: AppColors.humorBar)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _lettersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: AppColors.humorBar));
          }
          if (snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune lettre reçue pour l’instant !', style: TextStyle(color: AppColors.humorBar)));
          }
          final letters = _applyFilter(snapshot.data!);
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Toutes'),
                    SizedBox(width: 8),
                    _buildFilterChip('unread', 'Non lues'),
                    SizedBox(width: 8),
                    _buildFilterChip('anonymous', 'Anonymes'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: letters.length,
                  itemBuilder: (context, idx) {
                    final letter = letters[idx];
                    return _LetterPreviewTileHumor(
                      letter: letter,
                      onRead: () async {
                        await LetterService.markAsRead(letter['id']);
                        _loadLetters();
                      },
                      onReply: () {
                        // À relier à l’écran de réponse
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (selected) {
        setState(() {
          _filter = value;
        });
      },
      selectedColor: AppColors.humorBar.withOpacity(0.2),
      labelStyle: TextStyle(
        color: _filter == value ? AppColors.humorBar : Colors.grey[700],
        fontWeight: _filter == value ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _LetterPreviewTileHumor extends StatelessWidget {
  final Map<String, dynamic> letter;
  final VoidCallback onRead;
  final VoidCallback onReply;

  const _LetterPreviewTileHumor({
    required this.letter,
    required this.onRead,
    required this.onReply,
  });

  Color _getPaperColor(String paperType) {
    switch (paperType) {
      case 'comic': return Colors.yellowAccent;
      default: return Colors.white;
    }
  }

  Color _getInkColor(String inkColor) {
    switch (inkColor) {
      case 'blue': return Colors.blue;
      case 'red': return Colors.red;
      case 'orange': return Colors.orange;
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showLetterDialog(context),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getPaperColor(letter['paperType']).withOpacity(letter['isRead'] ? 0.5 : 1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: letter['isRead'] ? Colors.grey[300]! : AppColors.humorBar,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.humorBar.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: CircleAvatar(
            backgroundColor: AppColors.humorBar.withOpacity(0.2),
            child: Icon(Icons.emoji_emotions, color: AppColors.humorBar),
          ),
          title: Row(
            children: [
              Text(
                letter['subject'] ?? '(Sans sujet)',
                style: TextStyle(
                  color: _getInkColor(letter['inkColor']),
                  fontWeight: letter['isRead'] ? FontWeight.normal : FontWeight.bold,
                  fontFamily: 'Comic Sans MS',
                ),
              ),
              if (!letter['isRead'])
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(Icons.mark_email_unread, color: AppColors.humorBar, size: 16),
                ),
            ],
          ),
          subtitle: Text(
            letter['isAnonymous']
                ? 'Expéditeur: Mystère'
                : 'Expéditeur: ${letter['senderName'] ?? "Inconnu"}',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: AppColors.humorBar),
        ),
      ),
    );
  }

  void _showLetterDialog(BuildContext context) async {
    if (!letter['isRead']) {
      await onRead();
    }
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(maxHeight: 530),
            padding: EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _getPaperColor(letter['paperType']),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.humorBar.withOpacity(0.16),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sujet
                  Text(
                    letter['subject'] ?? '(Sans sujet)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getInkColor(letter['inkColor']),
                      fontFamily: 'Comic Sans MS',
                    ),
                  ),
                  SizedBox(height: 10),
                  // Expéditeur
                  Text(
                    letter['isAnonymous']
                        ? 'Expéditeur : Mystère'
                        : 'Expéditeur : ${letter['senderName'] ?? "Inconnu"}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 14),
                  // Contenu
                  Text(
                    letter['content'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: _getInkColor(letter['inkColor']),
                      fontFamily: 'Comic Sans MS',
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24),
                  // Actions
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                        label: Text('Fermer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.humorBar,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: onReply,
                        icon: Icon(Icons.reply, color: AppColors.humorBar),
                        label: Text('Répondre'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.humorBar),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
