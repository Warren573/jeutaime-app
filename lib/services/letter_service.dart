import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/letter_thread.dart';
import '../models/letter_message.dart';

class LetterService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer un nouveau thread de lettres entre deux utilisateurs
  static Future<String> createThread({
    required String userId1,
    required String userId2,
  }) async {
    try {
      final threadRef = _firestore.collection('letterThreads').doc();
      
      final threadData = {
        'id': threadRef.id,
        'participants': [userId1, userId2],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'currentTurn': userId1,
        'messageCount': 0,
        'isArchived': false,
      };

      await threadRef.set(threadData);
      return threadRef.id;
    } catch (e) {
      print('Erreur lors de la création du thread: $e');
      rethrow;
    }
  }

  // Envoyer un message dans un thread
  static Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String content,
    String? theme,
    int wordCount = 0,
    String? mood,
    List<String>? attachments,
  }) async {
    try {
      final messageRef = _firestore
          .collection('letterThreads')
          .doc(threadId)
          .collection('messages')
          .doc();

      final messageData = {
        'id': messageRef.id,
        'threadId': threadId,
        'senderId': senderId,
        'content': content,
        'theme': theme,
        'wordCount': wordCount,
        'mood': mood,
        'attachments': attachments ?? [],
        'createdAt': FieldValue.serverTimestamp(),
        'sentAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'readAt': null,
      };

      await messageRef.set(messageData);

      // Mettre à jour le thread
      await _firestore.collection('letterThreads').doc(threadId).update({
        'lastMessageAt': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(1),
        'currentTurn': senderId,
      });

    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      rethrow;
    }
  }

  // Obtenir les threads d'un utilisateur
  static Stream<List<LetterThread>> getUserThreads(String userId) {
    try {
      return _firestore
          .collection('letterThreads')
          .where('participants', arrayContains: userId)
          .where('isArchived', isEqualTo: false)
          .orderBy('lastMessageAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return LetterThread.fromMap(data, doc.id);
        }).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des threads: $e');
      return Stream.value([]);
    }
  }

  // Obtenir les messages d'un thread
  static Stream<List<LetterMessage>> getThreadMessages(String threadId) {
    try {
      return _firestore
          .collection('letterThreads')
          .doc(threadId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return LetterMessage.fromMap(data, doc.id);
        }).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des messages: $e');
      return Stream.value([]);
    }
  }

  // Obtenir les lettres reçues par un utilisateur
  static Stream<List<LetterMessage>> getReceivedLetters(String userId) {
    try {
      return _firestore
          .collectionGroup('messages')
          .where('senderId', isNotEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        List<LetterMessage> letters = [];
        
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final threadId = data['threadId'] as String;
          
          // Vérifier si l'utilisateur fait partie de ce thread
          final threadDoc = await _firestore
              .collection('letterThreads')
              .doc(threadId)
              .get();
              
          if (threadDoc.exists) {
            final threadData = threadDoc.data()!;
            final participants = List<String>.from(threadData['participants'] ?? []);
            
            if (participants.contains(userId)) {
              letters.add(LetterMessage.fromMap(data, doc.id));
            }
          }
        }
        
        return letters;
      });
    } catch (e) {
      print('Erreur lors de la récupération des lettres reçues: $e');
      return Stream.value([]);
    }
  }

  // Marquer une lettre comme lue
  static Future<void> markAsRead(String threadId, String messageId, String userId) async {
    try {
      await _firestore
          .collection('letterThreads')
          .doc(threadId)
          .collection('messages')
          .doc(messageId)
          .update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors du marquage comme lu: $e');
      rethrow;
    }
  }

  // Archiver une lettre pour un utilisateur
  static Future<void> archiveLetterForUser(String threadId, String userId) async {
    try {
      // Dans ce cas simple, nous archivons tout le thread
      await _firestore.collection('letterThreads').doc(threadId).update({
        'isArchived': true,
        'archivedBy': FieldValue.arrayUnion([userId]),
        'archivedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de l\'archivage: $e');
      rethrow;
    }
  }

  // Archiver un thread pour un utilisateur
  static Future<void> archiveThreadForUser(String threadId, String userId) async {
    return archiveLetterForUser(threadId, userId);
  }
}
