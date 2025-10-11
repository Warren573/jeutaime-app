import 'package:flutter/material.dart';

class LettersScreen extends StatefulWidget {
  const LettersScreen({super.key});

  @override
  State<LettersScreen> createState() => _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _letters = [
    {
      'id': 1,
      'sender': 'Sarah M.',
      'preview': 'Bonjour ! J\'ai lu votre profil et je trouve votre passion pour les voyages fascinante...',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'isStarred': false,
      'fullText': 'Bonjour ! J\'ai lu votre profil et je trouve votre passion pour les voyages fascinante. J\'aimerais beaucoup en savoir plus sur vos aventures autour du monde. Moi-même, j\'adore découvrir de nouvelles cultures et j\'ai récemment visité le Japon. Avez-vous déjà eu l\'occasion d\'y aller ? J\'espère que cette lettre vous plaira et que nous pourrons échanger davantage. Bonne journée !',
      'responses': 3,
      'letterCost': 2,
    },
    {
      'id': 2,
      'sender': 'Emma L.',
      'preview': 'Votre description m\'a touchée, surtout quand vous parlez de votre amour pour la lecture...',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'isStarred': true,
      'fullText': 'Votre description m\'a touchée, surtout quand vous parlez de votre amour pour la lecture. Je suis également une grande lectrice et j\'adore les romans historiques. Quel est votre genre préféré ? J\'ai l\'impression que nous avons beaucoup de points communs et j\'aimerais beaucoup faire votre connaissance. En espérant une réponse de votre part !',
      'responses': 1,
      'letterCost': 2,
    },
    {
      'id': 3,
      'sender': 'Julie D.',
      'preview': 'Je suis tombée sur votre profil et j\'ai été séduite par votre sens de l\'humour...',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
      'isStarred': false,
      'fullText': 'Je suis tombée sur votre profil et j\'ai été séduite par votre sens de l\'humour. C\'est rare de trouver quelqu\'un qui sait allier profondeur et légèreté. J\'aimerais beaucoup discuter avec vous de tout et de rien. Que diriez-vous d\'un échange épistolaire moderne ? J\'attends votre réponse avec impatience !',
      'responses': 0,
      'letterCost': 2,
    },
  ];

  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
    
    _updateUnreadCount();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateUnreadCount() {
    _unreadCount = _letters.where((letter) => !letter['isRead']).length;
  }

  void _toggleStar(int index) {
    setState(() {
      _letters[index]['isStarred'] = !_letters[index]['isStarred'];
    });
  }

  void _markAsRead(int index) {
    if (!_letters[index]['isRead']) {
      setState(() {
        _letters[index]['isRead'] = true;
        _updateUnreadCount();
      });
    }
  }

