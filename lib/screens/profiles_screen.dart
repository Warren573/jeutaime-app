/**
 * RÉFÉRENCE OBLIGATOIRE: https://jeutaime-warren.web.app/
 * 
 * Reproduit l'onglet Profils de la référence
 * Stack de cartes + actions like/pass avec animations swipe
 */

import 'package:flutter/material.dart';
import '../config/ui_reference.dart';
import '../models/user_profile.dart';
import '../widgets/profile_card.dart';

class ProfilesScreen extends StatefulWidget {
  @override
  _ProfilesScreenState createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen>
    with TickerProviderStateMixin {
  List<UserProfile> profiles = UserProfile.getMockProfiles();
  int currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(2.0, 0.0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSwipeAction(bool isLike) {
    if (currentIndex < profiles.length) {
      _animationController.forward().then((_) {
        setState(() {
          currentIndex++;
        });
        _animationController.reset();
        
        // Afficher un feedback
        _showSwipeFeedback(isLike);
      });
    }
  }

  void _showSwipeFeedback(bool isLike) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Text(isLike ? '💝' : '👋', style: TextStyle(fontSize: 20)),
          SizedBox(width: 10),
          Text(
            isLike ? 'Profil liké !' : 'Profil passé',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 16),
          ),
        ],
      ),
      backgroundColor: isLike 
        ? Colors.green.withOpacity(0.8)
        : Colors.orange.withOpacity(0.8),
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIReference.colors['background'],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              UIReference.colors['background']!,
              UIReference.colors['accent']!.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildProfileStack(),
              ),
              _buildActionButtons(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('👤', style: TextStyle(fontSize: 28)),
              SizedBox(width: 15),
              Text(
                'Découvrir',
                style: UIReference.titleStyle.copyWith(fontSize: 28),
              ),
            ],
          ),
          // Compteur de profils
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: UIReference.colors['accent']!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '${currentIndex + 1}/${profiles.length}',
              style: UIReference.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStack() {
    if (currentIndex >= profiles.length) {
      return _buildNoMoreProfiles();
    }

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Carte suivante (en arrière-plan)
          if (currentIndex + 1 < profiles.length)
            Positioned(
              child: Transform.scale(
                scale: 0.9,
                child: ProfileCard(
                  user: profiles[currentIndex + 1],
                ),
              ),
            ),
          
          // Carte actuelle (au premier plan)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ProfileCard(
                    user: profiles[currentIndex],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreProfiles() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎉', style: TextStyle(fontSize: 64)),
          SizedBox(height: 20),
          Text(
            'Plus de profils !',
            style: UIReference.titleStyle.copyWith(fontSize: 24),
          ),
          SizedBox(height: 10),
          Text(
            'Revenez plus tard pour découvrir\nde nouveaux profils',
            textAlign: TextAlign.center,
            style: UIReference.bodyStyle.copyWith(
              color: UIReference.colors['textSecondary'],
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentIndex = 0;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UIReference.colors['primary'],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Recommencer',
              style: TextStyle(fontFamily: 'Georgia', fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (currentIndex >= profiles.length) return SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Bouton Passer
          GestureDetector(
            onTap: () => _onSwipeAction(false),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.close,
                color: Colors.orange,
                size: 30,
              ),
            ),
          ),
          
          // Bouton Super Like (étoile)
          GestureDetector(
            onTap: () => _showSuperLikeDialog(),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.star,
                color: Colors.blue,
                size: 25,
              ),
            ),
          ),
          
          // Bouton Liker
          GestureDetector(
            onTap: () => _onSwipeAction(true),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite,
                color: Colors.green,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuperLikeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Text('⭐', style: TextStyle(fontSize: 24)),
              SizedBox(width: 10),
              Text(
                'Super Like',
                style: UIReference.subtitleStyle.copyWith(fontSize: 20),
              ),
            ],
          ),
          content: Text(
            'Envoyer un Super Like à ${profiles[currentIndex].name} ?\n\nCoût : 5 pièces 💰',
            style: UIReference.bodyStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(color: UIReference.colors['textSecondary']),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _onSwipeAction(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Text('⭐', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 10),
                        Text('Super Like envoyé !'),
                      ],
                    ),
                    backgroundColor: Colors.blue.withOpacity(0.8),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }
}