import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProgressionWidget extends StatefulWidget {
  final double progress; // 0.0 à 1.0
  final String title;
  final String? subtitle;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;
  final bool animated;
  final Widget? leadingIcon;
  final Widget? trailingWidget;

  const ProgressionWidget({
    super.key,
    required this.progress,
    required this.title,
    this.subtitle,
    this.progressColor,
    this.backgroundColor,
    this.height = 8.0,
    this.animated = true,
    this.leadingIcon,
    this.trailingWidget,
  });

  @override
  State<ProgressionWidget> createState() => _ProgressionWidgetState();
}

class _ProgressionWidgetState extends State<ProgressionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.animated) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ProgressionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress.clamp(0.0, 1.0),
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      
      if (widget.animated) {
        _animationController.reset();
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec titre et icône
        Row(
          children: [
            if (widget.leadingIcon != null) ...[
              widget.leadingIcon!,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.trailingWidget != null) ...[
              const SizedBox(width: 8),
              widget.trailingWidget!,
            ] else ...[
              Text(
                '${(widget.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        
        // Barre de progression
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.textSecondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: widget.animated
                ? AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.progressColor ?? AppColors.primary,
                        ),
                        minHeight: widget.height,
                      );
                    },
                  )
                : LinearProgressIndicator(
                    value: widget.progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.progressColor ?? AppColors.primary,
                    ),
                    minHeight: widget.height,
                  ),
          ),
        ),
      ],
    );
  }
}