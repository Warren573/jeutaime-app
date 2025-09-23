import 'package:cloud_firestore/cloud_firestore.dart';

class Bar {
  final String barId;
  final String name;
  final BarType type;
  final bool isActive;
  final int activeUsers;
  final int maxParticipants;
  final DateTime? expiresAt;
  final String? weekISO; // Pour bar hebdomadaire (format: 2025-W01)
  final int? year;
  final Map<String, dynamic>? settings; // Contrôles d'ambiance
  final bool isPremiumOnly;
  final int? minimumAge;
  final List<String> requiredInterests;

  Bar({
    required this.barId,
    required this.name,
    required this.type,
    this.isActive = true,
    this.activeUsers = 0,
    this.maxParticipants = 4,
    this.expiresAt,
    this.weekISO,
    this.year,
    this.settings,
    this.isPremiumOnly = false,
    this.minimumAge,
    this.requiredInterests = const [],
  });

  factory Bar.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Bar(
      barId: doc.id,
      name: data['name'] ?? '',
      type: BarType.fromString(data['type'] ?? 'romantic'),
      isActive: data['isActive'] ?? true,
      activeUsers: data['activeUsers'] ?? 0,
      maxParticipants: data['maxParticipants'] ?? 4,
      expiresAt: data['expiresAt'] != null 
          ? (data['expiresAt'] as Timestamp).toDate() 
          : null,
      weekISO: data['weekISO'],
      year: data['year'],
      settings: data['settings'] as Map<String, dynamic>?,
      isPremiumOnly: data['isPremiumOnly'] ?? false,
      minimumAge: data['minimumAge'],
      requiredInterests: List<String>.from(data['requiredInterests'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.value,
      'isActive': isActive,
      'activeUsers': activeUsers,
      'maxParticipants': maxParticipants,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'weekISO': weekISO,
      'year': year,
      'settings': settings,
      'isPremiumOnly': isPremiumOnly,
      'minimumAge': minimumAge,
      'requiredInterests': requiredInterests,
    };
  }

  // Activités disponibles selon le type de bar
  List<BarActivity> get availableActivities {
    switch (type) {
      case BarType.romantic:
        return [
          BarActivity(
            id: 'compliment',
            name: 'Compliments Sincères',
            description: 'Envoyer un compliment authentique',
            coins: 25,
            icon: 'favorite',
          ),
          BarActivity(
            id: 'poem',
            name: 'Poème Express',
            description: 'Composer un haïku ou petit poème',
            coins: 40,
            icon: 'auto_stories',
          ),
          BarActivity(
            id: 'memory',
            name: 'Plus Beau Souvenir',
            description: 'Partager un souvenir romantique',
            coins: 35,
            icon: 'favorite_border',
          ),
          BarActivity(
            id: 'quote',
            name: 'Citation Préférée',
            description: 'Partager une citation qui touche',
            coins: 30,
            icon: 'format_quote',
          ),
        ];
      
      case BarType.humorous:
        return [
          BarActivity(
            id: 'joke',
            name: 'Blague du Siècle',
            description: 'Raconter sa meilleure blague',
            coins: 30,
            icon: 'sentiment_very_satisfied',
          ),
          BarActivity(
            id: 'mime',
            name: 'Mime Express',
            description: 'Mimer un concept (60 sec max)',
            coins: 40,
            icon: 'accessibility',
          ),
          BarActivity(
            id: 'story',
            name: 'Histoire Absurde',
            description: 'Inventer une histoire loufoque',
            coins: 35,
            icon: 'auto_stories',
          ),
          BarActivity(
            id: 'puns',
            name: 'Bataille Calembours',
            description: 'Duel de jeux de mots',
            coins: 25,
            icon: 'psychology',
          ),
        ];
      
      case BarType.pirate:
        return [
          BarActivity(
            id: 'adventure',
            name: 'Récit d\'Aventure',
            description: 'Raconter sa plus belle aventure',
            coins: 40,
            icon: 'sailing',
          ),
          BarActivity(
            id: 'riddle',
            name: 'Énigme de Navigation',
            description: 'Résoudre des défis de capitaine',
            coins: 50,
            icon: 'psychology',
          ),
          BarActivity(
            id: 'courage',
            name: 'Défi de Courage',
            description: 'Prouver sa bravoure',
            coins: 35,
            icon: 'shield',
          ),
          BarActivity(
            id: 'treasure',
            name: 'Carte au Trésor',
            description: 'Créer une chasse au trésor',
            coins: 45,
            icon: 'map',
          ),
        ];
      
      case BarType.weekly:
        return [
          BarActivity(
            id: 'discovery',
            name: 'Questions Découverte',
            description: 'Questions originales pour se connaître',
            coins: 30,
            icon: 'quiz',
          ),
          BarActivity(
            id: 'compliments',
            name: 'Compliments Croisés',
            description: 'Échanges de compliments sincères',
            coins: 25,
            icon: 'favorite',
          ),
          BarActivity(
            id: 'collaborative',
            name: 'Projet Collaboratif',
            description: 'Créer ensemble (playlist, voyage...)',
            coins: 50,
            icon: 'group_work',
          ),
        ];
      
      case BarType.hidden:
        return [
          BarActivity(
            id: 'oracle',
            name: 'Oracle de Compatibilité',
            description: 'Analyse approfondie des affinités',
            coins: 100,
            icon: 'auto_awesome',
          ),
          BarActivity(
            id: 'time_capsule',
            name: 'Capsule Temporelle',
            description: 'Messages programmés pour le futur',
            coins: 75,
            icon: 'schedule',
          ),
        ];
    }
  }

  // Alias pour compatibilité avec BarService
  List<BarActivity> get activities => availableActivities;
}

enum BarType {
  romantic('romantic'),
  humorous('humorous'),
  pirate('pirate'),
  weekly('weekly'),
  hidden('hidden');

  const BarType(this.value);
  final String value;

  static BarType fromString(String value) {
    return BarType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => BarType.romantic,
    );
  }

  String get displayName {
    switch (this) {
      case BarType.romantic:
        return '🌹 Bar Romantique';
      case BarType.humorous:
        return '😄 Bar Humoristique';
      case BarType.pirate:
        return '🏴‍☠️ Bar Pirates';
      case BarType.weekly:
        return '📅 Bar Hebdomadaire';
      case BarType.hidden:
        return '👑 Bar Caché';
    }
  }

  String get description {
    switch (this) {
      case BarType.romantic:
        return 'Ambiance tamisée, poésie et émotions';
      case BarType.humorous:
        return 'Festive, bonne humeur garantie';
      case BarType.pirate:
        return 'Aventure maritime, camaraderie';
      case BarType.weekly:
        return 'Groupe fermé de 4 personnes pendant 7 jours';
      case BarType.hidden:
        return 'Accès ultra-exclusif : 3 énigmes à résoudre';
    }
  }
}

class BarActivity {
  final String id;
  final String name;
  final String description;
  final int coins;
  final String icon;
  final bool isPremium;

  BarActivity({
    required this.id,
    required this.name,
    required this.description,
    required this.coins,
    required this.icon,
    this.isPremium = false,
  });
}