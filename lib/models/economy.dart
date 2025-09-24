import 'package:flutter/material.dart';

/// Modèle pour la monnaie virtuelle du jeu
class Currency {
  final String id;
  final String name;
  final String symbol;
  final String emoji;
  final Color color;
  final bool isPremium;

  const Currency({
    required this.id,
    required this.name,
    required this.symbol,
    required this.emoji,
    required this.color,
    this.isPremium = false,
  });
}

/// Article disponible à l'achat
class ShopItem {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final ShopCategory category;
  final Map<String, int> prices; // currencyId -> price
  final ItemRarity rarity;
  final bool isLimited;
  final DateTime? availableUntil;
  final int? maxPurchases;
  final int requiredLevel;
  final List<String> requiredAchievements;
  final Map<String, dynamic> metadata;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    required this.prices,
    this.rarity = ItemRarity.common,
    this.isLimited = false,
    this.availableUntil,
    this.maxPurchases,
    this.requiredLevel = 1,
    this.requiredAchievements = const [],
    this.metadata = const {},
  });

  bool canPurchase(UserWallet wallet, int userLevel, List<String> userAchievements) {
    // Vérifier le niveau requis
    if (userLevel < requiredLevel) return false;
    
    // Vérifier les achievements requis
    for (String achievement in requiredAchievements) {
      if (!userAchievements.contains(achievement)) return false;
    }
    
    // Vérifier la disponibilité temporelle
    if (isLimited && availableUntil != null) {
      if (DateTime.now().isAfter(availableUntil!)) return false;
    }
    
    // Vérifier si l'utilisateur a assez de monnaie
    for (String currencyId in prices.keys) {
      int required = prices[currencyId]!;
      int available = wallet.getCurrencyAmount(currencyId);
      if (available < required) return false;
    }
    
    return true;
  }

  String getPriceDisplay() {
    List<String> priceStrings = [];
    prices.forEach((currencyId, amount) {
      // Récupérer le symbole de la monnaie depuis EconomyService
      String symbol = EconomyService.getCurrencySymbol(currencyId);
      priceStrings.add('$amount $symbol');
    });
    return priceStrings.join(' + ');
  }
}

/// Portefeuille utilisateur
class UserWallet {
  final Map<String, int> currencies;
  final List<PurchasedItem> purchasedItems;
  final List<Transaction> transactionHistory;
  final DateTime lastUpdated;

  const UserWallet({
    this.currencies = const {},
    this.purchasedItems = const [],
    this.transactionHistory = const [],
    required this.lastUpdated,
  });

  int getCurrencyAmount(String currencyId) {
    return currencies[currencyId] ?? 0;
  }

  bool hasCurrency(String currencyId, int amount) {
    return getCurrencyAmount(currencyId) >= amount;
  }

  UserWallet addCurrency(String currencyId, int amount, String reason) {
    Map<String, int> newCurrencies = Map.from(currencies);
    newCurrencies[currencyId] = getCurrencyAmount(currencyId) + amount;
    
    List<Transaction> newHistory = List.from(transactionHistory);
    newHistory.add(Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.earned,
      currencyId: currencyId,
      amount: amount,
      reason: reason,
      timestamp: DateTime.now(),
    ));
    
    return UserWallet(
      currencies: newCurrencies,
      purchasedItems: purchasedItems,
      transactionHistory: newHistory,
      lastUpdated: DateTime.now(),
    );
  }

  UserWallet spendCurrency(String currencyId, int amount, String reason, {ShopItem? item}) {
    if (!hasCurrency(currencyId, amount)) {
      throw Exception('Pas assez de $currencyId');
    }
    
    Map<String, int> newCurrencies = Map.from(currencies);
    newCurrencies[currencyId] = getCurrencyAmount(currencyId) - amount;
    
    List<Transaction> newHistory = List.from(transactionHistory);
    newHistory.add(Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.spent,
      currencyId: currencyId,
      amount: -amount,
      reason: reason,
      timestamp: DateTime.now(),
      itemId: item?.id,
    ));
    
    List<PurchasedItem> newItems = List.from(purchasedItems);
    if (item != null) {
      newItems.add(PurchasedItem(
        itemId: item.id,
        purchaseDate: DateTime.now(),
        quantity: 1,
      ));
    }
    
    return UserWallet(
      currencies: newCurrencies,
      purchasedItems: newItems,
      transactionHistory: newHistory,
      lastUpdated: DateTime.now(),
    );
  }

  bool hasItem(String itemId) {
    return purchasedItems.any((item) => item.itemId == itemId);
  }

  int getItemQuantity(String itemId) {
    return purchasedItems
        .where((item) => item.itemId == itemId)
        .fold(0, (total, item) => total + item.quantity);
  }
}

