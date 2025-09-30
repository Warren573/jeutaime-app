import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'coin_service.dart';

class LetterService {
  static LetterService? _instance;
  static LetterService get instance => _instance ??= LetterService._();
  
  LetterService._();
  
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  
  static const int MAX_WORDS = 500; // Limite en mots
  static const int MIN_WORDS = 10; // Minimum anti-spam
  static const int COOLDOWN_BETWEEN_LETTERS_MS = 300000; // 5 min
  static const int MAX_LETTERS_PER_DAY = 20;
  static const int MAX_LETTERS_PER_DAY_PREMIUM = 50;
  static const int ATTACHMENT_MAX_SIZE = 5000000; // 5MB
  static const List<String> ALLOWED_ATTACHMENTS = ['image/jpeg', 'image/png', 'image/gif'];
  static const int TURN_TIMEOUT_DAYS = 7; // Timeout pour anti-ghosting
  static const int LETTER_COST = 30; // Coût en pièces
  
  // Créer une nouvelle conversation par lettres
  Future<String?> createLetterThread(String user1Id, String user2Id) async {
    try {
      final threadData = {
        'participants': [user1Id, user2Id],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'currentTurn': user1Id, // Le créateur commence
        'turnDeadline': DateTime.now().add(Duration(days: TURN_TIMEOUT_DAYS)),
        'messageCount': 0,
        'ghostingWarnings': 0,
      };
      
      final docRef = await _firestore.collection('letterThreads').add(threadData);
      return docRef.id;
    } catch (e) {
      print('Erreur création thread lettres: $e');
      return null;
    }
  }
  
  // Envoyer une lettre
  Future<bool> sendLetter({
    required String threadId,
    required String senderId,
    required String content,
  }) async {
    if (content.split(' ').length > MAX_WORDS) {
      throw Exception('Lettre trop longue (max $MAX_WORDS mots)');
    }
    
    try {
      // Vérifier et dépenser les pièces
      final canSend = await CoinService.instance.sendLetter(senderId, 'other_user');
      if (!canSend) {
        throw Exception('Pas assez de pièces pour envoyer une lettre');
      }
      
      await _firestore.runTransaction((transaction) async {
        final threadRef = _firestore.collection('letterThreads').doc(threadId);
        final threadDoc = await transaction.get(threadRef);
        
        if (!threadDoc.exists) {
          throw Exception('Thread non trouvé');
        }
        
        final threadData = threadDoc.data()!;
        final participants = List<String>.from(threadData['participants']);
        final currentTurn = threadData['currentTurn'];
        
        // Vérifier que c'est le bon tour
        if (currentTurn != senderId) {
          throw Exception('Ce n\'est pas votre tour');
        }
        
        // Déterminer le prochain joueur
        final nextPlayer = participants.firstWhere((p) => p != senderId);
        
        // Créer le message
        final messageData = {
          'threadId': threadId,
          'senderId': senderId,
          'content': content,
          'timestamp': FieldValue.serverTimestamp(),
          'wordCount': content.split(' ').length,
          'characterCount': content.length,
        };
        
        // Ajouter le message
        transaction.set(_firestore.collection('letterMessages').doc(), messageData);
        
        // Mettre à jour le thread
        transaction.update(threadRef, {
          'currentTurn': nextPlayer,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'turnDeadline': DateTime.now().add(const Duration(hours: 48)),
          'messageCount': FieldValue.increment(1),
          'ghostingWarnings': 0, // Reset des warnings
        });
      });
      
      return true;
    } catch (e) {
      print('Erreur envoi lettre: $e');
      return false;
    }
  }
  
