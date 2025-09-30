import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/economy.dart';
import 'currency_display.dart';

class DailyReward {
  final int day;
  final int coins;
  final int gems;
  final bool isClaimed;
  final bool isToday;

  DailyReward({
    required this.day,
    required this.coins,
    required this.gems,
    required this.isClaimed,
    required this.isToday,
  });
}

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

  int _currentDay = 1;
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

    _generateRewards();
    _controller.forward();
    _sparkleController.repeat();
  }

  void _generateRewards() {
    _rewards = List.generate(7, (index) {
      int day = index + 1;
      int coins = 50 + (day * 25); // Progression des récompenses
      int gems = day == 7 ? 10 : (day % 3 == 0 ? 5 : 0); // Gems les dimanches et tous les 3 jours
      
      return DailyReward(
        day: day,
        coins: coins,
        gems: gems,
        isClaimed: day < _currentDay,
        isToday: day == _currentDay,
      );
    });
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
                            AppColors.primary,
                            AppColors.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '🎁 Récompenses Quotidiennes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'Jour $_currentDay',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _rewards.length,
              itemBuilder: (context, index) {
                final reward = _rewards[index];
                return _buildRewardCard(reward);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(DailyReward reward) {
    bool canClaim = reward.isToday && !_hasClaimedToday;
    
    return GestureDetector(
      onTap: canClaim ? () => _claimReward(reward) : null,
      child: Container(
        decoration: BoxDecoration(
          color: reward.isClaimed 
              ? Colors.green.withOpacity(0.3)
              : reward.isToday 
                  ? AppColors.goldAccent.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: reward.isToday 
                ? AppColors.goldAccent
                : Colors.white.withOpacity(0.3),
            width: reward.isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'J${reward.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: reward.isToday ? AppColors.goldAccent : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            if (reward.isClaimed)
              const Icon(Icons.check, color: Colors.green, size: 16)
            else ...[
              Text(
                '${reward.coins}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
              if (reward.gems > 0)
                Text(
                  '${reward.gems}💎',
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.blue,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final todayReward = _rewards.firstWhere((r) => r.isToday);
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (!_hasClaimedToday) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    size: 48,
                    color: AppColors.goldAccent,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Récompense d\'aujourd\'hui',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CurrencyDisplay(
                        coins: todayReward.coins,
                        gems: todayReward.gems,
                        showLabels: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _claimReward(todayReward),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Récupérer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Colors.green,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Récompense récupérée !',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Revenez demain pour plus de récompenses',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Fermer',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSparkles() {
    return List.generate(15, (index) {
      double left = (index * 37.0) % 300;
      double top = (index * 23.0) % 400;
      double delay = index * 0.1;
      
      return Positioned(
        left: left,
        top: top,
        child: Transform.rotate(
          angle: _sparkleAnimation.value * 6.28 + delay,
          child: Opacity(
            opacity: (0.3 + (_sparkleAnimation.value * 0.7)) * 
                    (1.0 - (index / 15.0) * 0.5),
            child: const Icon(
              Icons.star,
              color: AppColors.goldAccent,
              size: 12,
            ),
          ),
        ),
      );
    });
  }

  void _claimReward(DailyReward reward) {
    setState(() {
      _hasClaimedToday = true;
    });
    
    // Notifier le parent des récompenses récupérées
    widget.onRewardClaimed('coins', reward.coins);
    if (reward.gems > 0) {
      widget.onRewardClaimed('gems', reward.gems);
    }
    
    // Animation de succès
    _controller.reset();
    _controller.forward();
  }
}