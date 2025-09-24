import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import '../theme/app_colors.dart';import '../models/economy.dart';

import 'currency_display.dart';import '../config/ui_reference.dart';



class DailyRewardsDialog extends StatefulWidget {class DailyRewardsDialog extends StatefulWidget {

  final int consecutiveDays;  final Function(String currencyId, int amount) onRewardClaimed;

  final int todayReward;

  final List<int> weeklyRewards;  const DailyRewardsDialog({

  final VoidCallback onClaimReward;    super.key,

  final VoidCallback onClose;    required this.onRewardClaimed,

  });

  const DailyRewardsDialog({

    Key? key,  @override

    required this.consecutiveDays,  State<DailyRewardsDialog> createState() => _DailyRewardsDialogState();

    required this.todayReward,}

    required this.weeklyRewards,

    required this.onClaimReward,class _DailyRewardsDialogState extends State<DailyRewardsDialog>

    required this.onClose,    with TickerProviderStateMixin {

  }) : super(key: key);  late AnimationController _controller;

  late AnimationController _sparkleController;

  @override  late Animation<double> _scaleAnimation;

  State<DailyRewardsDialog> createState() => _DailyRewardsDialogState();  late Animation<double> _rotationAnimation;

}  late Animation<double> _sparkleAnimation;



class _DailyRewardsDialogState extends State<DailyRewardsDialog>  int _currentDay = 1; // Simuler le jour actuel

