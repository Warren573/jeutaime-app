import 'package:flutter/material.dart';
import '../models/economy.dart';
import '../config/ui_reference.dart';

class DailyRewardsDialog extends StatefulWidget {
  final Function(String currencyId, int amount) onRewardClaimed;

  const DailyRewardsDialog({
    super.key,
    required this.onRewardClaimed,
  });

  @override
  State<DailyRewardsDialog> createState() => _DailyRewardsDialogState();
}

class _DailyRewardsDialogState extends State<DailyRewardsDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _sparkleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleAnimation;

  int _currentDay = 1; // Simuler le jour actuel
  List<DailyReward> _rewards = [];
  bool _hasClaimedToday = false;

  @override
  void initState() {
    super.initState();
    
    // Animation pour le bounce de la boîte
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Animation pour les étincelles
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));

    _rewards = EconomyService.getDailyRewards();
    _controller.forward();
    _sparkleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _sparkleController]),
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Stack(
              children: [
                // Étincelles de fond
                ..._buildSparkles(),
                
                // Contenu principal
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value * 0.1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            UIReference.primaryColor,
                            UIReference.accentColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: UIReference.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          _buildRewardsList(),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '🎁',
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            'Récompenses Quotidiennes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: UIReference.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jour ${_currentDay} / 7',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: UIReference.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsList() {
    return Container(
      height: 300,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: _rewards.length,
        itemBuilder: (context, index) {
          final reward = _rewards[index];
          final dayNumber = index + 1;
          final isCurrentDay = dayNumber == _currentDay;
          final isPastDay = dayNumber < _currentDay;
          final isFutureDay = dayNumber > _currentDay;
          
          return _buildRewardCard(reward, dayNumber, isCurrentDay, isPastDay);
        },
      ),
    );
  }

  Widget _buildRewardCard(DailyReward reward, int dayNumber, bool isCurrentDay, bool isPastDay) {
    final currency = EconomyService.getCurrency(reward.currencyId);
    
    return GestureDetector(
      onTap: isCurrentDay && !_hasClaimedToday ? () => _claimReward(reward) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isCurrentDay 
              ? UIReference.white
              : isPastDay
                  ? UIReference.white.withOpacity(0.3)
                  : UIReference.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentDay 
                ? UIReference.accentColor
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isCurrentDay ? [
            BoxShadow(
              color: UIReference.accentColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Jour $dayNumber',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCurrentDay ? UIReference.primaryColor : UIReference.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currency?.symbol ?? '?',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${reward.amount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isCurrentDay ? UIReference.primaryColor : UIReference.white,
                    ),
                  ),
                  if (reward.isBonus)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'BONUS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            if (isPastDay)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (!_hasClaimedToday && _currentDay <= 7)
            Expanded(
              child: ElevatedButton(
                onPressed: () => _claimCurrentReward(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIReference.white,
                  foregroundColor: UIReference.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Récupérer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          
          const SizedBox(width: 12),
          
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: TextStyle(
                color: UIReference.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSparkles() {
    List<Widget> sparkles = [];
    for (int i = 0; i < 8; i++) {
      sparkles.add(
        Positioned(
          left: (i * 60.0) + (50 * _sparkleAnimation.value),
          top: (i * 40.0) + (30 * _sparkleAnimation.value),
          child: Transform.rotate(
            angle: _sparkleAnimation.value * 2 * 3.14159,
            child: Opacity(
              opacity: (1.0 - _sparkleAnimation.value) * 0.6,
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.amber,
                size: 16,
              ),
            ),
          ),
        ),
      );
    }
    return sparkles;
  }

  void _claimReward(DailyReward reward) {
    setState(() {
      _hasClaimedToday = true;
    });
    
    widget.onRewardClaimed(reward.currencyId, reward.amount);
    
    // Animation de succès
    _controller.reset();
    _controller.forward();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.white),
            const SizedBox(width: 8),
            Text('Récompense récupérée ! +${reward.amount}'),
          ],
        ),
        backgroundColor: UIReference.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _claimCurrentReward() {
    if (_currentDay <= _rewards.length) {
      final reward = _rewards[_currentDay - 1];
      _claimReward(reward);
    }
  }
}