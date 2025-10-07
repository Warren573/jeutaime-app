import 'package:cloud_firestore/cloud_firestore.dart';
enum BarType {
  romantic,
  humorous,
  pirate,
  weekly,
  hidden,
}

extension BarTypeExtension on BarType {
  String get value {
    switch (this) {
      case BarType.romantic:
        return 'romantic';
      case BarType.humorous:
        return 'humorous';
      case BarType.pirate:
        return 'pirate';
      case BarType.weekly:
        return 'weekly';
      case BarType.hidden:
        return 'hidden';
    }
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

  static BarType fromString(String value) {
    switch (value) {
      case 'romantic':
        return BarType.romantic;
      case 'humorous':
        return BarType.humorous;
      case 'pirate':
        return BarType.pirate;
      case 'weekly':
        return BarType.weekly;
      case 'hidden':
        return BarType.hidden;
      default:
        return BarType.romantic;
    }
  }
}

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
  final String ambiance;

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
    this.ambiance = '',
  });

  factory Bar.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Bar(
      barId: doc.id,
      name: data['name'] ?? '',
      type: BarTypeExtension.fromString(data['type'] ?? 'romantic'),
      isActive: data['isActive'] ?? true,
      activeUsers: data['activeUsers'] ?? 0,
      maxParticipants: data['maxParticipants'] ?? 4,
      expiresAt: data['expiresAt'] is Timestamp ? (data['expiresAt'] as Timestamp).toDate() : null,
      weekISO: data['weekISO'],
      year: data['year'],
      settings: data['settings'],
      isPremiumOnly: data['isPremiumOnly'] ?? false,
      minimumAge: data['minimumAge'],
      requiredInterests: List<String>.from(data['requiredInterests'] ?? []),
      ambiance: data['ambiance'] ?? '',
    );
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