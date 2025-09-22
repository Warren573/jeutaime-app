import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../services/letter_service.dart';

class LettersInboxScreen extends StatefulWidget {
  @override
  _LettersInboxScreenState createState() => _LettersInboxScreenState();
}

class _LettersInboxScreenState extends State<LettersInboxScreen> {
  late Future<List<Map<String, dynamic>>> _lettersFuture;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadLetters();
  }

  void _loadLetters() {
    setState(() {
      _lettersFuture = LetterService.getReceivedLetters();
    });
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
            Icon(Icons.mail, color: AppColors.romanticBar),
            SizedBox(width: 8),
            Text('Lettres reçues', style: TextStyle(color: AppColors.romanticBar)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.archive, color: AppColors.romanticBar),
            onPressed: () {
              // À relier à la boîte à souvenirs
            },
            tooltip: 'Boîte à souvenirs',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _lettersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: AppColors.romanticBar));
          }
          if (snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final letters = _applyFilter(snapshot.data!);

          return Column(
            children: [
              _buildFilters(),
              Expanded(
                child: ListView.builder(
                  itemCount: letters.length,
                  itemBuilder: (context, idx) {
                    final letter = letters[idx];
                    return _LetterPreviewTile(
                      letter: letter,
                      onRead: () async {
                        await LetterService.markAsRead(letter['id']);
                        _loadLetters();
                      },
                      onReply: () {
                        // À relier à l'écran de réponse
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

  Widget _buildFilters() {
    return Padding(
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
      selectedColor: AppColors.romanticBar.withOpacity(0.2),
      labelStyle: TextStyle(
        color: _filter == value ? AppColors.romanticBar : Colors.grey[700],
        fontWeight: _filter == value ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_email_unread, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Aucune lettre reçue pour le moment',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Quand un utilisateur vous enverra une lettre romantique, elle apparaîtra ici.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ---- Widget pour un aperçu de lettre (cliquable pour lecture détaillée) ----
class _LetterPreviewTile extends StatelessWidget {
  final Map<String, dynamic> letter;
  final VoidCallback onRead;
  final VoidCallback onReply;

  const _LetterPreviewTile({
    required this.letter,
    required this.onRead,
    required this.onReply,
  });

  Color _getPaperColor(String paperType) {
    switch (paperType) {
      case 'rose': return Color(0xFFFFE4E1);
      case 'gold': return Color(0xFFFFD700);
      case 'vintage': return Color(0xFFDEB887);
      default: return Color(0xFFF5F5DC);
    }
  }

  Color _getInkColor(String inkColor) {
    switch (inkColor) {
      case 'blue': return Colors.blue;
      case 'red': return Colors.red;
      case 'gold': return Color(0xFFDAA520);
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
            color: letter['isRead'] ? Colors.grey[300]! : AppColors.romanticBar,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.romanticBar.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: CircleAvatar(
            backgroundColor: AppColors.romanticBar.withOpacity(0.2),
            backgroundImage: !letter['isAnonymous'] && letter['senderPhoto'] != null && letter['senderPhoto'] != ''
                ? NetworkImage(letter['senderPhoto'])
                : null,
            child: letter['isAnonymous'] || letter['senderPhoto'] == null || letter['senderPhoto'] == ''
                ? Icon(Icons.person_outline, color: AppColors.romanticBar)
                : null,
          ),
          title: Row(
            children: [
              Text(
                letter['subject'] ?? '(Sans sujet)',
                style: TextStyle(
                  color: _getInkColor(letter['inkColor']),
                  fontWeight: letter['isRead'] ? FontWeight.normal : FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
              if (!letter['isRead'])
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(Icons.mark_email_unread, color: AppColors.romanticBar, size: 16),
                ),
            ],
          ),
          subtitle: Text(
            letter['isAnonymous']
                ? 'Expéditeur: Anonyme'
                : 'Expéditeur: ${letter['senderName'] ?? "Inconnu"}',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: AppColors.romanticBar),
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
                  color: AppColors.romanticBar.withOpacity(0.16),
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
                      fontFamily: 'serif',
                    ),
                  ),
                  SizedBox(height: 10),
                  // Expéditeur
                  Text(
                    letter['isAnonymous']
                        ? 'Expéditeur : Anonyme'
                        : 'Expéditeur : ${letter['senderName'] ?? "Inconnu"}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 14),
                  // Contenu
                  Text(
                    letter['content'],
                    style: TextStyle(
                      fontSize: 16,
                      color: _getInkColor(letter['inkColor']),
                      fontFamily: 'serif',
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
                          backgroundColor: AppColors.romanticBar,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: onReply,
                        icon: Icon(Icons.reply, color: AppColors.romanticBar),
                        label: Text('Répondre'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.romanticBar),
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
