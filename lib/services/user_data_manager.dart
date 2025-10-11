import 'dart:convert';
import 'package:flutter/foundation.dart';

class UserDataManager {
  static const String _keyCoins = 'user_coins';
  static const String _keyLevel = 'user_level';
  static const String _keyXP = 'user_xp';
  static const String _keyGameStats = 'game_stats';
  static const String _keyAchievements = 'achievements';
  static const String _keyPetStats = 'pet_stats';
  static const String _keyUnlockedFeatures = 'unlocked_features';

  // Singleton pattern
  static final UserDataManager _instance = UserDataManager._internal();
  factory UserDataManager() => _instance;
  UserDataManager._internal();

  // Mock storage (remplace SharedPreferences pour la démo)
  final Map<String, dynamic> _storage = {};

  // User progress
  int get coins => _storage[_keyCoins] ?? 245;
  int get level => _storage[_keyLevel] ?? 1;
  int get xp => _storage[_keyXP] ?? 0;
  
  // XP required for next level (exponential growth)
  int get xpToNextLevel => (level * 100 * (1 + level * 0.2)).round();
  double get levelProgress => xpToNextLevel > 0 ? xp / xpToNextLevel : 0;

  // Game statistics
  GameStats get gameStats {
    final data = _storage[_keyGameStats];
    if (data != null) {
      return GameStats.fromJson(jsonDecode(data));
    }
    return GameStats();
  }

  // Pet statistics
  PetStats get petStats {
    final data = _storage[_keyPetStats];
    if (data != null) {
      return PetStats.fromJson(jsonDecode(data));
    }
    return PetStats();
  }

  // Achievements
  List<String> get unlockedAchievements {
    final data = _storage[_keyAchievements];
    if (data != null) {
      return List<String>.from(jsonDecode(data));
    }
    return [];
  }

  // Unlocked features
  List<String> get unlockedFeatures {
    final data = _storage[_keyUnlockedFeatures];
    if (data != null) {
      return List<String>.from(jsonDecode(data));
    }
    return ['basic_games', 'adoption_basic'];
  }

  // Update coins
  void updateCoins(int delta) {
    final newCoins = (coins + delta).clamp(0, 999999);
    _storage[_keyCoins] = newCoins;
    _saveData();
    
    if (delta > 0) {
      _addXP(delta ~/ 2); // 1 XP for every 2 coins earned
    }
  }

  // Add XP and handle level ups
  void _addXP(int xpGained) {
    final newXP = xp + xpGained;
    int newLevel = level;
    int currentXP = newXP;

    // Check for level ups
    while (currentXP >= (newLevel * 100 * (1 + newLevel * 0.2)).round()) {
      currentXP -= (newLevel * 100 * (1 + newLevel * 0.2)).round();
      newLevel++;
      _onLevelUp(newLevel);
    }

    _storage[_keyXP] = currentXP;
    _storage[_keyLevel] = newLevel;
    _saveData();
  }

  void _onLevelUp(int newLevel) {
    // Level up rewards
    int levelReward = newLevel * 50;
    _storage[_keyCoins] = coins + levelReward;
    
    // Unlock new features based on level
    List<String> features = List<String>.from(unlockedFeatures);
    
    switch (newLevel) {
      case 2:
        if (!features.contains('premium_games')) {
          features.add('premium_games');
        }
        break;
      case 3:
        if (!features.contains('adoption_advanced')) {
          features.add('adoption_advanced');
        }
        break;
      case 5:
        if (!features.contains('special_bars')) {
          features.add('special_bars');
        }
        break;
      case 10:
        if (!features.contains('vip_features')) {
          features.add('vip_features');
        }
        break;
    }
    
    _storage[_keyUnlockedFeatures] = jsonEncode(features);
    
    if (kDebugMode) {
      print('🎉 Level Up! Nouveau niveau: $newLevel, Récompense: $levelReward pièces');
    }
  }

  // Update game statistics
  void updateGameStats(String gameType, {
    int? gamesPlayed,
    int? bestScore,
    int? totalScore,
    Duration? bestTime,
  }) {
    final stats = gameStats;
    
    switch (gameType.toLowerCase()) {
      case 'reactivity':
        if (gamesPlayed != null) stats.reactivityGamesPlayed += gamesPlayed;
        if (bestScore != null && bestScore > stats.reactivityBestScore) {
          stats.reactivityBestScore = bestScore;
        }
        break;
      case 'memory':
        if (gamesPlayed != null) stats.memoryGamesPlayed += gamesPlayed;
        if (bestScore != null && bestScore > stats.memoryBestScore) {
          stats.memoryBestScore = bestScore;
        }
        break;
      case 'snake':
        if (gamesPlayed != null) stats.snakeGamesPlayed += gamesPlayed;
        if (bestScore != null && bestScore > stats.snakeBestScore) {
          stats.snakeBestScore = bestScore;
        }
        break;
      case 'quiz':
        if (gamesPlayed != null) stats.quizGamesPlayed += gamesPlayed;
        if (bestScore != null && bestScore > stats.quizBestScore) {
          stats.quizBestScore = bestScore;
        }
        break;
    }
    
    _storage[_keyGameStats] = jsonEncode(stats.toJson());
    _saveData();
    
    _checkAchievements();
  }

