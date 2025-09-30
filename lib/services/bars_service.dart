import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

enum BarType {
  romantic, // Bar Romantique 🌹
  humor,    // Bar Humoristique 😄
  pirates,  // Bar Pirates 🏴‍☠️
  weekly,   // Bar Hebdomadaire 📅
  hidden,   // Bar Caché 👑
}

class BarsService {
  static BarsService? _instance;
  static BarsService get instance => _instance ??= BarsService._();
  
  BarsService._();
  
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  
  // Configuration des bars selon votre vision
  Map<BarType, Map<String, dynamic>> get barConfigs => {
    BarType.romantic: {
      'name': 'Bar Romantique',
      'icon': '🌹',
      'description': 'Poésie, déclarations et moments tendres',
      'activities': ['Quiz Amour', 'Poème Collaboratif', 'Sérénade'],
      'maxCapacity': 50,
      'entryFee': 0,
    },
    BarType.humor: {
      'name': 'Bar Humoristique',
      'icon': '😄',  
      'description': 'Rires, blagues et bonne humeur',
      'activities': ['Concours Blagues', 'Mime Party', 'Stand-up Amateur'],
      'maxCapacity': 50,
      'entryFee': 0,
    },
    BarType.pirates: {
      'name': 'Bar Pirates',
      'icon': '🏴‍☠️',
      'description': 'Aventures, défis et esprit d\'équipe',
      'activities': ['Chasse au Trésor', 'Défi Combat', 'Navigation'],
      'maxCapacity': 50,
      'entryFee': 0,
    },
    BarType.weekly: {
      'name': 'Bar Hebdomadaire',
      'icon': '📅',
      'description': 'Groupes équilibrés 2H/2F, 7 jours',
      'activities': ['Activités Groupe', 'Notation Mutuelle', 'Défis Équipe'],
      'maxCapacity': 4, // 2H + 2F
      'entryFee': 50,
    },
    BarType.hidden: {
      'name': 'Bar Caché',
      'icon': '👑',
      'description': 'Accès par énigmes, chat avec le Créateur',
      'activities': ['Énigmes Progressives', 'Chat Créateur', 'Défis Secrets'],
      'maxCapacity': 20,
      'entryFee': 100,
    },
  };
  
  // Rejoindre un bar
  Future<String?> joinBar({
    required String userId,
    required BarType barType,
    String? gender, // Pour le bar hebdomadaire
  }) async {
    try {
      final config = barConfigs[barType]!;
      
      // Vérifications spéciales selon le type de bar
      if (barType == BarType.weekly) {
        return await _joinWeeklyBar(userId, gender!);
      } else if (barType == BarType.hidden) {
        final canJoin = await _checkHiddenBarAccess(userId);
        if (!canJoin) {
          throw Exception('Vous devez résoudre 3 énigmes pour accéder au Bar Caché');
        }
      }
      
      // Trouver ou créer une session active
      String? sessionId = await _findAvailableSession(barType);
      sessionId ??= await _createNewSession(barType);
      
      if (sessionId == null) {
        throw Exception('Impossible de créer une session');
      }
      
      // Ajouter l'utilisateur à la session
      await _addUserToSession(sessionId, userId);
      
      return sessionId;
    } catch (e) {
      print('Erreur rejoindre bar: $e');
      return null;
    }
  }
  
  // Logique spéciale pour le Bar Hebdomadaire
  Future<String?> _joinWeeklyBar(String userId, String gender) async {
    try {
      // Chercher un groupe en attente qui a besoin de ce genre
      final query = await _firestore
          .collection('barSessions')
          .where('barType', isEqualTo: 'weekly')
          .where('isActive', isEqualTo: true)
          .where('status', isEqualTo: 'waiting')
          .get();
      
      for (final doc in query.docs) {
        final data = doc.data();
        final participants = List<Map<String, dynamic>>.from(data['participants'] ?? []);
        
        if (participants.length >= 4) continue; // Groupe complet
        
        // Compter les genres
        final maleCount = participants.where((p) => p['gender'] == 'male').length;
        final femaleCount = participants.where((p) => p['gender'] == 'female').length;
        
        // Vérifier si on peut ajouter ce genre
        if ((gender == 'male' && maleCount < 2) || 
            (gender == 'female' && femaleCount < 2)) {
          
          // Ajouter l'utilisateur
          await _firestore.collection('barSessions').doc(doc.id).update({
            'participants': FieldValue.arrayUnion([{
              'userId': userId,
              'gender': gender,
              'joinedAt': FieldValue.serverTimestamp(),
            }]),
          });
          
          // Si le groupe est maintenant complet (2H + 2F), le démarrer
          if (participants.length == 3) {
            await _startWeeklyGroup(doc.id);
          }
          
          return doc.id;
        }
      }
      
      // Aucun groupe trouvé, en créer un nouveau
      return await _createWeeklyGroup(userId, gender);
    } catch (e) {
      print('Erreur Bar Hebdomadaire: $e');
      return null;
    }
  }
  
  Future<String> _createWeeklyGroup(String userId, String gender) async {
    final docRef = await _firestore.collection('barSessions').add({
      'barType': 'weekly',
      'isActive': true,
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': DateTime.now().add(Duration(days: 7)),
      'participants': [{
        'userId': userId,
        'gender': gender,
        'joinedAt': FieldValue.serverTimestamp(),
      }],
      'activities': [],
      'ratings': {},
    });
    
    return docRef.id;
  }
  
