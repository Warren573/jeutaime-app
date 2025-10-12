import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class InteractionService {
  static InteractionService? _instance;
  static InteractionService get instance => _instance ??= InteractionService._();
  InteractionService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Envoie un like à un utilisateur
  Future<InteractionResult> sendLike({
    required String targetUserId,
    bool isSuperLike = false,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return InteractionResult.error('Utilisateur non connecté');
      }

      // Vérifier si l'interaction existe déjà
      final existingInteraction = await _findExistingInteraction(
        currentUser.uid,
        targetUserId,
      );

      if (existingInteraction != null) {
        return InteractionResult.error('Interaction déjà envoyée');
      }

      // Créer la nouvelle interaction
      final interaction = UserInteraction(
        id: '',
        fromUserId: currentUser.uid,
        toUserId: targetUserId,
        type: isSuperLike ? InteractionType.superLike : InteractionType.like,
        timestamp: DateTime.now(),
        isRead: false,
      );

      final docRef = await _firestore
          .collection('interactions')
          .add(interaction.toMap());

      // Vérifier si c'est un match mutuel
      final reverseInteraction = await _findExistingInteraction(
        targetUserId,
        currentUser.uid,
      );

      bool isMatch = false;
      if (reverseInteraction != null && 
          (reverseInteraction.type == InteractionType.like || 
           reverseInteraction.type == InteractionType.superLike)) {
        isMatch = true;
        await _createMatch(currentUser.uid, targetUserId);
      }

      // Feedback haptique
      if (isSuperLike) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }

      return InteractionResult.success(
        isMatch: isMatch,
        isSuperLike: isSuperLike,
      );
    } catch (e) {
      print('Erreur envoi like: $e');
      return InteractionResult.error('Erreur lors de l\'envoi');
    }
  }

  /// Envoie un dislike
  Future<InteractionResult> sendDislike(String targetUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return InteractionResult.error('Utilisateur non connecté');
      }

      final interaction = UserInteraction(
        id: '',
        fromUserId: currentUser.uid,
        toUserId: targetUserId,
        type: InteractionType.dislike,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _firestore
          .collection('interactions')
          .add(interaction.toMap());

      HapticFeedback.selectionClick();
      
      return InteractionResult.success(isMatch: false);
    } catch (e) {
      print('Erreur envoi dislike: $e');
      return InteractionResult.error('Erreur lors de l\'envoi');
    }
  }

  /// Trouve une interaction existante entre deux utilisateurs
  Future<UserInteraction?> _findExistingInteraction(
    String fromUserId,
    String toUserId,
  ) async {
    try {
      final query = await _firestore
          .collection('interactions')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return UserInteraction.fromMap(doc.data(), doc.id);
      }

      return null;
    } catch (e) {
      print('Erreur recherche interaction: $e');
      return null;
    }
  }

  /// Crée un match entre deux utilisateurs
  Future<void> _createMatch(String userId1, String userId2) async {
    try {
      final match = UserMatch(
        id: '',
        userIds: [userId1, userId2],
        timestamp: DateTime.now(),
        isActive: true,
        conversationId: null,
      );

      await _firestore
          .collection('matches')
          .add(match.toMap());

      // Notification de match (simulée)
      await _sendMatchNotification(userId1, userId2);
    } catch (e) {
      print('Erreur création match: $e');
    }
  }

  /// Envoie une notification de match
  Future<void> _sendMatchNotification(String userId1, String userId2) async {
    // TODO: Implémenter avec Firebase Cloud Messaging
    print('🎉 Nouveau match entre $userId1 et $userId2 !');
  }

  /// Récupère les likes reçus par l'utilisateur
  Stream<List<UserInteraction>> getReceivedLikes() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('interactions')
        .where('toUserId', isEqualTo: currentUser.uid)
        .where('type', whereIn: [
          InteractionType.like.toString(),
          InteractionType.superLike.toString(),
        ])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserInteraction.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Récupère les matchs de l'utilisateur
  Stream<List<UserMatch>> getUserMatches() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('matches')
        .where('userIds', arrayContains: currentUser.uid)
        .where('isActive', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserMatch.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Marque les likes comme lus
  Future<void> markLikesAsRead(List<String> interactionIds) async {
    try {
      final batch = _firestore.batch();
      
      for (String id in interactionIds) {
        batch.update(
          _firestore.collection('interactions').doc(id),
          {'isRead': true},
        );
      }

      await batch.commit();
    } catch (e) {
      print('Erreur marquage likes lus: $e');
    }
  }

  /// Compte les likes non lus
  Future<int> getUnreadLikesCount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      final query = await _firestore
          .collection('interactions')
          .where('toUserId', isEqualTo: currentUser.uid)
          .where('type', whereIn: [
            InteractionType.like.toString(),
            InteractionType.superLike.toString(),
          ])
          .where('isRead', isEqualTo: false)
          .get();

      return query.docs.length;
    } catch (e) {
      print('Erreur comptage likes non lus: $e');
      return 0;
    }
  }

  /// Envoie un "boost" de profil (augmente la visibilité)
  Future<bool> boostProfile({
    required int duration, // en minutes
    required int cost, // en coins
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'boostEndTime': Timestamp.fromDate(
          DateTime.now().add(Duration(minutes: duration)),
        ),
        'boostActive': true,
      });

      return true;
    } catch (e) {
      print('Erreur boost profil: $e');
      return false;
    }
  }

  /// Annule un match
  Future<bool> unmatch(String matchId) async {
    try {
      await _firestore
          .collection('matches')
          .doc(matchId)
          .update({'isActive': false});

      return true;
    } catch (e) {
      print('Erreur annulation match: $e');
      return false;
    }
  }

  /// Signale un utilisateur
  Future<bool> reportUser({
    required String userId,
    required String reason,
    String? additionalInfo,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await _firestore
          .collection('reports')
          .add({
        'reporterId': currentUser.uid,
        'reportedUserId': userId,
        'reason': reason,
        'additionalInfo': additionalInfo,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      return true;
    } catch (e) {
      print('Erreur signalement: $e');
      return false;
    }
  }

  /// Vérifie si un utilisateur est bloqué
  Future<bool> isUserBlocked(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final blockedUsers = List<String>.from(data['blockedUsers'] ?? []);
        return blockedUsers.contains(userId);
      }

      return false;
    } catch (e) {
      print('Erreur vérification blocage: $e');
      return false;
    }
  }

  /// Obtient les statistiques d'interactions
  Future<InteractionStats> getInteractionStats() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return InteractionStats.empty();
      }

      // Likes envoyés
      final sentLikes = await _firestore
          .collection('interactions')
          .where('fromUserId', isEqualTo: currentUser.uid)
          .where('type', isEqualTo: InteractionType.like.toString())
          .get();

      // Super-likes envoyés
      final sentSuperLikes = await _firestore
          .collection('interactions')
          .where('fromUserId', isEqualTo: currentUser.uid)
          .where('type', isEqualTo: InteractionType.superLike.toString())
          .get();

      // Likes reçus
      final receivedLikes = await _firestore
          .collection('interactions')
          .where('toUserId', isEqualTo: currentUser.uid)
          .where('type', whereIn: [
            InteractionType.like.toString(),
            InteractionType.superLike.toString(),
          ])
          .get();

      // Matchs
      final matches = await _firestore
          .collection('matches')
          .where('userIds', arrayContains: currentUser.uid)
          .where('isActive', isEqualTo: true)
          .get();

      return InteractionStats(
        sentLikes: sentLikes.docs.length,
        sentSuperLikes: sentSuperLikes.docs.length,
        receivedLikes: receivedLikes.docs.length,
        totalMatches: matches.docs.length,
      );
    } catch (e) {
      print('Erreur statistiques: $e');
      return InteractionStats.empty();
    }
  }
}

