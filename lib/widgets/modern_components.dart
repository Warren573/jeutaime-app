import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_system.dart';

/// Composants UI modernes réutilisables pour JeuTaime
class ModernComponents {
  
  // ============================================================================
  // BOUTONS MODERNES
  // ============================================================================
  
  /// Bouton principal avec dégradé et animation
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isEnabled = true,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      child: DesignSystem.gradientButton(
        text: text,
        onPressed: isEnabled && !isLoading ? onPressed : () {},
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: DesignSystem.spaceL,
          vertical: DesignSystem.spaceM,
        ),
        textStyle: DesignSystem.labelLarge.copyWith(
          color: isEnabled ? DesignSystem.textOnPrimary : DesignSystem.textDisabled,
        ),
      ),
    );
  }
  
  /// Bouton secondaire avec bordure
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isEnabled = true,
    double? width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border.all(
          color: isEnabled ? DesignSystem.primaryPink : DesignSystem.textDisabled,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceL,
              vertical: DesignSystem.spaceM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: isEnabled ? DesignSystem.primaryPink : DesignSystem.textDisabled,
                    size: 20,
                  ),
                  const SizedBox(width: DesignSystem.spaceS),
                ],
                Text(
                  text,
                  style: DesignSystem.labelLarge.copyWith(
                    color: isEnabled ? DesignSystem.primaryPink : DesignSystem.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Bouton flottant moderne avec animation
  static Widget modernFAB({
    required VoidCallback onPressed,
    required IconData icon,
    String? tooltip,
    bool isExtended = false,
    String? label,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: DesignSystem.primaryGradient,
        borderRadius: BorderRadius.circular(
          isExtended ? DesignSystem.radiusXL : DesignSystem.radiusCircle,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignSystem.primaryPink.withOpacity(0.4),
            blurRadius: DesignSystem.elevationHigh,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(
            isExtended ? DesignSystem.radiusXL : DesignSystem.radiusCircle,
          ),
          child: Padding(
            padding: EdgeInsets.all(
              isExtended ? DesignSystem.spaceM : DesignSystem.spaceL,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: DesignSystem.textOnPrimary,
                  size: 24,
                ),
                if (isExtended && label != null) ...[
                  const SizedBox(width: DesignSystem.spaceS),
                  Text(
                    label,
                    style: DesignSystem.labelLarge,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // ============================================================================
  // CARTES ET CONTAINERS
  // ============================================================================
  
  /// Card moderne avec animation hover
  static Widget modernCard({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? elevation,
    BorderRadius? borderRadius,
    Gradient? gradient,
    bool hasGlassEffect = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: margin ?? const EdgeInsets.all(DesignSystem.spaceS),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null 
                ? (hasGlassEffect 
                    ? DesignSystem.surfaceDark.withOpacity(0.8)
                    : DesignSystem.surfaceDark)
                : null,
            borderRadius: borderRadius ?? BorderRadius.circular(DesignSystem.radiusL),
            border: hasGlassEffect
                ? Border.all(color: Colors.white.withOpacity(0.1), width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: elevation ?? DesignSystem.elevationMedium,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap != null
                  ? () {
                      HapticFeedback.selectionClick();
                      onTap();
                    }
                  : null,
              borderRadius: borderRadius ?? BorderRadius.circular(DesignSystem.radiusL),
              child: Padding(
                padding: padding ?? const EdgeInsets.all(DesignSystem.spaceM),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Profile card avec photo et informations
  static Widget profileCard({
    required String name,
    required int age,
    String? bio,
    String? imageUrl,
    List<String>? interests,
    VoidCallback? onTap,
    bool showLikeButton = true,
    VoidCallback? onLike,
    VoidCallback? onSuperLike,
    VoidCallback? onDislike,
  }) {
    return modernCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image de profil avec overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DesignSystem.radiusL),
                  topRight: Radius.circular(DesignSystem.radiusL),
                ),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: DesignSystem.primaryGradient,
                  ),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              _buildProfilePlaceholder(name),
                        )
                      : _buildProfilePlaceholder(name),
                ),
              ),
              // Overlay avec dégradé
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Actions de swipe si activées
              if (showLikeButton)
                Positioned(
                  bottom: DesignSystem.spaceM,
                  right: DesignSystem.spaceM,
                  child: Row(
                    children: [
                      _buildSwipeButton(
                        icon: Icons.close,
                        color: DesignSystem.redError,
                        onPressed: onDislike ?? () {},
                      ),
                      const SizedBox(width: DesignSystem.spaceS),
                      _buildSwipeButton(
                        icon: Icons.star,
                        color: DesignSystem.goldAccent,
                        onPressed: onSuperLike ?? () {},
                      ),
                      const SizedBox(width: DesignSystem.spaceS),
                      _buildSwipeButton(
                        icon: Icons.favorite,
                        color: DesignSystem.primaryPink,
                        onPressed: onLike ?? () {},
                      ),
                    ],
                  ),
                ),
            ],
          ),
          // Informations de profil
          Padding(
            padding: const EdgeInsets.all(DesignSystem.spaceM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom et âge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$name, $age',
                        style: DesignSystem.headingSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Bio si présente
                if (bio != null && bio.isNotEmpty) ...[
                  const SizedBox(height: DesignSystem.spaceS),
                  Text(
                    bio,
                    style: DesignSystem.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                // Centres d'intérêt
                if (interests != null && interests.isNotEmpty) ...[
                  const SizedBox(height: DesignSystem.spaceM),
                  Wrap(
                    spacing: DesignSystem.spaceS,
                    runSpacing: DesignSystem.spaceS,
                    children: interests.take(3).map((interest) => 
                      interestChip(interest),
                    ).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Widget placeholder pour photo de profil
  static Widget _buildProfilePlaceholder(String name) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: DesignSystem.primaryGradient,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: DesignSystem.headingLarge.copyWith(
            fontSize: 80,
            color: DesignSystem.textOnPrimary,
          ),
        ),
      ),
    );
  }
  
  /// Bouton d'action pour swipe
  static Widget _buildSwipeButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(25),
          child: Icon(
            icon,
            color: DesignSystem.textOnPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
  
  // ============================================================================
  // CHAMPS DE SAISIE
  // ============================================================================
  
  /// Champ de saisie moderne avec validation
  static Widget modernTextField({
    required String label,
    TextEditingController? controller,
    String? hint,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int? maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DesignSystem.labelMedium,
        ),
        const SizedBox(height: DesignSystem.spaceS),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          enabled: enabled,
          style: DesignSystem.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: DesignSystem.textSecondary,
                    size: 20,
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(
                      suffixIcon,
                      color: DesignSystem.textSecondary,
                      size: 20,
                    ),
                    onPressed: onSuffixTap,
                  )
                : null,
          ),
        ),
      ],
    );
  }
  
  // ============================================================================
  // COMPOSANTS SPÉCIALISÉS
  // ============================================================================
  
  /// Chip moderne pour centres d'intérêt
  static Widget interestChip(String interest, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spaceM,
        vertical: DesignSystem.spaceS,
      ),
      decoration: BoxDecoration(
        gradient: isSelected ? DesignSystem.primaryGradient : null,
        color: isSelected ? null : DesignSystem.surfaceLight.withOpacity(0.5),
        border: Border.all(
          color: isSelected 
              ? Colors.transparent 
              : DesignSystem.textDisabled.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
      ),
      child: Text(
        interest,
        style: DesignSystem.bodySmall.copyWith(
          color: isSelected ? DesignSystem.textOnPrimary : DesignSystem.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
  
  /// Badge de niveau avec XP
  static Widget levelBadge({
    required int level,
    required int currentXP,
    required int nextLevelXP,
    double? size,
  }) {
    final progress = currentXP / nextLevelXP;
    final badgeSize = size ?? 60.0;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cercle de progression
        SizedBox(
          width: badgeSize,
          height: badgeSize,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: DesignSystem.surfaceLight.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(
              DesignSystem.goldAccent,
            ),
          ),
        ),
        // Badge central
        Container(
          width: badgeSize - 8,
          height: badgeSize - 8,
          decoration: BoxDecoration(
            gradient: DesignSystem.goldGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: DesignSystem.goldAccent.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              level.toString(),
              style: DesignSystem.labelLarge.copyWith(
                fontSize: size != null ? size * 0.3 : 18,
                fontWeight: FontWeight.w800,
                color: DesignSystem.backgroundDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Loading shimmer effect
  static Widget shimmerEffect({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DesignSystem.surfaceLight.withOpacity(0.3),
        borderRadius: borderRadius ?? BorderRadius.circular(DesignSystem.radiusM),
      ),
      child: const ShimmerAnimation(),
    );
  }
  
  /// App Bar moderne avec dégradé
  static PreferredSizeWidget modernAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    PreferredSizeWidget? bottom,
  }) {
    return AppBar(
      title: Text(
        title,
        style: DesignSystem.headingSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      bottom: bottom,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: DesignSystem.primaryGradient,
        ),
      ),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }
}

/// Animation shimmer pour les loading states
class ShimmerAnimation extends StatefulWidget {
  const ShimmerAnimation({Key? key}) : super(key: key);

  @override
  State<ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
            ),
          ),
        );
      },
    );
  }
}