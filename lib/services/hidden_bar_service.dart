import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class HiddenBarService {
  static HiddenBarService? _instance;
  static HiddenBarService get instance => _instance ??= HiddenBarService._();
  
  HiddenBarService._();
  
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  
  static const int TOTAL_RIDDLES = 5;
  static const int ENTRY_COST = 100; // Coût élevé pour l'exclusivité
  
  // Énigmes progressives du Bar Caché
  final List<Map<String, dynamic>> _riddles = [
    {
      'id': 1,
      'question': 'Je suis le sentiment qui unit les cœurs, invisible mais puissant. Que suis-je ?',
      'answer': 'amour',
      'hint': 'Ce mot de 5 lettres fait battre tous les cœurs...',
      'difficulty': 'facile',
    },
    {
      'id': 2,
      'question': 'Je brille dans la nuit sans être une étoile, les amoureux me contemplent. Que suis-je ?',
      'answer': 'lune',
      'hint': 'Astre nocturne des romantiques...',
      'difficulty': 'facile',
    },
    {
      'id': 3,
      'question': 'Je suis rouge, parfumée, et offerte avec tendresse. Les épines me protègent. Que suis-je ?',
      'answer': 'rose',
      'hint': 'Fleur emblématique de l\'amour...',
      'difficulty': 'moyen',
    },
    {
      'id': 4,
      'question': 'Je suis un serment éternel, échangé entre deux âmes. Je brille au doigt. Que suis-je ?',
      'answer': 'alliance',
      'hint': 'Bijou symbolique du mariage...',
      'difficulty': 'moyen',
    },
    {
      'id': 5,
      'question': 'Je suis la promesse d\'un avenir partagé, célébrée en blanc. Que suis-je ?',
      'answer': 'mariage',
      'hint': 'Cérémonie d\'union sacrée...',
      'difficulty': 'difficile',
    },
  ];
  
  // Initialiser le parcours d'énigmes pour un utilisateur
  Future<String?> startRiddleQuest(String userId) async {
    try {
      // Vérifier si l'utilisateur a déjà un parcours en cours
      final existingQuest = await _firestore
          .collection('riddleQuests')
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: false)
          .get();
      
      if (existingQuest.docs.isNotEmpty) {
        return existingQuest.docs.first.id;
      }
      
      // Créer un nouveau parcours
      final questData = {
        'userId': userId,
        'currentRiddleIndex': 0,
        'solvedRiddles': [],
        'attempts': 0,
        'hints': [],
        'startedAt': FieldValue.serverTimestamp(),
        'isCompleted': false,
        'completedAt': null,
        'timeSpent': 0,
      };
      
      final docRef = await _firestore.collection('riddleQuests').add(questData);
      return docRef.id;
    } catch (e) {
      print('Erreur démarrage quête énigmes: $e');
      return null;
    }
  }
  
  // Obtenir l'énigme actuelle pour un utilisateur
  Future<Map<String, dynamic>?> getCurrentRiddle(String questId) async {
    try {
      final questDoc = await _firestore.collection('riddleQuests').doc(questId).get();
      
      if (!questDoc.exists) {
        return null;
      }
      
      final questData = questDoc.data()!;
      final currentIndex = questData['currentRiddleIndex'] as int;
      
      if (currentIndex >= _riddles.length) {
        return null; // Quête terminée
      }
      
      final riddle = _riddles[currentIndex];
      final solvedCount = (questData['solvedRiddles'] as List).length;
      
      return {
        'riddle': {
          'id': riddle['id'],
          'question': riddle['question'],
          'hint': riddle['hint'],
          'difficulty': riddle['difficulty'],
        },
        'progress': {
          'current': currentIndex + 1,
          'total': TOTAL_RIDDLES,
          'solved': solvedCount,
          'attempts': questData['attempts'],
        },
      };
    } catch (e) {
      print('Erreur récupération énigme: $e');
      return null;
    }
  }
  
  // Soumettre une réponse à l'énigme
  Future<Map<String, dynamic>> submitAnswer(String questId, String answer) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final questRef = _firestore.collection('riddleQuests').doc(questId);
        final questDoc = await transaction.get(questRef);
        
        if (!questDoc.exists) {
          return {'success': false, 'error': 'Quête introuvable'};
        }
        
        final questData = questDoc.data()!;
        final currentIndex = questData['currentRiddleIndex'] as int;
        final attempts = questData['attempts'] as int;
        final solvedRiddles = List<int>.from(questData['solvedRiddles']);
        
        if (currentIndex >= _riddles.length) {
          return {'success': false, 'error': 'Quête déjà terminée'};
        }
        
        final correctAnswer = _riddles[currentIndex]['answer'].toLowerCase();
        final userAnswer = answer.toLowerCase().trim();
        
        if (userAnswer == correctAnswer) {
          // Réponse correcte
          solvedRiddles.add(_riddles[currentIndex]['id']);
          final newIndex = currentIndex + 1;
          final isCompleted = newIndex >= _riddles.length;
          
          transaction.update(questRef, {
            'currentRiddleIndex': newIndex,
            'solvedRiddles': solvedRiddles,
            'attempts': attempts + 1,
            'isCompleted': isCompleted,
            'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
          });
          
          if (isCompleted) {
            // Quête terminée, donner accès au Bar Caché
            await _grantHiddenBarAccess(questData['userId']);
            return {
              'success': true,
              'correct': true,
              'completed': true,
              'message': '🎉 Félicitations ! Vous avez accès au Bar Caché !',
            };
          } else {
            return {
              'success': true,
              'correct': true,
              'completed': false,
              'message': '✅ Correct ! Énigme suivante...',
              'nextRiddle': _riddles[newIndex],
            };
          }
        } else {
          // Réponse incorrecte
          transaction.update(questRef, {
            'attempts': attempts + 1,
          });
          
          return {
            'success': true,
            'correct': false,
            'completed': false,
            'message': '❌ Réponse incorrecte. Essayez encore !',
            'hint': _riddles[currentIndex]['hint'],
          };
        }
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Donner accès au Bar Caché
  Future<void> _grantHiddenBarAccess(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'hasHiddenBarAccess': true,
        'hiddenBarUnlockedAt': FieldValue.serverTimestamp(),
      });
      
      // Ajouter aux statistiques
      await _firestore.collection('users').doc(userId).update({
        'achievements': FieldValue.arrayUnion(['hidden_bar_master']),
        'coins': FieldValue.increment(200), // Récompense
      });
    } catch (e) {
      print('Erreur accès bar caché: $e');
    }
  }
  
  // Vérifier si l'utilisateur a accès au Bar Caché
  Future<bool> hasHiddenBarAccess(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return false;
      }
      
      return userDoc.data()?['hasHiddenBarAccess'] ?? false;
    } catch (e) {
      print('Erreur vérification accès: $e');
      return false;
    }
  }
  
  // Obtenir le Bar Caché actuel (s'il existe)
  Future<Map<String, dynamic>?> getCurrentHiddenBar() async {
    try {
      final activeBar = await _firestore
          .collection('hiddenBars')
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isGreaterThan: DateTime.now())
          .limit(1)
          .get();
      
      if (activeBar.docs.isEmpty) {
        // Créer un nouveau Bar Caché
        return await _createNewHiddenBar();
      }
      
      return activeBar.docs.first.data();
    } catch (e) {
      print('Erreur récupération bar caché: $e');
      return null;
    }
  }
  
  // Créer un nouveau Bar Caché
  Future<Map<String, dynamic>?> _createNewHiddenBar() async {
    try {
      final themes = [
        {
          'name': 'Le Jardin Secret',
          'description': 'Un havre de paix pour les âmes sensibles',
          'ambiance': 'romantique',
          'color': 'pink',
        },
        {
          'name': 'La Bibliothèque Interdite',
          'description': 'Où les secrets les plus profonds sont partagés',
          'ambiance': 'mystérieuse',
          'color': 'purple',
        },
        {
          'name': 'L\'Observatoire des Étoiles',
          'description': 'Contemplez l\'infini avec votre âme sœur',
          'ambiance': 'cosmique',
          'color': 'indigo',
        },
      ];
      
      final selectedTheme = themes[DateTime.now().weekday % themes.length];
      
      final barData = {
        'id': _firestore.collection('hiddenBars').doc().id,
        'theme': selectedTheme,
        'participants': [],
        'maxParticipants': 10, // Limité pour l'exclusivité
        'entryCost': ENTRY_COST,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(Duration(days: 3)), // 3 jours de durée
        'activities': [
          'Confessions Anonymes',
          'Poésie Collaborative',
          'Énigmes Philosophiques',
          'Cercle de Vérité',
        ],
        'chatRoomId': '',
      };
      
      final docRef = await _firestore.collection('hiddenBars').add(barData);
      
      // Créer le salon de chat
      final chatData = {
        'barId': docRef.id,
        'participants': [],
        'messages': [],
        'isExclusive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      final chatRef = await _firestore.collection('hiddenBarChats').add(chatData);
      
      await docRef.update({'chatRoomId': chatRef.id});
      
      barData['id'] = docRef.id;
      barData['chatRoomId'] = chatRef.id;
      
      return barData;
    } catch (e) {
      print('Erreur création bar caché: $e');
      return null;
    }
  }
  
  // Rejoindre le Bar Caché
  Future<Map<String, dynamic>> joinHiddenBar(String barId, String userId) async {
    try {
      // Vérifier l'accès
      final hasAccess = await hasHiddenBarAccess(userId);
      if (!hasAccess) {
        return {'success': false, 'error': 'Accès refusé. Complétez les énigmes d\'abord.'};
      }
      
      return await _firestore.runTransaction((transaction) async {
        final barRef = _firestore.collection('hiddenBars').doc(barId);
        final barDoc = await transaction.get(barRef);
        
        if (!barDoc.exists) {
          return {'success': false, 'error': 'Bar introuvable'};
        }
        
        final barData = barDoc.data()!;
        final participants = List<String>.from(barData['participants']);
        final maxParticipants = barData['maxParticipants'] as int;
        
        if (participants.contains(userId)) {
          return {'success': false, 'error': 'Vous êtes déjà dans ce bar'};
        }
        
        if (participants.length >= maxParticipants) {
          return {'success': false, 'error': 'Bar complet'};
        }
        
        // Vérifier l'expiration
        final expiresAt = (barData['expiresAt'] as Timestamp).toDate();
        if (DateTime.now().isAfter(expiresAt)) {
          return {'success': false, 'error': 'Ce bar a expiré'};
        }
        
        participants.add(userId);
        
        transaction.update(barRef, {
          'participants': participants,
        });
        
        // Ajouter au chat
        final chatRef = _firestore.collection('hiddenBarChats').doc(barData['chatRoomId']);
        transaction.update(chatRef, {
          'participants': FieldValue.arrayUnion([userId]),
        });
        
        return {'success': true, 'message': 'Bienvenue dans le Bar Caché !'};
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Obtenir les statistiques des énigmes d'un utilisateur
  Future<Map<String, dynamic>> getUserRiddleStats(String userId) async {
    try {
      final quests = await _firestore
          .collection('riddleQuests')
          .where('userId', isEqualTo: userId)
          .get();
      
      int totalAttempts = 0;
      int completedQuests = 0;
      
      for (final quest in quests.docs) {
        final data = quest.data();
        totalAttempts += data['attempts'] as int;
        if (data['isCompleted'] == true) {
          completedQuests++;
        }
      }
      
      final hasAccess = await hasHiddenBarAccess(userId);
      
      return {
        'totalAttempts': totalAttempts,
        'completedQuests': completedQuests,
        'hasHiddenBarAccess': hasAccess,
        'riddlesMastery': completedQuests > 0 ? (completedQuests / _riddles.length * 100).round() : 0,
      };
    } catch (e) {
      print('Erreur stats énigmes: $e');
      return {};
    }
  }
  
  // Envoyer un message dans le Bar Caché
  Future<bool> sendHiddenBarMessage({
    required String chatRoomId,
    required String senderId,
    required String message,
  }) async {
    try {
      await _firestore.collection('hiddenBarChats').doc(chatRoomId).update({
        'messages': FieldValue.arrayUnion([{
          'senderId': senderId,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'isPhilosophical': message.contains('?'), // Marquer les questions philosophiques
        }]),
      });
      
      return true;
    } catch (e) {
      print('Erreur message bar caché: $e');
      return false;
    }
  }
  
  // Obtenir les messages du Bar Caché
  Stream<DocumentSnapshot> getHiddenBarMessages(String chatRoomId) {
    return _firestore.collection('hiddenBarChats').doc(chatRoomId).snapshots();
  }
}