# JeuTaime - Brief de Développement Complet

## 🎯 Objectif
Adapter l'application web JeuTaime existante (https://jeutaime-warren.web.app/) vers Flutter tout en gardant EXACTEMENT le même design visuel et la même architecture fonctionnelle.

## 📐 Design Visuel à Reproduire

### Palette de Couleurs (à remplacer dans AppColors)
```dart
class AppColors {
  // Couleurs principales (basées sur l'app web existante)
  static const Color primaryBrown = Color(0xFF8B4513); // Brun principal
  static const Color lightBrown = Color(0xFFA0522D);   // Brun clair
  static const Color beige = Color(0xFFF5F5DC);        // Beige
  static const Color goldAccent = Color(0xFFFFD700);   // Or pour les pièces
  static const Color textDark = Color(0xFF2C3E50);     // Texte sombre
  
  // Dégradé de fond principal
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF8B7355), Color(0xFFA0956B), Color(0xFFD2B48C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dégradé navigation
  static const LinearGradient navGradient = LinearGradient(
    colors: [Color(0xFF8B4513), Color(0xFFA0522D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Couleurs des bars (identiques au web)
  static const Color romanticBar = Color(0xFFE91E63);    // Rose romantique
  static const Color humorousBar = Color(0xFFFF9800);    // Orange humoristique
  static const Color pirateBar = Color(0xFF8B4513);      // Brun pirate
  static const Color weeklyBar = Color(0xFF4169E1);      // Bleu hebdo
  static const Color mysteryBar = Color(0xFF9400D3);     // Violet mystère
}
```

### Typographie
- **Police principale** : Georgia (pour élégance)
- **Fallback** : Times New Roman, serif
- **Tailles** : 
  - Titre principal : 1.8em (~29sp)
  - Sous-titres : 1.2em (~19sp)
  - Corps de texte : 1.0em (~16sp)
  - Petit texte : 0.8em (~13sp)

### Effets Visuels Critiques
1. **Backdrop blur** : `backdrop-filter: blur(20px)`
2. **Ombres** : `box-shadow: 0 4px 15px rgba(0,0,0,0.1)`
3. **Border radius** : 15px-25px selon les éléments
4. **Transparence** : `rgba(245,245,220,0.9)` pour les cartes

## 🏗️ Architecture de l'App

### Structure des Écrans
```
lib/
├── main.dart
├── screens/
│   ├── home/
│   │   └── home_screen.dart           # Écran principal avec les bars
│   ├── bars/
│   │   ├── romantic_bar_screen.dart   # Bar romantique
│   │   ├── humorous_bar_screen.dart   # Bar humoristique
│   │   ├── pirate_bar_screen.dart     # Bar pirates
│   │   └── letters_screen.dart        # "Mes Lettres" (4ème bar)
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── widgets/
│   ├── common/
│   │   ├── bottom_navigation.dart     # Navigation principale
│   │   ├── app_header.dart           # Header avec pièces
│   │   └── back_button.dart          # Bouton retour custom
│   ├── bars/
│   │   ├── bar_card.dart             # Carte d'un bar
│   │   └── bar_activity_card.dart    # Activité dans un bar
│   └── effects/
│       └── glass_morphism.dart       # Effet glassmorphism
├── theme/
│   ├── app_colors.dart               # À REMPLACER
│   ├── app_themes.dart               # Thèmes globaux
│   └── text_styles.dart             # Styles de texte
└── services/
    └── firebase_service.dart         # Services Firebase
```

## 📱 Navigation Bottom Nav (5 onglets)

Reproduire exactement la navigation web :
```dart
class BottomNavigation extends StatelessWidget {
  final List<NavItem> items = [
    NavItem(icon: "🏠", label: "Accueil", route: "/home"),
    NavItem(icon: "👤", label: "Profils", route: "/profiles"),
    NavItem(icon: "🍸", label: "Bars", route: "/bars"),
    NavItem(icon: "💌", label: "Lettres", route: "/letters"),
    NavItem(icon: "⚙️", label: "Paramètres", route: "/settings"),
  ];
}
```

**Styles critiques** :
- Position : `fixed bottom`
- Background : Dégradé brun `navGradient`
- Border radius : `25px 25px 0 0`
- Backdrop blur pour transparence
- Animation hover : `translateY(-2px)`

## 🎨 Écran Accueil (HomeScreen)

