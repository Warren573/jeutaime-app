
import 'package:flutter/material.dart';
import '../config/ui_reference.dart';

// Définition minimale pour compatibilité
class BarActivity {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final dynamic type;
  final int participantsMin;
  final int participantsMax;
  final Duration estimatedDuration;
  final List<String> rewards;

  const BarActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.participantsMin,
    required this.participantsMax,
    required this.estimatedDuration,
    required this.rewards,
  });
}

class Badge {
  final String name;
  const Badge({required this.name});
}

class Reward {
  final String title;
  const Reward({required this.title});
}

/// Modèle pour le contenu thématique d'un bar

class BarContent {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final Color themeColor;
  final List<BarActivity> activities;
  final List<BarChallenge> challenges;
  final BarAccessLevel accessLevel;
  final String? unlockCondition;
  // Ajouts pour compatibilité UI
  final List<Group> groups;
  final List<SpecialEvent> specialEvents;
  final List<Badge> badges;
  final List<Reward> rewards;
  final int totalVisits;
  final int totalChallengesCompleted;

  const BarContent({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.themeColor,
    required this.activities,
    required this.challenges,
    required this.accessLevel,
    this.unlockCondition,
    this.groups = const [],
    this.specialEvents = const [],
    this.badges = const [],
    this.rewards = const [],
    this.totalVisits = 0,
    this.totalChallengesCompleted = 0,
  });
}


class Group {
  final String name;
  const Group({required this.name});
}

class SpecialEvent {
  final String title;
  const SpecialEvent({required this.title});
}


// Badge et Reward sont supposés être définis ailleurs dans le projet
// Si besoin, ajouter ici des classes vides pour éviter les erreurs de compilation :
// class Badge {}
// class Reward {}

/// Défi/challenge d'un bar
class BarChallenge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final ChallengeType type;
  final int pointsReward;
  final bool isDaily;
  final bool isWeekly;
  final Map<String, dynamic>? requirements;

  const BarChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.pointsReward,
    this.isDaily = false,
    this.isWeekly = false,
    this.requirements,
  });
}

enum ActivityType {
  conversation,
  game,
  teamChallenge,
  quest,
  riddle,
}

enum ChallengeType {
  daily,
  weekly,
  special,
  unlock,
}

enum BarAccessLevel {
  public,     // Accessible à tous
  restricted, // Conditions à remplir
  premium,    // Nécessite des points/achat
  hidden,     // Accès par énigmes
}

/// Service de gestion du contenu des bars
class BarContentService {
  static List<BarContent> getAllBars() {
    return [
      _getRomanticBar(),
      _getHumorBar(),
      _getPiratesBar(),
      _getWeeklyBar(),
      _getHiddenBar(),
    ];
  }

