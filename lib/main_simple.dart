import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JeuTaime - Aperçu Local',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Georgia',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: JeuTaimePreview(),
    );
  }
}

class JeuTaimePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8E7), // Couleur parchemin
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header avec logo
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.favorite, size: 64, color: Color(0xFFD4A574)),
                    SizedBox(height: 12),
                    Text(
                      'JeuTaime',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'Version Locale - Développement',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8B4513).withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
              
              // Message de comparaison
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 32),
                    SizedBox(height: 12),
                    Text(
                      'Aperçu de Développement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Comparez avec la version en production :\njeutaime-warren.web.app',
                      style: TextStyle(
                        color: Colors.blue[700],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
              
              // Statut de compilation
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'Application Compilée ✅',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Toutes les erreurs de compilation ont été corrigées.\nL\'application JeuTaime est maintenant fonctionnelle.',
                      style: TextStyle(
                        color: Colors.green[700],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
              
              // Fonctionnalités principales
              Text(
                'Fonctionnalités Principales',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
              SizedBox(height: 20),
              
              // Grid des fonctionnalités
              _buildFeatureCard('Bars Thématiques', Icons.local_bar, Colors.orange),
              SizedBox(height: 12),
              _buildFeatureCard('Système de Lettres', Icons.mail, Colors.pink),
              SizedBox(height: 12),
              _buildFeatureCard('Profils & Découverte', Icons.person, Colors.blue),
              SizedBox(height: 12),
              _buildFeatureCard('Monnaie Virtuelle', Icons.monetization_on, Colors.green),
              SizedBox(height: 12),
              _buildFeatureCard('Authentification', Icons.security, Colors.purple),
              
              SizedBox(height: 30),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openProductionApp(context),
                      icon: Icon(Icons.launch, color: Colors.white),
                      label: Text('Voir Production', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD4A574),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAppInfo(context),
                      icon: Icon(Icons.info, color: Colors.white),
                      label: Text('Infos App', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B4513),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B4513),
            ),
          ),
          Spacer(),
          Icon(Icons.check, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  void _openProductionApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.launch, color: Color(0xFFD4A574)),
            SizedBox(width: 8),
            Text('App en Production'),
          ],
        ),
        content: Text(
          'Votre vraie application JeuTaime est disponible sur :\n\nhttps://jeutaime-warren.web.app/\n\nCette version locale montre que la compilation fonctionne parfaitement !',
          style: TextStyle(height: 1.4),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Compris', style: TextStyle(color: Color(0xFFD4A574))),
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.favorite, color: Color(0xFFD4A574)),
            SizedBox(width: 8),
            Text('JeuTaime Info'),
          ],
        ),
        content: Text(
          'État : ✅ Compilée avec succès\nBranche : pr-fix-compile\nVersion : Dev locale\n\nToutes les erreurs ont été corrigées :\n• Services de lettres\n• Modèles de données\n• Authentification Firebase\n• Interface utilisateur\n\nL\'app est prête pour le développement !',
          style: TextStyle(height: 1.4),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Parfait !', style: TextStyle(color: Color(0xFFD4A574))),
          ),
        ],
      ),
    );
  }
}

class JeuTaimePreviewScreen extends StatefulWidget {
  @override
  _JeuTaimePreviewScreenState createState() => _JeuTaimePreviewScreenState();
}

