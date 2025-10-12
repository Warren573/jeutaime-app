import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../utils/performance_optimizer.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String otherUserAvatar;
  final Function(int)? onCoinsUpdated;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    required this.otherUserAvatar,
    this.onCoinsUpdated,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _animationController = PerformanceOptimizer.createOptimizedController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _loadMessages();
    _markMessagesAsRead();
    _animationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    ChatService.getMessagesStream(widget.conversationId).listen((messages) {
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      
      // Auto-scroll vers le bas pour les nouveaux messages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void _markMessagesAsRead() {
    ChatService.markMessagesAsRead(widget.conversationId);
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isTyping = true;
    });

    final success = await ChatService.sendMessage(
      conversationId: widget.conversationId,
      content: content,
    );

    if (success) {
      _messageController.clear();
      PerformanceOptimizer.hapticFeedback(HapticFeedbackType.lightImpact);
      
      // Récompense en coins pour envoyer des messages
      widget.onCoinsUpdated?.call(2);
    } else {
      _showErrorSnackBar('Erreur lors de l\'envoi du message');
    }

    setState(() {
      _isTyping = false;
    });
  }

  Future<void> _sendGameChallenge(String gameType) async {
    final success = await ChatService.sendMessage(
      conversationId: widget.conversationId,
      content: 'Défi de jeu : $gameType',
      type: MessageType.gameChallenge,
      metadata: {
        'gameType': gameType,
        'challengeId': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );

    if (success) {
      PerformanceOptimizer.hapticFeedback(HapticFeedbackType.mediumImpact);
      widget.onCoinsUpdated?.call(5);
    }
  }

  void _showGameChallengeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Row(
          children: [
            Icon(Icons.games, color: Color(0xFFE91E63)),
            SizedBox(width: 10),
            Text(
              'Défier en jeu',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGameChallengeOption('⚡', 'Jeu de Réactivité', 'Réactivité'),
            _buildGameChallengeOption('🧩', 'Puzzle Challenge', 'Puzzle'),
            _buildGameChallengeOption('🎯', 'Précision Master', 'Précision'),
            _buildGameChallengeOption('⭕', 'Morpion', 'Morpion'),
            _buildGameChallengeOption('🧱', 'Casse-Briques', 'Casse-Briques'),
            _buildGameChallengeOption('🎴', 'Jeu de Cartes', 'Cartes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameChallengeOption(String emoji, String title, String gameType) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        _sendGameChallenge(gameType);
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * _slideAnimation.value),
            child: Opacity(
              opacity: 1 - _slideAnimation.value,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1a1a1a),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE91E63),
            child: Text(
              widget.otherUserAvatar,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'En ligne',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: Colors.white),
          onPressed: () {
            // TODO: Appel vidéo
            _showErrorSnackBar('Appel vidéo bientôt disponible !');
          },
        ),
        IconButton(
          icon: const Icon(Icons.phone, color: Colors.white),
          onPressed: () {
            // TODO: Appel audio
            _showErrorSnackBar('Appel audio bientôt disponible !');
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF2a2a2a),
          onSelected: (value) {
            switch (value) {
              case 'block':
                _showBlockDialog();
                break;
              case 'report':
                _showReportDialog();
                break;
              case 'delete':
                _showDeleteDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Bloquer', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report, color: Colors.orange),
                  SizedBox(width: 10),
                  Text('Signaler', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Supprimer', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE91E63),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _buildMessageList(),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Commencez votre conversation !',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.isFromCurrentUser;
        final showTime = index == 0 || 
            _messages[index - 1].timestamp.difference(message.timestamp).inMinutes > 5;

        return Column(
          children: [
            if (showTime) _buildTimeIndicator(message.timestamp),
            _buildMessageBubble(message, isMe),
          ],
        );
      },
    );
  }

  Widget _buildTimeIndicator(DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatTime(timestamp),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE91E63),
              child: Text(
                widget.otherUserAvatar,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFE91E63) : const Color(0xFF2a2a2a),
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                ),
              ),
              child: _buildMessageContent(message),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Icon(
              message.isRead ? Icons.done_all : Icons.done,
              size: 16,
              color: message.isRead ? Colors.blue : Colors.grey,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        );
      
      case MessageType.gameChallenge:
        return _buildGameChallengeMessage(message);
      
      case MessageType.image:
        return _buildImageMessage(message);
      
      default:
        return Text(
          message.content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        );
    }
  }

  Widget _buildGameChallengeMessage(ChatMessage message) {
    final gameType = message.metadata['gameType'] ?? 'Jeu';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.games, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Défi de jeu',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            gameType,
            style: const TextStyle(color: Colors.white),
          ),
          if (!message.isFromCurrentUser) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // TODO: Lancer le jeu en mode défi
                _showErrorSnackBar('Mode défi bientôt disponible !');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accepter le défi'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageMessage(ChatMessage message) {
    final imageUrl = message.metadata['imageUrl'] ?? '';
    final caption = message.metadata['caption'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey,
                  child: const Icon(Icons.error, color: Colors.white),
                );
              },
            ),
          ),
        if (caption.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            caption,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a),
        border: Border(top: BorderSide(color: Color(0xFF333333))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _showGameChallengeDialog,
            icon: const Icon(Icons.games, color: Color(0xFFE91E63)),
            tooltip: 'Défier en jeu',
          ),
          IconButton(
            onPressed: () {
              // TODO: Envoyer une image
              _showErrorSnackBar('Envoi d\'images bientôt disponible !');
            },
            icon: const Icon(Icons.image, color: Colors.grey),
            tooltip: 'Envoyer une image',
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2a2a2a),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Tapez votre message...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isTyping ? null : _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isTyping 
                    ? Colors.grey 
                    : const Color(0xFFE91E63),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isTyping ? Icons.hourglass_empty : Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          'Bloquer cet utilisateur ?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Vous ne pourrez plus recevoir de messages de ${widget.otherUserName}.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ChatService.blockUser(
                widget.conversationId,
                'other_user_id', // TODO: Récupérer l'ID réel
              );
              
              if (success) {
                Navigator.pop(context);
              } else {
                _showErrorSnackBar('Erreur lors du blocage');
              }
            },
            child: const Text(
              'Bloquer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          'Signaler cet utilisateur ?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Votre signalement sera examiné par notre équipe.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showErrorSnackBar('Signalement envoyé !');
            },
            child: const Text(
              'Signaler',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          'Supprimer la conversation ?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Cette action est irréversible.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ChatService.deleteConversation(
                widget.conversationId,
              );
              
              if (success) {
                Navigator.pop(context);
              } else {
                _showErrorSnackBar('Erreur lors de la suppression');
              }
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}