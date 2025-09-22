import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bar_card.dart';
import '../models/bar_model.dart';
import '../theme/app_colors.dart';
import 'bars/romantic_bar_screen.dart';
import 'bars/humor_bar_screen.dart';
import 'bars/weekly_bar_screen.dart';
import 'bars/mystery_bar_screen.dart';
import 'bars/random_bar_screen.dart';
import 'profile/profile_screen.dart';
import 'messages/messages_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isFunMode = true; // Mode fun/sérieux

  final List<BarModel> bars = [
    BarModel(
      id: 'romantic',
      name: 'Bar Romantique',
      description: 'Pour les âmes sensibles et les cœurs passionnés',
      icon: Icons.favorite,
      color: Colors.pink,
      illustration: 'assets/bars/romantic_bar.png',
    ),
    BarModel(
      id: 'humor',
      name: 'Bar Humoristique',
      description: 'Rire ensemble, c\'est déjà s\'aimer un peu',
      icon: Icons.sentiment_very_satisfied,
      color: Colors.orange,
      illustration: 'assets/bars/humor_bar.png',
    ),
    BarModel(
      id: 'weekly',
      name: 'Bar Hebdomadaire',
      description: 'Le thème change chaque semaine',
      icon: Icons.calendar_today,
      color: Colors.purple,
      illustration: 'assets/bars/weekly_bar.png',
    ),
    BarModel(
      id: 'mystery',
      name: 'Bar Mystère',
      description: 'Résolvez l\'énigme pour entrer',
      icon: Icons.lock,
      color: Colors.indigo,
      illustration: 'assets/bars/mystery_bar.png',
    ),
    BarModel(
      id: 'random',
      name: 'Bar Aléatoire',
      description: 'Laissez le hasard décider de vos rencontres',
      icon: Icons.shuffle,
      color: Colors.teal,
      illustration: 'assets/bars/random_bar.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isFunMode ? AppColors.funBackground : AppColors.seriousBackground,
      appBar: AppBar(
        title: Text(
          'JeuTaime',
          style: TextStyle(
            fontFamily: _isFunMode ? 'ComicSans' : 'Montserrat',
            fontWeight: FontWeight.bold,
            color: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFunMode ? Icons.sentiment_very_satisfied : Icons.business_center),
            onPressed: () => setState(() => _isFunMode = !_isFunMode),
            tooltip: _isFunMode ? 'Mode sérieux' : 'Mode fun',
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildBarsGrid() : _buildOtherScreens(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Bars',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Boutique',
          ),
        ],
      ),
    );
  }

  Widget _buildBarsGrid() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisissez votre ambiance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _isFunMode ? AppColors.funText : AppColors.seriousText,
              fontFamily: _isFunMode ? 'ComicSans' : 'Montserrat',
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Chaque bar a sa personnalité unique',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: _isFunMode ? 'ComicSans' : 'Montserrat',
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: bars.length,
              itemBuilder: (context, index) {
                return BarCard(
                  bar: bars[index],
                  isFunMode: _isFunMode,
                  onTap: () => _navigateToBar(bars[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherScreens() {
    switch (_selectedIndex) {
      case 1:
        return MessagesScreen();
      case 2:
        return Center(child: Text('Quiz à venir'));
      case 3:
        return Center(child: Text('Boutique à venir'));
      default:
        return _buildBarsGrid();
    }
  }

  void _navigateToBar(BarModel bar) {
    Widget screen;
    
    switch (bar.id) {
      case 'romantic':
        screen = RomanticBarScreen();
        break;
      case 'humor':
        screen = HumorBarScreen();
        break;
      case 'weekly':
        screen = WeeklyBarScreen();
        break;
      case 'mystery':
        screen = MysteryBarScreen();
        break;
      case 'random':
        screen = RandomBarScreen();
        break;
      default:
        return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
