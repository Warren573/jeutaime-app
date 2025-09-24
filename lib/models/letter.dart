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

// ===== NOUVEAUX MODÈLES POUR LE SYSTÈME DE TEMPLATES =====

/// Template de lettre prédéfini
class LetterTemplate {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final LetterType type;
  final String templateContent;
  final Map<String, String> placeholders;
  final LetterStyle defaultStyle;
  final bool isPremium;
  final int unlockLevel;

  const LetterTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.type,
    required this.templateContent,
    required this.placeholders,
    required this.defaultStyle,
    this.isPremium = false,
    this.unlockLevel = 1,
  });
}

/// Style de présentation d'une lettre
class LetterStyle {
  final String backgroundColor;
  final String textColor;
  final String fontFamily;
  final double fontSize;
  final String paperTexture;
  final String borderStyle;
  final List<String> decorations;

  const LetterStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.fontFamily,
    required this.fontSize,
    required this.paperTexture,
    required this.borderStyle,
    this.decorations = const [],
  });
}

/// Types de lettres disponibles
enum LetterType {
  romantic,      // Lettre romantique
  friendship,    // Lettre d'amitié
  apology,      // Lettre d'excuses
  gratitude,    // Lettre de remerciement
  confession,   // Déclaration
  poetry,       // Poésie
  story,        // Petite histoire
  surprise,     // Surprise
  anonymous,    // Lettre anonyme
  future,       // Lettre future (programmée)
}

/// Service de gestion des lettres avec templates
class LetterService {
  static List<LetterTemplate> getAvailableTemplates({int userLevel = 1}) {
    return [
      // Templates romantiques
      LetterTemplate(
        id: 'romantic_classic',
        name: 'Déclaration Classique',
        description: 'Une déclaration d\'amour intemporelle',
        emoji: '💕',
        type: LetterType.romantic,
        templateContent: '''Mon/Ma {recipient_title} {name},

Depuis que nos chemins se sont croisés, ma vie a pris une couleur nouvelle. 
Chaque jour passé à tes côtés est un cadeau que je chéris.

{personal_message}

Avec tout mon amour,
{sender_name} 💖''',
        placeholders: {
          'recipient_title': 'chéri(e)',
          'name': '[Nom]',
          'personal_message': '[Votre message personnel]',
          'sender_name': '[Votre nom]',
        },
        defaultStyle: LetterStyle(
          backgroundColor: '#FFF5F5',
          textColor: '#8B4A6B',
          fontFamily: 'Georgia',
          fontSize: 16.0,
          paperTexture: 'parchemin',
          borderStyle: 'coeur',
          decorations: ['roses', 'coeurs'],
        ),
      ),

      LetterTemplate(
        id: 'friendship_warm',
        name: 'Amitié Chaleureuse',
        description: 'Pour exprimer une amitié sincère',
        emoji: '🤗',
        type: LetterType.friendship,
        templateContent: '''Salut {name} !

Tu sais, avoir un(e) ami(e) comme toi, c'est vraiment précieux. 
Tu es toujours là dans les moments importants, et ça me touche beaucoup.

{personal_message}

Ton ami(e) fidèle,
{sender_name} 🌟''',
        placeholders: {
          'name': '[Prénom]',
          'personal_message': '[Votre message d\'amitié]',
          'sender_name': '[Votre nom]',
        },
        defaultStyle: LetterStyle(
          backgroundColor: '#F0F8FF',
          textColor: '#4682B4',
          fontFamily: 'Georgia',
          fontSize: 16.0,
          paperTexture: 'lin',
          borderStyle: 'simple',
          decorations: ['etoiles', 'nuages'],
        ),
      ),

      LetterTemplate(
        id: 'apology_sincere',
        name: 'Excuses Sincères',
        description: 'Pour présenter des excuses authentiques',
        emoji: '🙏',
        type: LetterType.apology,
        templateContent: '''Cher/Chère {name},

Je réalise que mes mots ou mes actions t'ont blessé(e), et j'en suis vraiment désolé(e).
Ce n'était pas mon intention, mais je comprends ta réaction.

{personal_message}

J'espère que tu pourras me pardonner.
{sender_name}''',
        placeholders: {
          'name': '[Prénom]',
          'personal_message': '[Vos excuses personnelles]',
          'sender_name': '[Votre nom]',
        },
        defaultStyle: LetterStyle(
          backgroundColor: '#FFF8DC',
          textColor: '#8B4513',
          fontFamily: 'Georgia',
          fontSize: 16.0,
          paperTexture: 'papier_recyclé',
          borderStyle: 'sobre',
          decorations: ['feuilles'],
        ),
      ),

      LetterTemplate(
        id: 'gratitude_deep',
        name: 'Gratitude Profonde',
        description: 'Pour exprimer une reconnaissance sincère',
        emoji: '🙏',
        type: LetterType.gratitude,
        templateContent: '''Mon/Ma cher/chère {name},

Aujourd'hui, j'ai envie de prendre le temps de te dire MERCI.
Merci pour {reason_1}.
Merci pour {reason_2}.
Merci pour {reason_3}.

{personal_gratitude}

Tu comptes énormément pour moi, et j'avais besoin que tu le saches.

Avec toute ma reconnaissance,
{sender_name} 🌈''',
        placeholders: {
          'name': '[Prénom]',
          'reason_1': '[première raison de gratitude]',
          'reason_2': '[deuxième raison de gratitude]',
          'reason_3': '[troisième raison de gratitude]',
          'personal_gratitude': '[message personnel de remerciement]',
          'sender_name': '[Votre nom]',
        },
        defaultStyle: LetterStyle(
          backgroundColor: '#FFF9E6',
          textColor: '#D97706',
          fontFamily: 'Georgia',
          fontSize: 16.0,
          paperTexture: 'kraft',
          borderStyle: 'naturel',
          decorations: ['soleil', 'fleurs_sauvages'],
        ),
      ),

      // Templates premium (niveau 3+)
      if (userLevel >= 3)
        LetterTemplate(
          id: 'poetry_romantic',
          name: 'Poésie Romantique',
          description: 'Un poème d\'amour personnalisé',
          emoji: '📝',
          type: LetterType.poetry,
          templateContent: '''À toi, {name} 💫

Tes yeux sont des étoiles dans la nuit,
Ton sourire, le soleil de ma vie.
{custom_verse_1}

Quand tu parles, le monde s'illumine,
Quand tu ris, mon cœur se dessine.
{custom_verse_2}

Alors reste près de moi, mon trésor,
Car avec toi, je vis encore et encore.

Ton poète épris,
{sender_name} 🌹''',
          placeholders: {
            'name': '[Prénom]',
            'custom_verse_1': '[Vos vers personnels - ligne 1]',
            'custom_verse_2': '[Vos vers personnels - ligne 2]',
            'sender_name': '[Votre nom]',
          },
          defaultStyle: LetterStyle(
            backgroundColor: '#F8F0FF',
            textColor: '#663399',
            fontFamily: 'Georgia',
            fontSize: 18.0,
            paperTexture: 'parchemin_royal',
            borderStyle: 'ornements',
            decorations: ['plumes', 'enluminures'],
          ),
          isPremium: true,
          unlockLevel: 3,
        ),
    ].where((template) => template.unlockLevel <= userLevel).toList();
  }