/// Article acheté par l'utilisateur
class PurchasedItem {
  final String itemId;
  final DateTime purchaseDate;
  final int quantity;
  final Map<String, dynamic> metadata;

  const PurchasedItem({
    required this.itemId,
    required this.purchaseDate,
    this.quantity = 1,
    this.metadata = const {},
  });
}

/// Transaction dans l'historique
class Transaction {
  final String id;
  final TransactionType type;
  final String currencyId;
  final int amount; // Positif pour gains, négatif pour dépenses
  final String reason;
  final DateTime timestamp;
  final String? itemId;
  final Map<String, dynamic> metadata;

  const Transaction({
    required this.id,
    required this.type,
    required this.currencyId,
    required this.amount,
    required this.reason,
    required this.timestamp,
    this.itemId,
    this.metadata = const {},
  });

  bool get isEarned => type == TransactionType.earned;
  bool get isSpent => type == TransactionType.spent;
}

/// Énumérations
enum ShopCategory {
  avatars,        // Customisation d'avatar
  decorations,    // Décorations pour lettres
  themes,         // Thèmes d'interface
  consumables,    // Objets consommables
  premium,        // Articles premium
  limited,        // Édition limitée
  seasonal,       // Événements saisonniers
}

enum ItemRarity {
  common,         // Commun - gris
  rare,          // Rare - bleu
  epic,          // Épique - violet
  legendary,     // Légendaire - orange
  mythic,        // Mythique - rouge
}

enum TransactionType {
  earned,        // Monnaie gagnée
  spent,         // Monnaie dépensée
  gift,          // Cadeau reçu
  reward,        // Récompense
  purchase,      // Achat direct
  refund,        // Remboursement
}

/// Service principal de gestion de l'économie
class EconomyService {
  /// Monnaies disponibles dans le jeu
  static const List<Currency> currencies = [
    Currency(
      id: 'coins',
      name: 'Pièces d\'Or',
      symbol: '🪙',
      emoji: '🪙',
      color: Color(0xFFFFD700),
    ),
    Currency(
      id: 'hearts',
      name: 'Cœurs',
      symbol: '💕',
      emoji: '💕',
      color: Color(0xFFE91E63),
    ),
    Currency(
      id: 'gems',
      name: 'Gemmes',
      symbol: '💎',
      emoji: '💎',
      color: Color(0xFF673AB7),
      isPremium: true,
    ),
  ];

