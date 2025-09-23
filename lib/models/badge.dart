import 'package:cloud_firestore/cloud_firestore.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final BadgeCategory category;
  final int coinsReward;
  final BadgeRarity rarity;
  final DateTime? unlockedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.category,
    this.coinsReward = 50,
    this.rarity = BadgeRarity.common,
    this.unlockedAt,
  });

  factory Badge.fromMap(Map<String, dynamic> data) {
    return Badge(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconPath: data['iconPath'] ?? '',
      category: BadgeCategory.fromString(data['category'] ?? 'progression'),
      coinsReward: data['coinsReward'] ?? 50,
      rarity: BadgeRarity.fromString(data['rarity'] ?? 'common'),
      unlockedAt: data['unlockedAt'] != null
          ? (data['unlockedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'category': category.value,
      'coinsReward': coinsReward,
      'rarity': rarity.value,
      'unlockedAt': unlockedAt != null 
          ? Timestamp.fromDate(unlockedAt!) 
          : null,
    };
  }

  bool get isUnlocked => unlockedAt != null;
}

enum BadgeCategory {
  progression('progression'),
  bars('bars'),
  social('social'),
  premium('premium'),
  special('special');

  const BadgeCategory(this.value);
  final String value;

  static BadgeCategory fromString(String value) {
    return BadgeCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => BadgeCategory.progression,
    );
  }

  String get displayName {
    switch (this) {
      case BadgeCategory.progression:
        return 'Progression';
      case BadgeCategory.bars:
        return 'Bars';
      case BadgeCategory.social:
        return 'Social';
      case BadgeCategory.premium:
        return 'Premium';
      case BadgeCategory.special:
        return 'Spécial';
    }
  }
}

enum BadgeRarity {
  common('common'),
  rare('rare'),
  epic('epic'),
  legendary('legendary');

  const BadgeRarity(this.value);
  final String value;

  static BadgeRarity fromString(String value) {
    return BadgeRarity.values.firstWhere(
      (rarity) => rarity.value == value,
      orElse: () => BadgeRarity.common,
    );
  }

  String get displayName {
    switch (this) {
      case BadgeRarity.common:
        return 'Commun';
      case BadgeRarity.rare:
        return 'Rare';
      case BadgeRarity.epic:
        return 'Épique';
      case BadgeRarity.legendary:
        return 'Légendaire';
    }
  }
}

