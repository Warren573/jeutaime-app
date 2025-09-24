import 'package:flutter/material.dart';
import '../models/letter.dart';
import '../config/ui_reference.dart';

class LetterThreadCard extends StatelessWidget {
  final LetterThread thread;
  final VoidCallback onTap;

  const LetterThreadCard({
    super.key,
    required this.thread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: UIReference.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: UIReference.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: _getBorderColor(),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec avatar et statut
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _getParticipantName(),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: UIReference.textPrimary,
                                ),
                              ),
                            ),
                            _buildStatusBadge(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getLastMessageTime(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: UIReference.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (thread.isUserTurn('current_user'))
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: UIReference.accentColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: UIReference.accentColor,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Informations de la conversation
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.forum_outlined,
                    label: '${thread.messageCount} message${thread.messageCount > 1 ? 's' : ''}',
                    color: UIReference.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  if (thread.status == ThreadStatus.ghostingDetected)
                    _buildInfoChip(
                      icon: Icons.warning_amber,
                      label: 'Ghosting détecté',
                      color: UIReference.warningColor,
                    ),
                  if (thread.isUserTurn('current_user') && thread.status == ThreadStatus.active)
                    _buildInfoChip(
                      icon: Icons.notifications_active,
                      label: 'Votre tour',
                      color: UIReference.accentColor,
                    ),
                ],
              ),
              
              // Indicateur de progression si ghosting
              if (thread.status == ThreadStatus.ghostingDetected) ...[
                const SizedBox(height: 12),
                _buildGhostingIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                UIReference.primaryColor,
                UIReference.accentColor,
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: UIReference.white,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              _getParticipantInitial(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        if (thread.isUserTurn('current_user'))
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: UIReference.accentColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: UIReference.white,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.edit,
                size: 8,
                color: UIReference.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    if (thread.status == ThreadStatus.ghostingDetected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: UIReference.warningColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber,
              size: 12,
              color: UIReference.warningColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Ghosting',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: UIReference.warningColor,
              ),
            ),
          ],
        ),
      );
    }
    
    if (thread.isUserTurn('current_user')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: UIReference.accentColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_active,
              size: 12,
              color: UIReference.accentColor,
            ),
            const SizedBox(width: 4),
            Text(
              'À vous',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: UIReference.accentColor,
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: UIReference.textSecondary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'En attente',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: UIReference.textSecondary,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGhostingIndicator() {
    final daysSinceLastMessage = thread.timeSinceLastMessage.inDays;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UIReference.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: UIReference.warningColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 16,
            color: UIReference.warningColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pas de réponse depuis $daysSinceLastMessage jour${daysSinceLastMessage > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: UIReference.warningColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    if (thread.status == ThreadStatus.ghostingDetected) {
      return UIReference.warningColor.withOpacity(0.3);
    }
    
    if (thread.isUserTurn('current_user')) {
      return UIReference.accentColor.withOpacity(0.3);
    }
    
    return UIReference.primaryColor.withOpacity(0.1);
  }

  String _getParticipantName() {
    // Simulation - en réalité, on récupérerait le nom depuis la base de données
    final otherParticipant = thread.getOtherParticipant('current_user');
    
    switch (otherParticipant) {
      case 'alice_123':
        return 'Alice Martin';
      case 'bob_456':
        return 'Bob Dupont';
      case 'charlie_789':
        return 'Charlie Rousseau';
      default:
        return 'Utilisateur inconnu';
    }
  }

  String _getParticipantInitial() {
    final name = _getParticipantName();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _getLastMessageTime() {
    final now = DateTime.now();
    final difference = now.difference(thread.lastMessageAt);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return 'Il y a plus d\'une semaine';
    }
  }
}