### Header Principal
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0x998B4513), Color(0x99A0522D)],
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Column(
    children: [
      Text("🏛️ JeuTaime", style: titleStyle),
      Text("L'art de la rencontre authentique", style: subtitleStyle),
      UserInfoRow(
        userName: "Warren",
        userStatus: "📍 Profil : Nouvel arrivant",
        coins: 1000,
      ),
    ],
  ),
)
```

### Grille des Bars
4 cartes disposées verticalement :

1. **🌹 Bar Romantique**
   - Couleur : `Color(0xFFE91E63)`
   - Stats : "12 personnes • 3 groupes actifs"

2. **😄 Bar Humoristique**
   - Couleur : `Color(0xFFFF9800)`
   - Stats : "18 personnes • Défi du jour actif"

3. **🏴‍☠️ Bar Pirates**
   - Couleur : `Color(0xFF8B4513)`
   - Stats : "15 personnes • Chasse au trésor"

4. **💌 Mes Lettres**
   - Couleur : `Color(0xFF4169E1)`
   - Description : "Correspondances authentiques"

## 🍸 Écrans de Bars

### Structure Commune
```dart
Scaffold(
  body: Container(
    decoration: BoxDecoration(gradient: backgroundGradient),
    child: SafeArea(
      child: Column(
        children: [
          CustomBackButton(),
          BarHeader(barName: "...", subtitle: "...", participants: 12),
          Expanded(
            child: ListView(
              children: [
                BarContentCard(title: "Bienvenue...", content: "..."),
                ActivitiesCard(activities: [...]),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
)
```

### Bar Romantique - Contenu Spécifique
**Activités** :
- 💝 Compliments sincères (+25 pièces)
- 📝 Poèmes express (+40 pièces)
- 🌟 Partage de souvenirs (+35 pièces)
- 💭 Citations préférées (+30 pièces)
- 💌 Lettres d'amour Premium

**Groupes** :
- "Poésie & Émotions"
- "Voyages Romantiques"

### Bar Humoristique - Contenu Spécifique
**Défi du jour** : "Racontez votre pire blague avec le plus de sérieux possible" (+100 pièces)

**Activités** :
- 😂 Blague du siècle (+30 pièces)
- 🎭 Mime express (+40 pièces)
- 📖 Histoire absurde (+35 pièces)
- 🤹 Bataille calembours (+25 pièces)
- 🎪 Improv sketch (+50 pièces)

**Groupes** :
- "Stand-up Amateurs"
- "Jeux de Mots & Cie"

### Bar Pirates - Contenu Spécifique
**Chasse au trésor** : "L'île mystérieuse" - 3 énigmes (+150 pièces)

**Activités** :
- ⚔️ Récit d'aventure (+40 pièces)
- 🧭 Énigme de navigation (+50 pièces)
- 🏴‍☠️ Défi de courage (+35 pièces)
- 🗺️ Carte au trésor (+45 pièces)
- 🐙 Légende nautique (+60 pièces)

**Équipages** :
- "Les Corsaires du Rhum"
- "Chasseurs de Légendes"

## 🎨 Composants Réutilisables

### 1. BarCard Widget
```dart
class BarCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final String stats;
  final Color accentColor;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: // ... contenu de la carte
      ),
    );
  }
}
```

### 2. GlassMorphism Effect
```dart
class GlassMorphism extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

### 3. CoinsDisplay Widget
```dart
class CoinsDisplay extends StatelessWidget {
  final int coins;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        "💰 $coins pièces",
        style: TextStyle(
          color: Color(0xFF8B4513),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
```

## 🔧 Tâches de Développement Prioritaires

### Phase 1 : Structure et Design (Semaine 1)
1. **Remplacer AppColors** avec les couleurs exactes du web
2. **Créer AppThemes** avec les dégradés et effets
3. **Implémenter BottomNavigation** identique au web
4. **Créer HomeScreen** avec header et grille des bars
5. **Développer BarCard** avec animations hover

### Phase 2 : Écrans de Bars (Semaine 2)
1. **RomanticBarScreen** avec toutes ses activités
2. **HumorousBarScreen** avec défi du jour
3. **PirateBarScreen** avec chasse au trésor
4. **LettersScreen** (4ème bar du web)
5. **Navigation** entre écrans fluide

### Phase 3 : Composants Avancés (Semaine 3)
1. **GlassMorphism** effect parfait
2. **Animations** de cartes et boutons
3. **CustomBackButton** avec style web
4. **ActivityCard** pour chaque activité
5. **UserInfoRow** avec données dynamiques

### Phase 4 : Intégration Firebase (Semaine 4)
1. **Firebase Auth** (existant à adapter)
2. **Firestore** pour données utilisateur
3. **Gestion des pièces** en temps réel
4. **États** des bars et participants
5. **Synchronisation** avec le backend web

## 🎯 Critères de Réussite

### Visual Fidelity (90%+)
- [ ] Couleurs exactement identiques
- [ ] Dégradés reproduits fidèlement  
- [ ] Typography Georgia correctement appliquée
- [ ] Effets glassmorphism fonctionnels
- [ ] Animations smooth et identiques

### Functional Fidelity (100%)
- [ ] Navigation identique à la web app
- [ ] Écrans des bars avec même contenu
- [ ] Système de pièces visible partout
- [ ] États des groupes/participants corrects
- [ ] Firebase intégré et fonctionnel

### Performance
- [ ] Chargement < 3s
- [ ] Animations 60fps
- [ ] Pas de lag navigation
- [ ] Gestion mémoire optimisée

## 📝 Notes Importantes

1. **NE PAS** changer l'UI/UX existante - reproduire exactement
2. **GARDER** la même architecture d'écrans que le web
3. **RESPECTER** les couleurs et gradients à la perfection
4. **MAINTENIR** la cohérence visuelle à 100%
5. **OPTIMISER** pour mobile tout en gardant le design

## 🚀 Commande de Démarrage

**Claude, commence par :**
1. Remplacer complètement `lib/theme/app_colors.dart` avec les nouvelles couleurs
2. Créer le nouveau `bottom_navigation.dart` identique au web
3. Restructurer `home_screen.dart` pour matcher l'écran d'accueil web
4. Implémenter les 4 écrans de bars avec leur contenu exact

**Objectif** : Une application Flutter qui ressemble à 95%+ à https://jeutaime-warren.web.app/ 

Commençons ! 🎯