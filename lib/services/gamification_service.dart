import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

enum BadgeType {
  social, // Badges sociaux (conversations, matches, etc.)
  achievement, // Achievements spéciaux
  milestone, // Paliers de progression
  premium, // Badges premium
  event, // Badges d'événements
  master, // Badges de maîtrise
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  diamond,
  legendary,
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final BadgeType type;
  final AchievementTier tier;
  final int rarity; // 1-100, plus faible = plus rare
  final DateTime unlockedAt;
  final Map<String, dynamic> metadata;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.type,
    required this.tier,
    required this.rarity,
    required this.unlockedAt,
    this.metadata = const {},
  });

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      type: BadgeType.values.firstWhere(
        (e) => e.toString() == 'BadgeType.${map['type']}',
        orElse: () => BadgeType.achievement,
      ),
      tier: AchievementTier.values.firstWhere(
        (e) => e.toString() == 'AchievementTier.${map['tier']}',
        orElse: () => AchievementTier.bronze,
      ),
      rarity: map['rarity'] ?? 50,
      unlockedAt: (map['unlockedAt'] as Timestamp).toDate(),
      metadata: map['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'type': type.toString().split('.').last,
      'tier': tier.toString().split('.').last,
      'rarity': rarity,
      'unlockedAt': unlockedAt,
      'metadata': metadata,
    };
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> requirements;
  final Map<String, dynamic> progress;
  final int maxProgress;
  final int currentProgress;
  final bool isCompleted;
  final Badge? badge;
  final int coinReward;
  final List<String> prerequisites;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.requirements,
    required this.progress,
    required this.maxProgress,
    required this.currentProgress,
    required this.isCompleted,
    this.badge,
    required this.coinReward,
    this.prerequisites = const [],
  });
}

class GamificationService {
  static GamificationService? _instance;
  static GamificationService get instance => _instance ??= GamificationService._();
  
  GamificationService._();
  
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  
  // Définition des badges disponibles
  static const Map<String, Map<String, dynamic>> AVAILABLE_BADGES = {
    // Badges sociaux
    'first_match': {
      'name': 'Premier Match',
      'description': 'Votre premier match sur JeTaime',
      'type': 'social',
      'tier': 'bronze',
      'rarity': 10,
      'coinReward': 50,
      'iconUrl': 'assets/badges/first_match.png',
    },
    'conversation_starter': {
      'name': 'Brise-Glace',
      'description': 'Commencez 10 conversations',
      'type': 'social',
      'tier': 'silver',
      'rarity': 25,
      'coinReward': 100,
      'iconUrl': 'assets/badges/conversation_starter.png',
    },
    'social_butterfly': {
      'name': 'Papillon Social',
      'description': 'Ayez 50 conversations actives',
      'type': 'social',
      'tier': 'gold',
      'rarity': 45,
      'coinReward': 250,
      'iconUrl': 'assets/badges/social_butterfly.png',
    },
    
    // Badges de lettres
    'first_letter': {
      'name': 'Première Lettre',
      'description': 'Envoyez votre première lettre authentique',
      'type': 'achievement',
      'tier': 'bronze',
      'rarity': 15,
      'coinReward': 75,
      'iconUrl': 'assets/badges/first_letter.png',
    },
    'letter_master': {
      'name': 'Maître Épistolaire',
      'description': 'Échangez 25 lettres complètes',
      'type': 'achievement',
      'tier': 'gold',
      'rarity': 60,
      'coinReward': 300,
      'iconUrl': 'assets/badges/letter_master.png',
    },
    
    // Badges des bars
    'bar_explorer': {
      'name': 'Explorateur de Bars',
      'description': 'Visitez tous les types de bars',
      'type': 'achievement',
      'tier': 'silver',
      'rarity': 35,
      'coinReward': 150,
      'iconUrl': 'assets/badges/bar_explorer.png',
    },
    'riddle_master': {
      'name': 'Maître des Énigmes',
      'description': 'Résolvez toutes les énigmes du Bar Caché',
      'type': 'master',
      'tier': 'diamond',
      'rarity': 85,
      'coinReward': 500,
      'iconUrl': 'assets/badges/riddle_master.png',
    },
    
    // Badges de parrainage
    'first_referral': {
      'name': 'Premier Parrain',
      'description': 'Votre premier parrainage réussi',
      'type': 'social',
      'tier': 'bronze',
      'rarity': 20,
      'coinReward': 100,
      'iconUrl': 'assets/badges/first_referral.png',
    },
    'referral_champion': {
      'name': 'Champion de Parrainage',
      'description': 'Parrainez 25 nouveaux utilisateurs',
      'type': 'master',
      'tier': 'gold',
      'rarity': 70,
      'coinReward': 400,
      'iconUrl': 'assets/badges/referral_champion.png',
    },
    
    // Badges premium
    'premium_member': {
      'name': 'Membre Premium',
      'description': 'Devenez membre Premium',
      'type': 'premium',
      'tier': 'gold',
      'rarity': 40,
      'coinReward': 200,
      'iconUrl': 'assets/badges/premium_member.png',
    },
    'premium_veteran': {
      'name': 'Vétéran Premium',
      'description': '6 mois consécutifs de Premium',
      'type': 'premium',
      'tier': 'diamond',
      'rarity': 75,
      'coinReward': 500,
      'iconUrl': 'assets/badges/premium_veteran.png',
    },
    
    // Badges légendaires
    'app_founder': {
      'name': 'Fondateur',
      'description': 'Utilisateur des 1000 premiers',
      'type': 'event',
      'tier': 'legendary',
      'rarity': 95,
      'coinReward': 1000,
      'iconUrl': 'assets/badges/app_founder.png',
    },
    'perfect_gentleman': {
      'name': 'Gentleman Parfait',
      'description': 'Aucun strike, 100+ interactions positives',
      'type': 'master',
      'tier': 'legendary',
      'rarity': 90,
      'coinReward': 750,
      'iconUrl': 'assets/badges/perfect_gentleman.png',
    },
  };
  