  // Check and unlock achievements
  void _checkAchievements() {
    List<String> achievements = List<String>.from(unlockedAchievements);
    final stats = gameStats;
    
    // Game-based achievements
    if (stats.totalGamesPlayed >= 10 && !achievements.contains('gamer_bronze')) {
      achievements.add('gamer_bronze');
      updateCoins(100);
    }
    
    if (stats.totalGamesPlayed >= 50 && !achievements.contains('gamer_silver')) {
      achievements.add('gamer_silver');
      updateCoins(250);
    }
    
    if (stats.totalGamesPlayed >= 100 && !achievements.contains('gamer_gold')) {
      achievements.add('gamer_gold');
      updateCoins(500);
    }
    
    // Score-based achievements
    if (stats.memoryBestScore >= 500 && !achievements.contains('memory_master')) {
      achievements.add('memory_master');
      updateCoins(200);
    }
    
    if (stats.snakeBestScore >= 200 && !achievements.contains('snake_champion')) {
      achievements.add('snake_champion');
      updateCoins(200);
    }
    
    _storage[_keyAchievements] = jsonEncode(achievements);
    _saveData();
  }

  // Check if feature is unlocked
  bool isFeatureUnlocked(String feature) {
    return unlockedFeatures.contains(feature);
  }

  // Save data (mock implementation)
  void _saveData() {
    if (kDebugMode) {
      print('💾 Données sauvegardées: Niveau $level, ${coins} pièces, ${xp} XP');
    }
  }

  // Reset all data (for testing)
  void resetUserData() {
    _storage.clear();
    _saveData();
  }

  // Get level-based title
  String getLevelTitle() {
    if (level >= 20) return '👑 Maître de l\'Amour';
    if (level >= 15) return '💎 Expert Romance';
    if (level >= 10) return '🌟 Cupido Avancé';
    if (level >= 5) return '💕 Romantique Confirmé';
    if (level >= 3) return '❤️ Amoureux Expérimenté';
    return '💖 Novice en Amour';
  }
}

class GameStats {
  int reactivityGamesPlayed = 0;
  int reactivityBestScore = 0;
  
  int memoryGamesPlayed = 0;
  int memoryBestScore = 0;
  
  int snakeGamesPlayed = 0;
  int snakeBestScore = 0;
  
  int quizGamesPlayed = 0;
  int quizBestScore = 0;
  
  int puzzleGamesPlayed = 0;
  int puzzleBestScore = 0;
  
  int precisionGamesPlayed = 0;
  int precisionBestScore = 0;
  
  int ticTacToeGamesPlayed = 0;
  int ticTacToeWins = 0;
  
  int breakoutGamesPlayed = 0;
  int breakoutBestScore = 0;

  int get totalGamesPlayed => 
    reactivityGamesPlayed + memoryGamesPlayed + snakeGamesPlayed + 
    quizGamesPlayed + puzzleGamesPlayed + precisionGamesPlayed +
    ticTacToeGamesPlayed + breakoutGamesPlayed;

  GameStats();

  GameStats.fromJson(Map<String, dynamic> json) {
    reactivityGamesPlayed = json['reactivityGamesPlayed'] ?? 0;
    reactivityBestScore = json['reactivityBestScore'] ?? 0;
    memoryGamesPlayed = json['memoryGamesPlayed'] ?? 0;
    memoryBestScore = json['memoryBestScore'] ?? 0;
    snakeGamesPlayed = json['snakeGamesPlayed'] ?? 0;
    snakeBestScore = json['snakeBestScore'] ?? 0;
    quizGamesPlayed = json['quizGamesPlayed'] ?? 0;
    quizBestScore = json['quizBestScore'] ?? 0;
    puzzleGamesPlayed = json['puzzleGamesPlayed'] ?? 0;
    puzzleBestScore = json['puzzleBestScore'] ?? 0;
    precisionGamesPlayed = json['precisionGamesPlayed'] ?? 0;
    precisionBestScore = json['precisionBestScore'] ?? 0;
    ticTacToeGamesPlayed = json['ticTacToeGamesPlayed'] ?? 0;
    ticTacToeWins = json['ticTacToeWins'] ?? 0;
    breakoutGamesPlayed = json['breakoutGamesPlayed'] ?? 0;
    breakoutBestScore = json['breakoutBestScore'] ?? 0;
  }

  Map<String, dynamic> toJson() => {
    'reactivityGamesPlayed': reactivityGamesPlayed,
    'reactivityBestScore': reactivityBestScore,
    'memoryGamesPlayed': memoryGamesPlayed,
    'memoryBestScore': memoryBestScore,
    'snakeGamesPlayed': snakeGamesPlayed,
    'snakeBestScore': snakeBestScore,
    'quizGamesPlayed': quizGamesPlayed,
    'quizBestScore': quizBestScore,
    'puzzleGamesPlayed': puzzleGamesPlayed,
    'puzzleBestScore': puzzleBestScore,
    'precisionGamesPlayed': precisionGamesPlayed,
    'precisionBestScore': precisionBestScore,
    'ticTacToeGamesPlayed': ticTacToeGamesPlayed,
    'ticTacToeWins': ticTacToeWins,
    'breakoutGamesPlayed': breakoutGamesPlayed,
    'breakoutBestScore': breakoutBestScore,
  };
}

class PetStats {
  String adoptedPetType = '';
  int petLevel = 1;
  int petHappiness = 100;
  int petEnergy = 100;
  int interactionsToday = 0;
  DateTime lastInteraction = DateTime.now();

  PetStats();

  PetStats.fromJson(Map<String, dynamic> json) {
    adoptedPetType = json['adoptedPetType'] ?? '';
    petLevel = json['petLevel'] ?? 1;
    petHappiness = json['petHappiness'] ?? 100;
    petEnergy = json['petEnergy'] ?? 100;
    interactionsToday = json['interactionsToday'] ?? 0;
    lastInteraction = DateTime.tryParse(json['lastInteraction'] ?? '') ?? DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'adoptedPetType': adoptedPetType,
    'petLevel': petLevel,
    'petHappiness': petHappiness,
    'petEnergy': petEnergy,
    'interactionsToday': interactionsToday,
    'lastInteraction': lastInteraction.toIso8601String(),
  };
}