// Définition de tous les badges disponibles
class BadgeDefinitions {
  static final Map<String, Badge> allBadges = {
    // Badges de Progression
    'newcomer': Badge(
      id: 'newcomer',
      name: 'Nouvel Arrivant',
      description: 'Inscription complète sur JeuTaime',
      iconPath: 'assets/badges/newcomer.png',
      category: BadgeCategory.progression,
      coinsReward: 100,
    ),
    
    'certified': Badge(
      id: 'certified',
      name: 'Certifié',
      description: 'Photo validée par notre équipe',
      iconPath: 'assets/badges/certified.png',
      category: BadgeCategory.progression,
      coinsReward: 200,
    ),
    
    'first_steps': Badge(
      id: 'first_steps',
      name: 'Premier Pas',
      description: 'Première lettre envoyée',
      iconPath: 'assets/badges/first_steps.png',
      category: BadgeCategory.progression,
      coinsReward: 150,
    ),
    
    'faithful': Badge(
      id: 'faithful',
      name: 'Fidèle',
      description: 'Connexion 7 jours consécutifs',
      iconPath: 'assets/badges/faithful.png',
      category: BadgeCategory.progression,
      coinsReward: 300,
    ),

    // Badges par Bar
    'romantic': Badge(
      id: 'romantic',
      name: 'Romantique',
      description: '5 activités dans le Bar Romantique',
      iconPath: 'assets/badges/romantic.png',
      category: BadgeCategory.bars,
      coinsReward: 250,
      rarity: BadgeRarity.rare,
    ),
    
    'humorist': Badge(
      id: 'humorist',
      name: 'Humoriste',
      description: '5 activités dans le Bar Humoristique',
      iconPath: 'assets/badges/humorist.png',
      category: BadgeCategory.bars,
      coinsReward: 250,
      rarity: BadgeRarity.rare,
    ),
    
    'corsair': Badge(
      id: 'corsair',
      name: 'Corsaire',
      description: '5 activités dans le Bar Pirates',
      iconPath: 'assets/badges/corsair.png',
      category: BadgeCategory.bars,
      coinsReward: 250,
      rarity: BadgeRarity.rare,
    ),
    
    'enigmatic': Badge(
      id: 'enigmatic',
      name: 'Énigmatique',
      description: 'Accès au Bar Caché déverrouillé',
      iconPath: 'assets/badges/enigmatic.png',
      category: BadgeCategory.bars,
      coinsReward: 500,
      rarity: BadgeRarity.legendary,
    ),

    // Badges Sociaux
    'correspondent': Badge(
      id: 'correspondent',
      name: 'Correspondant',
      description: '10 lettres échangées',
      iconPath: 'assets/badges/correspondent.png',
      category: BadgeCategory.social,
      coinsReward: 200,
    ),
    
    'generous_heart': Badge(
      id: 'generous_heart',
      name: 'Cœur Généreux',
      description: '20 compliments envoyés',
      iconPath: 'assets/badges/generous_heart.png',
      category: BadgeCategory.social,
      coinsReward: 300,
    ),
    
    'poet': Badge(
      id: 'poet',
      name: 'Poète du Cœur',
      description: '5 poèmes partagés',
      iconPath: 'assets/badges/poet.png',
      category: BadgeCategory.social,
      coinsReward: 250,
      rarity: BadgeRarity.rare,
    ),

    // Badges Premium
    'velvet_quill': Badge(
      id: 'velvet_quill',
      name: 'Plume de Velours',
      description: 'Plus belle lettre du mois',
      iconPath: 'assets/badges/velvet_quill.png',
      category: BadgeCategory.premium,
      coinsReward: 1000,
      rarity: BadgeRarity.legendary,
    ),
    
    'vip_sanctuary': Badge(
      id: 'vip_sanctuary',
      name: 'VIP Sanctuaire',
      description: 'Membre permanent du Bar Caché',
      iconPath: 'assets/badges/vip_sanctuary.png',
      category: BadgeCategory.premium,
      coinsReward: 500,
      rarity: BadgeRarity.epic,
    ),

    // Badges Spéciaux
    'weekly_profile': Badge(
      id: 'weekly_profile',
      name: 'Profil de la Semaine',
      description: 'Élu profil de la semaine par la communauté',
      iconPath: 'assets/badges/weekly_profile.png',
      category: BadgeCategory.special,
      coinsReward: 500,
      rarity: BadgeRarity.epic,
    ),
  };

  static Badge? getBadge(String id) {
    return allBadges[id];
  }

  static List<Badge> getBadgesByCategory(BadgeCategory category) {
    return allBadges.values
        .where((badge) => badge.category == category)
        .toList();
  }
}

// Système de défis quotidiens/hebdomadaires
class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int coinsReward;
  final Map<String, dynamic> requirements;
  final DateTime expiresAt;
  final bool isCompleted;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.coinsReward,
    this.requirements = const {},
    required this.expiresAt,
    this.isCompleted = false,
  });

  factory Challenge.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Challenge(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: ChallengeType.fromString(data['type'] ?? 'daily'),
      coinsReward: data['coinsReward'] ?? 0,
      requirements: data['requirements'] as Map<String, dynamic>? ?? {},
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.value,
      'coinsReward': coinsReward,
      'requirements': requirements,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isCompleted': isCompleted,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

enum ChallengeType {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  special('special');

  const ChallengeType(this.value);
  final String value;

  static ChallengeType fromString(String value) {
    return ChallengeType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ChallengeType.daily,
    );
  }

  String get displayName {
    switch (this) {
      case ChallengeType.daily:
        return 'Quotidien';
      case ChallengeType.weekly:
        return 'Hebdomadaire';
      case ChallengeType.monthly:
        return 'Mensuel';
      case ChallengeType.special:
        return 'Spécial';
    }
  }
}