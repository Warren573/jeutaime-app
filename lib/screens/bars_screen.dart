/**
 * RÉFÉRENCE OBLIGATOIRE: https://jeutaime-warren.web.app/
 * 
 * Reproduit l'onglet Bars de la référence
 * 5 bars thématiques
 */

import 'package:flutter/material.dart';
import '../config/ui_reference.dart';
import '../models/bar_content.dart';
import '../widgets/enhanced_bar_card.dart';

class BarsScreen extends StatefulWidget {
  @override
  _BarsScreenState createState() => _BarsScreenState();
}

class _BarsScreenState extends State<BarsScreen> {
  late List<BarContent> allBars;
  Map<String, bool> unlockedBars = {};

  @override
  void initState() {
    super.initState();
    allBars = BarContentService.getAllBars();
    
    // Simuler les conditions de déblocage
    unlockedBars = {
      'romantic': true,  // Toujours débloqué
      'humor': true,     // Toujours débloqué
      'pirates': true,   // Peut être verrouillé selon les conditions
      'weekly': false,   // Nécessite niveau 5
      'hidden': false,   // Nécessite énigme
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIReference.colors['background'],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              UIReference.colors['background']!,
              UIReference.colors['accent']!.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStatsSection(),
              Expanded(
                child: _buildBarsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Text('🍸', style: TextStyle(fontSize: 28)),
          SizedBox(width: 15),
          Text(
            'Nos Bars',
            style: UIReference.titleStyle.copyWith(fontSize: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    int unlockedCount = unlockedBars.values.where((unlocked) => unlocked).length;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.lock_open,
            label: 'Débloqués',
            value: '$unlockedCount/${allBars.length}',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.people,
            label: 'Membres',
            value: '1.2k',
            color: UIReference.colors['primary']!,
          ),
          _buildStatItem(
            icon: Icons.star,
            label: 'Points',
            value: '850',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Georgia',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontFamily: 'Georgia',
          ),
        ),
      ],
    );
  }

  Widget _buildBarsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4),
      itemCount: allBars.length,
      itemBuilder: (context, index) {
        final barContent = allBars[index];
        final isUnlocked = unlockedBars[barContent.id] ?? false;
        
        return EnhancedBarCard(
          barContent: barContent,
          isUnlocked: isUnlocked,
          onTap: () => _handleBarTap(barContent, isUnlocked),
        );
      },
    );
  }

  void _handleBarTap(BarContent barContent, bool isUnlocked) {
    if (isUnlocked) {
      // Navigation vers l'écran de détail du bar (déjà géré dans EnhancedBarCard)
    } else {
      _showUnlockDialog(barContent);
    }
  }

  void _showUnlockDialog(BarContent barContent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(barContent.emoji, style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                barContent.name,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ce bar est actuellement verrouillé.',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Condition de déblocage:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              ),
            ),
            SizedBox(height: 4),
            Text(
              barContent.unlockCondition ?? 'Conditions non définies',
              style: TextStyle(
                color: barContent.themeColor,
                fontFamily: 'Georgia',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: TextStyle(
                color: barContent.themeColor,
                fontFamily: 'Georgia',
              ),
            ),
          ),
          if (barContent.id == 'weekly' || barContent.id == 'pirates')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _unlockBar(barContent.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: barContent.themeColor,
              ),
              child: Text(
                'Débloquer',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _unlockBar(String barId) {
    setState(() {
      unlockedBars[barId] = true;
    });
    
    final barContent = allBars.firstWhere((bar) => bar.id == barId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 ${barContent.name} débloqué !'),
        backgroundColor: barContent.themeColor,
      ),
    );
  }
}