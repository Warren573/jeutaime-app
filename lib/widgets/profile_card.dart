/**
 * RÉFÉRENCE OBLIGATOIRE: https://jeutaime-warren.web.app/
 * 
 * Widget de carte profil swipable
 * Style bois chaleureux avec informations détaillées
 */

import 'package:flutter/material.dart';
import '../config/ui_reference.dart';
import '../widgets/interactive_avatar_widget.dart';
import '../screens/profile_detail_screen.dart';
import '../models/user_profile.dart';
import '../models/interaction_system.dart';

class ProfileCard extends StatefulWidget {
  final UserProfile profile;
  final Function(bool) onSwipe;

  const ProfileCard({
    Key? key,
    required this.profile,
    required this.onSwipe,
  }) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  int currentPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailScreen(profile: widget.profile),
          ),
        );
      },
      child: Container(
      margin: EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: UIReference.colors['cardBackground'],
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            // Photo de profil avec gestion du swipe entre photos
            _buildPhotoSection(),
            
            // Indicateurs de photos
            if (widget.profile.photos.length > 1) _buildPhotoIndicators(),
            
            // Informations en bas
            _buildProfileInfo(),
            
            // Status en ligne
            _buildOnlineStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _nextPhoto,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: UIReference.colors['accent']!.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: UIReference.colors['primary'],
                    child: Text(
                      widget.profile.name[0],
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Photo ${currentPhotoIndex + 1}/${widget.profile.photos.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoIndicators() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Row(
        children: List.generate(
          widget.profile.photos.length,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: 3,
              decoration: BoxDecoration(
                color: index <= currentPhotoIndex
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineStatus() {
    return Positioned(
      top: 40,
      right: 20,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.profile.isOnline ? Colors.green : Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4),
            Text(
              widget.profile.lastSeen,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'Georgia',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom, âge et avatar interactif
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '${widget.profile.name}, ${widget.profile.age}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: InteractiveAvatarWidget(
                          user: widget.profile,
                          currentUser: widget.profile, // Temporaire pour les tests
                          relation: widget.profile.relation ?? UserRelation(),
                          size: 40,
                          showFullInteractions: false,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: UIReference.colors['accent']!.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '📍 ${widget.profile.distance.toStringAsFixed(1)}km',
                    style: TextStyle(
                      fontSize: 12,
                      color: UIReference.colors['textPrimary'],
                      fontFamily: 'Georgia',
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            // Ville et profession
            Row(
              children: [
                Text(
                  '📍 ${widget.profile.city}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'Georgia',
                  ),
                ),
                SizedBox(width: 15),
                Text(
                  '💼 ${widget.profile.job}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'Georgia',
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Bio
            Text(
              widget.profile.bio,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                height: 1.4,
                fontFamily: 'Georgia',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: 15),
            
            // Intérêts
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: widget.profile.interests.take(4).map((interest) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: UIReference.colors['primary']!.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontFamily: 'Georgia',
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ),
    );
  }

  void _nextPhoto() {
    setState(() {
      currentPhotoIndex = (currentPhotoIndex + 1) % widget.profile.photos.length;
    });
  }
}