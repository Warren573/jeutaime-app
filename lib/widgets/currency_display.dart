import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import '../theme/app_colors.dart';import '../models/economy.dart';

import '../config/ui_reference.dart';

class CurrencyDisplay extends StatelessWidget {

  final int coins;class CurrencyDisplay extends StatefulWidget {

  final bool showBackground;  final Currency currency;

  final double fontSize;  final int amount;

  final bool showAnimation;

  const CurrencyDisplay({

    Key? key,  const CurrencyDisplay({

    required this.coins,    super.key,

    this.showBackground = true,    required this.currency,

    this.fontSize = 16,    required this.amount,

  }) : super(key: key);    this.showAnimation = false,

  });

  @override

  Widget build(BuildContext context) {  @override

    Widget content = Row(  State<CurrencyDisplay> createState() => _CurrencyDisplayState();

      mainAxisSize: MainAxisSize.min,}

      children: [

        Icon(class _CurrencyDisplayState extends State<CurrencyDisplay>

          Icons.monetization_on,    with SingleTickerProviderStateMixin {

          color: showBackground ? Colors.white : AppColors.goldAccent,  late AnimationController _controller;

          size: fontSize * 1.2,  late Animation<double> _scaleAnimation;

        ),  late Animation<double> _rotationAnimation;

        const SizedBox(width: 4),

        Text(  @override

          _formatCoins(coins),  void initState() {

          style: TextStyle(    super.initState();

            fontSize: fontSize,    _controller = AnimationController(

            fontWeight: FontWeight.bold,      duration: const Duration(milliseconds: 800),

            color: showBackground ? Colors.white : AppColors.goldAccent,      vsync: this,

          ),    );

        ),    

      ],    _scaleAnimation = Tween<double>(

    );      begin: 0.8,

      end: 1.0,

    if (showBackground) {    ).animate(CurvedAnimation(

      return Container(      parent: _controller,

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),      curve: Curves.elasticOut,

        decoration: BoxDecoration(    ));

          gradient: AppColors.coinsGradient,    

          borderRadius: BorderRadius.circular(20),    _rotationAnimation = Tween<double>(

          boxShadow: [      begin: 0,

            BoxShadow(      end: 0.1,

              color: Colors.black.withOpacity(0.2),    ).animate(CurvedAnimation(

              blurRadius: 4,      parent: _controller,

              offset: const Offset(0, 2),      curve: Curves.easeInOut,

            ),    ));

          ],

        ),    if (widget.showAnimation) {

        child: content,      _controller.repeat(reverse: true);

      );    }

    }  }



    return content;  @override

  }  void dispose() {

    _controller.dispose();

  String _formatCoins(int coins) {    super.dispose();

    if (coins >= 1000000) {  }

      return '${(coins / 1000000).toStringAsFixed(1)}M';

    } else if (coins >= 1000) {  @override

      return '${(coins / 1000).toStringAsFixed(1)}K';  Widget build(BuildContext context) {

    }    return AnimatedBuilder(

    return coins.toString();      animation: _controller,

  }      builder: (context, child) {

}        return Transform.scale(
          scale: widget.showAnimation ? _scaleAnimation.value : 1.0,
          child: Transform.rotate(
            angle: widget.showAnimation ? _rotationAnimation.value : 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: UIReference.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: UIReference.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: UIReference.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: UIReference.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.currency.symbol,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatNumber(widget.amount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.currency.name,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}