  // Récupérer les conversations de l'utilisateur
  Stream<QuerySnapshot> getUserLetterThreads(String userId) {
    return _firestore
        .collection('letterThreads')
        .where('participants', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }
  
  // Récupérer les messages d'une conversation
  Stream<QuerySnapshot> getLetterMessages(String threadId) {
    return _firestore
        .collection('letterMessages')
        .where('threadId', isEqualTo: threadId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  // Vérifier les timeouts (anti-ghosting)
  Future<void> checkTimeouts() async {
    try {
      final now = DateTime.now();
      final expiredThreads = await _firestore
          .collection('letterThreads')
          .where('isActive', isEqualTo: true)
          .where('turnDeadline', isLessThan: now)
          .get();
      
      for (final doc in expiredThreads.docs) {
        final data = doc.data();
        final currentTurn = data['currentTurn'];
        final warnings = data['ghostingWarnings'] ?? 0;
        
        if (warnings >= 2) {
          // Trop de warnings, fermer la conversation
          await _closeThreadForGhosting(doc.id, currentTurn);
        } else {
          // Donner un warning
          await _giveGhostingWarning(doc.id, currentTurn);
        }
      }
    } catch (e) {
      print('Erreur vérification timeouts: $e');
    }
  }
  
  Future<void> _giveGhostingWarning(String threadId, String userId) async {
    await _firestore.collection('letterThreads').doc(threadId).update({
      'ghostingWarnings': FieldValue.increment(1),
      'turnDeadline': DateTime.now().add(Duration(days: TURN_TIMEOUT_DAYS)),
    });
    
    // Ajouter strike à l'utilisateur
    await _firestore.collection('users').doc(userId).update({
      'ghostingStrikes': FieldValue.increment(1),
    });
  }
  
  Future<void> _closeThreadForGhosting(String threadId, String ghosterId) async {
    await _firestore.runTransaction((transaction) async {
      final threadRef = _firestore.collection('letterThreads').doc(threadId);
      final threadDoc = await transaction.get(threadRef);
      
      if (!threadDoc.exists) return;
      
      final participants = List<String>.from(threadDoc.data()!['participants']);
      final victim = participants.firstWhere((p) => p != ghosterId);
      
      // Fermer le thread
      transaction.update(threadRef, {
        'isActive': false,
        'closedReason': 'ghosting',
        'closedAt': FieldValue.serverTimestamp(),
      });
      
      // Sanctionner le ghosteur
      transaction.update(_firestore.collection('users').doc(ghosterId), {
        'ghostingStrikes': FieldValue.increment(2),
      });
      
      // Récompenser la victime
      transaction.update(_firestore.collection('users').doc(victim), {
        'coins': FieldValue.increment(100), // Compensation
      });
    });
  }
  
  // Archiver une conversation (Boîte à Souvenirs)
  Future<bool> archiveThread(String threadId, String userId) async {
    try {
      await _firestore.collection('letterThreads').doc(threadId).update({
        'isActive': false,
        'archivedBy': userId,
        'archivedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print('Erreur archivage: $e');
      return false;
    }
  }
  
  // Statistiques pour l'utilisateur
  Future<Map<String, dynamic>> getLetterStats(String userId) async {
    try {
      final activeThreads = await _firestore
          .collection('letterThreads')
          .where('participants', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .get();
      
      final archivedThreads = await _firestore
          .collection('letterThreads')
          .where('participants', arrayContains: userId)
          .where('isActive', isEqualTo: false)
          .get();
      
      final sentMessages = await _firestore
          .collection('letterMessages')
          .where('senderId', isEqualTo: userId)
          .get();
      
      return {
        'activeThreads': activeThreads.size,
        'archivedThreads': archivedThreads.size,
        'sentMessages': sentMessages.size,
        'averageWordCount': _calculateAverageWordCount(sentMessages.docs),
      };
    } catch (e) {
      print('Erreur stats lettres: $e');
      return {};
    }
  }
  
  double _calculateAverageWordCount(List<QueryDocumentSnapshot> messages) {
    if (messages.isEmpty) return 0.0;
    
    final totalWords = messages.fold<int>(
      0,
      (sum, doc) => sum + (doc.data() as Map<String, dynamic>)['wordCount'] as int,
    );
    
    return totalWords / messages.length;
  }
}