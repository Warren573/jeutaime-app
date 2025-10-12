import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_system.dart';
import '../widgets/modern_animations.dart';
import 'home_screen.dart';
import 'profiles_screen.dart';
import 'bars_screen.dart';
import 'letters_screen.dart';
import 'pet_mode_selection_screen.dart';
import 'settings_screen.dart';

/// Navigation principale moderne avec animations et design system unifié
class ModernMainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const ModernMainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<ModernMainNavigationScreen> createState() => _ModernMainNavigationScreenState();
}

class _ModernMainNavigationScreenState extends State<ModernMainNavigationScreen>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;
  late AnimationController _navigationController;
  late List<AnimationController> _iconControllers;

  // Écrans de l'application
  final List<Widget> _screens = [
    HomeScreen(),
    ProfilesScreen(),
    BarsScreen(),
    const LettersScreen(),
    PetModeSelectionScreen(onCoinsUpdated: (coins) {}, currentCoins: 0),
    SettingsScreen(),
  ];

  // Configuration des onglets de navigation
  final List<NavigationTab> _navigationTabs = [
    NavigationTab(
      icon: Icons.home_rounded,
      activeIcon: Icons.home,
      label: 'Accueil',
      color: DesignSystem.primaryPink,
    ),
    NavigationTab(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Profils',
      color: DesignSystem.primaryPurple,
    ),
    NavigationTab(
      icon: Icons.local_bar_outlined,
      activeIcon: Icons.local_bar_rounded,
      label: 'Bars',
      color: DesignSystem.orangeAccent,
    ),
    NavigationTab(
      icon: Icons.mail_outline_rounded,
      activeIcon: Icons.mail_rounded,
      label: 'Lettres',
      color: DesignSystem.blueInfo,
    ),
    NavigationTab(
      icon: Icons.pets_outlined,
      activeIcon: Icons.pets_rounded,
      label: 'Adoption',
      color: DesignSystem.greenSuccess,
    ),
    NavigationTab(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Réglages',
      color: DesignSystem.textSecondary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    
    // Animation controller pour la navigation
    _navigationController = AnimationController(
      duration: ModernAnimations.normalDuration,
      vsync: this,
    );
    
    // Controllers d'animation pour chaque icône
    _iconControllers = List.generate(
      _navigationTabs.length,
      (index) => AnimationController(
        duration: ModernAnimations.fastDuration,
        vsync: this,
      ),
    );
    
    // Anime l'icône active au démarrage
    _iconControllers[_currentIndex].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navigationController.dispose();
    for (final controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    // Feedback haptique
    HapticFeedback.selectionClick();

    // Animation des icônes
    _iconControllers[_currentIndex].reverse();
    _iconControllers[index].forward();

    setState(() {
      _currentIndex = index;
    });

    // Animation de la page
    _pageController.animateToPage(
      index,
      duration: ModernAnimations.normalDuration,
      curve: ModernAnimations.normalCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.backgroundDark,
      extendBody: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: DesignSystem.backgroundGradient,
            ),
          ),
          // Page content
          PageView(
            controller: _pageController,
            children: _screens.map((screen) => 
              ModernAnimations.fadeInWithDelay(
                child: screen,
                delay: const Duration(milliseconds: 100),
              ),
            ).toList(),
            onPageChanged: (index) {
              if (_currentIndex != index) {
                _onTabTapped(index);
              }
            },
            physics: const NeverScrollableScrollPhysics(),
          ),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNavigation(),
    );
  }

  Widget _buildModernBottomNavigation() {
    return Container(
      margin: const EdgeInsets.all(DesignSystem.spaceM),
      child: Container(
        decoration: BoxDecoration(
          color: DesignSystem.surfaceDark.withOpacity(0.95),
          borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: DesignSystem.elevationVeryHigh,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: DesignSystem.primaryPink.withOpacity(0.1),
              blurRadius: DesignSystem.elevationMedium,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceS,
              vertical: DesignSystem.spaceS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navigationTabs.length,
                (index) => _buildNavigationItem(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(int index) {
    final tab = _navigationTabs[index];
    final isSelected = _currentIndex == index;
    
    return ModernAnimations.pressableButton(
      onPressed: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: ModernAnimations.normalDuration,
        curve: ModernAnimations.normalCurve,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? DesignSystem.spaceM : DesignSystem.spaceS,
          vertical: DesignSystem.spaceS,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    tab.color.withOpacity(0.2),
                    tab.color.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          border: isSelected
              ? Border.all(
                  color: tab.color.withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône animée
            AnimatedBuilder(
              animation: _iconControllers[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_iconControllers[index].value * 0.2),
                  child: Icon(
                    isSelected ? tab.activeIcon : tab.icon,
                    color: isSelected ? tab.color : DesignSystem.textDisabled,
                    size: 24,
                  ),
                );
              },
            ),
            // Label avec animation
            AnimatedContainer(
              duration: ModernAnimations.normalDuration,
              curve: ModernAnimations.normalCurve,
              width: isSelected ? null : 0,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: DesignSystem.spaceS,
                      ),
                      child: Text(
                        tab.label,
                        style: DesignSystem.labelMedium.copyWith(
                          color: tab.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modèle de données pour les onglets de navigation
class NavigationTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const NavigationTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}