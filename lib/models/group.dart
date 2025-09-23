import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String groupId;
  final GroupType type;
  final String barId;
  final List<String> members; // UIDs des membres
  final GroupStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;
  final String id;
  final String name;
  final String description;
  final int maxSize;
  final bool isActive;
  final bool isPrivate;
  final String theme;

  Group({
    required this.groupId,
    required this.type,
    required this.barId,
    this.members = const [],
    this.status = GroupStatus.forming,
    required this.createdAt,
    this.expiresAt,
    this.metadata,
    String? id,
    this.name = '',
    this.description = '',
    this.maxSize = 4,
    this.isActive = true,
    this.isPrivate = false,
    this.theme = '',
  }) : id = id ?? groupId;

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Group(
      groupId: doc.id,
      type: GroupType.fromString(data['type'] ?? 'bar'),
      barId: data['barId'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      status: GroupStatus.fromString(data['status'] ?? 'forming'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null 
          ? (data['expiresAt'] as Timestamp).toDate() 
          : null,
      metadata: data['metadata'] as Map<String, dynamic>?,
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      maxSize: data['maxSize'] ?? 4,
      isActive: data['isActive'] ?? true,
      isPrivate: data['isPrivate'] ?? false,
      theme: data['theme'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.value,
      'barId': barId,
      'members': members,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'metadata': metadata,
    };
  }

  // Vérifier si le groupe est complet
  bool get isFull {
    return members.length >= 4; // Max 4 membres par défaut
  }

  // Vérifier si un utilisateur est dans le groupe
  bool containsUser(String uid) {
    return members.contains(uid);
  }

  // Obtenir le nombre de places restantes
  int get availableSlots {
    return 4 - members.length;
  }

  // Vérifier si le groupe a expiré
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Group copyWith({
    GroupType? type,
    String? barId,
    List<String>? members,
    GroupStatus? status,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return Group(
      groupId: groupId,
      type: type ?? this.type,
      barId: barId ?? this.barId,
      members: members ?? this.members,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum GroupType {
  bar('bar'),
  private('private'),
  event('event');

  const GroupType(this.value);
  final String value;

  static GroupType fromString(String value) {
    return GroupType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => GroupType.bar,
    );
  }
}

enum GroupStatus {
  forming('forming'),
  active('active'),
  expired('expired'),
  archived('archived');

  const GroupStatus(this.value);
  final String value;

  static GroupStatus fromString(String value) {
    return GroupStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => GroupStatus.forming,
    );
  }

  String get displayName {
    switch (this) {
      case GroupStatus.forming:
        return 'En formation';
      case GroupStatus.active:
        return 'Actif';
      case GroupStatus.expired:
        return 'Expiré';
      case GroupStatus.archived:
        return 'Archivé';
    }
  }
}