    with TickerProviderStateMixin {  List<DailyReward> _rewards = [];

  late AnimationController _animationController;  bool _hasClaimedToday = false;

  late Animation<double> _scaleAnimation;

  @override

  @override  void initState() {

  void initState() {    super.initState();

    super.initState();    

    _animationController = AnimationController(    // Animation pour le bounce de la boîte

      duration: const Duration(milliseconds: 500),    _controller = AnimationController(

      vsync: this,      duration: const Duration(milliseconds: 1200),

    );      vsync: this,

    _scaleAnimation = Tween<double>(    );

      begin: 0.0,    

      end: 1.0,    // Animation pour les étincelles

    ).animate(CurvedAnimation(    _sparkleController = AnimationController(

      parent: _animationController,      duration: const Duration(milliseconds: 2000),

      curve: Curves.elasticOut,      vsync: this,

    ));    );

    _animationController.forward();    

  }    _scaleAnimation = Tween<double>(

      begin: 0.5,

  @override      end: 1.0,

  void dispose() {    ).animate(CurvedAnimation(

    _animationController.dispose();      parent: _controller,

    super.dispose();      curve: Curves.elasticOut,

  }    ));

    

  @override    _rotationAnimation = Tween<double>(

  Widget build(BuildContext context) {      begin: -0.1,

    return Dialog(      end: 0.1,

      backgroundColor: Colors.transparent,    ).animate(CurvedAnimation(

      child: ScaleTransition(      parent: _controller,

        scale: _scaleAnimation,      curve: Curves.easeInOut,

        child: Container(    ));

          padding: const EdgeInsets.all(20),    

          decoration: BoxDecoration(    _sparkleAnimation = Tween<double>(

            gradient: AppColors.backgroundGradient,      begin: 0.0,

            borderRadius: BorderRadius.circular(16),      end: 1.0,

            boxShadow: [    ).animate(CurvedAnimation(

              BoxShadow(      parent: _sparkleController,

                color: Colors.black.withOpacity(0.3),      curve: Curves.easeInOut,

                blurRadius: 20,    ));

                offset: const Offset(0, 10),

              ),    _rewards = EconomyService.getDailyRewards();

            ],    _controller.forward();

          ),    _sparkleController.repeat(reverse: true);

          child: Column(  }

            mainAxisSize: MainAxisSize.min,

            children: [  @override

              Row(  void dispose() {

                mainAxisAlignment: MainAxisAlignment.spaceBetween,    _controller.dispose();

                children: [    _sparkleController.dispose();

                  const Text(    super.dispose();

                    '🎁 Récompenses Quotidiennes',  }

                    style: TextStyle(

                      fontSize: 20,  @override

                      fontWeight: FontWeight.bold,  Widget build(BuildContext context) {

                      color: Colors.white,    return AnimatedBuilder(

                    ),      animation: Listenable.merge([_controller, _sparkleController]),

                  ),      builder: (context, child) {

                  IconButton(        return Dialog(

                    onPressed: widget.onClose,          backgroundColor: Colors.transparent,

                    icon: const Icon(Icons.close, color: Colors.white),          child: Container(

                  ),            constraints: const BoxConstraints(maxHeight: 600),

                ],            child: Stack(

              ),              children: [

              const SizedBox(height: 20),                // Étincelles de fond

              Text(                ..._buildSparkles(),

                'Jour ${widget.consecutiveDays}',                

                style: const TextStyle(                // Contenu principal

                  fontSize: 16,                Transform.scale(

                  color: Colors.white70,                  scale: _scaleAnimation.value,

                ),                  child: Transform.rotate(

              ),                    angle: _rotationAnimation.value * 0.1,

              const SizedBox(height: 10),                    child: Container(

              Container(                      decoration: BoxDecoration(

                padding: const EdgeInsets.all(16),                        gradient: LinearGradient(

                decoration: BoxDecoration(                          begin: Alignment.topLeft,

                  color: Colors.white.withOpacity(0.1),                          end: Alignment.bottomRight,

                  borderRadius: BorderRadius.circular(12),                          colors: [

                ),                            UIReference.primaryColor,

                child: Column(                            UIReference.accentColor,

                  children: [                          ],

                    const Icon(                        ),

                      Icons.card_giftcard,                        borderRadius: BorderRadius.circular(20),

                      size: 48,                        boxShadow: [

                      color: AppColors.goldAccent,                          BoxShadow(

                    ),                            color: UIReference.black.withOpacity(0.3),

                    const SizedBox(height: 12),                            blurRadius: 20,

                    const Text(                            offset: const Offset(0, 10),

                      'Récompense d\'aujourd\'hui',                          ),

                      style: TextStyle(                        ],

                        fontSize: 14,                      ),

                        color: Colors.white70,                      child: Column(

                      ),                        mainAxisSize: MainAxisSize.min,

                    ),                        children: [

                    const SizedBox(height: 8),                          _buildHeader(),

                    CurrencyDisplay(                          _buildRewardsList(),

                      coins: widget.todayReward,                          _buildFooter(),

                      fontSize: 18,                        ],

                    ),                      ),

                  ],                    ),

                ),                  ),

              ),                ),

              const SizedBox(height: 20),              ],

              const Text(            ),

                'Récompenses de la semaine',          ),

                style: TextStyle(        );

                  fontSize: 16,      },

                  fontWeight: FontWeight.bold,    );

                  color: Colors.white,  }

                ),

              ),  Widget _buildHeader() {

              const SizedBox(height: 12),    return Container(

              Row(      padding: const EdgeInsets.all(20),

                mainAxisAlignment: MainAxisAlignment.spaceEvenly,      child: Column(

                children: List.generate(7, (index) {        children: [

                  bool isClaimed = index < widget.consecutiveDays - 1;          Text(

                  bool isToday = index == widget.consecutiveDays - 1;            '🎁',

                  bool isFuture = index > widget.consecutiveDays - 1;            style: const TextStyle(fontSize: 40),

                            ),

                  return Column(          const SizedBox(height: 8),

                    children: [          Text(

                      Container(            'Récompenses Quotidiennes',

                        width: 36,            style: Theme.of(context).textTheme.titleLarge?.copyWith(

                        height: 36,              color: UIReference.white,

                        decoration: BoxDecoration(              fontWeight: FontWeight.bold,

                          color: isClaimed            ),

                              ? AppColors.success          ),

                              : isToday          const SizedBox(height: 4),

                                  ? AppColors.goldAccent          Text(

                                  : Colors.white.withOpacity(0.3),            'Jour ${_currentDay} / 7',

                          shape: BoxShape.circle,            style: Theme.of(context).textTheme.bodyMedium?.copyWith(

                          border: Border.all(              color: UIReference.white.withOpacity(0.8),

                            color: Colors.white,            ),

                            width: 2,          ),

                          ),        ],

                        ),      ),

                        child: Center(    );

                          child: isClaimed  }

                              ? const Icon(

                                  Icons.check,  Widget _buildRewardsList() {

                                  color: Colors.white,    return Container(

                                  size: 20,      height: 300,

                                )      child: GridView.builder(

                              : Text(        padding: const EdgeInsets.symmetric(horizontal: 20),

                                  '${index + 1}',        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(

                                  style: const TextStyle(          crossAxisCount: 2,

                                    color: Colors.white,          crossAxisSpacing: 12,

                                    fontWeight: FontWeight.bold,          mainAxisSpacing: 12,

                                    fontSize: 12,          childAspectRatio: 1.2,

                                  ),        ),

                                ),        itemCount: _rewards.length,

                        ),        itemBuilder: (context, index) {

                      ),          final reward = _rewards[index];

                      const SizedBox(height: 4),          final dayNumber = index + 1;

                      Text(          final isCurrentDay = dayNumber == _currentDay;

                        widget.weeklyRewards[index].toString(),          final isPastDay = dayNumber < _currentDay;

                        style: TextStyle(          final isFutureDay = dayNumber > _currentDay;

                          fontSize: 10,          

                          color: isFuture           return _buildRewardCard(reward, dayNumber, isCurrentDay, isPastDay);

                              ? Colors.white38         },

                              : Colors.white,      ),

                          fontWeight: FontWeight.bold,    );

                        ),  }

                      ),

                    ],  Widget _buildRewardCard(DailyReward reward, int dayNumber, bool isCurrentDay, bool isPastDay) {

                  );    final currency = EconomyService.getCurrency(reward.currencyId);

                }),    

              ),    return GestureDetector(

              const SizedBox(height: 24),      onTap: isCurrentDay && !_hasClaimedToday ? () => _claimReward(reward) : null,

              SizedBox(      child: AnimatedContainer(

                width: double.infinity,        duration: const Duration(milliseconds: 300),

                child: ElevatedButton(        decoration: BoxDecoration(

                  onPressed: widget.onClaimReward,          color: isCurrentDay 

                  style: ElevatedButton.styleFrom(              ? UIReference.white

                    backgroundColor: AppColors.goldAccent,              : isPastDay

                    foregroundColor: Colors.white,                  ? UIReference.white.withOpacity(0.3)

                    padding: const EdgeInsets.symmetric(vertical: 16),                  : UIReference.white.withOpacity(0.1),

                    shape: RoundedRectangleBorder(          borderRadius: BorderRadius.circular(12),

                      borderRadius: BorderRadius.circular(12),          border: Border.all(

                    ),            color: isCurrentDay 

                  ),                ? UIReference.accentColor

                  child: const Text(                : Colors.transparent,

                    'Récupérer la récompense',            width: 2,

                    style: TextStyle(          ),

                      fontSize: 16,          boxShadow: isCurrentDay ? [

                      fontWeight: FontWeight.bold,            BoxShadow(

                    ),              color: UIReference.accentColor.withOpacity(0.3),

                  ),              blurRadius: 8,

                ),              offset: const Offset(0, 4),

              ),            ),

            ],          ] : null,

          ),        ),

        ),        child: Stack(

      ),          children: [

    );            Padding(

  }              padding: const EdgeInsets.all(12),

}              child: Column(

                mainAxisAlignment: MainAxisAlignment.center,

// Fonction helper pour afficher le dialog                children: [

void showDailyRewardsDialog(                  Text(

  BuildContext context, {                    'Jour $dayNumber',

  required int consecutiveDays,                    style: TextStyle(

  required int todayReward,                      fontWeight: FontWeight.bold,

  required List<int> weeklyRewards,                      color: isCurrentDay ? UIReference.primaryColor : UIReference.white.withOpacity(0.8),

  required VoidCallback onClaimReward,                      fontSize: 12,

}) {                    ),

  showDialog(                  ),

    context: context,                  const SizedBox(height: 8),

    barrierDismissible: false,                  Text(

    builder: (context) => DailyRewardsDialog(                    currency?.symbol ?? '?',

      consecutiveDays: consecutiveDays,                    style: const TextStyle(fontSize: 24),

      todayReward: todayReward,                  ),

      weeklyRewards: weeklyRewards,                  const SizedBox(width: 4),

      onClaimReward: () {                  Text(

        Navigator.of(context).pop();                    '${reward.amount}',

        onClaimReward();                    style: TextStyle(

      },                      fontWeight: FontWeight.bold,

      onClose: () => Navigator.of(context).pop(),                      fontSize: 16,

    ),                      color: isCurrentDay ? UIReference.primaryColor : UIReference.white,

  );                    ),

}                  ),
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