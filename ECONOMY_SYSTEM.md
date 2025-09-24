# 🛍️ Système d'Économie JeuTaime - Documentation Complète

## 📋 Vue d'ensemble

Le système d'économie de JeuTaime est un système complet de monnaie virtuelle avec boutique intégrée, récompenses quotidiennes, et gestion des transactions. Il comprend 3 devises, 7 catégories d'articles, un système de rareté à 5 niveaux, et des mécaniques de progression.

## 💰 Système de Monnaies

### 🪙 Pièces (Coins) - Monnaie Principale
- **ID**: `coins`
- **Symbole**: 🪙
- **Couleur**: Ambre
- **Usage**: Monnaie principale pour achats courants
- **Obtention**: Actions quotidiennes, mini-jeux, progression

### 💕 Cœurs (Hearts) - Monnaie Romantique  
- **ID**: `hearts`
- **Symbole**: 💕
- **Couleur**: Rose/Rouge
- **Usage**: Actions romantiques, cadeaux spéciaux
- **Obtention**: Interactions romantiques, lettres d'amour, matches réussis

### 💎 Gemmes (Gems) - Monnaie Premium
- **ID**: `gems`
- **Symbole**: 💎
- **Couleur**: Bleu/Violet
- **Usage**: Articles premium, fonctionnalités exclusives
- **Obtention**: Achats in-app, succès majeurs, événements spéciaux

## 🛒 Système de Boutique

### 📱 Catégories d'Articles

1. **🎭 Avatars** (`avatars`)
   - Personnalisations de profil
   - Accessoires et costumes
   - Expressions faciales

2. **🎨 Décorations** (`decorations`)
   - Cadres de profil
   - Arrière-plans personnalisés
   - Bordures spéciales

3. **🎨 Thèmes** (`themes`)
   - Thèmes d'interface
   - Palettes de couleurs
   - Styles visuels

4. **⚡ Consommables** (`consumables`)
   - Boosters temporaires
   - Super-likes
   - Multiplicateurs d'XP

5. **⭐ Premium** (`premium`)
   - Fonctionnalités exclusives
   - Accès anticipé
   - Avantages VIP

6. **🏆 Édition Limitée** (`limited`)
   - Articles événementiels
   - Collectibles rares
   - Exclusivités temporaires

7. **🎪 Saisonniers** (`seasonal`)
   - Articles thématiques
   - Décorations festives
   - Événements spéciaux

### 🏆 Système de Rareté

1. **Commun** - Gris (`#9E9E9E`)
2. **Rare** - Bleu (`#2196F3`) 
3. **Épique** - Violet (`#9C27B0`)
4. **Légendaire** - Orange (`#FF9800`)
5. **Mythique** - Rouge (`#F44336`)

## 🎁 Système de Récompenses Quotidiennes

### 📅 Cycle de 7 Jours
- **Jour 1**: 50 🪙 Pièces
- **Jour 2**: 75 🪙 Pièces
- **Jour 3**: 5 💕 Cœurs
- **Jour 4**: 100 🪙 Pièces
- **Jour 5**: 10 💕 Cœurs
- **Jour 6**: 150 🪙 Pièces  
- **Jour 7**: 3 💎 Gemmes (BONUS)

### ⭐ Fonctionnalités
- Interface animée avec étincelles
- Progression visuelle sur 7 jours
- Bonus spécial le 7ème jour
- Sauvegarde automatique de l'état
- Notification de disponibilité

## 🔄 Système de Transactions

### 📊 UserWallet - Portefeuille Utilisateur
```dart
class UserWallet {
  Map<String, int> currencies;     // Montants par devise
  List<Transaction> transactionHistory; // Historique complet
  DateTime lastUpdated;           // Dernière mise à jour
}
```

### 📈 Transaction - Enregistrement des Mouvements
```dart
class Transaction {
  String id;              // Identifiant unique
  String currencyId;      // Type de devise
  int amount;             // Montant (+ ou -)
  String reason;          // Raison de la transaction
  DateTime timestamp;     // Horodatage
  bool isEarned;         // Gain ou dépense
  ShopItem? item;        // Article associé si achat
}
```

## 🎯 Fonctionnalités Avancées

