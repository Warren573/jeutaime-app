import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class LettersService {
  static LettersService? _instance;
  static LettersService get instance => _instance ??= LettersService._();
  
  LettersService._();
  
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  
  // Constantes
  static const int MAX_LETTER_LENGTH = 500;
  static const int TURN_TIMEOUT_HOURS = 48;
  
  // Créer un nouveau thread de lettres
  Future<Map<String, dynamic>> createLetterThread({
    required String senderId,
    required String receiverId,
    required String subject,
  }) async {
    try {
      final threadData = {
        'participants': [senderId, receiverId],
        'subject': subject,
        'isActive': true,
        'currentTurn': senderId,
        'turnDeadline': DateTime.now().add(const Duration(hours: TURN_TIMEOUT_HOURS)),
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
        'letterCount': 0,
        'status': 'active',
      };
      
      final docRef = await _firestore.collection('letterThreads').add(threadData);
      
      return {
        'success': true,
        'threadId': docRef.id,
        'thread': threadData,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Envoyer une lettre
  Future<Map<String, dynamic>> sendLetter({
    required String threadId,
    required String senderId,
    required String content,
  }) async {
    try {
      if (content.length > MAX_LETTER_LENGTH) {
        throw Exception('Lettre trop longue (max $MAX_LETTER_LENGTH caractères)');
      }
      
      return await _firestore.runTransaction((transaction) async {
        final threadRef = _firestore.collection('letterThreads').doc(threadId);
        final threadDoc = await transaction.get(threadRef);
        
        if (!threadDoc.exists) {
          return {'success': false, 'error': 'Thread introuvable'};
        }
        
        final threadData = threadDoc.data()!;
        final participants = List<String>.from(threadData['participants']);
        final currentTurn = threadData['currentTurn'] as String;
        
        if (currentTurn != senderId) {
          return {'success': false, 'error': 'Ce n\'est pas votre tour'};
        }
        
        // Créer la lettre
        final letterData = {
          'threadId': threadId,
          'senderId': senderId,
          'content': content,
          'timestamp': FieldValue.serverTimestamp(),
          'wordCount': content.split(' ').length,
          'isRead': false,
        };
        
        final letterRef = await _firestore.collection('letters').add(letterData);
        
        // Mettre à jour le thread
        String nextTurn = participants.firstWhere((p) => p != senderId);
        
        transaction.update(threadRef, {
          'currentTurn': nextTurn,
          'turnDeadline': DateTime.now().add(const Duration(hours: TURN_TIMEOUT_HOURS)),
          'lastActivityAt': FieldValue.serverTimestamp(),
          'letterCount': FieldValue.increment(1),
          'lastLetterId': letterRef.id,
        });
        
        return {
          'success': true,
          'letterId': letterRef.id,
          'nextTurn': nextTurn,
        };
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Obtenir les lettres d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserLetters(String userId) async {
    try {
      final threads = await _firestore
          .collection('letterThreads')
          .where('participants', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('lastActivityAt', descending: true)
          .get();
      
      List<Map<String, dynamic>> userLetters = [];
      
      for (final thread in threads.docs) {
        final threadData = thread.data();
        threadData['id'] = thread.id;
        
        // Obtenir la dernière lettre
        final lastLetters = await _firestore
            .collection('letters')
            .where('threadId', isEqualTo: thread.id)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
        
        if (lastLetters.docs.isNotEmpty) {
          threadData['lastLetter'] = lastLetters.docs.first.data();
        }
        
        // Déterminer le statut pour cet utilisateur
        final currentTurn = threadData['currentTurn'] as String;
        threadData['status'] = currentTurn == userId ? 'your_turn' : 'waiting_reply';
        
        // Trouver l'autre participant
        final participants = List<String>.from(threadData['participants']);
        final otherParticipant = participants.firstWhere((p) => p != userId);
        threadData['participantId'] = otherParticipant;
        
        userLetters.add(threadData);
      }
      
      return userLetters;
    } catch (e) {
      print('Erreur getUserLetters: $e');
      return [];
    }
  }
  
  // Répondre à une lettre
  Future<Map<String, dynamic>> replyToLetter({
    required String threadId,
    required String senderId,
    required String content,
  }) async {
    return await sendLetter(
      threadId: threadId,
      senderId: senderId,
      content: content,
    );
  }
  
  // Marquer une lettre comme lue
  Future<bool> markLetterAsRead(String letterId, String userId) async {
    try {
      await _firestore.collection('letters').doc(letterId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
        'readBy': userId,
      });
      
      return true;
    } catch (e) {
      print('Erreur markLetterAsRead: $e');
      return false;
    }
  }
  
  // Obtenir les lettres d'un thread
  Future<List<Map<String, dynamic>>> getThreadLetters(String threadId) async {
    try {
      final letters = await _firestore
          .collection('letters')
          .where('threadId', isEqualTo: threadId)
          .orderBy('timestamp', descending: false)
          .get();
      
      return letters.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Erreur getThreadLetters: $e');
      return [];
    }
  }
  
  // Fermer un thread de lettres
  Future<bool> closeLetterThread(String threadId, String userId) async {
    try {
      await _firestore.collection('letterThreads').doc(threadId).update({
        'isActive': false,
        'closedAt': FieldValue.serverTimestamp(),
        'closedBy': userId,
        'status': 'closed',
      });
      
      return true;
    } catch (e) {
      print('Erreur closeLetterThread: $e');
      return false;
    }
  }
  
  // Statistiques des lettres d'un utilisateur
  Future<Map<String, dynamic>> getUserLetterStats(String userId) async {
    try {
      // Threads actifs
      final activeThreads = await _firestore
          .collection('letterThreads')
          .where('participants', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .get();
      
      // Lettres envoyées
      final sentLetters = await _firestore
          .collection('letters')
          .where('senderId', isEqualTo: userId)
          .get();
      
      // Threads complétés
      final completedThreads = await _firestore
          .collection('letterThreads')
          .where('participants', arrayContains: userId)
          .where('isActive', isEqualTo: false)
          .get();
      
      return {
        'activeThreads': activeThreads.size,
        'lettersSent': sentLetters.size,
        'completedExchanges': completedThreads.size,
        'totalThreads': activeThreads.size + completedThreads.size,
      };
    } catch (e) {
      print('Erreur getUserLetterStats: $e');
      return {
        'activeThreads': 0,
        'lettersSent': 0,
        'completedExchanges': 0,
        'totalThreads': 0,
      };
    }
  }
}