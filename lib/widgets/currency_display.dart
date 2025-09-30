import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CurrencyDisplay extends StatelessWidget {
  final int coins;
  final int gems;
  final bool showLabels;
  final bool showBackground;
  final double fontSize;

  const CurrencyDisplay({
    super.key,
    this.coins = 0,
    this.gems = 0,
    this.showLabels = true,
    this.showBackground = true,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: showBackground ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6) : null,
      decoration: showBackground
          ? BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (coins > 0) ...[
            Icon(
              Icons.monetization_on,
              color: AppColors.goldAccent,
              size: fontSize + 2,
            ),
            const SizedBox(width: 4),
            Text(
              _formatNumber(coins),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.goldAccent,
              ),
            ),
            if (showLabels) ...[
              const SizedBox(width: 4),
              Text(
                'pièces',
                style: TextStyle(
                  fontSize: fontSize - 2,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
          if (coins > 0 && gems > 0) const SizedBox(width: 12),
          if (gems > 0) ...[
            Icon(
              Icons.diamond,
              color: AppColors.secondary,
              size: fontSize + 2,
            ),
            const SizedBox(width: 4),
            Text(
              _formatNumber(gems),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            if (showLabels) ...[
              const SizedBox(width: 4),
              Text(
                'gemmes',
                style: TextStyle(
                  fontSize: fontSize - 2,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ],
      ),
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
