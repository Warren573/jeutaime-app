import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/bar.dart';

class BarCard extends StatelessWidget {
  final Bar bar;
  final VoidCallback onJoin;
  final bool isPremiumUser;

  const BarCard({
    super.key,
    required this.bar,
    required this.onJoin,
    this.isPremiumUser = false,
  });

  @override
  Widget build(BuildContext context) {
    bool canJoin = _canJoinBar();
    
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getBarGradientColors(),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildDescription(),
              const SizedBox(height: 16),
              _buildStats(),
              const SizedBox(height: 16),
              _buildJoinButton(canJoin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getBarEmoji(),
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bar.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bar.type.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (bar.isPremiumOnly)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.goldAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'PREMIUM',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      bar.type.description,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        height: 1.4,
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.people,
          label: 'Participants',
          value: '${bar.activeUsers}/${bar.maxParticipants}',
        ),
        const SizedBox(width: 24),
        if (bar.expiresAt != null)
          _buildStatItem(
            icon: Icons.access_time,
            label: 'Expire',
            value: _formatTimeRemaining(),
          ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bar.isActive 
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                bar.isActive ? Icons.circle : Icons.pause_circle,
                size: 12,
                color: bar.isActive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                bar.isActive ? 'Actif' : 'Suspendu',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: bar.isActive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton(bool canJoin) {
    String buttonText;
    Color buttonColor;
    IconData buttonIcon;
    VoidCallback? onPressed;

    if (!bar.isActive) {
      buttonText = 'Bar fermé';
      buttonColor = Colors.grey;
      buttonIcon = Icons.lock;
      onPressed = null;
    } else if (!canJoin) {
      buttonText = _getJoinBlockReason();
      buttonColor = Colors.red.shade600;
      buttonIcon = Icons.block;
      onPressed = null;
    } else if (bar.activeUsers >= bar.maxParticipants) {
      buttonText = 'Complet';
      buttonColor = Colors.orange.shade600;
      buttonIcon = Icons.group;
      onPressed = null;
    } else {
      buttonText = 'Rejoindre le bar';
      buttonColor = Colors.white;
      buttonIcon = Icons.login;
      onPressed = onJoin;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonColor == Colors.white ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(buttonIcon, size: 20),
            const SizedBox(width: 8),
            Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canJoinBar() {
    if (!bar.isActive) return false;
    if (bar.isPremiumOnly && !isPremiumUser) return false;
    if (bar.activeUsers >= bar.maxParticipants) return false;
    return true;
  }

  String _getJoinBlockReason() {
    if (bar.isPremiumOnly && !isPremiumUser) {
      return 'Premium requis';
    }
    return 'Accès refusé';
  }

  List<Color> _getBarGradientColors() {
    switch (bar.type) {
      case BarType.romantic:
        return [
          const Color(0xFF8B4B8C),
          const Color(0xFFB85A85),
        ];
      case BarType.humorous:
        return [
          const Color(0xFFFF6B35),
          const Color(0xFFFF8E53),
        ];
      case BarType.pirate:
        return [
          const Color(0xFF2D4A3E),
          const Color(0xFF3E5E4F),
        ];
      case BarType.weekly:
        return [
          const Color(0xFF1E3A8A),
          const Color(0xFF3B82F6),
        ];
      case BarType.hidden:
        return [
          const Color(0xFF4C1D95),
          const Color(0xFF7C3AED),
        ];
    }
  }

  String _getBarEmoji() {
    switch (bar.type) {
      case BarType.romantic:
        return '🌹';
      case BarType.humorous:
        return '😄';
      case BarType.pirate:
        return '🏴‍☠️';
      case BarType.weekly:
        return '📅';
      case BarType.hidden:
        return '👑';
    }
  }

  String _formatTimeRemaining() {
    if (bar.expiresAt == null) return '';
    
    final now = DateTime.now();
    final difference = bar.expiresAt!.difference(now);
    
    if (difference.isNegative) return 'Expiré';
    
    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}min';
    }
  }
}