  /// Génère des suggestions de contenu basées sur le type de lettre
  static List<String> getContentSuggestions(LetterType type) {
    switch (type) {
      case LetterType.romantic:
        return [
          "Chaque jour avec toi est comme un rêve qui devient réalité...",
          "Tu illumines ma vie comme le soleil illumine le monde...",
          "Dans tes yeux, j'ai trouvé mon foyer...",
          "Ton amour est la mélodie qui fait danser mon cœur...",
          "Avec toi, j'ai appris ce que signifie vraiment aimer...",
        ];
      
      case LetterType.friendship:
        return [
          "Notre amitié est un trésor que je garde précieusement...",
          "Tu es cette personne sur qui je peux toujours compter...",
          "Nos fous rires résonnent encore dans ma mémoire...",
          "Tu as ce don de rendre tout plus beau, plus simple...",
          "Grâce à toi, j'ai découvert ce qu'est la vraie amitié...",
        ];

      case LetterType.apology:
        return [
          "Mes mots ont dépassé ma pensée, et j'en suis vraiment désolé(e)...",
          "Je réalise maintenant l'impact de mes actions...",
          "Ton pardon serait le plus beau des cadeaux...",
          "Je veux réparer ce qui peut l'être entre nous...",
          "Tu mérites mieux que ce que j'ai fait...",
        ];

      case LetterType.gratitude:
        return [
          "Ta générosité me touche au plus profond de mon cœur...",
          "Tu as été là quand j'en avais le plus besoin...",
          "Tes petites attentions font toute la différence...",
          "Je ne sais pas comment te remercier assez...",
          "Tu m'as appris la vraie valeur de la gentillesse...",
        ];

      case LetterType.confession:
        return [
          "Il y a quelque chose d'important que je dois te dire...",
          "Mon cœur déborde et j'ai besoin de me confier...",
          "Ces sentiments grandissent en moi chaque jour...",
          "Je ne peux plus garder cela pour moi...",
          "Tu as le droit de connaître mes sentiments...",
        ];

      default:
        return [
          "J'avais envie de prendre de tes nouvelles...",
          "Tu me manques et j'espère que tu vas bien...",
          "J'ai pensé à toi aujourd'hui...",
          "Il faut qu'on se donne des nouvelles plus souvent...",
          "J'espère que cette lettre te fera sourire...",
        ];
    }
  }

  /// Vérifie si un template est disponible pour l'utilisateur
  static bool isTemplateUnlocked(LetterTemplate template, int userLevel) {
    return userLevel >= template.unlockLevel;
  }
}