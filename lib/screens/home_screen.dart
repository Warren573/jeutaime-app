import 'package:flutter/material.dart';
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

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      _BarsTabScreen(isFunMode: _isFunMode, bars: bars, navigateToBar: _navigateToBar),
      MessagesScreen(),
      _QuizTabScreen(),
      _ShopTabScreen(),
    ]);
  }

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
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _BarsTabScreen(isFunMode: _isFunMode, bars: bars, navigateToBar: _navigateToBar),
          MessagesScreen(),
          _QuizTabScreen(),
          _ShopTabScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: _isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_bar),
              activeIcon: Icon(Icons.local_bar, size: 28),
              label: 'Bars',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble, size: 28),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.quiz_outlined),
              activeIcon: Icon(Icons.quiz, size: 28),
              label: 'Quiz',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined),
              activeIcon: Icon(Icons.store, size: 28),
              label: 'Boutique',
            ),
          ],
        ),
      ),
    );
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

// Onglet des Bars
class _BarsTabScreen extends StatelessWidget {
  final bool isFunMode;
  final List<BarModel> bars;
  final Function(BarModel) navigateToBar;
  
  const _BarsTabScreen({
    required this.isFunMode,
    required this.bars,
    required this.navigateToBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isFunMode ? AppColors.funBackground : AppColors.seriousBackground,
      appBar: AppBar(
        title: Text(
          'JeuTaime',
          style: TextStyle(
            fontFamily: isFunMode ? 'ComicSans' : 'Montserrat',
            fontWeight: FontWeight.bold,
            color: isFunMode ? AppColors.funPrimary : AppColors.seriousPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisissez votre ambiance',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isFunMode ? AppColors.funText : AppColors.seriousText,
                fontFamily: isFunMode ? 'ComicSans' : 'Montserrat',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Chaque bar a sa personnalité unique',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: isFunMode ? 'ComicSans' : 'Montserrat',
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: bars.length,
                itemBuilder: (context, index) {
                  return BarCard(
                    bar: bars[index],
                    isFunMode: isFunMode,
                    onTap: () => navigateToBar(bars[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Onglet Quiz
class _QuizTabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz & Jeux'),
        backgroundColor: AppColors.funSecondary,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.psychology, color: AppColors.funPrimary),
                title: Text('Quiz de compatibilité'),
                subtitle: Text('Découvrez votre personnalité amoureuse'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Naviguer vers le quiz
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.games, color: AppColors.funSecondary),
                title: Text('Jeux d\'interaction'),
                subtitle: Text('Brise-glace et activités amusantes'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Naviguer vers les jeux
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Onglet Boutique
class _ShopTabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boutique'),
        backgroundColor: AppColors.funAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.star, color: Colors.amber),
                title: Text('Premium'),
                subtitle: Text('Accès illimité à tous les bars'),
                trailing: Text('9.99€/mois'),
                onTap: () {
                  // TODO: Naviguer vers l'abonnement premium
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.monetization_on, color: AppColors.funAccent),
                title: Text('Pièces'),
                subtitle: Text('Achetez des pièces virtuelles'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Naviguer vers l'achat de pièces
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Suppression des anciennes méthodes
