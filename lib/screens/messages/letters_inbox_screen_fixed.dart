import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/letter_thread.dart';
import '../../models/letter_message.dart';
import '../../models/thread_status.dart';
import '../../services/letter_service.dart';
import '../../theme/app_colors.dart';

class LettersInboxScreen extends StatefulWidget {
  const LettersInboxScreen({Key? key}) : super(key: key);

  @override
  State<LettersInboxScreen> createState() => _LettersInboxScreenState();
}

class _LettersInboxScreenState extends State<LettersInboxScreen> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Vous devez être connecté pour voir vos lettres'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.mail, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Mes Lettres', style: TextStyle(color: AppColors.primary)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.primary),
            tooltip: 'Boîte à souvenirs',
            onPressed: () => Navigator.pushNamed(context, '/memory_box'),
          ),
        ],
      ),
      body: StreamBuilder<List<LetterThread>>(
        stream: LetterService.getUserThreads(currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur lors du chargement',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final threads = snapshot.data ?? [];

          if (threads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucune correspondance',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Commencez par découvrir des profils !',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/discovery'),
                    icon: const Icon(Icons.explore),
                    label: const Text('Découvrir des profils'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: threads.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final thread = threads[index];
              return _buildThreadCard(thread);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/discovery'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.edit, color: Colors.white),
        tooltip: 'Écrire une nouvelle lettre',
      ),
    );
  }

  Widget _buildThreadCard(LetterThread thread) {
    final otherParticipant = thread.participants
        .firstWhere((id) => id != currentUserId, orElse: () => 'Inconnu');
    
    final isMyTurn = thread.lastTurnUid != currentUserId;
    final statusColor = _getStatusColor(thread.status);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openThread(thread),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom et statut
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      otherParticipant.isNotEmpty 
                          ? otherParticipant[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Correspondance avec $otherParticipant',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStatusText(thread.status),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isMyTurn) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Votre tour',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleThreadAction(thread, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(Icons.archive_outlined),
                            SizedBox(width: 8),
                            Text('Archiver'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'block',
                        child: Row(
                          children: [
                            Icon(Icons.block_outlined, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Bloquer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Informations sur la conversation
              Row(
                children: [
                  Icon(Icons.message_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${thread.messageCount} message(s)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatLastActivity(thread.lastMessageAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ThreadStatus status) {
    switch (status) {
      case ThreadStatus.active:
        return AppColors.success;
      case ThreadStatus.archived:
        return Colors.grey;
      case ThreadStatus.ghostingDetected:
        return AppColors.warning;
    }
  }

  String _getStatusText(ThreadStatus status) {
    switch (status) {
      case ThreadStatus.active:
        return 'Actif';
      case ThreadStatus.archived:
        return 'Archivé';
      case ThreadStatus.ghostingDetected:
        return 'En attente';
    }
  }

  String _formatLastActivity(DateTime lastActivity) {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    }
  }

  void _openThread(LetterThread thread) {
    Navigator.pushNamed(
      context,
      '/thread_detail',
      arguments: thread.threadId,
    );
  }

  void _handleThreadAction(LetterThread thread, String action) {
    switch (action) {
      case 'archive':
        _archiveThread(thread);
        break;
      case 'block':
        _blockThread(thread);
        break;
    }
  }

  void _archiveThread(LetterThread thread) async {
    try {
      await LetterService.archiveThreadForUser(thread.threadId, currentUserId!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversation archivée'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _blockThread(LetterThread thread) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquer cette conversation'),
        content: const Text(
          'Êtes-vous sûr de vouloir bloquer cette conversation ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performBlock(thread);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Bloquer'),
          ),
        ],
      ),
    );
  }

  void _performBlock(LetterThread thread) async {
    try {
      // Récupérer l'autre participant
      final otherParticipant = thread.participants
          .firstWhere((id) => id != currentUserId);

      // Logique de blocage (à implémenter dans LetterService)
      // await LetterService.blockThread(thread.threadId, currentUserId!, otherParticipant);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversation bloquée'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}