// Classes de données
enum InteractionType {
  like,
  superLike,
  dislike,
}

class UserInteraction {
  final String id;
  final String fromUserId;
  final String toUserId;
  final InteractionType type;
  final DateTime timestamp;
  final bool isRead;

  const UserInteraction({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'type': type.toString(),
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  static UserInteraction fromMap(Map<String, dynamic> map, String id) {
    return UserInteraction(
      id: id,
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      type: InteractionType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => InteractionType.like,
      ),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}

class UserMatch {
  final String id;
  final List<String> userIds;
  final DateTime timestamp;
  final bool isActive;
  final String? conversationId;

  const UserMatch({
    required this.id,
    required this.userIds,
    required this.timestamp,
    required this.isActive,
    this.conversationId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userIds': userIds,
      'timestamp': Timestamp.fromDate(timestamp),
      'isActive': isActive,
      'conversationId': conversationId,
    };
  }

  static UserMatch fromMap(Map<String, dynamic> map, String id) {
    return UserMatch(
      id: id,
      userIds: List<String>.from(map['userIds'] ?? []),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      conversationId: map['conversationId'],
    );
  }

  String getOtherUserId(String currentUserId) {
    return userIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }
}

class InteractionResult {
  final bool success;
  final String? error;
  final bool isMatch;
  final bool isSuperLike;

  const InteractionResult({
    required this.success,
    this.error,
    required this.isMatch,
    this.isSuperLike = false,
  });

  factory InteractionResult.success({
    required bool isMatch,
    bool isSuperLike = false,
  }) {
    return InteractionResult(
      success: true,
      isMatch: isMatch,
      isSuperLike: isSuperLike,
    );
  }

  factory InteractionResult.error(String error) {
    return InteractionResult(
      success: false,
      error: error,
      isMatch: false,
    );
  }
}

class InteractionStats {
  final int sentLikes;
  final int sentSuperLikes;
  final int receivedLikes;
  final int totalMatches;

  const InteractionStats({
    required this.sentLikes,
    required this.sentSuperLikes,
    required this.receivedLikes,
    required this.totalMatches,
  });

  factory InteractionStats.empty() {
    return const InteractionStats(
      sentLikes: 0,
      sentSuperLikes: 0,
      receivedLikes: 0,
      totalMatches: 0,
    );
  }

  double get matchRate {
    final totalSent = sentLikes + sentSuperLikes;
    if (totalSent == 0) return 0.0;
    return totalMatches / totalSent;
  }
}