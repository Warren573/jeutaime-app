import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final List<String> participantIds;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String lastMessage;
  final String lastMessageSender;
  final Map<String, bool> readStatus;
  final int messageCount;
  final String type; // 'letter', 'match', 'group'
  final String status; // 'active', 'ended', 'ghosted'

  Conversation({
    required this.id,
    required this.participantIds,
    required this.createdAt,
    required this.lastMessageAt,
    required this.lastMessage,
    required this.lastMessageSender,
    required this.readStatus,
    this.messageCount = 0,
    this.type = 'letter',
    this.status = 'active',
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageSender: map['lastMessageSender'] ?? '',
      readStatus: Map<String, bool>.from(map['readStatus'] ?? {}),
      messageCount: map['messageCount'] ?? 0,
      type: map['type'] ?? 'letter',
      status: map['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantIds': participantIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'readStatus': readStatus,
      'messageCount': messageCount,
      'type': type,
      'status': status,
    };
  }

  Conversation copyWith({
    String? id,
    List<String>? participantIds,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessage,
    String? lastMessageSender,
    Map<String, bool>? readStatus,
    int? messageCount,
    String? type,
    String? status,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      readStatus: readStatus ?? this.readStatus,
      messageCount: messageCount ?? this.messageCount,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}