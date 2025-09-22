/// Modèle pour les conversations entre utilisateurs
class ConversationModel {
  final String id;
  final List<String> participantIds;
  final MessageModel? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  ConversationModel({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  /// Crée une conversation à partir d'un JSON
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      participantIds: List<String>.from(json['participantIds'] ?? []),
      lastMessage: json['lastMessage'] != null 
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  /// Convertit la conversation en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}

/// Modèle pour les messages individuels
class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.isRead = false,
  });

  /// Crée un message à partir d'un JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      isRead: json['isRead'] ?? false,
    );
  }

  /// Convertit le message en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'isRead': isRead,
    };
  }
}

/// Types de messages supportés
enum MessageType {
  text,
  image,
  letter,
  gift,
  sticker,
}