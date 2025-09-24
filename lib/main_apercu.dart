import 'package:flutter/material.dart';

void main() {
  runApp(JeuTaimeApp());
}

class JeuTaimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime - Aperçu',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Georgia',
      ),
      home: ApercuScreen(),
    );
  }
}

class ApercuScreen extends StatefulWidget {
  @override
  _ApercuScreenState createState() => _ApercuScreenState();
}

class _ApercuScreenState extends State<ApercuScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5E6),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'JeuTaime',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFFFF6B6B),
        elevation: 0,
        actions: [
          Icon(Icons.favorite_border, color: Colors.white),
          SizedBox(width: 8),
          Text('245', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(width: 16),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFFFF6B6B),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Lettres'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Boutique'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildBarsTab();
      case 1:
        return _buildLettresTab();
      case 2:
        return _buildQuizTab();
      case 3:
        return _buildBoutiqueTab();
      default:
        return _buildBarsTab();
    }
  }

  Widget _buildBarsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bars Thématiques',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          Text(
            'Choisissez votre ambiance pour des rencontres authentiques',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20),
          _buildBarCard(
            '🌹 Bar Romantique',
            'Pour les âmes sensibles et les cœurs passionnés',
            Colors.pink,
            '12 personnes',
          ),
          _buildBarCard(
            '😄 Bar Humoristique',
            'Rire ensemble, c\'est déjà s\'aimer un peu',
            Colors.orange,
            '8 personnes',
          ),
          _buildBarCard(
            '🏴‍☠️ Bar Pirates',
            'Aventures et trésors cachés vous attendent',
            Colors.indigo,
            '15 personnes',
          ),
          _buildBarCard(
            '📅 Bar Hebdomadaire',
            'Thème de la semaine : "Voyages de rêve"',
            Colors.purple,
            '6 personnes',
          ),
          _buildBarCard(
            '👑 Bar Caché',
            'Résolvez l\'énigme pour accéder aux secrets...',
            Colors.deepPurple,
            'Exclusif',
          ),
        ],
      ),
    );
  }

  Widget _buildBarCard(String title, String description, Color color, String status) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ouverture du $title')),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    title.split(' ')[0],
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.substring(2), // Enlève l'emoji
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLettresTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💌 Mes Lettres',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _buildLettreCard('Marie, 26 ans', 'Merci pour ce merveilleux poème...', '2 min'),
          _buildLettreCard('Sophie, 24 ans', 'Votre blague m\'a fait beaucoup rire !', '1h'),
          _buildLettreCard('Emma, 28 ans', 'Cette aventure pirate était géniale...', '1j'),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ouverture du composeur de lettres')),
              );
            },
            icon: Icon(Icons.edit),
            label: Text('Écrire une nouvelle lettre'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLettreCard(String nom, String apercu, String temps) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFFF6B6B),
            child: Text(nom[0], style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nom, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(apercu, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Text(temps, style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuizTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 Quiz & Compatibilité',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _buildQuizCard('💝 Langages de l\'Amour', 'Découvrez comment vous exprimez l\'amour', Colors.pink),
          _buildQuizCard('🎭 Test de Personnalité', 'Quel type d\'amoureux êtes-vous ?', Colors.purple),
          _buildQuizCard('🌟 Compatibilité Astrale', 'Les étoiles influencent-elles vos relations ?', Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildQuizCard(String title, String description, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(description, style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Démarrage du quiz : $title')),
              );
            },
            child: Text('Commencer'),
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBoutiqueTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🛍️ Boutique',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _buildPackCard('Pack Starter', '1 000 pièces', '2,99€', Colors.green),
          _buildPackCard('Pack Charme', '2 500 pièces', '6,99€', Colors.orange),
          _buildPackCard('Pack Romance', '5 000 pièces', '12,99€', Colors.pink),
          _buildPackCard('Pack Elite', '10 000 pièces', '22,99€', Colors.purple),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '👑 Premium',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '19,90€/mois',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  '• 5000 pièces offertes\n• Accès prioritaire aux bars\n• Fonctionnalités exclusives',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackCard(String titre, String pieces, String prix, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.monetization_on, color: Colors.white, size: 30),
            ),
            SizedBox(height: 12),
            Text(titre, 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(pieces, style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 8),
            Text(prix, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              child: Text('Acheter'),
              style: ElevatedButton.styleFrom(backgroundColor: color),
            ),
          ],
        ),
      ),
    );
  }
}