import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class WeeklyBarService {
  static WeeklyBarService? _instance;
  static WeeklyBarService get instance => _instance ??= WeeklyBarService._();
  
  WeeklyBarService._();
  
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  
  static const int BAR_DURATION_DAYS = 7;
  static const int MAX_PARTICIPANTS = 4; // 2 hommes + 2 femmes
  static const int ENTRY_COST = 50; // Coût en pièces
  
  // Créer un nouveau bar hebdomadaire
  Future<String?> createWeeklyBar({
    required String theme,
    required String description,
    required Map<String, dynamic> activities,
  }) async {
    try {
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: BAR_DURATION_DAYS));
      
      final barData = {
        'theme': theme,
        'description': description,
        'activities': activities,
        'startDate': startDate,
        'endDate': endDate,
        'isActive': true,
        'participants': [],
        'maleCount': 0,
        'femaleCount': 0,
        'maxParticipants': MAX_PARTICIPANTS,
        'entryCost': ENTRY_COST,
        'createdAt': FieldValue.serverTimestamp(),
        'matches': [],
        'chatRoomId': '',
      };
      
      final docRef = await _firestore.collection('weeklyBars').add(barData);
      
      // Créer le salon de chat associé
      final chatRoomData = {
        'barId': docRef.id,
        'participants': [],
        'messages': [],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      final chatRef = await _firestore.collection('barChatRooms').add(chatRoomData);
      
      // Mettre à jour le bar avec l'ID du chat
      await docRef.update({'chatRoomId': chatRef.id});
      
      return docRef.id;
    } catch (e) {
      print('Erreur création bar hebdomadaire: $e');
      return null;
    }
  }
  
  // Rejoindre un bar hebdomadaire
  Future<Map<String, dynamic>> joinWeeklyBar(String barId, String userId, String userGender) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final barRef = _firestore.collection('weeklyBars').doc(barId);
        final barDoc = await transaction.get(barRef);
        
        if (!barDoc.exists) {
          return {'success': false, 'error': 'Bar introuvable'};
        }
        
        final barData = barDoc.data()!;
        final participants = List<String>.from(barData['participants']);
        final maleCount = barData['maleCount'] as int;
        final femaleCount = barData['femaleCount'] as int;
        
        // Vérifier si l'utilisateur est déjà dans le bar
        if (participants.contains(userId)) {
          return {'success': false, 'error': 'Vous êtes déjà dans ce bar'};
        }
        
        // Vérifier les limites de genre
        if (userGender == 'male' && maleCount >= 2) {
          return {'success': false, 'error': 'Limite d\'hommes atteinte (2/2)'};
        }
        if (userGender == 'female' && femaleCount >= 2) {
          return {'success': false, 'error': 'Limite de femmes atteinte (2/2)'};
        }
        
        // Vérifier si le bar est encore actif
        final endDate = (barData['endDate'] as Timestamp).toDate();
        if (DateTime.now().isAfter(endDate)) {
          return {'success': false, 'error': 'Ce bar a expiré'};
        }
        
        // Ajouter l'utilisateur
        participants.add(userId);
        final newMaleCount = userGender == 'male' ? maleCount + 1 : maleCount;
        final newFemaleCount = userGender == 'female' ? femaleCount + 1 : femaleCount;
        
        transaction.update(barRef, {
          'participants': participants,
          'maleCount': newMaleCount,
          'femaleCount': newFemaleCount,
        });
        
        // Ajouter au salon de chat
        final chatRoomRef = _firestore.collection('barChatRooms').doc(barData['chatRoomId']);
        transaction.update(chatRoomRef, {
          'participants': FieldValue.arrayUnion([userId]),
        });
        
        // Si le bar est plein, créer les matches
        if (participants.length == MAX_PARTICIPANTS) {
          _createMatches(barId, participants);
        }
        
        return {'success': true, 'message': 'Vous avez rejoint le bar avec succès!'};
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Créer les matches quand le bar est plein
  Future<void> _createMatches(String barId, List<String> participants) async {
    try {
      // Récupérer les informations des participants
      final userDocs = await Future.wait(
        participants.map((userId) => _firestore.collection('users').doc(userId).get())
      );
      
      final males = <String>[];
      final females = <String>[];
      
      for (int i = 0; i < userDocs.length; i++) {
        final userData = userDocs[i].data() as Map<String, dynamic>;
        final gender = userData['gender'];
        if (gender == 'male') {
          males.add(participants[i]);
        } else if (gender == 'female') {
          females.add(participants[i]);
        }
      }
      
      // Créer les matches aléatoires
      males.shuffle();
      females.shuffle();
      
      final matches = <Map<String, dynamic>>[];
      for (int i = 0; i < males.length && i < females.length; i++) {
        matches.add({
          'male': males[i],
          'female': females[i],
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'active',
        });
      }
      
      // Sauvegarder les matches
      await _firestore.collection('weeklyBars').doc(barId).update({
        'matches': matches,
        'matchingCompleted': true,
        'matchingCompletedAt': FieldValue.serverTimestamp(),
      });
      
      // Créer des conversations privées pour chaque match
      for (final match in matches) {
        await _createMatchConversation(barId, match['male'], match['female']);
      }
      
    } catch (e) {
      print('Erreur création matches: $e');
    }
  }
  
  // Créer une conversation privée pour un match
  Future<void> _createMatchConversation(String barId, String user1, String user2) async {
    try {
      final conversationData = {
        'barId': barId,
        'participants': [user1, user2],
        'messages': [],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(Duration(days: BAR_DURATION_DAYS)),
      };
      
      await _firestore.collection('matchConversations').add(conversationData);
    } catch (e) {
      print('Erreur création conversation match: $e');
    }
  }
  
  // Obtenir les bars hebdomadaires actifs
  Stream<QuerySnapshot> getActiveWeeklyBars() {
    return _firestore
        .collection('weeklyBars')
        .where('isActive', isEqualTo: true)
        .where('endDate', isGreaterThan: DateTime.now())
        .orderBy('endDate')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Obtenir les bars où l'utilisateur participe
  Stream<QuerySnapshot> getUserWeeklyBars(String userId) {
    return _firestore
        .collection('weeklyBars')
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Envoyer un message dans le salon de bar
  Future<bool> sendBarMessage({
    required String chatRoomId,
    required String senderId,
    required String message,
  }) async {
    try {
      await _firestore.collection('barChatRooms').doc(chatRoomId).update({
        'messages': FieldValue.arrayUnion([{
          'senderId': senderId,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        }]),
      });
      
      return true;
    } catch (e) {
      print('Erreur envoi message bar: $e');
      return false;
    }
  }
  
  // Obtenir les messages du salon de bar
  Stream<DocumentSnapshot> getBarMessages(String chatRoomId) {
    return _firestore.collection('barChatRooms').doc(chatRoomId).snapshots();
  }
  
  // Quitter un bar hebdomadaire
  Future<bool> leaveWeeklyBar(String barId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final barRef = _firestore.collection('weeklyBars').doc(barId);
        final barDoc = await transaction.get(barRef);
        
        if (!barDoc.exists) return;
        
        final barData = barDoc.data()!;
        final participants = List<String>.from(barData['participants']);
        
        if (!participants.contains(userId)) return;
        
        participants.remove(userId);
        
        // Récupérer le genre de l'utilisateur
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userGender = userDoc.data()?['gender'];
        
        final maleCount = barData['maleCount'] as int;
        final femaleCount = barData['femaleCount'] as int;
        
        transaction.update(barRef, {
          'participants': participants,
          'maleCount': userGender == 'male' ? maleCount - 1 : maleCount,
          'femaleCount': userGender == 'female' ? femaleCount - 1 : femaleCount,
        });
        
        // Retirer du salon de chat
        final chatRoomRef = _firestore.collection('barChatRooms').doc(barData['chatRoomId']);
        transaction.update(chatRoomRef, {
          'participants': FieldValue.arrayRemove([userId]),
        });
      });
      
      return true;
    } catch (e) {
      print('Erreur quitter bar: $e');
      return false;
    }
  }
  
  // Nettoyer les bars expirés
  Future<void> cleanupExpiredBars() async {
    try {
      final expiredBars = await _firestore
          .collection('weeklyBars')
          .where('isActive', isEqualTo: true)
          .where('endDate', isLessThan: DateTime.now())
          .get();
      
      for (final doc in expiredBars.docs) {
        await doc.reference.update({'isActive': false});
      }
    } catch (e) {
      print('Erreur nettoyage bars expirés: $e');
    }
  }
  
  // Obtenir les statistiques d'un bar
  Future<Map<String, dynamic>> getBarStats(String barId) async {
    try {
      final barDoc = await _firestore.collection('weeklyBars').doc(barId).get();
      
      if (!barDoc.exists) {
        return {};
      }
      
      final barData = barDoc.data()!;
      final chatRoomDoc = await _firestore.collection('barChatRooms').doc(barData['chatRoomId']).get();
      
      final messageCount = chatRoomDoc.exists 
          ? (chatRoomDoc.data()!['messages'] as List).length 
          : 0;
      
      return {
        'participants': barData['participants'].length,
        'maleCount': barData['maleCount'],
        'femaleCount': barData['femaleCount'],
        'messageCount': messageCount,
        'isMatchingCompleted': barData['matchingCompleted'] ?? false,
        'timeRemaining': _calculateTimeRemaining(barData['endDate']),
      };
    } catch (e) {
      print('Erreur stats bar: $e');
      return {};
    }
  }
  
  String _calculateTimeRemaining(Timestamp endDate) {
    final end = endDate.toDate();
    final now = DateTime.now();
    final difference = end.difference(now);
    
    if (difference.isNegative) {
      return 'Expiré';
    }
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    
    if (days > 0) {
      return '$days jour${days > 1 ? 's' : ''} ${hours}h';
    } else {
      return '${hours}h ${difference.inMinutes % 60}min';
    }
  }

  // Obtenir les bars disponibles
  Future<List<Map<String, dynamic>>> getAvailableBars() async {
    try {
      final activeBars = await _firestore
          .collection('weeklyBars')
          .where('isActive', isEqualTo: true)
          .where('endDate', isGreaterThan: DateTime.now())
          .orderBy('endDate', descending: false)
          .limit(10)
          .get();
      
      List<Map<String, dynamic>> availableBars = [];
      
      for (final bar in activeBars.docs) {
        final data = bar.data();
        data['id'] = bar.id;
        
        final participants = data['participants'] as List? ?? [];
        data['spotsRemaining'] = 4 - participants.length;
        data['canJoin'] = participants.length < 4;
        
        availableBars.add(data);
      }
      
      return availableBars;
    } catch (e) {
      print('Erreur getAvailableBars: $e');
      return [];
    }
  }
}