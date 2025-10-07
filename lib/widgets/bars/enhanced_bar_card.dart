import 'package:flutter/material.dart';
import '../../models/bar.dart';
import '../../theme/app_colors.dart';
import '../../models/bar_content.dart';

class EnhancedBarCard extends StatefulWidget {
  final Bar bar;
  final VoidCallback? onJoin;
  final bool showAnimation;

  const EnhancedBarCard({
    super.key,
    required this.bar,
    this.onJoin,
    this.showAnimation = true,
  });

  @override
  State<EnhancedBarCard> createState() => _EnhancedBarCardState();
}


class _EnhancedBarCardState extends State<EnhancedBarCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  Widget _buildGroupsPreview() {
    final barContent = BarContentService.getBarById(widget.bar.barId);
    if (barContent == null || barContent.groups == null || barContent.groups.isEmpty) {
      return SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      children: barContent.groups.take(2).map((group) {
        return Chip(
          label: Text(group.name, style: TextStyle(fontSize: 12)),
          avatar: Icon(Icons.group, size: 16),
          backgroundColor: Colors.blue.withOpacity(0.18),
        );
      }).toList(),
    );
  }

  Widget _buildEventsPreview() {
    final barContent = BarContentService.getBarById(widget.bar.barId);
    if (barContent == null || barContent.specialEvents == null || barContent.specialEvents.isEmpty) {
      return SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      children: barContent.specialEvents.take(1).map((event) {
        return Chip(
          label: Text(event.title, style: TextStyle(fontSize: 12)),
          avatar: Icon(Icons.event, size: 16),
          backgroundColor: Colors.purple.withOpacity(0.18),
        );
      }).toList(),
    );
  }

  Widget _buildBadgesPreview() {
    final barContent = BarContentService.getBarById(widget.bar.barId);
    if (barContent == null || barContent.badges == null || barContent.badges.isEmpty) {
      return SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      children: barContent.badges.take(2).map((badge) {
        return Chip(
          label: Text(badge.name, style: TextStyle(fontSize: 12)),
          avatar: Icon(Icons.emoji_events, size: 16),
          backgroundColor: Colors.amber.withOpacity(0.18),
        );
      }).toList(),
    );
  }

  Widget _buildRewardsPreview() {
    final barContent = BarContentService.getBarById(widget.bar.barId);
    if (barContent == null || barContent.rewards == null || barContent.rewards.isEmpty) {
      return SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      children: barContent.rewards.take(1).map((reward) {
        return Chip(
          label: Text(reward.title, style: TextStyle(fontSize: 12)),
          avatar: Icon(Icons.card_giftcard, size: 16),
          backgroundColor: Colors.greenAccent.withOpacity(0.18),
        );
      }).toList(),
    );
  }

  Widget _buildStatsPreview() {
    final barContent = BarContentService.getBarById(widget.bar.barId);
    if (barContent == null) {
      return SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text('${barContent.totalVisits}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Visites', style: TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
        Column(
          children: [
            Text('${barContent.totalChallengesCompleted}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Défis', style: TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBarColor() {
    switch (widget.bar.type) {
      case BarType.romantic:
        return AppColors.romanticBar;
      case BarType.humorous:
        return AppColors.humorousBar;
      case BarType.pirate:
        return AppColors.pirateBar;
      case BarType.weekly:
        return AppColors.weeklyBar;
      default:
        return AppColors.primary;
    }
  }

  LinearGradient _getBarGradient() {
    switch (widget.bar.type) {
      case BarType.romantic:
        return AppColors.romanticGradient;
      case BarType.humorous:
        return AppColors.humorousGradient;
      case BarType.pirate:
        return AppColors.pirateGradient;
      case BarType.weekly:
        return AppColors.weeklyGradient;
      default:
        return AppColors.backgroundGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.showAnimation ? _scaleAnimation.value : 1.0,
          child: Card(
            elevation: _isHovered ? 12 : 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: widget.onJoin,
              onHover: (hovering) {
                setState(() {
                  _isHovered = hovering;
                });
                if (hovering && widget.showAnimation) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: _getBarGradient(),
                ),
                child: Stack(
                  children: [
                    // Contenu principal
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre et icône
                            Row(
                              children: [
                                Icon(
                                  _getBarIcon(),
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.bar.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Description
                            Text(
                              _getBarDescription(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            // Preview des activités
                            _buildActivitiesPreview(),
                            // Ambiance
                            if (widget.bar.ambiance != null && widget.bar.ambiance.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.nightlife, color: Colors.orangeAccent, size: 18),
                                    SizedBox(width: 6),
                                    Text(widget.bar.ambiance, style: TextStyle(fontSize: 13, color: Colors.orangeAccent)),
                                  ],
                                ),
                              ),
                            SizedBox(height: 8),
                            // Groupes
                            _buildGroupsPreview(),
                            // Événements spéciaux
                            _buildEventsPreview(),
                            // Badges
                            _buildBadgesPreview(),
                            // Récompenses
                            _buildRewardsPreview(),
                            // Statistiques
                            _buildStatsPreview(),
                            // Statistiques classiques
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStat(
                                  Icons.people,
                                  '${widget.bar.activeUsers}',
                                  'Membres',
                                ),
                                _buildStat(
                                  Icons.group,
                                  '${widget.bar.maxParticipants}',
                                  'Max',
                                ),
                                if (widget.bar.isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'ACTIF',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Effet de survol
                    if (_isHovered)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _getBarDescription() {
    switch (widget.bar.type) {
      case BarType.romantic:
        return 'Retrouvez-vous dans une ambiance romantique et tendre pour des conversations pleines de douceur.';
      case BarType.humorous:
        return 'Riez ensemble dans une ambiance détendue et amusante. Parfait pour briser la glace !';
      case BarType.pirate:
        return 'Embarquez pour une aventure maritime pleine de mystères et de conversations captivantes.';
      case BarType.weekly:
        return 'Les lettres hebdomadaires : une tradition pour des échanges profonds et authentiques.';
      default:
        return 'Un espace de rencontre unique pour des conversations mémorables.';
    }
  }

  IconData _getBarIcon() {
    switch (widget.bar.type) {
      case BarType.romantic:
        return Icons.favorite;
      case BarType.humorous:
        return Icons.emoji_emotions;
      case BarType.pirate:
        return Icons.sailing;
      case BarType.weekly:
        return Icons.mail;
      default:
        return Icons.local_bar;
    }
  }

  Widget _buildActivitiesPreview() {
    final barContent = BarContentService.getBarById(widget.bar.barId);
    if (barContent == null || barContent.activities.isEmpty) {
      return SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      children: barContent.activities.take(3).map((activity) {
        return Chip(
          label: Text(activity.title, style: TextStyle(fontFamily: 'Georgia', fontSize: 12)),
          avatar: Text(activity.emoji, style: TextStyle(fontSize: 16)),
          backgroundColor: Colors.white.withOpacity(0.18),
        );
      }).toList(),
    );
  }
}