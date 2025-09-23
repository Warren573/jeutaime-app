import 'package:cloud_firestore/cloud_firestore.dart';

class LetterMessage {
  final String id;
  final String threadId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final String? paperType; // 'classic', 'parchment', 'modern'
  final String? inkColor; // 'black', 'blue', 'red', 'purple'
  final bool isAnonymous;
  final double cost; // coût en pièces
  final String status; // 'sent', 'delivered', 'read'
  final Map<String, dynamic>? metadata; // infos supplémentaires
  final String? theme;
  final int wordCount;
  final String? mood;
  final List<String> attachments;
  final DateTime sentAt;
  final DateTime? readAt;

  LetterMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
    this.paperType,
    this.inkColor,
    this.isAnonymous = false,
    this.cost = 0.0,
    this.status = 'sent',
    this.metadata,
    this.theme,
    this.wordCount = 0,
    this.mood,
    this.attachments = const [],
    required this.sentAt,
    this.readAt,
  });

  factory LetterMessage.fromMap(Map<String, dynamic> map, String docId) {
    return LetterMessage(
      id: docId,
      threadId: map['threadId'] ?? '',
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      paperType: map['paperType'],
      inkColor: map['inkColor'],
      isAnonymous: map['isAnonymous'] ?? false,
      cost: (map['cost'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'sent',
      metadata: map['metadata']?.cast<String, dynamic>(),
      theme: map['theme'],
      wordCount: map['wordCount'] ?? 0,
      mood: map['mood'],
      attachments: List<String>.from(map['attachments'] ?? []),
      sentAt: (map['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (map['readAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'threadId': threadId,
      'senderId': senderId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'paperType': paperType,
      'inkColor': inkColor,
      'isAnonymous': isAnonymous,
      'cost': cost,
      'status': status,
      'metadata': metadata,
      'theme': theme,
      'wordCount': wordCount,
      'mood': mood,
      'attachments': attachments,
      'sentAt': Timestamp.fromDate(sentAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  LetterMessage copyWith({
    String? id,
    String? threadId,
    String? senderId,
    String? content,
    DateTime? createdAt,
    bool? isRead,
    String? paperType,
    String? inkColor,
    bool? isAnonymous,
    double? cost,
    String? status,
    Map<String, dynamic>? metadata,
    String? theme,
    int? wordCount,
    String? mood,
    List<String>? attachments,
    DateTime? sentAt,
    DateTime? readAt,
  }) {
    return LetterMessage(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      paperType: paperType ?? this.paperType,
      inkColor: inkColor ?? this.inkColor,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      cost: cost ?? this.cost,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      theme: theme ?? this.theme,
      wordCount: wordCount ?? this.wordCount,
      mood: mood ?? this.mood,
      attachments: attachments ?? this.attachments,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
    );
  }
}