### 🔒 Système de Prérequis
- **Niveau requis**: Articles débloqués par progression
- **Succès requis**: Articles liés aux achievements
- **Disponibilité temporelle**: Articles événementiels
- **Validation automatique**: Vérification avant achat

### 💡 Mécaniques de Gain
```dart
class EarningAction {
  String id;              // Identifiant de l'action
  String name;            // Nom affiché
  String description;     // Description détaillée
  Map<String, int> rewards; // Récompenses par devise
  Duration? cooldown;     // Temps de recharge
  int maxDaily;          // Limite quotidienne
}
```

### 📱 Interface Utilisateur

#### 🏪 Écran Boutique (`ShopScreen`)
- **En-tête gradient** avec soldes des devises
- **Onglets de catégories** avec emojis et compteurs
- **Filtres avancés**: recherche, prix abordables
- **Grille d'articles** avec cartes détaillées
- **Historique des transactions** en modal
- **Bouton récompenses quotidiennes**

#### 🎴 Carte d'Article (`ShopItemCard`)
- **Badge de rareté** coloré
- **Emoji représentatif** grande taille
- **Informations détaillées** nom/description
- **Prix multi-devises** avec symboles
- **Bouton d'achat intelligent** selon état
- **Overlay de verrouillage** pour prérequis
- **Animations de feedback** achat/échec

#### 💰 Affichage des Devises (`CurrencyDisplay`)
- **Design glassmorphism** effet transparent
- **Animations de pulsation** pour attraction
- **Formatage intelligent** K/M pour gros nombres
- **Symboles emoji** pour reconnaissance
- **Mise à jour temps réel**

#### 🎁 Dialogue Récompenses (`DailyRewardsDialog`)
- **Animation d'apparition** élastique
- **Étincelles de fond** en mouvement
- **Grille de progression** 7 jours
- **État visuel** récupéré/disponible/futur
- **Badge bonus** jour 7 spécial
- **Son de victoire** (optionnel)

## 🔧 Architecture Technique

### 📦 EconomyService - Service Central
```dart
class EconomyService {
  static List<Currency> currencies;         // Devises disponibles
  static List<ShopItem> getShopItems();    // Catalogue boutique
  static List<DailyReward> getDailyRewards(); // Récompenses quotidiennes
  static UserWallet getUserWallet();       // Portefeuille utilisateur
  static bool canAfford(UserWallet, ShopItem); // Vérification achat
  static Currency? getCurrency(String id); // Récupération devise
}
```

### 🎨 Configuration UI
```dart
// Couleurs système dans UIReference
static Color primaryColor = Color(0xFFE91E63);    // Rose principal
static Color accentColor = Color(0xFF673AB7);     // Violet accent  
static Color successColor = Color(0xFF4CAF50);    // Vert succès
static Color errorColor = Color(0xFFF44336);      // Rouge erreur
```

## 🚀 Points d'Extension

### 🔮 Fonctionnalités Futures Suggérées
1. **Système d'Investissement**: Faire fructifier les devises
2. **Marché P2P**: Échanges entre utilisateurs
3. **Enchères**: Articles rares aux enchères
4. **Abonnements**: Revenus passifs premium
5. **Crypto-Rewards**: Intégration blockchain légère
6. **Événements Dynamiques**: Boutique temporaire
7. **Système de Craft**: Combiner articles
8. **NFT légers**: Collectibles uniques

### 📊 Métriques & Analytics
- Taux de conversion par devise
- Articles les plus populaires  
- Revenus par catégorie
- Engagement récompenses quotidiennes
- Rétention par système économique

## ✅ État Actuel

### ✅ Fonctionnalités Implémentées
- [x] Système 3 devises complet
- [x] Boutique avec 7 catégories  
- [x] Rareté 5 niveaux avec couleurs
- [x] 15+ articles exemples
- [x] Récompenses quotidiennes animées
- [x] Système de transactions complet
- [x] Interface responsive complète
- [x] Validation des prérequis
- [x] Historique détaillé
- [x] Animations et feedback

### 🔄 Intégration en Cours
- [x] Connexion avec système de progression
- [x] Intégration navigation principale
- [x] Cohérence design UI/UX
- [x] Gestion d'état persistante

Le système d'économie JeuTaime est maintenant complètement fonctionnel et prêt à être intégré dans l'application principale ! 🎉