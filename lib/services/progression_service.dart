import 'package:flutter/material.dart';

/// Service de gestion de la progression et gamification
class ProgressionService {
  static const Map<String, int> _levelThresholds = {
    '1': 0,
    '2': 100,
    '3': 250,
    '4': 500,
    '5': 1000,
    '6': 2000,
    '7': 3500,
    '8': 5500,
    '9': 8500,
    '10': 12500,
  };

  /// Calcule le niveau basé sur les points
  static int calculateLevel(int points) {
    for (int level = 10; level >= 1; level--) {
      if (points >= _levelThresholds[level.toString()]!) {
        return level;
      }
    }
    return 1;
  }

  /// Points nécessaires pour le prochain niveau
  static int pointsToNextLevel(int currentPoints) {
    int currentLevel = calculateLevel(currentPoints);
    if (currentLevel >= 10) return 0;
    
    int nextLevelThreshold = _levelThresholds[(currentLevel + 1).toString()]!;
    return nextLevelThreshold - currentPoints;
  }

  /// Progression en pourcentage vers le prochain niveau
  static double getLevelProgress(int currentPoints) {
    int currentLevel = calculateLevel(currentPoints);
    if (currentLevel >= 10) return 1.0;
    
    int currentLevelThreshold = _levelThresholds[currentLevel.toString()]!;
    int nextLevelThreshold = _levelThresholds[(currentLevel + 1).toString()]!;
    
    int progressPoints = currentPoints - currentLevelThreshold;
    int totalNeeded = nextLevelThreshold - currentLevelThreshold;
    
    return progressPoints / totalNeeded;
  }

  /// Vérifie si un bar est débloqué selon les conditions
  static bool isBarUnlocked(String barId, UserProgressData userData) {
    switch (barId) {
      case 'romantic':
      case 'humor':
        return true; // Toujours débloqués
        
      case 'pirates':
        return userData.humorActivitiesCompleted >= 2;
        
      case 'weekly':
        return userData.level >= 5 && userData.profileCompletion >= 100;
        
      case 'hidden':
        return userData.sphinxRiddleSolved;
        
      default:
        return false;
    }
  }

  /// Récompenses disponibles selon le niveau
  static List<Reward> getAvailableRewards(int level) {
    List<Reward> rewards = [];
    
    if (level >= 2) {
      rewards.add(Reward(
        id: 'custom_avatar',
        title: 'Avatar Personnalisé',
        description: 'Créez votre propre avatar emoji',
        icon: '🎭',
        type: RewardType.feature,
      ));
    }
    
    if (level >= 3) {
      rewards.add(Reward(
        id: 'premium_filters',
        title: 'Filtres Premium',
        description: 'Filtres de recherche avancés',
        icon: '🔍',
        type: RewardType.feature,
      ));
    }
    
    if (level >= 5) {
      rewards.add(Reward(
        id: 'weekly_access',
        title: 'Accès Bar Hebdomadaire',
        description: 'Participez aux groupes exclusifs',
        icon: '📅',
        type: RewardType.access,
      ));
    }
    
    if (level >= 7) {
      rewards.add(Reward(
        id: 'vip_badge',
        title: 'Badge VIP',
        description: 'Statut VIP visible sur votre profil',
        icon: '👑',
        type: RewardType.cosmetic,
      ));
    }
    
    if (level >= 10) {
      rewards.add(Reward(
        id: 'master_status',
        title: 'Statut Maître',
        description: 'Accès aux fonctionnalités exclusives',
        icon: '⭐',
        type: RewardType.exclusive,
      ));
    }
    
    return rewards;
  }

