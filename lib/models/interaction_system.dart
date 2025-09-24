/**
 * RÉFÉRENCE OBLIGATOIRE: https://jeutaime-warren.web.app/
 * 
 * Système d'interactions entre avatars pour JeuTaime Flutter
 * Actions déblocables selon les relations et activités
 */

import 'package:flutter/material.dart';

enum ActionCategory { basic, friendship, magic, romantic }

class InteractionAction {
  final String id;
  final String emoji;
  final String name;
  final int cost;
  final String description;
  final ActionCategory category;

  const InteractionAction({
    required this.id,
    required this.emoji,
    required this.name,
    required this.cost,
    required this.description,
    required this.category,
  });
}

class InteractionEffect {
  final String animation;
  final int duration;
  final String message;
  final String sound;
  final String particles;

  const InteractionEffect({
    required this.animation,
    required this.duration,
    required this.message,
    required this.sound,
    required this.particles,
  });
}

class UserRelation {
  final bool barWeeklyCompleted;
  final bool activitiesShared;
  final bool friendship;
  final bool compatibility80;
  final bool heartConnection;
  final int messagesCount;
  final double compatibilityScore;

  const UserRelation({
    this.barWeeklyCompleted = false,
    this.activitiesShared = true,
    this.friendship = false,
    this.compatibility80 = false,
    this.heartConnection = false,
    this.messagesCount = 0,
    this.compatibilityScore = 0.0,
  });

  UserRelation copyWith({
    bool? barWeeklyCompleted,
    bool? activitiesShared,
    bool? friendship,
    bool? compatibility80,
    bool? heartConnection,
    int? messagesCount,
    double? compatibilityScore,
  }) {
    return UserRelation(
      barWeeklyCompleted: barWeeklyCompleted ?? this.barWeeklyCompleted,
      activitiesShared: activitiesShared ?? this.activitiesShared,
      friendship: friendship ?? (messagesCount ?? this.messagesCount) >= 3,
      compatibility80: compatibility80 ?? (compatibilityScore ?? this.compatibilityScore) >= 80,
      heartConnection: heartConnection ?? this.heartConnection,
      messagesCount: messagesCount ?? this.messagesCount,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
    );
  }
}

class InteractionSystem {
  /// Actions disponibles selon les conditions de relation
  static List<InteractionAction> getAvailableActions(UserRelation relation) {
    final List<InteractionAction> actions = [];
    
    // Actions de base (toujours disponibles)
    actions.addAll([
      InteractionAction(
        id: 'wave',
        emoji: '👋',
        name: 'Salut',
        cost: 0,
        description: 'Un petit salut amical',
        category: ActionCategory.basic,
      ),
      InteractionAction(
        id: 'smile',
        emoji: '😊',
        name: 'Sourire',
        cost: 0,
        description: 'Partagez un sourire chaleureux',
        category: ActionCategory.basic,
      ),
    ]);
    
    // Actions débloquées par les activités partagées
    if (relation.activitiesShared) {
      actions.addAll([
        InteractionAction(
          id: 'gift',
          emoji: '🎁',
          name: 'Cadeau',
          cost: 10,
          description: 'Offrez un petit cadeau virtuel',
          category: ActionCategory.friendship,
        ),
        InteractionAction(
          id: 'flower',
          emoji: '🌹',
          name: 'Fleur',
          cost: 15,
          description: 'Une belle rose pour faire plaisir',
          category: ActionCategory.friendship,
        ),
      ]);
    }
    
    // Actions d'amitié (3+ messages échangés)
    if (relation.friendship) {
      actions.addAll([
        InteractionAction(
          id: 'hug',
          emoji: '🤗',
          name: 'Câlin',
          cost: 20,
          description: 'Un câlin virtuel réconfortant',
          category: ActionCategory.friendship,
        ),
        InteractionAction(
          id: 'tickle',
          emoji: '😆',
          name: 'Chatouille',
          cost: 25,
          description: 'Déclenchez un fou rire !',
          category: ActionCategory.friendship,
        ),
      ]);
    }
    
    // Actions magiques (bar hebdomadaire terminé)
    if (relation.barWeeklyCompleted) {
      actions.addAll([
        InteractionAction(
          id: 'magic',
          emoji: '✨',
          name: 'Sort Magique',
          cost: 50,
          description: 'Lancez un sort de bonheur !',
          category: ActionCategory.magic,
        ),
        InteractionAction(
          id: 'crown',
          emoji: '👑',
          name: 'Couronnement',
          cost: 75,
          description: 'Couronnez cette personne spéciale',
          category: ActionCategory.magic,
        ),
      ]);
    }
    
    // Actions romantiques (compatibilité 80%+)
    if (relation.compatibility80) {
      actions.add(
        InteractionAction(
          id: 'kiss',
          emoji: '😘',
          name: 'Bisou Joue',
          cost: 100,
          description: 'Un bisou délicat sur la joue',
          category: ActionCategory.romantic,
        ),
      );
    }
    
    // Actions cœur à cœur (connexion profonde)
    if (relation.heartConnection) {
      actions.add(
        InteractionAction(
          id: 'heart',
          emoji: '💕',
          name: 'Cœur à Cœur',
          cost: 150,
          description: 'Partagez un moment d\'intimité',
          category: ActionCategory.romantic,
        ),
      );
    }
    
    return actions;
  }