  // Débloquer un badge
  Future<Map<String, dynamic>> unlockBadge(String userId, String badgeId) async {
    try {
      final badgeConfig = AVAILABLE_BADGES[badgeId];
      if (badgeConfig == null) {
        return {'success': false, 'error': 'Badge inexistant'};
      }
      
      return await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          return {'success': false, 'error': 'Utilisateur introuvable'};
        }
        
        final userData = userDoc.data()!;
        final unlockedBadges = List<String>.from(userData['unlockedBadges'] ?? []);
        
        // Vérifier si le badge est déjà débloqué
        if (unlockedBadges.contains(badgeId)) {
          return {'success': false, 'error': 'Badge déjà débloqué'};
        }
        
        // Créer le badge
        final badge = Badge(
          id: badgeId,
          name: badgeConfig['name'],
          description: badgeConfig['description'],
          iconUrl: badgeConfig['iconUrl'],
          type: BadgeType.values.firstWhere(
            (e) => e.toString().split('.').last == badgeConfig['type'],
          ),
          tier: AchievementTier.values.firstWhere(
            (e) => e.toString().split('.').last == badgeConfig['tier'],
          ),
          rarity: badgeConfig['rarity'],
          unlockedAt: DateTime.now(),
        );
        
        // Mettre à jour l'utilisateur
        transaction.update(userRef, {
          'unlockedBadges': FieldValue.arrayUnion([badgeId]),
          'coins': FieldValue.increment(badgeConfig['coinReward']),
          'gamificationStats.totalBadges': FieldValue.increment(1),
          'gamificationStats.totalCoinsFromBadges': FieldValue.increment(badgeConfig['coinReward']),
        });
        
        // Enregistrer le badge avec ses détails
        transaction.set(_firestore.collection('userBadges').doc('${userId}_$badgeId'), {
          ...badge.toMap(),
          'userId': userId,
          'earnedAt': FieldValue.serverTimestamp(),
        });
        
        // Enregistrer l'événement
        transaction.set(_firestore.collection('gamificationEvents').doc(), {
          'userId': userId,
          'type': 'badge_unlocked',
          'badgeId': badgeId,
          'timestamp': FieldValue.serverTimestamp(),
          'coinReward': badgeConfig['coinReward'],
        });
        
        return {
          'success': true,
          'badge': badge.toMap(),
          'coinReward': badgeConfig['coinReward'],
        };
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Vérifier et débloquer automatiquement les badges
  Future<List<Map<String, dynamic>>> checkAndUnlockBadges(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];
      
      final userData = userDoc.data()!;
      final unlockedBadges = List<String>.from(userData['unlockedBadges'] ?? []);
      List<Map<String, dynamic>> newBadges = [];
      
      // Vérifier chaque condition de badge
      for (final badgeEntry in AVAILABLE_BADGES.entries) {
        final badgeId = badgeEntry.key;
        final badgeConfig = badgeEntry.value;
        
        if (unlockedBadges.contains(badgeId)) continue;
        
        bool shouldUnlock = false;
        
        switch (badgeId) {
          case 'first_match':
            final matches = userData['matches'] as List? ?? [];
            shouldUnlock = matches.isNotEmpty;
            break;
            
          case 'conversation_starter':
            final conversationCount = userData['stats']?['totalConversations'] ?? 0;
            shouldUnlock = conversationCount >= 10;
            break;
            
          case 'social_butterfly':
            final activeConversations = userData['stats']?['activeConversations'] ?? 0;
            shouldUnlock = activeConversations >= 50;
            break;
            
          case 'first_letter':
            final lettersSent = userData['letterStats']?['lettersSent'] ?? 0;
            shouldUnlock = lettersSent >= 1;
            break;
            
          case 'letter_master':
            final completedLetters = userData['letterStats']?['completedExchanges'] ?? 0;
            shouldUnlock = completedLetters >= 25;
            break;
            
          case 'bar_explorer':
            final barTypes = Set<String>.from(userData['barStats']?['visitedBarTypes'] ?? []);
            shouldUnlock = barTypes.length >= 3; // 3 types de bars différents
            break;
            
          case 'riddle_master':
            final solvedRiddles = userData['hiddenBarStats']?['solvedRiddles'] ?? 0;
            shouldUnlock = solvedRiddles >= 5;
            break;
            
          case 'first_referral':
            final totalReferrals = userData['referralStats']?['totalReferrals'] ?? 0;
            shouldUnlock = totalReferrals >= 1;
            break;
            
          case 'referral_champion':
            final totalReferrals = userData['referralStats']?['totalReferrals'] ?? 0;
            shouldUnlock = totalReferrals >= 25;
            break;
            
          case 'premium_member':
            final isPremium = userData['isPremium'] ?? false;
            shouldUnlock = isPremium;
            break;
            
          case 'premium_veteran':
            final premiumDuration = userData['premiumStats']?['totalDurationMonths'] ?? 0;
            shouldUnlock = premiumDuration >= 6;
            break;
            
          case 'app_founder':
            final userId = userDoc.id;
            final userNumber = await _getUserRegistrationNumber(userId);
            shouldUnlock = userNumber <= 1000;
            break;
            
          case 'perfect_gentleman':
            final strikes = userData['antiGhostingStats']?['totalStrikes'] ?? 0;
            final positiveInteractions = userData['stats']?['positiveInteractions'] ?? 0;
            shouldUnlock = strikes == 0 && positiveInteractions >= 100;
            break;
        }
        
        if (shouldUnlock) {
          final result = await unlockBadge(userId, badgeId);
          if (result['success'] == true) {
            newBadges.add(result);
          }
        }
      }
      
      return newBadges;
    } catch (e) {
      print('Erreur vérification badges: $e');
      return [];
    }
  }
  
  // Obtenir le numéro d'inscription de l'utilisateur
  Future<int> _getUserRegistrationNumber(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return 999999;
      
      final userData = userDoc.data()!;
      final createdAt = userData['createdAt'] as Timestamp?;
      
      if (createdAt == null) return 999999;
      
      // Compter les utilisateurs créés avant celui-ci
      final earlierUsers = await _firestore
          .collection('users')
          .where('createdAt', isLessThan: createdAt)
          .get();
      
      return earlierUsers.size + 1;
    } catch (e) {
      return 999999;
    }
  }
  
  // Obtenir les badges d'un utilisateur
  Future<List<Badge>> getUserBadges(String userId) async {
    try {
      final badgeDocs = await _firestore
          .collection('userBadges')
          .where('userId', isEqualTo: userId)
          .orderBy('earnedAt', descending: true)
          .get();
      
      return badgeDocs.docs.map((doc) => Badge.fromMap(doc.data())).toList();
    } catch (e) {
      print('Erreur récupération badges: $e');
      return [];
    }
  }
  
  // Calculer le niveau de l'utilisateur
  Future<Map<String, dynamic>> calculateUserLevel(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return {};
      
      final userData = userDoc.data()!;
      
      // Calculer les points d'expérience
      int totalXP = 0;
      
      // XP des matches
      final matches = userData['matches'] as List? ?? [];
      totalXP += matches.length * 10;
      
      // XP des conversations
      final conversations = userData['stats']?['totalConversations'] ?? 0;
      totalXP += (conversations as int) * 15;
      
      // XP des lettres
      final letters = userData['letterStats']?['lettersSent'] ?? 0;
      totalXP += (letters as int) * 25;
      
      // XP des parrainages
      final referrals = userData['referralStats']?['totalReferrals'] ?? 0;
      totalXP += (referrals as int) * 50;
      
      // XP des badges
      final badges = userData['unlockedBadges'] as List? ?? [];
      totalXP += badges.length * 30;
      
      // XP premium bonus
      final isPremium = userData['isPremium'] ?? false;
      if (isPremium) {
        totalXP = (totalXP * 1.2).round(); // 20% de bonus
      }
      
      // Calculer le niveau (progression logarithmique)
      int level = 1;
      int xpForNextLevel = 100;
      int totalXpNeeded = 0;
      
      while (totalXP >= totalXpNeeded + xpForNextLevel) {
        totalXpNeeded += xpForNextLevel;
        level++;
        xpForNextLevel = (xpForNextLevel * 1.15).round(); // Augmentation de 15% par niveau
      }
      
      final currentLevelXP = totalXP - totalXpNeeded;
      final progressPercent = (currentLevelXP / xpForNextLevel * 100).round();
      
      // Déterminer le titre
      String title = _getTitleForLevel(level);
      
      return {
        'level': level,
        'totalXP': totalXP,
        'currentLevelXP': currentLevelXP,
        'xpForNextLevel': xpForNextLevel,
        'progressPercent': progressPercent,
        'title': title,
        'isPremium': isPremium,
      };
    } catch (e) {
      print('Erreur calcul niveau: $e');
      return {
        'level': 1,
        'totalXP': 0,
        'currentLevelXP': 0,
        'xpForNextLevel': 100,
        'progressPercent': 0,
        'title': 'Nouveau',
        'isPremium': false,
      };
    }
  }
  
  // Obtenir le titre selon le niveau
  String _getTitleForLevel(int level) {
    if (level >= 100) return 'Légende Éternelle';
    if (level >= 75) return 'Maître de l\'Amour';
    if (level >= 50) return 'Virtuose des Cœurs';
    if (level >= 35) return 'Expert en Romance';
    if (level >= 25) return 'Séducteur Confirmé';
    if (level >= 15) return 'Charmeur Expérimenté';
    if (level >= 10) return 'Apprenti Cupid';
    if (level >= 5) return 'Explorateur Social';
    return 'Nouveau Romantique';
  }
  
  // Créer un défi quotidien
  Future<Map<String, dynamic>> createDailyChallenge(String userId) async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      // Vérifier si un défi existe déjà pour aujourd'hui
      final existingChallenge = await _firestore
          .collection('dailyChallenges')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: todayStr)
          .limit(1)
          .get();
      
      if (existingChallenge.docs.isNotEmpty) {
        return existingChallenge.docs.first.data();
      }
      
      // Défis possibles
      final challenges = [
        {
          'type': 'send_messages',
          'title': 'Brise-Glace',
          'description': 'Envoyez 3 premiers messages aujourd\'hui',
          'target': 3,
          'reward': 75,
          'category': 'social',
        },
        {
          'type': 'send_letter',
          'title': 'Épistolaire',
          'description': 'Envoyez une lettre authentique',
          'target': 1,
          'reward': 100,
          'category': 'letters',
        },
        {
          'type': 'visit_bars',
          'title': 'Explorateur',
          'description': 'Visitez 2 bars différents',
          'target': 2,
          'reward': 80,
          'category': 'exploration',
        },
        {
          'type': 'complete_profile',
          'title': 'Perfectionniste',
          'description': 'Complétez votre profil à 100%',
          'target': 1,
          'reward': 150,
          'category': 'profile',
        },
        {
          'type': 'positive_interactions',
          'title': 'Gentleman',
          'description': 'Ayez 5 interactions positives',
          'target': 5,
          'reward': 120,
          'category': 'behavior',
        },
      ];
      
      // Choisir un défi aléatoire
      final random = DateTime.now().millisecondsSinceEpoch % challenges.length;
      final selectedChallenge = challenges[random];
      
      final challengeData = {
        'userId': userId,
        'date': todayStr,
        'type': selectedChallenge['type'],
        'title': selectedChallenge['title'],
        'description': selectedChallenge['description'],
        'target': selectedChallenge['target'],
        'progress': 0,
        'isCompleted': false,
        'reward': selectedChallenge['reward'],
        'category': selectedChallenge['category'],
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection('dailyChallenges').add(challengeData);
      
      return challengeData;
    } catch (e) {
      print('Erreur création défi quotidien: $e');
      return {};
    }
  }
  
  // Mettre à jour le progrès d'un défi
  Future<bool> updateChallengeProgress(String userId, String challengeType, int increment) async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final challengeQuery = await _firestore
          .collection('dailyChallenges')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: todayStr)
          .where('type', isEqualTo: challengeType)
          .limit(1)
          .get();
      
      if (challengeQuery.docs.isEmpty) return false;
      
      final challengeDoc = challengeQuery.docs.first;
      final challengeData = challengeDoc.data();
      
      if (challengeData['isCompleted'] == true) return false;
      
      final newProgress = (challengeData['progress'] as int) + increment;
      final target = challengeData['target'] as int;
      final isCompleted = newProgress >= target;
      
      await challengeDoc.reference.update({
        'progress': newProgress.clamp(0, target),
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
      });
      
      // Si complété, donner la récompense
      if (isCompleted && challengeData['isCompleted'] != true) {
        await _firestore.collection('users').doc(userId).update({
          'coins': FieldValue.increment(challengeData['reward']),
          'gamificationStats.dailyChallengesCompleted': FieldValue.increment(1),
          'gamificationStats.totalCoinsFromChallenges': FieldValue.increment(challengeData['reward']),
        });
        
        // Défi bonus si c'est le 7ème défi de la semaine
        await _checkWeeklyStreakBonus(userId);
      }
      
      return isCompleted;
    } catch (e) {
      print('Erreur mise à jour défi: $e');
      return false;
    }
  }
  
  // Vérifier le bonus de série hebdomadaire
  Future<void> _checkWeeklyStreakBonus(String userId) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(Duration(days: 6));
      
      final weekStartStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
      final weekEndStr = '${weekEnd.year}-${weekEnd.month.toString().padLeft(2, '0')}-${weekEnd.day.toString().padLeft(2, '0')}';
      
      final completedChallenges = await _firestore
          .collection('dailyChallenges')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: weekStartStr)
          .where('date', isLessThanOrEqualTo: weekEndStr)
          .where('isCompleted', isEqualTo: true)
          .get();
      
      if (completedChallenges.size >= 7) {
        // Bonus hebdomadaire !
        await _firestore.collection('users').doc(userId).update({
          'coins': FieldValue.increment(300),
          'gamificationStats.weeklyStreakBonuses': FieldValue.increment(1),
        });
        
        // Tenter de débloquer le badge de constance
        await checkAndUnlockBadges(userId);
      }
    } catch (e) {
      print('Erreur vérification bonus hebdomadaire: $e');
    }
  }
  
  // Obtenir les statistiques de gamification
  Future<Map<String, dynamic>> getGamificationStats(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return {};
      
      final userData = userDoc.data()!;
      final badges = await getUserBadges(userId);
      final levelInfo = await calculateUserLevel(userId);
      
      // Statistiques des défis
      final completedChallenges = await _firestore
          .collection('dailyChallenges')
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: true)
          .get();
      
      // Défi du jour
      final todayChallenge = await createDailyChallenge(userId);
      
      // Classement badges par rareté
      badges.sort((a, b) => b.rarity.compareTo(a.rarity));
      
      return {
        'level': levelInfo,
        'badges': {
          'total': badges.length,
          'byTier': _groupBadgesByTier(badges),
          'rarest': badges.take(3).map((b) => b.toMap()).toList(),
          'recent': badges.take(5).map((b) => b.toMap()).toList(),
        },
        'challenges': {
          'totalCompleted': completedChallenges.size,
          'today': todayChallenge,
          'weeklyStreak': await _getWeeklyStreak(userId),
        },
        'achievements': {
          'totalUnlocked': userData['unlockedBadges']?.length ?? 0,
          'totalAvailable': AVAILABLE_BADGES.length,
          'completionRate': ((userData['unlockedBadges']?.length ?? 0) / AVAILABLE_BADGES.length * 100).round(),
        },
        'coins': {
          'current': userData['coins'] ?? 0,
          'fromBadges': userData['gamificationStats']?['totalCoinsFromBadges'] ?? 0,
          'fromChallenges': userData['gamificationStats']?['totalCoinsFromChallenges'] ?? 0,
        },
      };
    } catch (e) {
      print('Erreur stats gamification: $e');
      return {};
    }
  }
  
  // Grouper les badges par niveau
  Map<String, int> _groupBadgesByTier(List<Badge> badges) {
    Map<String, int> tierCounts = {};
    
    for (final badge in badges) {
      final tierName = badge.tier.toString().split('.').last;
      tierCounts[tierName] = (tierCounts[tierName] ?? 0) + 1;
    }
    
    return tierCounts;
  }
  
  // Obtenir la série hebdomadaire
  Future<int> _getWeeklyStreak(String userId) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      
      final challenges = await _firestore
          .collection('dailyChallenges')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}')
          .where('isCompleted', isEqualTo: true)
          .get();
      
      return challenges.size;
    } catch (e) {
      return 0;
    }
  }
  
  // Obtenir le leaderboard général
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 20}) async {
    try {
      final users = await _firestore
          .collection('users')
          .orderBy('gamificationStats.totalBadges', descending: true)
          .limit(limit)
          .get();
      
      List<Map<String, dynamic>> leaderboard = [];
      
      for (int i = 0; i < users.docs.length; i++) {
        final doc = users.docs[i];
        final data = doc.data();
        final levelInfo = await calculateUserLevel(doc.id);
        
        leaderboard.add({
          'rank': i + 1,
          'userId': doc.id,
          'username': data['username'] ?? 'Utilisateur ${doc.id.substring(0, 6)}',
          'level': levelInfo['level'],
          'totalBadges': data['gamificationStats']?['totalBadges'] ?? 0,
          'totalXP': levelInfo['totalXP'],
          'title': levelInfo['title'],
          'isPremium': data['isPremium'] ?? false,
        });
      }
      
      return leaderboard;
    } catch (e) {
      print('Erreur leaderboard: $e');
      return [];
    }
  }
}