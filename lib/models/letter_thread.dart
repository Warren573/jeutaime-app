import 'package:cloud_firestore/cloud_firestore.dart';

class LetterThread {
  final String id;
  final String participant1Id;
  final String participant2Id;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String lastMessage;
  final String? lastMessageSender;
  final bool participant1HasUnread;
  final bool participant2HasUnread;
  final int messageCount;
  final String status; // 'active', 'ghosted', 'completed'
  final DateTime? ghostingWarningAt;
  final String? subject;

  // Propriétés additionnelles pour compatibility
  List<String> get participants => [participant1Id, participant2Id];
  String get threadId => id;
  String? get lastTurnUid => lastMessageSender;

  LetterThread({
    required this.id,
    required this.participant1Id,
    required this.participant2Id,
    required this.createdAt,
    required this.lastMessageAt,
    required this.lastMessage,
    this.lastMessageSender,
    this.participant1HasUnread = false,
    this.participant2HasUnread = false,
    this.messageCount = 0,
    this.status = 'active',
    this.ghostingWarningAt,
    this.subject,
  });

  factory LetterThread.fromMap(Map<String, dynamic> map, String docId) {
    final participants = List<String>.from(map['participants'] ?? []);
    return LetterThread(
      id: docId,
      participant1Id: participants.isNotEmpty ? participants[0] : '',
      participant2Id: participants.length > 1 ? participants[1] : '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageAt: (map['lastActivity'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageSender: map['lastMessageSender'],
      participant1HasUnread: map['participant1HasUnread'] ?? false,
      participant2HasUnread: map['participant2HasUnread'] ?? false,
      messageCount: map['messageCount'] ?? 0,
      status: map['isActive'] == true ? 'active' : 'inactive',
      ghostingWarningAt: (map['ghostingWarningAt'] as Timestamp?)?.toDate(),
      subject: map['subject'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participant1Id': participant1Id,
      'participant2Id': participant2Id,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'participant1HasUnread': participant1HasUnread,
      'participant2HasUnread': participant2HasUnread,
      'messageCount': messageCount,
      'status': status,
      'ghostingWarningAt': ghostingWarningAt != null 
          ? Timestamp.fromDate(ghostingWarningAt!) 
          : null,
      'subject': subject,
    };
  }

  LetterThread copyWith({
    String? id,
    String? participant1Id,
    String? participant2Id,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessage,
    String? lastMessageSender,
    bool? participant1HasUnread,
    bool? participant2HasUnread,
    int? messageCount,
    String? status,
    DateTime? ghostingWarningAt,
    String? subject,
  }) {
    return LetterThread(
      id: id ?? this.id,
      participant1Id: participant1Id ?? this.participant1Id,
      participant2Id: participant2Id ?? this.participant2Id,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      participant1HasUnread: participant1HasUnread ?? this.participant1HasUnread,
      participant2HasUnread: participant2HasUnread ?? this.participant2HasUnread,
      messageCount: messageCount ?? this.messageCount,
      status: status ?? this.status,
      ghostingWarningAt: ghostingWarningAt ?? this.ghostingWarningAt,
      subject: subject ?? this.subject,
    );
  }
}