  static BarContent? getBarById(String id) {
    try {
      return getAllBars().firstWhere((bar) => bar.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Bar Romantique 🌹
  static BarContent _getRomanticBar() {
    return BarContent(
      id: 'romantic',
      name: 'Bar Romantique',
      emoji: '🌹',
      description: 'Ambiance tamisée, conversations intimes et connexions profondes',
      themeColor: const Color(0xFFE91E63),
      accessLevel: BarAccessLevel.public,
      activities: [
        BarActivity(
          id: 'deep_conversation',
          title: 'Conversation Profonde',
          description: 'Questions intimes pour mieux se découvrir en tête-à-tête',
          emoji: '💭',
          type: ActivityType.conversation,
          participantsMin: 2,
          participantsMax: 2,
          estimatedDuration: Duration(minutes: 30),
          rewards: ['Points de compatibilité', 'Badge "Cœur Ouvert"'],
        ),
        BarActivity(
          id: 'romantic_quest',
          title: 'Quête Romantique',
          description: 'Créez ensemble une histoire d\'amour virtuelle',
          emoji: '💕',
          type: ActivityType.quest,
          participantsMin: 2,
          participantsMax: 4,
          estimatedDuration: Duration(minutes: 45),
          rewards: ['Points Romance', 'Déblocage contenu exclusif'],
        ),
        BarActivity(
          id: 'poetry_challenge',
          title: 'Défi Poésie',
          description: 'Composez des vers romantiques ensemble',
          emoji: '📝',
          type: ActivityType.game,
          participantsMin: 2,
          participantsMax: 6,
          estimatedDuration: Duration(minutes: 20),
          rewards: ['Badge "Poète du Cœur"', 'Points créativité'],
        ),
      ],
      challenges: [
        BarChallenge(
          id: 'daily_compliment',
          title: 'Compliment du Jour',
          description: 'Faites un compliment sincère à 3 personnes',
          emoji: '🌟',
          type: ChallengeType.daily,
          pointsReward: 50,
          isDaily: true,
        ),
        BarChallenge(
          id: 'romantic_story',
          title: 'Histoire Romantique',
          description: 'Racontez votre plus beau souvenir romantique',
          emoji: '💖',
          type: ChallengeType.special,
          pointsReward: 100,
        ),
      ],
    );
  }

  /// Bar Humoristique 😄
  static BarContent _getHumorBar() {
    return BarContent(
      id: 'humor',
      name: 'Bar Humoristique',
      emoji: '😄',
      description: 'Défi du jour, blagues et rires garantis',
      themeColor: const Color(0xFFFF9800),
      accessLevel: BarAccessLevel.public,
      activities: [
        BarActivity(
          id: 'joke_battle',
          title: 'Battle de Blagues',
          description: 'Qui raconte la meilleure blague ?',
          emoji: '🤣',
          type: ActivityType.game,
          participantsMin: 2,
          participantsMax: 8,
          estimatedDuration: Duration(minutes: 15),
          rewards: ['Badge "Roi de l\'Humour"', 'Points Charisme'],
        ),
        BarActivity(
          id: 'improv_theater',
          title: 'Théâtre d\'Impro',
          description: 'Improvisations drôles sur des thèmes donnés',
          emoji: '🎭',
          type: ActivityType.teamChallenge,
          participantsMin: 4,
          participantsMax: 6,
          estimatedDuration: Duration(minutes: 30),
          rewards: ['Points Créativité', 'Déblocage Bar Pirates'],
        ),
        BarActivity(
          id: 'meme_creation',
          title: 'Création de Mèmes',
          description: 'Créez les mèmes les plus drôles ensemble',
          emoji: '😂',
          type: ActivityType.game,
          participantsMin: 2,
          participantsMax: 4,
          estimatedDuration: Duration(minutes: 25),
          rewards: ['Badge "Mème Master"', 'Points Viral'],
        ),
      ],
      challenges: [
        BarChallenge(
          id: 'daily_laugh',
          title: 'Rire Quotidien',
          description: 'Faites rire 5 personnes aujourd\'hui',
          emoji: '😆',
          type: ChallengeType.daily,
          pointsReward: 75,
          isDaily: true,
        ),
        BarChallenge(
          id: 'comedy_genius',
          title: 'Génie de la Comédie',
          description: 'Remportez 3 battles de blagues',
          emoji: '👑',
          type: ChallengeType.special,
          pointsReward: 200,
          requirements: {'joke_battle_wins': 3},
        ),
      ],
    );
  }

  /// Bar Pirates 🏴‍☠️
  static BarContent _getPiratesBar() {
    return BarContent(
      id: 'pirates',
      name: 'Bar Pirates',
      emoji: '🏴‍☠️',
      description: 'Chasse au trésor en équipe, aventures et défis corsaires',
      themeColor: const Color(0xFF795548),
      accessLevel: BarAccessLevel.restricted,
      unlockCondition: 'Compléter 2 activités du Bar Humoristique',
      activities: [
        BarActivity(
          id: 'treasure_hunt',
          title: 'Chasse au Trésor',
          description: 'Résolvez des énigmes pour trouver le trésor perdu',
          emoji: '🗺️',
          type: ActivityType.quest,
          participantsMin: 3,
          participantsMax: 6,
          estimatedDuration: Duration(hours: 1),
          rewards: ['Pièces d\'or virtuelles', 'Badge "Chasseur de Trésor"'],
        ),
        BarActivity(
          id: 'pirate_duel',
          title: 'Duel de Pirates',
          description: 'Affrontement d\'énigmes entre équipes rivales',
          emoji: '⚔️',
          type: ActivityType.teamChallenge,
          participantsMin: 4,
          participantsMax: 8,
          estimatedDuration: Duration(minutes: 45),
          rewards: ['Titre "Capitaine"', 'Accès Zone VIP'],
        ),
        BarActivity(
          id: 'sea_legends',
          title: 'Légendes des Mers',
          description: 'Racontez vos aventures maritimes imaginaires',
          emoji: '🌊',
          type: ActivityType.conversation,
          participantsMin: 3,
          participantsMax: 5,
          estimatedDuration: Duration(minutes: 30),
          rewards: ['Points Aventure', 'Badge "Conteur des Mers"'],
        ),
      ],
      challenges: [
        BarChallenge(
          id: 'daily_adventure',
          title: 'Aventure Quotidienne',
          description: 'Participez à une quête chaque jour',
          emoji: '🧭',
          type: ChallengeType.daily,
          pointsReward: 100,
          isDaily: true,
        ),
        BarChallenge(
          id: 'pirate_legend',
          title: 'Légende Pirate',
          description: 'Remportez 5 chasses au trésor',
          emoji: '👑',
          type: ChallengeType.special,
          pointsReward: 500,
          requirements: {'treasure_hunt_wins': 5},
        ),
      ],
    );
  }

  /// Bar Hebdomadaire 📅
  static BarContent _getWeeklyBar() {
    return BarContent(
      id: 'weekly',
      name: 'Bar Hebdomadaire',
      emoji: '📅',
      description: 'Groupe de 4 (2H/2F) - Thème changeant chaque semaine',
      themeColor: const Color(0xFF9C27B0),
      accessLevel: BarAccessLevel.restricted,
      unlockCondition: 'Niveau 5 et profil complet',
      activities: [
        BarActivity(
          id: 'weekly_theme',
          title: 'Défi Thématique',
          description: 'Activité basée sur le thème de la semaine',
          emoji: '🎯',
          type: ActivityType.teamChallenge,
          participantsMin: 4,
          participantsMax: 4, // Exactement 2H + 2F
          estimatedDuration: Duration(hours: 1, minutes: 30),
          rewards: ['Badge Thématique', 'Points Hebdomadaires'],
        ),
        BarActivity(
          id: 'group_bonding',
          title: 'Cohésion de Groupe',
          description: 'Activités pour créer des liens durables',
          emoji: '🤝',
          type: ActivityType.teamChallenge,
          participantsMin: 4,
          participantsMax: 4,
          estimatedDuration: Duration(minutes: 45),
          rewards: ['Points Amitié', 'Déblocage conversations privées'],
        ),
        BarActivity(
          id: 'weekly_project',
          title: 'Projet Collaboratif',
          description: 'Créez quelque chose ensemble selon le thème',
          emoji: '🛠️',
          type: ActivityType.quest,
          participantsMin: 4,
          participantsMax: 4,
          estimatedDuration: Duration(hours: 2),
          rewards: ['Œuvre collective', 'Badge "Créateur"'],
        ),
      ],
      challenges: [
        BarChallenge(
          id: 'weekly_participation',
          title: 'Participation Hebdo',
          description: 'Participez à toutes les activités de la semaine',
          emoji: '🏆',
          type: ChallengeType.weekly,
          pointsReward: 300,
          isWeekly: true,
        ),
        BarChallenge(
          id: 'group_harmony',
          title: 'Harmonie de Groupe',
          description: 'Maintenez une bonne entente pendant 4 semaines',
          emoji: '💫',
          type: ChallengeType.special,
          pointsReward: 1000,
          requirements: {'weeks_harmony': 4},
        ),
      ],
    );
  }

  /// Bar Caché 👑
  static BarContent _getHiddenBar() {
    return BarContent(
      id: 'hidden',
      name: 'Bar Caché',
      emoji: '👑',
      description: 'Accès exclusif par résolution d\'énigmes complexes',
      themeColor: const Color(0xFFFFD700),
      accessLevel: BarAccessLevel.hidden,
      unlockCondition: 'Résoudre l\'Énigme du Sphinx d\'Or',
      activities: [
        BarActivity(
          id: 'sphinx_riddle',
          title: 'Énigme du Sphinx',
          description: 'Résolvez les mystères les plus complexes',
          emoji: '🔮',
          type: ActivityType.riddle,
          participantsMin: 1,
          participantsMax: 3,
          estimatedDuration: Duration(hours: 2),
          rewards: ['Accès Bar Caché', 'Titre "Maître des Énigmes"'],
        ),
        BarActivity(
          id: 'exclusive_gathering',
          title: 'Rassemblement Exclusif',
          description: 'Rencontres entre membres d\'élite du Bar Caché',
          emoji: '✨',
          type: ActivityType.conversation,
          participantsMin: 2,
          participantsMax: 6,
          estimatedDuration: Duration(hours: 1),
          rewards: ['Connexions VIP', 'Accès contenu secret'],
        ),
        BarActivity(
          id: 'mystery_quest',
          title: 'Quête Mystère',
          description: 'Aventures secrètes pour initiés seulement',
          emoji: '🗝️',
          type: ActivityType.quest,
          participantsMin: 2,
          participantsMax: 4,
          estimatedDuration: Duration(hours: 3),
          rewards: ['Artefacts rares', 'Pouvoirs spéciaux'],
        ),
      ],
      challenges: [
        BarChallenge(
          id: 'daily_mystery',
          title: 'Mystère Quotidien',
          description: 'Résolvez une énigme mystérieuse chaque jour',
          emoji: '🌟',
          type: ChallengeType.daily,
          pointsReward: 200,
          isDaily: true,
        ),
        BarChallenge(
          id: 'grand_master',
          title: 'Grand Maître',
          description: 'Atteignez le plus haut niveau de l\'élite',
          emoji: '👑',
          type: ChallengeType.special,
          pointsReward: 2000,
          requirements: {'enigma_solved': 50, 'vip_connections': 10},
        ),
      ],
    );
  }
}