  /// Exécution d'une action avec effet visuel
  static InteractionEffect performAction(InteractionAction action, String targetName, String sourceName) {
    const Map<String, InteractionEffect> effects = {
      'wave': InteractionEffect(
        animation: 'wave',
        duration: 1000,
        message: 'vous salue amicalement !',
        sound: 'wave',
        particles: '👋',
      ),
      'smile': InteractionEffect(
        animation: 'bounce',
        duration: 800,
        message: 'vous sourit avec chaleur !',
        sound: 'smile',
        particles: '😊',
      ),
      'gift': InteractionEffect(
        animation: 'gift',
        duration: 1500,
        message: 'vous offre un cadeau surprise !',
        sound: 'gift',
        particles: '🎁✨',
      ),
      'flower': InteractionEffect(
        animation: 'flower',
        duration: 2000,
        message: 'vous offre une magnifique rose !',
        sound: 'flower',
        particles: '🌹💫',
      ),
      'hug': InteractionEffect(
        animation: 'hug',
        duration: 2500,
        message: 'vous serre dans ses bras virtuels !',
        sound: 'hug',
        particles: '🤗💕',
      ),
      'tickle': InteractionEffect(
        animation: 'tickle',
        duration: 1200,
        message: 'vous fait éclater de rire !',
        sound: 'tickle',
        particles: '😆✨',
      ),
      'magic': InteractionEffect(
        animation: 'sparkles',
        duration: 3000,
        message: 'vous lance un sort de bonheur !',
        sound: 'magic',
        particles: '✨🌟💫',
      ),
      'crown': InteractionEffect(
        animation: 'crown',
        duration: 2500,
        message: 'vous couronne avec honneur !',
        sound: 'crown',
        particles: '👑✨',
      ),
      'kiss': InteractionEffect(
        animation: 'kiss',
        duration: 2000,
        message: 'vous fait un tendre bisou !',
        sound: 'kiss',
        particles: '😘💕',
      ),
      'heart': InteractionEffect(
        animation: 'heart',
        duration: 3500,
        message: 'partage son cœur avec vous !',
        sound: 'heart',
        particles: '💕💖💝',
      ),
    };
    
    final effect = effects[action.id] ?? effects['smile']!;
    
    return InteractionEffect(
      animation: effect.animation,
      duration: effect.duration,
      message: '$sourceName ${effect.message}',
      sound: effect.sound,
      particles: effect.particles,
    );
  }

  /// Mise à jour des conditions selon les événements
  static UserRelation updateRelationConditions(UserRelation relation, String eventType, {Map<String, dynamic>? data}) {
    switch (eventType) {
      case 'bar_weekly_completed':
        return relation.copyWith(barWeeklyCompleted: true);
      case 'messages_exchanged':
        final count = data?['count'] ?? relation.messagesCount + 1;
        return relation.copyWith(
          messagesCount: count,
          friendship: count >= 3,
        );
      case 'compatibility_calculated':
        final score = data?['score'] ?? 0.0;
        return relation.copyWith(
          compatibilityScore: score,
          compatibility80: score >= 80,
        );
      case 'heart_connection':
        return relation.copyWith(heartConnection: true);
      case 'activities_shared':
        return relation.copyWith(activitiesShared: true);
      default:
        return relation;
    }
  }

  /// Couleur selon la catégorie d'action
  static Color getCategoryColor(ActionCategory category) {
    switch (category) {
      case ActionCategory.basic:
        return Colors.grey.shade600;
      case ActionCategory.friendship:
        return Colors.blue.shade600;
      case ActionCategory.magic:
        return Colors.purple.shade600;
      case ActionCategory.romantic:
        return Colors.pink.shade600;
    }
  }

  /// Icône selon la catégorie d'action
  static IconData getCategoryIcon(ActionCategory category) {
    switch (category) {
      case ActionCategory.basic:
        return Icons.waving_hand;
      case ActionCategory.friendship:
        return Icons.favorite;
      case ActionCategory.magic:
        return Icons.auto_awesome;
      case ActionCategory.romantic:
        return Icons.favorite_border;
    }
  }
}