  /// Articles disponibles dans la boutique
  static List<ShopItem> getShopItems() {
    return [
      // === CUSTOMISATION D'AVATAR ===
      ShopItem(
        id: 'avatar_frame_gold',
        name: 'Cadre Doré',
        description: 'Un magnifique cadre doré pour votre avatar',
        emoji: '🖼️',
        category: ShopCategory.avatars,
        prices: {'coins': 150},
        rarity: ItemRarity.rare,
      ),
      
      ShopItem(
        id: 'avatar_frame_hearts',
        name: 'Cadre Cœurs',
        description: 'Cadre romantique avec des cœurs animés',
        emoji: '💕',
        category: ShopCategory.avatars,
        prices: {'hearts': 50},
        rarity: ItemRarity.epic,
        requiredLevel: 3,
      ),

      ShopItem(
        id: 'avatar_sparkles',
        name: 'Effet Paillettes',
        description: 'Ajoute des paillettes scintillantes à votre avatar',
        emoji: '✨',
        category: ShopCategory.avatars,
        prices: {'coins': 200, 'hearts': 25},
        rarity: ItemRarity.epic,
        requiredLevel: 5,
      ),

      // === DÉCORATIONS POUR LETTRES ===
      ShopItem(
        id: 'letter_paper_royal',
        name: 'Papier Royal',
        description: 'Papier à lettres de qualité royale avec dorures',
        emoji: '📜',
        category: ShopCategory.decorations,
        prices: {'coins': 75},
        rarity: ItemRarity.rare,
      ),

      ShopItem(
        id: 'letter_seal_wax',
        name: 'Sceau de Cire',
        description: 'Authentifiez vos lettres avec un sceau de cire',
        emoji: '🏺',
        category: ShopCategory.decorations,
        prices: {'hearts': 30},
        rarity: ItemRarity.common,
      ),

      ShopItem(
        id: 'letter_perfume',
        name: 'Parfum Envoûtant',
        description: 'Parfumez vos lettres d\'un doux arôme',
        emoji: '🌸',
        category: ShopCategory.decorations,
        prices: {'hearts': 40},
        rarity: ItemRarity.rare,
        requiredLevel: 2,
      ),

      // === THÈMES D'INTERFACE ===
      ShopItem(
        id: 'theme_sunset',
        name: 'Thème Coucher de Soleil',
        description: 'Interface aux couleurs chaudes du coucher de soleil',
        emoji: '🌅',
        category: ShopCategory.themes,
        prices: {'coins': 300},
        rarity: ItemRarity.epic,
        requiredLevel: 4,
      ),

      ShopItem(
        id: 'theme_night',
        name: 'Thème Nuit Étoilée',
        description: 'Mode sombre élégant avec des étoiles',
        emoji: '🌙',
        category: ShopCategory.themes,
        prices: {'gems': 10},
        rarity: ItemRarity.legendary,
        requiredLevel: 6,
      ),

      // === OBJETS CONSOMMABLES ===
      ShopItem(
        id: 'boost_xp',
        name: 'Boost d\'XP',
        description: 'Double vos points d\'expérience pendant 1 heure',
        emoji: '⚡',
        category: ShopCategory.consumables,
        prices: {'coins': 50},
        rarity: ItemRarity.common,
        maxPurchases: 5, // Limite par jour
      ),

      ShopItem(
        id: 'heart_multiplier',
        name: 'Multiplicateur de Cœurs',
        description: 'Multiplie par 2 les cœurs gagnés pendant 2 heures',
        emoji: '💖',
        category: ShopCategory.consumables,
        prices: {'hearts': 100},
        rarity: ItemRarity.rare,
        maxPurchases: 3,
      ),

      // === ARTICLES PREMIUM ===
      ShopItem(
        id: 'premium_template_pack',
        name: 'Pack Templates Premium',
        description: 'Débloquez tous les templates de lettres premium',
        emoji: '📋',
        category: ShopCategory.premium,
        prices: {'gems': 25},
        rarity: ItemRarity.legendary,
        requiredLevel: 5,
      ),

      ShopItem(
        id: 'vip_badge',
        name: 'Badge VIP',
        description: 'Badge VIP visible sur votre profil',
        emoji: '👑',
        category: ShopCategory.premium,
        prices: {'gems': 50},
        rarity: ItemRarity.mythic,
        requiredLevel: 8,
      ),

      // === ÉDITION LIMITÉE ===
      ShopItem(
        id: 'valentine_frame',
        name: 'Cadre Saint-Valentin',
        description: 'Cadre spécial Saint-Valentin 2025 - Édition limitée',
        emoji: '💝',
        category: ShopCategory.limited,
        prices: {'hearts': 200, 'coins': 500},
        rarity: ItemRarity.mythic,
        isLimited: true,
        availableUntil: DateTime(2025, 2, 28),
        requiredLevel: 3,
      ),
    ];
  }

  /// Récompenses quotidiennes
  static List<DailyReward> getDailyRewards() {
    return [
      DailyReward(day: 1, currencyId: 'coins', amount: 50, emoji: '🪙'),
      DailyReward(day: 2, currencyId: 'hearts', amount: 25, emoji: '💕'),
      DailyReward(day: 3, currencyId: 'coins', amount: 75, emoji: '🪙'),
      DailyReward(day: 4, currencyId: 'hearts', amount: 40, emoji: '💕'),
      DailyReward(day: 5, currencyId: 'coins', amount: 100, emoji: '🪙'),
      DailyReward(day: 6, currencyId: 'gems', amount: 5, emoji: '💎'),
      DailyReward(day: 7, currencyId: 'coins', amount: 200, emoji: '🎁', isBonus: true),
    ];
  }

