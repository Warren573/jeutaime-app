import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_colors.dart';

class UserCard extends StatefulWidget {
  final UserModel user;
  final String barTheme;
  final VoidCallback onLike;
  final VoidCallback onMessage;
  final VoidCallback onViewProfile;

  const UserCard({
    Key? key,
    required this.user,
    required this.barTheme,
    required this.onLike,
    required this.onMessage,
    required this.onViewProfile,
  }) : super(key: key);

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getThemeColor() {
    switch (widget.barTheme) {
      case 'romantic': return AppColors.romanticBar;
      case 'humor': return AppColors.humorBar;
      case 'weekly': return AppColors.weeklyBar;
      case 'mystery': return AppColors.mysteryBar;
      case 'random': return AppColors.randomBar;
      default: return AppColors.funPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getThemeColor().withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec photo et infos de base
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getThemeColor().withOpacity(0.1),
                        _getThemeColor().withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Photo de profil
                        GestureDetector(
                          onTap: widget.onViewProfile,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _getThemeColor(), width: 3),
                              image: widget.user.mainPhoto.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(widget.user.mainPhoto),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            ),
                            child: widget.user.mainPhoto.isEmpty
                              ? Icon(Icons.person, size: 40, color: _getThemeColor())
                              : null,
                          ),
                        ),
                        
                        SizedBox(width: 16),
                        
                        // Infos de base
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.user.name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _getThemeColor(),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  if (widget.user.isVerified)
                                    Icon(Icons.verified, color: Colors.blue, size: 20),
                                ],
                              ),
                              
                              Text(
                                '${widget.user.age} ans',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              
                              SizedBox(height: 4),
                              
                              // Statut en ligne
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: widget.user.isOnline ? Colors.green : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    widget.user.onlineStatus,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Score de fiabilité
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    '${widget.user.reliabilityScore.toInt()}/100',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Contenu principal
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bio
                      if (widget.user.bio.isNotEmpty)
                        Text(
                          widget.user.bio,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      if (widget.user.bio.isNotEmpty) SizedBox(height: 12),
                      
                      // Intérêts
                      if (widget.user.interests.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: widget.user.interests.take(4).map((interest) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getThemeColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getThemeColor().withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                interest,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getThemeColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      
                      SizedBox(height: 16),
                      
                      // Actions
                      Row(
                        children: [
                          // Bouton Like
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() => _isLiked = true);
                                _animationController.forward().then((_) {
                                  _animationController.reverse();
                                });
                                widget.onLike();
                              },
                              icon: Icon(
                                _isLiked ? Icons.favorite : Icons.favorite_border,
                                color: Colors.white,
                              ),
                              label: Text(
                                _isLiked ? 'Liké !' : 'J\'aime',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isLiked ? Colors.pink : _getThemeColor(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          
                          SizedBox(width: 12),
                          
                          // Bouton Message
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.onMessage,
                              icon: Icon(
                                widget.barTheme == 'romantic' ? Icons.mail : Icons.message,
                                color: _getThemeColor(),
                              ),
                              label: Text(
                                widget.barTheme == 'romantic' ? 'Lettre' : 'Message',
                                style: TextStyle(
                                  color: _getThemeColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: _getThemeColor()),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
