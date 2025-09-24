import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_model.dart';
import '../../services/matching_service.dart';
import '../../theme/app_colors.dart';
import '../chat/chat_list_screen.dart';

class MatchingScreen extends StatefulWidget {
  @override
  _MatchingScreenState createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>
    with TickerProviderStateMixin {
  List<UserModel> _users = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _scaleAnimation;
  Animation<double>? _rotationAnimation;
  bool _isDragging = false;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUsers();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(2.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final users = await MatchingService.getRecommendations(limit: 10);
      setState(() {
        _users = users;
        _currentIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Découverte',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilters,
            icon: Icon(Icons.tune, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatListScreen()),
            ),
            icon: Stack(
              children: [
                Icon(Icons.chat, color: AppColors.textPrimary),
                // TODO: Ajouter badge pour nouveaux messages
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _users.isEmpty
              ? _buildEmptyState()
              : _buildMatchingInterface(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Recherche de personnes compatibles...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Plus de personnes pour le moment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Revenez plus tard ou élargissez vos critères de recherche !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadUsers,
                  icon: Icon(Icons.refresh),
                  label: Text('Actualiser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _showFilters,
                  icon: Icon(Icons.tune),
                  label: Text('Filtres'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchingInterface() {
    return Column(
      children: [
        // Indicateur de progression
        _buildProgressIndicator(),

        // Stack des cartes
        Expanded(
          child: Center(
            child: _buildCardStack(),
          ),
        ),

        // Boutons d'action
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final progress = _currentIndex / _users.length;
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 8),
          Text(
            '${_currentIndex + 1} / ${_users.length}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack() {
    if (_currentIndex >= _users.length) {
      return _buildEmptyState();
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.7,
      child: Stack(
        children: [
          // Carte suivante (arrière-plan)
          if (_currentIndex + 1 < _users.length)
            Positioned.fill(
              child: Transform.scale(
                scale: 0.95,
                child: _UserCard(
                  user: _users[_currentIndex + 1],
                  onTap: () {},
                ),
              ),
            ),

          // Carte actuelle (premier plan)
          Positioned.fill(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Transform.translate(
                offset: _dragOffset,
                child: Transform.rotate(
                  angle: _dragOffset.dx * 0.001,
                  child: _UserCard(
                    user: _users[_currentIndex],
                    onTap: _viewProfile,
                  ),
                ),
              ),
            ),
          ),

          // Indicateurs de swipe
          if (_isDragging) _buildSwipeIndicators(),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeDirection = _dragOffset.dx > 0 ? 'LIKE' : 'NOPE';
    final opacity = (_dragOffset.dx.abs() / (screenWidth * 0.3)).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: (swipeDirection == 'LIKE' ? Colors.green : Colors.red)
              .withOpacity(opacity * 0.3),
        ),
        child: Center(
          child: Transform.rotate(
            angle: swipeDirection == 'LIKE' ? -0.5 : 0.5,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: swipeDirection == 'LIKE' ? Colors.green : Colors.red,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                swipeDirection,
                style: TextStyle(
                  color: swipeDirection == 'LIKE' ? Colors.green : Colors.red,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            onPressed: () => _handleSwipe(false),
            icon: Icons.close,
            color: Colors.red,
            size: 60,
          ),
          _ActionButton(
            onPressed: _showSuperLike,
            icon: Icons.star,
            color: Colors.blue,
            size: 50,
          ),
          _ActionButton(
            onPressed: () => _handleSwipe(true),
            icon: Icons.favorite,
            color: Colors.green,
            size: 60,
          ),
          _ActionButton(
            onPressed: _showBoosts,
            icon: Icons.flash_on,
            color: Colors.purple,
            size: 50,
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    if (_dragOffset.dx.abs() > threshold) {
      _handleSwipe(_dragOffset.dx > 0);
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _isDragging = false;
      });
    }
  }

  Future<void> _handleSwipe(bool isLike) async {
    if (_currentIndex >= _users.length) return;

    // Animation de sortie
    await _animateCardExit(isLike);

    // Traitement du swipe
    final currentUser = _users[_currentIndex];
    final isMatch = await MatchingService.processSwipe(
      targetUserId: currentUser.uid,
      isLike: isLike,
    );

    // Feedback haptique
    if (isLike) {
      HapticFeedback.lightImpact();
    }

    // Afficher match si nécessaire
    if (isMatch && isLike) {
      _showMatchDialog(currentUser);
    }

    // Passer à l'utilisateur suivant
    setState(() {
      _currentIndex++;
      _dragOffset = Offset.zero;
      _isDragging = false;
    });

    // Recharger si on arrive à la fin
    if (_currentIndex >= _users.length - 2) {
      _loadUsers();
    }
  }

  Future<void> _animateCardExit(bool isLike) async {
    await _animationController!.forward();
    _animationController!.reset();
  }

  void _viewProfile() {
    // TODO: Implémenter vue profil détaillée
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profil détaillé bientôt disponible')),
    );
  }

  void _showFilters() {
    // TODO: Implémenter écran de filtres
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Filtres de recherche',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Filtres avancés bientôt disponibles'),
            Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuperLike() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Super Like bientôt disponible')),
    );
  }

  void _showBoosts() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Boosts bientôt disponibles')),
    );
  }

  void _showMatchDialog(UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MatchDialog(user: user),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _UserCard({Key? key, required this.user, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo de fond
              user.mainPhoto.isNotEmpty
                  ? Image.network(
                      user.mainPhoto,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),

              // Gradient en bas
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 200,
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
                ),
              ),

              // Informations utilisateur
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${user.name}, ${user.age}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (user.isVerified)
                            Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 24,
                            ),
                        ],
                      ),
                      
                      if (user.bio.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          user.bio,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      if (user.interests.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: user.interests.take(3).map((interest) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                interest,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Indicateur d'activité
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isOnline ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.isOnline ? 'En ligne' : user.onlineStatus,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.person,
          size: 100,
          color: AppColors.primary.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final double size;

  const _ActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchDialog extends StatelessWidget {
  final UserModel user;

  const _MatchDialog({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'C\'est un match ! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundImage: user.mainPhoto.isNotEmpty
                  ? NetworkImage(user.mainPhoto)
                  : null,
              child: user.mainPhoto.isEmpty
                  ? Icon(Icons.person, size: 50)
                  : null,
            ),
            SizedBox(height: 16),
            Text(
              'Vous vous êtes plu mutuellement avec ${user.name} !',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Continuer'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatListScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Envoyer un message'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}