  /// Obtenir le portefeuille utilisateur (simulation)
  static UserWallet getUserWallet() {
    // En réalité, récupéré depuis Firebase/SharedPreferences
    return UserWallet(
      currencies: {
        'coins': 1250,
        'hearts': 185,
        'gems': 8,
      },
      purchasedItems: [
        PurchasedItem(
          itemId: 'avatar_frame_gold',
          purchaseDate: DateTime.now().subtract(Duration(days: 3)),
        ),
        PurchasedItem(
          itemId: 'letter_paper_royal',
          purchaseDate: DateTime.now().subtract(Duration(days: 1)),
        ),
      ],
      transactionHistory: [
        Transaction(
          id: '1',
          type: TransactionType.earned,
          currencyId: 'coins',
          amount: 100,
          reason: 'Connexion quotidienne',
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
        ),
        Transaction(
          id: '2',
          type: TransactionType.spent,
          currencyId: 'coins',
          amount: -75,
          reason: 'Achat Papier Royal',
          timestamp: DateTime.now().subtract(Duration(days: 1)),
          itemId: 'letter_paper_royal',
        ),
      ],
      lastUpdated: DateTime.now(),
    );
  }

  /// Actions qui rapportent de la monnaie
  static Map<String, Map<String, int>> getEarningActions() {
    return {
      'daily_login': {'coins': 50, 'hearts': 10},
      'send_letter': {'hearts': 5},
      'receive_letter': {'hearts': 3},
      'complete_bar_activity': {'coins': 25, 'hearts': 15},
      'profile_view': {'hearts': 1},
      'match_found': {'coins': 100, 'hearts': 50},
      'achievement_unlock': {'coins': 150},
      'level_up': {'coins': 200, 'gems': 2},
    };
  }

  /// Obtenir le symbole d'une monnaie
  static String getCurrencySymbol(String currencyId) {
    for (Currency currency in currencies) {
      if (currency.id == currencyId) {
        return currency.symbol;
      }
    }
    return '?';
  }

  /// Obtenir une monnaie par ID
  static Currency? getCurrency(String currencyId) {
    for (Currency currency in currencies) {
      if (currency.id == currencyId) {
        return currency;
      }
    }
    return null;
  }

  /// Calculer le total de richesse d'un utilisateur
  static int calculateWealthScore(UserWallet wallet) {
    int score = 0;
    score += wallet.getCurrencyAmount('coins');
    score += wallet.getCurrencyAmount('hearts') * 2;
    score += wallet.getCurrencyAmount('gems') * 50;
    return score;
  }

  /// Vérifier si l'utilisateur peut s'offrir un article
  static bool canAfford(UserWallet wallet, ShopItem item) {
    for (String currencyId in item.prices.keys) {
      int required = item.prices[currencyId]!;
      int available = wallet.getCurrencyAmount(currencyId);
      if (available < required) return false;
    }
    return true;
  }
}

/// Récompense quotidienne
class DailyReward {
  final int day;
  final String currencyId;
  final int amount;
  final String emoji;
  final bool isBonus;

  const DailyReward({
    required this.day,
    required this.currencyId,
    required this.amount,
    required this.emoji,
    this.isBonus = false,
  });
}

/// Extension pour les couleurs de rareté
extension ItemRarityExtension on ItemRarity {
  Color get color {
    switch (this) {
      case ItemRarity.common:
        return const Color(0xFF9E9E9E);
      case ItemRarity.rare:
        return const Color(0xFF2196F3);
      case ItemRarity.epic:
        return const Color(0xFF9C27B0);
      case ItemRarity.legendary:
        return const Color(0xFFFF9800);
      case ItemRarity.mythic:
        return const Color(0xFFE91E63);
    }
  }

  String get name {
    switch (this) {
      case ItemRarity.common:
        return 'Commun';
      case ItemRarity.rare:
        return 'Rare';
      case ItemRarity.epic:
        return 'Épique';
      case ItemRarity.legendary:
        return 'Légendaire';
      case ItemRarity.mythic:
        return 'Mythique';
    }
  }
}

/// Extension pour les catégories
extension ShopCategoryExtension on ShopCategory {
  String get displayName {
    switch (this) {
      case ShopCategory.avatars:
        return 'Avatars';
      case ShopCategory.decorations:
        return 'Décorations';
      case ShopCategory.themes:
        return 'Thèmes';
      case ShopCategory.consumables:
        return 'Consommables';
      case ShopCategory.premium:
        return 'Premium';
      case ShopCategory.limited:
        return 'Édition Limitée';
      case ShopCategory.seasonal:
        return 'Saisonnier';
    }
  }

  String get emoji {
    switch (this) {
      case ShopCategory.avatars:
        return '👤';
      case ShopCategory.decorations:
        return '🎨';
      case ShopCategory.themes:
        return '🌈';
      case ShopCategory.consumables:
        return '⚡';
      case ShopCategory.premium:
        return '👑';
      case ShopCategory.limited:
        return '⭐';
      case ShopCategory.seasonal:
        return '🎭';
    }
  }
}