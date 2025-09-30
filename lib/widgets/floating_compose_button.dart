import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FloatingComposeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onTap;

  const FloatingComposeButton({
    super.key,
    this.onPressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed ?? onTap,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.edit),
      label: const Text(
        'Nouvelle lettre',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 4,
    );
  }
}