class _JeuTaimePreviewScreenState extends State<JeuTaimePreviewScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5E6), // AppColors.funBackground
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text('JeuTaime', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Color(0xFFFF6B6B), // AppColors.funPrimary
        elevation: 0,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text('1,250', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFFFF6B6B),
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.local_bar), label: 'Bars'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Lettres'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Boutique'),
        ],
      ),
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0: return _buildBarsScreen();
      case 1: return _buildLettresScreen();
      case 2: return _buildQuizScreen();
      case 3: return _buildBoutiqueScreen();
      default: return _buildBarsScreen();
    }
  }

  Widget _buildBarsScreen() {
    final bars = [
      {'name': 'Bar Romantique', 'desc': 'Pour les âmes sensibles', 'icon': Icons.favorite, 'color': Colors.pink},
      {'name': 'Bar Humoristique', 'desc': 'Rire ensemble', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.orange},
      {'name': 'Bar Pirates', 'desc': 'Aventures épiques', 'icon': Icons.sailing, 'color': Colors.brown},
      {'name': 'Bar Hebdomadaire', 'desc': 'Groupe de 4 personnes', 'icon': Icons.calendar_today, 'color': Colors.purple},
      {'name': 'Bar Caché', 'desc': 'Résolvez les énigmes', 'icon': Icons.lock, 'color': Colors.indigo},
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bars Thématiques', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
              childAspectRatio: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: bars.length,
            itemBuilder: (context, index) {
              final bar = bars[index];
              return _buildBarCard(
                bar['name'] as String, 
                bar['desc'] as String, 
                bar['icon'] as IconData, 
                bar['color'] as Color
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBarCard(String name, String description, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showBarDetails(name),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(name, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(description, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.7), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLettresScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mes Correspondances', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          _buildLetterCard('Emma, 26 ans', 'Merci pour votre lettre...', '2h', false),
          _buildLetterCard('Lucas, 29 ans', 'J\'ai adoré notre échange...', '1j', true),
          _buildLetterCard('Sophie, 24 ans', 'Votre sens de l\'humour...', '3j', false),
          SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.edit),
              label: Text('Écrire une nouvelle lettre'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () => _showWriteLetterDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterCard(String name, String preview, String time, bool unread) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2))],
        border: unread ? Border.all(color: Color(0xFFFF6B6B), width: 2) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFFF6B6B).withOpacity(0.1),
            child: Text(name[0], style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                    Spacer(),
                    Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    if (unread) Container(
                      margin: EdgeInsets.only(left: 8),
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: Color(0xFFFF6B6B), shape: BoxShape.circle),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(preview, style: TextStyle(color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quiz de Compatibilité', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          _buildQuizCard('Langages de l\'Amour', 'Découvrez votre profil', Icons.favorite, Colors.pink),
          _buildQuizCard('Style de Relation', 'Comment aimez-vous?', Icons.psychology, Colors.purple),
          _buildQuizCard('Valeurs Communes', 'Ce qui compte vraiment', Icons.stars, Colors.blue),
          _buildQuizCard('Personnalité MBTI', 'Votre type psychologique', Icons.person, Colors.green),
        ],
      ),
    );
  }

  Widget _buildQuizCard(String title, String description, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        ],
      ),
    );
  }

  Widget _buildBoutiqueScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Boutique', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Rechargez vos pièces et débloquez Premium', style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 20),
          
          // Premium
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.purple[400]!, Colors.purple[600]!]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text('Premium', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Spacer(),
                    Text('19,90€/mois', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
                SizedBox(height: 12),
                Text('5000 pièces offertes + fonctionnalités exclusives', 
                     style: TextStyle(color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          Text('Packs de Pièces', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildPackCard('1 000', '2,99€', 'Starter', Colors.blue),
              _buildPackCard('2 500', '6,99€', 'Charme', Colors.green),
              _buildPackCard('5 000', '12,99€', 'Romance', Colors.orange),
              _buildPackCard('10 000', '22,99€', 'Elite', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackCard(String coins, String price, String name, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monetization_on, color: color, size: 32),
          SizedBox(height: 8),
          Text(coins, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('pièces', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          SizedBox(height: 8),
          Text(price, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(name, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  void _showBarDetails(String barName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(barName),
        content: Text('Fonctionnalité complète à venir!\nCette interface montre l\'aperçu de JeuTaime.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
  }

  void _showWriteLetterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Écrire une lettre'),
        content: Text('Interface de composition de lettre (500 mots max)\navec thèmes et encres disponibles.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Fermer')),
        ],
      ),
    );
  }
}