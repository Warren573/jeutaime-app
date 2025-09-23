import 'package:cloud_firestore/cloud_firestore.dart';

class LetterThread {
  final String threadId; // Format: uidA_uidB (alphabétique)
  final List<String> participants; // Toujours 2 participants
  final ThreadStatus status;
  final String lastTurnUid; // Qui doit répondre
  final DateTime lastMessageAt;
  final DateTime updatedAt;
  final List<String> archivedBy; // UIDs ayant archivé
  final DateTime? ghostingDetectedAt;
  final int messageCount;

  LetterThread({
    required this.threadId,
    required this.participants,
    this.status = ThreadStatus.active,
    required this.lastTurnUid,
    required this.lastMessageAt,
    required this.updatedAt,
    this.archivedBy = const [],
    this.ghostingDetectedAt,
    this.messageCount = 0,
  });

  factory LetterThread.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return LetterThread(
      threadId: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      status: ThreadStatus.fromString(data['status'] ?? 'active'),
      lastTurnUid: data['lastTurnUid'] ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      archivedBy: List<String>.from(data['archivedBy'] ?? []),
      ghostingDetectedAt: data['ghostingDetectedAt'] != null
          ? (data['ghostingDetectedAt'] as Timestamp).toDate()
          : null,
      messageCount: data['messageCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'status': status.value,
      'lastTurnUid': lastTurnUid,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'archivedBy': archivedBy,
      'ghostingDetectedAt': ghostingDetectedAt != null
          ? Timestamp.fromDate(ghostingDetectedAt!)
          : null,
      'messageCount': messageCount,
    };
  }

  // Créer un thread ID depuis deux UIDs
  static String createThreadId(String uid1, String uid2) {
    List<String> sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // Obtenir l'autre participant
  String getOtherParticipant(String currentUid) {
    return participants.firstWhere(
      (uid) => uid != currentUid,
      orElse: () => '',
    );
  }

  // Vérifier si c'est le tour d'un utilisateur
  bool isUserTurn(String uid) {
    return lastTurnUid != uid; // C'est le tour si ce n'est PAS lui qui a envoyé le dernier
  }

  // Vérifier si archivé par un utilisateur
  bool isArchivedBy(String uid) {
    return archivedBy.contains(uid);
  }

  // Vérifier si le thread est en ghosting
  bool get isGhosting {
    return status == ThreadStatus.ghostingDetected;
  }

  // Calculer le temps depuis le dernier message
  Duration get timeSinceLastMessage {
    return DateTime.now().difference(lastMessageAt);
  }

  // Vérifier si le thread doit être marqué comme ghosting (7 jours)
  bool get shouldDetectGhosting {
    return timeSinceLastMessage.inDays >= 7 && status == ThreadStatus.active;
  }

  LetterThread copyWith({
    ThreadStatus? status,
    String? lastTurnUid,
    DateTime? lastMessageAt,
    DateTime? updatedAt,
    List<String>? archivedBy,
    DateTime? ghostingDetectedAt,
    int? messageCount,
  }) {
    return LetterThread(
      threadId: threadId,
      participants: participants,
      status: status ?? this.status,
      lastTurnUid: lastTurnUid ?? this.lastTurnUid,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedBy: archivedBy ?? this.archivedBy,
      ghostingDetectedAt: ghostingDetectedAt ?? this.ghostingDetectedAt,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}

enum ThreadStatus {
  active('active'),
  archived('archived'),
  ghostingDetected('ghosting_detected');

  const ThreadStatus(this.value);
  final String value;

  static ThreadStatus fromString(String value) {
    return ThreadStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ThreadStatus.active,
    );
  }

  String get displayName {
    switch (this) {
      case ThreadStatus.active:
        return 'Active';
      case ThreadStatus.archived:
        return 'Archivée';
      case ThreadStatus.ghostingDetected:
        return 'Ghosting détecté';
    }
  }
}

class LetterMessage {
  final String messageId;
  final String threadId;
  final String authorUid;
  final String content; // Max 500 mots
  final List<LetterAttachment> attachments;
  final DateTime createdAt;
  final bool read;
  final Map<String, dynamic>? metadata; // Style du papier, etc.

  LetterMessage({
    required this.messageId,
    required this.threadId,
    required this.authorUid,
    required this.content,
    this.attachments = const [],
    required this.createdAt,
    this.read = false,
    this.metadata,
  });

  factory LetterMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return LetterMessage(
      messageId: doc.id,
      threadId: data['threadId'] ?? '',
      authorUid: data['authorUid'] ?? '',
      content: data['content'] ?? '',
      attachments: (data['attachments'] as List<dynamic>?)
          ?.map((a) => LetterAttachment.fromMap(a as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      read: data['read'] ?? false,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'threadId': threadId,
      'authorUid': authorUid,
      'content': content,
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'read': read,
      'metadata': metadata,
    };
  }

  // Compter le nombre de mots
  int get wordCount {
    return content.trim().split(RegExp(r'\s+')).length;
  }

  // Vérifier si la limite de mots est respectée
  bool get isWithinWordLimit {
    return wordCount <= 500;
  }

  LetterMessage copyWith({
    String? content,
    List<LetterAttachment>? attachments,
    bool? read,
    Map<String, dynamic>? metadata,
  }) {
    return LetterMessage(
      messageId: messageId,
      threadId: threadId,
      authorUid: authorUid,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt,
      read: read ?? this.read,
      metadata: metadata ?? this.metadata,
    );
  }
}

class LetterAttachment {
  final String type; // 'gift', 'image', 'audio'
  final String url;
  final String? name;
  final int? cost; // Coût en pièces

  LetterAttachment({
    required this.type,
    required this.url,
    this.name,
    this.cost,
  });

  factory LetterAttachment.fromMap(Map<String, dynamic> data) {
    return LetterAttachment(
      type: data['type'] ?? '',
      url: data['url'] ?? '',
      name: data['name'],
      cost: data['cost'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'url': url,
      'name': name,
      'cost': cost,
    };
  }
}