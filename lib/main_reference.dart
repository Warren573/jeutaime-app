// IMPORTANT: Cette app doit reproduire EXACTEMENT https://jeutaime-warren.web.app/
// Style: dégradés chaleureux bois/romantique, navigation bottom avec 7 onglets
// Structure: même écrans, même UI, même fonctionnalités que la demo existante

/**
 * RÉFÉRENCE OBLIGATOIRE: https://jeutaime-warren.web.app/
 * 
 * Cette application principale doit avoir EXACTEMENT:
 * - Navigation bottom : 7 onglets (🏠 Accueil | 👤 Profils | 🍸 Bars | 💌 Lettres | 🛍️ Boutique | 📖 Journal | ⚙️ Paramètres)
 * - Style bois chaleureux avec dégradés
 * - Même structure que la démo de référence
 */

import 'package:flutter/material.dart';
import 'config/ui_reference.dart';
import 'screens/home_screen.dart';
import 'screens/profiles_screen.dart'; 
import 'screens/bars_screen.dart';
import 'screens/letters_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(JeuTaimeApp());
}

class JeuTaimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime - Reproduction exacte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: UIReference.colors['primary'],
        fontFamily: 'Georgia', // Police Georgia comme sur le site
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainAppScreen(),
    );
  }
}

/**
 * MainAppScreen - Reproduit https://jeutaime-warren.web.app/
 * Navigation bottom avec 7 onglets EXACTEMENT comme la référence
 */
class MainAppScreen extends StatefulWidget {
  @override
  _MainAppScreenState createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  // Les 6 écrans correspondant aux 6 onglets de la référence (Boutique maintenant dans Paramètres)
  final List<Widget> _screens = [
    HomeScreen(),      // 🏠 Accueil - grille des bars + header avec pièces
    ProfilesScreen(),  // 👤 Profils - stack de cartes + actions like/pass
    BarsScreen(),      // 🍸 Bars - 5 bars thématiques
    LettersScreen(),   // 💌 Lettres - correspondances authentiques
    JournalScreen(),   // 📖 Journal - badges + historique activités
    SettingsScreen(),  // ⚙️ Paramètres (contient maintenant la Boutique)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIReference.colors['background'],
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /**
   * Navigation bottom avec 7 onglets EXACTEMENT comme https://jeutaime-warren.web.app/
   * 🏠 Accueil | 👤 Profils | 🍸 Bars | 💌 Lettres | 🛍️ Boutique | 📖 Journal | ⚙️ Paramètres
   */
  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: UIReference.colors['cardBackground'],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(UIReference.navigationTabs.length, (index) {
              final tab = UIReference.navigationTabs[index];
              final isSelected = _selectedIndex == index;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tab['icon']!,
                        style: TextStyle(
                          fontSize: isSelected ? 24 : 20,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        tab['label']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Georgia',
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected 
                            ? UIReference.colors['primary']
                            : UIReference.colors['textSecondary'],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}