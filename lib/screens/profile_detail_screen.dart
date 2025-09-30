import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/emoji_avatar.dart';
import '../models/interaction_system.dart';
import '../widgets/interactive_avatar_widget.dart';
import '../config/ui_reference.dart';

class ProfileDetailScreen extends StatefulWidget {
  final UserProfile profile;

  const ProfileDetailScreen({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPhotoIndex = 0;
  final EmojiAvatarGenerator _avatarGenerator = EmojiAvatarGenerator();
  late EmojiAvatar _currentAvatar;

  @override
  void initState() {
    super.initState();
    _currentAvatar = EmojiAvatarGenerator.generateAvatar(
      gender: 'femme',
      personality: 'aventurière',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIReference.colors['background'],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Photos en arrière-plan
          _buildPhotoCarousel(),
          
          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),
          
          // Contenu principal
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildProfileContent(),
          ),
          
          // Avatar interactif positionné
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: InteractiveAvatarWidget(
                user: widget.profile,
                size: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCarousel() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPhotoIndex = index;
        });
      },
      itemCount: widget.profile.photos.length,
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: UIReference.colors['accent']!.withOpacity(0.3),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 100,
                  backgroundColor: UIReference.colors['primary'],
                  child: Text(
                    widget.profile.name[0],
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Photo ${index + 1}/${widget.profile.photos.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Georgia',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileContent() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicateur de drag
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // En-tête avec nom, âge et compatibilité
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.profile.name}, ${widget.profile.age}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: UIReference.colors['textPrimary'],
                        fontFamily: 'Georgia',
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: UIReference.colors['textSecondary'],
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${widget.profile.city} • ${widget.profile.distance.toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 16,
                            color: UIReference.colors['textSecondary'],
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.profile.relation != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: UIReference.colors['accent']!.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${widget.profile.relation!.compatibilityScore.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: UIReference.colors['primary'],
                          fontFamily: 'Georgia',
                        ),
                      ),
                      Text(
                        'Compatibilité',
                        style: TextStyle(
                          fontSize: 10,
                          color: UIReference.colors['textSecondary'],
                          fontFamily: 'Georgia',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Profession et statut en ligne
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: UIReference.colors['primary']!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.profile.job,
                  style: TextStyle(
                    fontSize: 14,
                    color: UIReference.colors['primary'],
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.profile.isOnline ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      widget.profile.lastSeen,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Bio
          Text(
            'À propos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UIReference.colors['textPrimary'],
              fontFamily: 'Georgia',
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.profile.bio,
            style: TextStyle(
              fontSize: 16,
              color: UIReference.colors['textSecondary'],
              fontFamily: 'Georgia',
              height: 1.4,
            ),
          ),
          
          SizedBox(height: 20),
          
          // Centres d'intérêt
          Text(
            'Centres d\'intérêt',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UIReference.colors['textPrimary'],
              fontFamily: 'Georgia',
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.profile.interests.map((interest) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: UIReference.colors['accent']!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: UIReference.colors['accent']!.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    fontSize: 14,
                    color: UIReference.colors['textPrimary'],
                    fontFamily: 'Georgia',
                  ),
                ),
              );
            }).toList(),
          ),
          
          Spacer(),
          
          // Boutons d'action
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Bouton refuser
        Expanded(
          child: Container(
            height: 56,
            margin: EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 'dislike');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(color: Colors.red.withOpacity(0.3)),
                ),
              ),
              child: Icon(
                Icons.close,
                size: 24,
              ),
            ),
          ),
        ),
        
        // Bouton super like
        Container(
          width: 56,
          height: 56,
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context, 'superlike');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: CircleBorder(),
              elevation: 2,
            ),
            child: Icon(
              Icons.star,
              size: 24,
            ),
          ),
        ),
        
        // Bouton aimer
        Expanded(
          child: Container(
            height: 56,
            margin: EdgeInsets.only(left: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 'like');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: UIReference.colors['primary'],
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Icon(
                Icons.favorite,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.report, color: Colors.red),
              title: Text('Signaler'),
              onTap: () {
                Navigator.pop(context);
                // Logique de signalement
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.orange),
              title: Text('Bloquer'),
              onTap: () {
                Navigator.pop(context);
                // Logique de blocage
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: UIReference.colors['primary']),
              title: Text('Partager le profil'),
              onTap: () {
                Navigator.pop(context);
                // Logique de partage
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}