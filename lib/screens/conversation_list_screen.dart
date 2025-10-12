import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/conversation.dart';
import '../utils/performance_optimizer.dart';
import 'chat/chat_screen.dart';

class ConversationListScreen extends StatefulWidget {
  final Function(int)? onCoinsUpdated;

  const ConversationListScreen({
    super.key,
    this.onCoinsUpdated,
  });

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  List<Conversation> _conversations = [];
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

    _loadConversations();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadConversations() {
    ChatService.getConversationsStream().listen((conversations) {
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    });
  }

  void _openChat(Conversation conversation) {
    final otherUserId = conversation.getOtherParticipantId('current_user_id');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: conversation.id,
          otherUserName: 'Utilisateur', // TODO: Récupérer le vrai nom
          otherUserAvatar: '👤', // TODO: Récupérer l'avatar
          onCoinsUpdated: widget.onCoinsUpdated,
        ),
      ),
    );
  }

  Future<void> _deleteConversation(String conversationId) async {
    final success = await ChatService.deleteConversation(conversationId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversation supprimée'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text(
          'Conversations',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Recherche de conversations
            },
          ),
        ],
      ),
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE91E63),
        ),
      );
    }

    if (_conversations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _conversations.length,
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFF333333),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return _buildConversationTile(conversation);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune conversation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Commencez à discuter avec vos matchs\npour voir vos conversations ici',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Retourner à l'écran de matching
              Navigator.pop(context);
            },
            icon: const Icon(Icons.favorite),
            label: const Text('Découvrir des profils'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    final isFromMe = conversation.lastMessageSenderId == 'current_user_id';
    final hasUnread = conversation.getUnreadCount('current_user_id') > 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE91E63),
              child: const Text(
                '👤', // TODO: Avatar réel
                style: TextStyle(fontSize: 24),
              ),
            ),
            if (hasUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE91E63),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${conversation.getUnreadCount('current_user_id')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Utilisateur', // TODO: Nom réel
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              _formatTime(conversation.lastMessageTime),
              style: TextStyle(
                color: hasUnread ? const Color(0xFFE91E63) : Colors.grey,
                fontSize: 12,
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              if (isFromMe) ...[
                Icon(
                  Icons.done_all,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  _truncateMessage(conversation.lastMessage),
                  style: TextStyle(
                    color: hasUnread ? Colors.white70 : Colors.grey,
                    fontSize: 14,
                    fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        onTap: () => _openChat(conversation),
        onLongPress: () => _showConversationOptions(conversation),
        tileColor: hasUnread 
            ? const Color(0xFFE91E63).withOpacity(0.05)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: hasUnread 
              ? const BorderSide(color: Color(0xFFE91E63), width: 0.5)
              : BorderSide.none,
        ),
      ),
    );
  }

  void _showConversationOptions(Conversation conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1e1e1e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Options de conversation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: Icons.mark_email_read,
              title: 'Marquer comme lu',
              onTap: () {
                Navigator.pop(context);
                ChatService.markMessagesAsRead(conversation.id);
              },
            ),
            _buildOptionTile(
              icon: Icons.notifications_off,
              title: 'Désactiver les notifications',
              onTap: () {
                Navigator.pop(context);
                // TODO: Gérer les notifications
              },
            ),
            _buildOptionTile(
              icon: Icons.block,
              title: 'Bloquer',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                _showBlockDialog(conversation);
              },
            ),
            _buildOptionTile(
              icon: Icons.delete,
              title: 'Supprimer',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(conversation);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showBlockDialog(Conversation conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          'Bloquer cette conversation ?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Vous ne pourrez plus recevoir de messages de cette personne.',
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
              final success = await ChatService.blockUser(
                conversation.id,
                conversation.getOtherParticipantId('current_user_id'),
              );
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Utilisateur bloqué'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text(
              'Bloquer',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Conversation conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text(
          'Supprimer cette conversation ?',
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
            onPressed: () {
              Navigator.pop(context);
              _deleteConversation(conversation.id);
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

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  String _truncateMessage(String message) {
    if (message.length <= 50) return message;
    return '${message.substring(0, 50)}...';
  }
}