  Future<void> _startWeeklyGroup(String sessionId) async {
    await _firestore.collection('barSessions').doc(sessionId).update({
      'status': 'active',
      'startedAt': FieldValue.serverTimestamp(),
    });
    
    // Programmer des activités pour la semaine
    await _scheduleWeeklyActivities(sessionId);
  }
  
  Future<void> _scheduleWeeklyActivities(String sessionId) async {
    final activities = [
      {'name': 'Présentation', 'day': 1, 'type': 'introduction'},
      {'name': 'Quiz Connaissance', 'day': 2, 'type': 'quiz'},
      {'name': 'Défi Créatif', 'day': 3, 'type': 'creative'},
      {'name': 'Activité Sportive', 'day': 4, 'type': 'sport'},
      {'name': 'Soirée Jeux', 'day': 5, 'type': 'games'},
      {'name': 'Discussion Libre', 'day': 6, 'type': 'discussion'},
      {'name': 'Notation Mutuelle', 'day': 7, 'type': 'rating'},
    ];
    
    for (final activity in activities) {
      await _firestore.collection('weeklyActivities').add({
        'sessionId': sessionId,
        'name': activity['name'],
        'type': activity['type'],
        'scheduledDate': DateTime.now().add(Duration(days: activity['day'] as int)),
        'isCompleted': false,
        'participantResponses': {},
      });
    }
  }
  
  // Vérifier l'accès au Bar Caché
  Future<bool> _checkHiddenBarAccess(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final solvedRiddles = List<String>.from(userDoc.data()?['solvedRiddles'] ?? []);
      return solvedRiddles.length >= 3;
    } catch (e) {
      return false;
    }
  }
  
  // Résoudre une énigme
  Future<bool> solveRiddle(String userId, String riddleId, String answer) async {
    try {
      final riddleDoc = await _firestore.collection('riddles').doc(riddleId).get();
      final correctAnswer = riddleDoc.data()?['answer'];
      
      if (answer.toLowerCase().trim() == correctAnswer.toLowerCase().trim()) {
        // Bonne réponse, marquer comme résolu
        await _firestore.collection('users').doc(userId).update({
          'solvedRiddles': FieldValue.arrayUnion([riddleId]),
        });
        
        // Donner des pièces de récompense
        await _firestore.collection('users').doc(userId).update({
          'coins': FieldValue.increment(200),
        });
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erreur résolution énigme: $e');
      return false;
    }
  }
  
  // Créer les énigmes par défaut
  Future<void> createDefaultRiddles() async {
    final riddles = [
      {
        'id': 'riddle1',
        'question': 'Je suis né de vos regards croisés, je grandis dans le silence, que suis-je ?',
        'answer': 'amour',
        'hint': 'Commence par la première lettre de l\'alphabet',
        'difficulty': 1,
      },
      {
        'id': 'riddle2', 
        'question': 'Plus on me partage, plus je grandis. Plus on me garde, plus je diminue. Que suis-je ?',
        'answer': 'bonheur',
        'hint': 'État d\'âme positif',
        'difficulty': 2,
      },
      {
        'id': 'riddle3',
        'question': 'Je relie deux cœurs sans jamais les toucher, je voyage sans bouger. Que suis-je ?',
        'answer': 'message',
        'hint': 'Moyen de communication',
        'difficulty': 3,
      },
    ];
    
    for (final riddle in riddles) {
      await _firestore.collection('riddles').doc(riddle['id'] as String).set(riddle);
    }
  }
  
  // Trouver une session disponible
  Future<String?> _findAvailableSession(BarType barType) async {
    try {
      final query = await _firestore
          .collection('barSessions')
          .where('barType', isEqualTo: barType.toString().split('.').last)
          .where('isActive', isEqualTo: true)
          .where('participantCount', isLessThan: barConfigs[barType]!['maxCapacity'])
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty ? query.docs.first.id : null;
    } catch (e) {
      return null;
    }
  }
  
  // Créer une nouvelle session
  Future<String?> _createNewSession(BarType barType) async {
    try {
      final config = barConfigs[barType]!;
      
      final docRef = await _firestore.collection('barSessions').add({
        'barType': barType.toString().split('.').last,
        'name': config['name'],
        'description': config['description'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'participantCount': 0,
        'maxCapacity': config['maxCapacity'],
        'participants': [],
        'activities': config['activities'],
        'currentActivity': null,
      });
      
      return docRef.id;
    } catch (e) {
      print('Erreur création session: $e');
      return null;
    }
  }
  
  // Ajouter un utilisateur à une session
  Future<void> _addUserToSession(String sessionId, String userId) async {
    await _firestore.collection('barSessions').doc(sessionId).update({
      'participants': FieldValue.arrayUnion([userId]),
      'participantCount': FieldValue.increment(1),
    });
  }
  
  // Récupérer les sessions actives d'un utilisateur
  Stream<QuerySnapshot> getUserBarSessions(String userId) {
    return _firestore
        .collection('barSessions')
        .where('participants', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }
  
  // Quitter un bar
  Future<bool> leaveBar(String sessionId, String userId) async {
    try {
      await _firestore.collection('barSessions').doc(sessionId).update({
        'participants': FieldValue.arrayRemove([userId]),
        'participantCount': FieldValue.increment(-1),
      });
      
      return true;
    } catch (e) {
      print('Erreur quitter bar: $e');
      return false;
    }
  }
}