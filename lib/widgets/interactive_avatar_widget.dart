import 'package:flutter/material.dart';/**

import '../models/user.dart'; * RÉFÉRENCE OBLIGATOIRE: https://jeutaime-warren.web.app/

 * 

class InteractiveAvatarWidget extends StatelessWidget { * Widget d'avatar interactif avec système d'actions

  final User user; * Style bois chaleureux JeuTaime

  final double size; */

  final VoidCallback? onTap;

import 'package:flutter/material.dart';

  const InteractiveAvatarWidget({import '../models/emoji_avatar.dart';

    Key? key,import '../models/interaction_system.dart';

    required this.user,import '../models/user_profile.dart';

    this.size = 100.0,import '../config/ui_reference.dart';

    this.onTap,

  }) : super(key: key);class InteractiveAvatarWidget extends StatefulWidget {

  final UserProfile user;

  @override  final UserProfile currentUser;

  Widget build(BuildContext context) {  final UserRelation relation;

    return GestureDetector(  final Function(InteractionAction, InteractionEffect)? onInteraction;

      onTap: onTap,  final double size;

      child: Container(

        width: size,  const InteractiveAvatarWidget({

        height: size,    Key? key,

        decoration: BoxDecoration(    required this.user,

          shape: BoxShape.circle,    required this.currentUser,

          border: Border.all(color: Colors.white, width: 3),    required this.relation,

          boxShadow: [    this.onInteraction,

            BoxShadow(    this.size = 60.0,

              color: Colors.black.withOpacity(0.2),  }) : super(key: key);

              blurRadius: 10,

              offset: const Offset(0, 4),  @override

            ),  _InteractiveAvatarWidgetState createState() => _InteractiveAvatarWidgetState();

          ],}

        ),

        child: ClipOval(class _InteractiveAvatarWidgetState extends State<InteractiveAvatarWidget>

          child: user.avatarUrl != null    with TickerProviderStateMixin {

              ? Image.network(  late EmojiAvatar avatar;

                  user.avatarUrl!,  late AnimationController _effectController;

                  fit: BoxFit.cover,  late AnimationController _shakeController;

                  errorBuilder: (context, error, stackTrace) {  late Animation<double> _scaleAnimation;

                    return _buildDefaultAvatar();  late Animation<Offset> _shakeAnimation;

                  },  

                )  bool showActionsMenu = false;

              : _buildDefaultAvatar(),  String currentEffect = '';

        ),  

      ),  @override

    );  void initState() {

  }    super.initState();

    

  Widget _buildDefaultAvatar() {    // Génération de l'avatar selon le profil utilisateur

    return Container(    avatar = EmojiAvatarGenerator.generateAvatar(

      decoration: const BoxDecoration(      gender: widget.user.interests.contains('feminine') ? 'feminine' : 

        gradient: LinearGradient(             widget.user.interests.contains('masculine') ? 'masculine' : 'neutral',

          colors: [Color(0xFF8B4513), Color(0xFFA0522D)],      barType: 'romantic',

          begin: Alignment.topLeft,      personality: 'romantic',

          end: Alignment.bottomRight,      interests: widget.user.interests,

        ),    );

      ),    

      child: Icon(    // Contrôleurs d'animation

        Icons.person,    _effectController = AnimationController(

        size: size * 0.5,      duration: Duration(milliseconds: 2000),

        color: Colors.white,      vsync: this,

      ),    );

    );    

  }    _shakeController = AnimationController(

}      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _effectController,
      curve: Curves.elasticOut,
    ));
    
    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.1, 0.0),
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticInOut,
    ));
  }

  @override
  void dispose() {
    _effectController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleActionsMenu,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar principal avec animations
          AnimatedBuilder(
            animation: Listenable.merge([_effectController, _shakeController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: SlideTransition(
                  position: _shakeAnimation,
                  child: _buildAvatarMain(),
                ),
              );
            },
          ),
          
          // Effet de particules
          if (currentEffect.isNotEmpty) _buildParticleEffect(),
          
          // Menu d'actions
          if (showActionsMenu) _buildActionsMenu(),
        ],
      ),
    );
  }

  Widget _buildAvatarMain() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: avatar.background,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          avatar.emoji,
          style: TextStyle(
            fontSize: widget.size * 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildParticleEffect() {
    return Positioned(
      top: -10,
      right: -10,
      child: AnimatedBuilder(
        animation: _effectController,
        builder: (context, child) {
          return Opacity(
            opacity: 1 - _effectController.value,
            child: Transform.translate(
              offset: Offset(0, -20 * _effectController.value),
              child: Transform.scale(
                scale: 0.5 + (_effectController.value * 0.8),
                child: Text(
                  currentEffect,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionsMenu() {
    final availableActions = InteractionSystem.getAvailableActions(widget.relation);
    
    return Positioned(
      top: widget.size + 10,
      left: -(200 - widget.size) / 2,
      child: Container(
        width: 200,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: UIReference.colors['cardBackground'],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: UIReference.colors['accent']!.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header du menu
            Text(
              'Interactions avec ${widget.user.name}',
              style: UIReference.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            
            // Liste des actions
            ...availableActions.map((action) => _buildActionItem(action)).toList(),
            
            SizedBox(height: 8),
            
            // Bouton fermer
            TextButton(
              onPressed: () => setState(() => showActionsMenu = false),
              child: Text(
                'Fermer',
                style: TextStyle(
                  color: UIReference.colors['textSecondary'],
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(InteractionAction action) {
    final categoryColor = InteractionSystem.getCategoryColor(action.category);
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _performInteraction(action),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: categoryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  action.emoji,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.name,
                        style: UIReference.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (action.description.isNotEmpty)
                        Text(
                          action.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: UIReference.colors['textSecondary'],
                            fontFamily: 'Georgia',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (action.cost > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${action.cost} 🪙',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleActionsMenu() {
    setState(() {
      showActionsMenu = !showActionsMenu;
    });
  }

  void _performInteraction(InteractionAction action) {
    final effect = InteractionSystem.performAction(
      action,
      widget.user.name,
      widget.currentUser.name,
    );
    
    // Animation visuelle selon le type d'action
    _showVisualEffect(action, effect);
    
    // Fermer le menu
    setState(() {
      showActionsMenu = false;
    });
    
    // Callback pour notifier l'interaction
    if (widget.onInteraction != null) {
      widget.onInteraction!(action, effect);
    }
    
    // Afficher message de notification
    _showInteractionFeedback(effect);
  }

  void _showVisualEffect(InteractionAction action, InteractionEffect effect) {
    setState(() {
      currentEffect = effect.particles.split(' ')[0]; // Premier emoji des particules
    });
    
    // Animation selon le type
    switch (effect.animation) {
      case 'wave':
      case 'bounce':
        _effectController.forward().then((_) {
          _effectController.reverse();
        });
        break;
      case 'tickle':
        _shakeController.forward().then((_) {
          _shakeController.reverse();
        });
        break;
      default:
        _effectController.forward().then((_) {
          _effectController.reverse();
        });
        break;
    }
    
    // Nettoyer l'effet après la durée
    Future.delayed(Duration(milliseconds: effect.duration), () {
      if (mounted) {
        setState(() {
          currentEffect = '';
        });
      }
    });
  }

  void _showInteractionFeedback(InteractionEffect effect) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              effect.particles.split(' ')[0],
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                effect.message,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: UIReference.colors['primary']!.withOpacity(0.9),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}