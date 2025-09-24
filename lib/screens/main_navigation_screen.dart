import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/letters/letters_screen.dart';
import '../screens/messages/messages_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/bars_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/matching/matching_screen.dart';
import '../config/ui_reference.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late PageController _pageController;

  final List<Widget> _screens = [
    MatchingScreen(),       // 0 - Découvrir (Matching)
    ChatListScreen(),       // 1 - Chat
    const LettersScreen(),  // 2 - Lettres
    BarsScreen(),           // 3 - Bars  
    ShopScreen(),           // 4 - Boutique
    ProfileScreen(),        // 5 - Profil
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: UIReference.white,
          boxShadow: [
            BoxShadow(
              color: UIReference.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.favorite_rounded,
                  label: 'Découvrir',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.chat_rounded,
                  label: 'Chat',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.mail_rounded,
                  label: 'Lettres',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.local_bar_rounded,
                  label: 'Bars',
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.shopping_bag_rounded,
                  label: 'Shop',
                ),
                _buildNavItem(
                  index: 5,
                  icon: Icons.person_rounded,
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? UIReference.primaryColor.withOpacity(0.15)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected 
                  ? UIReference.primaryColor
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected 
                  ? UIReference.white 
                  : UIReference.textSecondary,
                size: isSelected ? 22 : 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                  ? UIReference.primaryColor 
                  : UIReference.textSecondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: UIReference.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}