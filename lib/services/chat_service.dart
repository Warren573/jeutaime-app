import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final StreamController<List<ChatMessage>> _messagesController = StreamController.broadcast();
  static final Map<String, StreamSubscription> _messageSubscriptions = {};

  // Stream pour les messages d'une conversation
  static Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  // Stream pour les conversations de l'utilisateur actuel
  static Stream<List<Conversation>> getConversationsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Conversation.fromFirestore(doc))
            .toList());
  }

  // Envoyer un message
  static Future<bool> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Créer le message
      final message = ChatMessage(
        id: '', // Sera généré par Firestore
        conversationId: conversationId,
        senderId: user.uid,
        senderName: user.displayName ?? 'Utilisateur',
        content: content,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
        metadata: metadata,
      );

      // Ajouter le message à Firestore
      await _firestore.collection('messages').add(message.toFirestore());

      // Mettre à jour la conversation
      await _updateConversationLastMessage(conversationId, content, user.uid);

      return true;
    } catch (e) {
      print('Erreur envoi message: $e');
      return false;
    }
  }

  // Créer une nouvelle conversation
  static Future<String?> createConversation({
    required String otherUserId,
    required String otherUserName,
    String otherUserPhoto = '',
    String? matchId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Vérifier si une conversation existe déjà
      final existingConversation = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: user.uid)
          .get();

      for (var doc in existingConversation.docs) {
        final data = doc.data();
        final participantIds = List<String>.from(data['participantIds'] ?? []);
        if (participantIds.contains(otherUserId) && participantIds.length == 2) {
          return doc.id; // Conversation existe déjà
        }
      }

      // Créer une nouvelle conversation
      final conversation = Conversation(
        id: '',
        participantIds: [user.uid, otherUserId],
        participantNames: {
          user.uid: user.displayName ?? 'Vous',
          otherUserId: otherUserName,
        },
        participantPhotos: {
          user.uid: '', // À récupérer du profil utilisateur
          otherUserId: otherUserPhoto,
        },
        unreadCounts: {
          user.uid: 0,
          otherUserId: 0,
        },
        createdAt: DateTime.now(),
        matchId: matchId,
      );

      final docRef = await _firestore.collection('conversations').add(conversation.toFirestore());
      
      // Envoyer un message système de bienvenue
      await sendMessage(
        conversationId: docRef.id,
        content: '🎉 Vous avez un match ! Commencez la conversation.',
        type: MessageType.system,
      );

      return docRef.id;
    } catch (e) {
      print('Erreur création conversation: $e');
      return null;
    }
  }

  // Marquer les messages comme lus
  static Future<void> markMessagesAsRead(String conversationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Marquer tous les messages non lus de cette conversation comme lus
      final unreadMessages = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('senderId', isNotEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Réinitialiser le compteur non lu pour cet utilisateur
      await _firestore.collection('conversations').doc(conversationId).update({
        'unreadCounts.${user.uid}': 0,
      });
    } catch (e) {
      print('Erreur marquage lecture: $e');
    }
  }

  // Envoyer un cadeau virtuel
  static Future<bool> sendGift({
    required String conversationId,
    required String giftId,
    required String giftName,
    required int cost,
  }) async {
    try {
      // Vérifier que l'utilisateur a assez de coins
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final currentCoins = userDoc.data()?['coins'] ?? 0;

      if (currentCoins < cost) {
        return false; // Pas assez de coins
      }

      // Déduire les coins
      await _firestore.collection('users').doc(user.uid).update({
        'coins': FieldValue.increment(-cost),
      });

      // Envoyer le cadeau
      await sendMessage(
        conversationId: conversationId,
        content: '🎁 Cadeau: $giftName',
        type: MessageType.gift,
        metadata: {
          'giftId': giftId,
          'giftName': giftName,
          'cost': cost,
        },
      );

      return true;
    } catch (e) {
      print('Erreur envoi cadeau: $e');
      return false;
    }
  }

  // Récupérer l'historique des messages (pagination)
  static Future<List<ChatMessage>> getMessageHistory({
    required String conversationId,
    DateTime? before,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (before != null) {
        query = query.where('timestamp', isLessThan: Timestamp.fromDate(before));
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erreur récupération historique: $e');
      return [];
    }
  }

  // Supprimer une conversation
  static Future<bool> deleteConversation(String conversationId) async {
    try {
      // Supprimer tous les messages
      final messages = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Supprimer la conversation
      batch.delete(_firestore.collection('conversations').doc(conversationId));
      await batch.commit();

      return true;
    } catch (e) {
      print('Erreur suppression conversation: $e');
      return false;
    }
  }

  // Bloquer un utilisateur
  static Future<bool> blockUser(String conversationId, String userId) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'status': ConversationStatus.blocked.name,
        'metadata.blockedBy': _auth.currentUser?.uid,
        'metadata.blockedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Erreur blocage utilisateur: $e');
      return false;
    }
  }

  // Méthode privée pour mettre à jour le dernier message
  static Future<void> _updateConversationLastMessage(
    String conversationId,
    String content,
    String senderId,
  ) async {
    try {
      final conversationRef = _firestore.collection('conversations').doc(conversationId);
      final conversation = await conversationRef.get();
      
      if (conversation.exists) {
        final data = conversation.data() as Map<String, dynamic>;
        final participantIds = List<String>.from(data['participantIds'] ?? []);
        final currentUnreadCounts = Map<String, int>.from(data['unreadCounts'] ?? {});

        // Incrémenter le compteur non lu pour tous les participants sauf l'expéditeur
        for (String participantId in participantIds) {
          if (participantId != senderId) {
            currentUnreadCounts[participantId] = (currentUnreadCounts[participantId] ?? 0) + 1;
          }
        }

        await conversationRef.update({
          'lastMessage': content,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageSenderId': senderId,
          'unreadCounts': currentUnreadCounts,
        });
      }
    } catch (e) {
      print('Erreur mise à jour conversation: $e');
    }
  }

  // Nettoyer les resources
  static void dispose() {
    _messageSubscriptions.forEach((key, subscription) {
      subscription.cancel();
    });
    _messageSubscriptions.clear();
    _messagesController.close();
  }
}