  /// Vérifie les achievements débloqués
  static List<Achievement> checkNewAchievements(
    UserProgressData oldData,
    UserProgressData newData,
  ) {
    List<Achievement> newAchievements = [];
    
    // Achievement de niveau
    if (newData.level > oldData.level) {
      newAchievements.add(Achievement(
        id: 'level_${newData.level}',
        title: 'Niveau ${newData.level}',
        description: 'Vous avez atteint le niveau ${newData.level}!',
        icon: '🎯',
        points: newData.level * 50,
        unlockedAt: DateTime.now(),
      ));
    }
    
    // Achievement de compatibilité
    if (newData.matchesFound >= 10 && oldData.matchesFound < 10) {
      newAchievements.add(Achievement(
        id: 'match_master',
        title: 'Maître des Rencontres',
        description: '10 matchs trouvés',
        icon: '💘',
        points: 200,
        unlockedAt: DateTime.now(),
      ));
    }
    
    // Achievement social
    if (newData.messagesCount >= 100 && oldData.messagesCount < 100) {
      newAchievements.add(Achievement(
        id: 'social_butterfly',
        title: 'Papillon Social',
        description: '100 messages envoyés',
        icon: '🦋',
        points: 150,
        unlockedAt: DateTime.now(),
      ));
    }
    
    // Achievement bars
    if (newData.barsCompleted >= 3 && oldData.barsCompleted < 3) {
      newAchievements.add(Achievement(
        id: 'bar_explorer',
        title: 'Explorateur de Bars',
        description: 'Activité dans 3 bars différents',
        icon: '🍸',
        points: 300,
        unlockedAt: DateTime.now(),
      ));
    }
    
    return newAchievements;
  }

  /// Obtient les données de progression de l'utilisateur (simulation) - méthode statique
  static UserProgressData getUserProgressStatic() {
    // Simulation - en réalité, on récupérerait depuis Firebase/SharedPreferences
    return UserProgressData(
      points: 450,
      level: calculateLevel(450),
      messagesCount: 12,
      matchesFound: 3,
      humorActivitiesCompleted: 5,
      barsCompleted: 2,
      profileCompletion: 85,
      sphinxRiddleSolved: false,
      unlockedAchievements: ['first_message', 'bar_explorer'],
      unlockedRewards: ['golden_frame'],
    );
  }

  /// Méthode d'instance pour obtenir les données de progression
  UserProgressData getUserProgress() {
    return getUserProgressStatic();
  }
}

/// Données de progression utilisateur
class UserProgressData {
  final int points;
  final int level;
  final int messagesCount;
  final int matchesFound;
  final int humorActivitiesCompleted;
  final int barsCompleted;
  final int profileCompletion;
  final bool sphinxRiddleSolved;
  final List<String> unlockedAchievements;
  final List<String> unlockedRewards;

  UserProgressData({
    this.points = 0,
    this.level = 1,
    this.messagesCount = 0,
    this.matchesFound = 0,
    this.humorActivitiesCompleted = 0,
    this.barsCompleted = 0,
    this.profileCompletion = 0,
    this.sphinxRiddleSolved = false,
    this.unlockedAchievements = const [],
    this.unlockedRewards = const [],
  });

  UserProgressData copyWith({
    int? points,
    int? level,
    int? messagesCount,
    int? matchesFound,
    int? humorActivitiesCompleted,
    int? barsCompleted,
    int? profileCompletion,
    bool? sphinxRiddleSolved,
    List<String>? unlockedAchievements,
    List<String>? unlockedRewards,
  }) {
    return UserProgressData(
      points: points ?? this.points,
      level: level ?? this.level,
      messagesCount: messagesCount ?? this.messagesCount,
      matchesFound: matchesFound ?? this.matchesFound,
      humorActivitiesCompleted: humorActivitiesCompleted ?? this.humorActivitiesCompleted,
      barsCompleted: barsCompleted ?? this.barsCompleted,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      sphinxRiddleSolved: sphinxRiddleSolved ?? this.sphinxRiddleSolved,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      unlockedRewards: unlockedRewards ?? this.unlockedRewards,
    );
  }
}

/// Modèle d'achievement
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;
  final DateTime unlockedAt;
  final AchievementRarity rarity;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.unlockedAt,
    this.rarity = AchievementRarity.common,
  });
}

/// Modèle de récompense
class Reward {
  final String id;
  final String title;
  final String description;
  final String icon;
  final RewardType type;
  final int? costPoints;
  final bool isUnlocked;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    this.costPoints,
    this.isUnlocked = false,
  });
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

enum RewardType {
  cosmetic,   // Badges, avatars
  feature,    // Nouvelles fonctionnalités
  access,     // Accès à du contenu
  exclusive,  // Contenu exclusif
}