  void _deleteLetter(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a2a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('�️ Supprimer la lettre', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette lettre ? Cette action est irréversible.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _letters.removeAt(index);
                  _updateUnreadCount();
                });
                Navigator.pop(context);
                _showSnackBar('📧 Lettre supprimée');
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _readLetter(Map<String, dynamic> letter, int index) {
    _markAsRead(index);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LetterDetailScreen(
          letter: letter,
          onReply: () => _showReplyDialog(letter),
        ),
      ),
    );
  }

  void _showReplyDialog(Map<String, dynamic> letter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LetterReplyScreen(
          originalLetter: letter,
          onSent: () {
            _showSnackBar('✉️ Réponse envoyée !');
          },
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE91E63),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Text('✉️ Mes Lettres', style: TextStyle(color: Colors.white)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/write-letter');
            },
          ),
        ],
      ),
      body: _letters.isEmpty
          ? _buildEmptyState()
          : FadeTransition(
              opacity: _animationController,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _letters.length,
                itemBuilder: (context, index) {
                  return _buildLetterCard(_letters[index], index);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('✉️', style: TextStyle(fontSize: 64)),
          SizedBox(height: 20),
          Text(
            'Aucune lettre reçue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Vos lettres reçues apparaîtront ici.\nCommencez par envoyer quelques lettres !',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterCard(Map<String, dynamic> letter, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
        )),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _readLetter(letter, index),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: letter['isRead']
                    ? null
                    : const LinearGradient(
                        colors: [
                          Color(0xFF1e1e1e),
                          Color(0xFF2a2a2a),
                        ],
                      ),
                color: letter['isRead'] ? const Color(0xFF1e1e1e) : null,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: letter['isRead'] 
                      ? const Color(0xFF333333)
                      : const Color(0xFFE91E63).withOpacity(0.3),
                  width: letter['isRead'] ? 1 : 2,
                ),
                boxShadow: letter['isRead'] 
                    ? null
                    : [
                        BoxShadow(
                          color: const Color(0xFFE91E63).withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFE91E63),
                        child: Text(
                          letter['sender'][0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  letter['sender'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: letter['isRead'] 
                                        ? FontWeight.normal 
                                        : FontWeight.bold,
                                  ),
                                ),
                                if (!letter['isRead']) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE91E63),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              _formatTimestamp(letter['timestamp']),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              letter['isStarred'] ? Icons.star : Icons.star_border,
                              color: letter['isStarred'] 
                                  ? Colors.amber 
                                  : Colors.grey,
                            ),
                            onPressed: () => _toggleStar(index),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            color: const Color(0xFF2a2a2a),
                            onSelected: (value) {
                              switch (value) {
                                case 'mark_read':
                                  _markAsRead(index);
                                  break;
                                case 'delete':
                                  _deleteLetter(index);
                                  break;
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              if (!letter['isRead'])
                                const PopupMenuItem<String>(
                                  value: 'mark_read',
                                  child: Text('✓ Marquer comme lu', style: TextStyle(color: Colors.white)),
                                ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('🗑️ Supprimer', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    letter['preview'],
                    style: TextStyle(
                      color: letter['isRead'] ? Colors.grey : Colors.white,
                      fontSize: 14,
                      fontWeight: letter['isRead'] ? FontWeight.normal : FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      if (letter['responses'] > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '💬 ${letter['responses']} réponse${letter['responses'] > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Color(0xFFE91E63),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '💎 ${letter['letterCost']} coins pour répondre',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

class LetterDetailScreen extends StatelessWidget {
  final Map<String, dynamic> letter;
  final VoidCallback onReply;

  const LetterDetailScreen({
    super.key,
    required this.letter,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Lettre de ${letter['sender']}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.reply, color: Colors.white),
            onPressed: onReply,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFE91E63),
                        child: Text(
                          letter['sender'][0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              letter['sender'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatTimestamp(letter['timestamp']),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    letter['fullText'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onReply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  '✉️ Répondre (💎 ${letter['letterCost']} coins)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

class LetterReplyScreen extends StatefulWidget {
  final Map<String, dynamic> originalLetter;
  final VoidCallback onSent;

  const LetterReplyScreen({
    super.key,
    required this.originalLetter,
    required this.onSent,
  });

  @override
  State<LetterReplyScreen> createState() => _LetterReplyScreenState();
}

class _LetterReplyScreenState extends State<LetterReplyScreen> {
  final TextEditingController _controller = TextEditingController();
  int _wordCount = 0;
  bool _isValidLetter = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final words = _controller.text.trim().split(RegExp(r'\s+'));
    setState(() {
      _wordCount = words.where((word) => word.isNotEmpty).length;
      _isValidLetter = _wordCount >= 10;
    });
  }

  void _sendReply() {
    if (!_isValidLetter) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une lettre doit contenir au moins 10 mots.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simuler l'envoi
    widget.onSent();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Répondre à ${widget.originalLetter['sender']}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF2a2a2a),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF444444)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lettre originale :',
                    style: TextStyle(
                      color: Color(0xFFE91E63),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.originalLetter['fullText'],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Votre réponse :',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _controller,
              maxLines: 12,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Écrivez votre réponse ici...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE91E63)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_wordCount mots (minimum 10)',
                  style: TextStyle(
                    color: _isValidLetter ? Colors.green : Colors.red,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Coût: 💎 ${widget.originalLetter['letterCost']} coins',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValidLetter ? _sendReply : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isValidLetter 
                      ? const Color(0xFFE91E63)
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  '📨 Envoyer la réponse',
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