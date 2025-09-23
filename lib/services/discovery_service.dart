import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user.dart' as app_user;

class DiscoveryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir les utilisateurs pour la découverte
  static Future<List<app_user.User>> getDiscoveryUsers({
    required String currentUserId,
    int limit = 10,
    String theme = 'fun',
  }) async {
    try {
      // Obtenir le profil de l'utilisateur actuel
      final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (!currentUserDoc.exists) return [];

      final currentUser = app_user.User.fromFirestore(currentUserDoc);
      
      // Obtenir les utilisateurs déjà vus/swipés
      final seenUsersQuery = await _firestore
          .collection('swipes')
          .where('swiperId', isEqualTo: currentUserId)
          .get();
      
      final seenUserIds = seenUsersQuery.docs
          .map((doc) => doc.data()['swipedUserId'] as String)
          .toSet();
      
      seenUserIds.add(currentUserId); // Exclure soi-même

      // Requête de base pour les utilisateurs
      Query query = _firestore.collection('users');

      // Filtres selon le thème
      if (theme == 'serious') {
        query = query
            .where('seekingSerious', isEqualTo: true)
            .where('isVerified', isEqualTo: true);
      } else if (theme == 'adventure') {
        query = query
            .where('interests', arrayContainsAny: ['voyage', 'aventure', 'sport', 'nature']);
      }

      // Filtres par préférences
      final preferences = currentUser.preferences ?? {};
      final ageMin = preferences['ageMin'] ?? 18;
      final ageMax = preferences['ageMax'] ?? 50;

      query = query
          .where('age', isGreaterThanOrEqualTo: ageMin)
          .where('age', isLessThanOrEqualTo: ageMax)
          .where('lastActive', isGreaterThan: Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: 30)) // Actifs dans les 30 derniers jours
          ));

      // Exécuter la requête
      final querySnapshot = await query.limit(limit * 3).get(); // Plus de résultats pour filtrer

      final users = <app_user.User>[];
      
      for (final doc in querySnapshot.docs) {
        if (seenUserIds.contains(doc.id)) continue; // Skip les utilisateurs déjà vus
        
        final user = app_user.User.fromFirestore(doc);
        
        // Vérifier la compatibilité des préférences de genre
        if (!_isGenderCompatible(currentUser, user)) continue;
        
        // Calculer la distance si les deux ont une ville
        if (currentUser.city != null && user.city != null) {
          // Pour une version simplifiée, on peut juste vérifier si c'est la même ville
          // Dans une vraie app, on utiliserait une API de géolocalisation
          if (currentUser.city != user.city) continue;
        }
        
        users.add(user);
        
        if (users.length >= limit) break;
      }

      // Trier par score de compatibilité
      users.sort((a, b) => _calculateCompatibilityScore(currentUser, b)
          .compareTo(_calculateCompatibilityScore(currentUser, a)));

      return users;
    } catch (e) {
      print('Error getting discovery users: $e');
      return [];
    }
  }

  // Enregistrer un swipe
  static Future<bool> recordSwipe({
    required String swiperId,
    required String swipedUserId,
    required bool isLike,
    String? message,
  }) async {
    try {
      final swipeData = {
        'swiperId': swiperId,
        'swipedUserId': swipedUserId,
        'isLike': isLike,
        'createdAt': Timestamp.now(),
        'message': message,
      };

      // Enregistrer le swipe
      await _firestore.collection('swipes').add(swipeData);

      // Si c'est un like, vérifier s'il y a match
      if (isLike) {
        final reverseSwipeQuery = await _firestore
            .collection('swipes')
            .where('swiperId', isEqualTo: swipedUserId)
            .where('swipedUserId', isEqualTo: swiperId)
            .where('isLike', isEqualTo: true)
            .limit(1)
            .get();

        if (reverseSwipeQuery.docs.isNotEmpty) {
          // C'est un match !
          await _createMatch(swiperId, swipedUserId);
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error recording swipe: $e');
      return false;
    }
  }

  // Créer un match
  static Future<void> _createMatch(String user1Id, String user2Id) async {
    final matchId = _generateMatchId(user1Id, user2Id);
    
    final matchData = {
      'id': matchId,
      'users': [user1Id, user2Id],
      'createdAt': Timestamp.now(),
      'isActive': true,
      'lastMessageAt': null,
      'unreadCount': {
        user1Id: 0,
        user2Id: 0,
      },
    };

    await _firestore.collection('matches').doc(matchId).set(matchData);

    // Envoyer des notifications aux deux utilisateurs
    await _sendMatchNotifications(user1Id, user2Id);
  }

  // Obtenir les matches de l'utilisateur
  static Stream<List<Map<String, dynamic>>> getMatches(String userId) {
    return _firestore
        .collection('matches')
        .where('users', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }).toList());
  }

  // Obtenir les utilisateurs qui ont liké l'utilisateur actuel
  static Future<List<app_user.User>> getUsersWhoLikedMe(String userId) async {
    try {
      final likesQuery = await _firestore
          .collection('swipes')
          .where('swipedUserId', isEqualTo: userId)
          .where('isLike', isEqualTo: true)
          .get();

      final likerIds = likesQuery.docs
          .map((doc) => doc.data()['swiperId'] as String)
          .toList();

      if (likerIds.isEmpty) return [];

      // Obtenir les profils des utilisateurs qui ont liké
      final users = <app_user.User>[];
      
      for (final likerId in likerIds) {
        final userDoc = await _firestore.collection('users').doc(likerId).get();
        if (userDoc.exists) {
          users.add(app_user.User.fromFirestore(userDoc));
        }
      }

      return users;
    } catch (e) {
      print('Error getting users who liked me: $e');
      return [];
    }
  }

  // Boost du profil (premium)
  static Future<void> boostProfile(String userId, int duration) async {
    final boostEndTime = DateTime.now().add(Duration(minutes: duration));
    
    await _firestore.collection('users').doc(userId).update({
      'boostActive': true,
      'boostEndTime': Timestamp.fromDate(boostEndTime),
    });
  }

  // Super like (premium)
  static Future<bool> superLike({
    required String swiperId,
    required String swipedUserId,
    String? message,
  }) async {
    try {
      final superLikeData = {
        'swiperId': swiperId,
        'swipedUserId': swipedUserId,
        'isSuperLike': true,
        'createdAt': Timestamp.now(),
        'message': message,
      };

      await _firestore.collection('superLikes').add(superLikeData);

      // Notifier l'utilisateur ciblé
      await _firestore.collection('notifications').add({
        'userId': swipedUserId,
        'type': 'superlike',
        'fromUserId': swiperId,
        'message': message,
        'createdAt': Timestamp.now(),
        'isRead': false,
      });

      return true;
    } catch (e) {
      print('Error sending super like: $e');
      return false;
    }
  }

  // Calculer la distance entre deux points
  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000; // En km
  }

  // Vérifier la compatibilité des préférences de genre
  static bool _isGenderCompatible(app_user.User currentUser, app_user.User otherUser) {
    final currentPrefs = currentUser.preferences ?? {};
    final otherPrefs = otherUser.preferences ?? {};
    
    final currentInterestedIn = currentPrefs['interestedIn'] as List<String>? ?? ['all'];
    final otherInterestedIn = otherPrefs['interestedIn'] as List<String>? ?? ['all'];
    
    // Si l'un des deux accepte tous les genres
    if (currentInterestedIn.contains('all') || otherInterestedIn.contains('all')) {
      return true;
    }
    
    // Vérifier la compatibilité mutuelle
    return currentInterestedIn.contains(otherUser.gender) && 
           otherInterestedIn.contains(currentUser.gender);
  }

  // Calculer le score de compatibilité
  static int _calculateCompatibilityScore(app_user.User user1, app_user.User user2) {
    int score = 0;
    
    // Intérêts communs (40 points max)
    final commonInterests = user1.interests
        .where((interest) => user2.interests.contains(interest))
        .length;
    score += (commonInterests * 8).clamp(0, 40);
    
    // Différence d'âge (20 points max)
    final ageDiff = (user1.age - user2.age).abs();
    score += (20 - ageDiff * 2).clamp(0, 20);
    
    // Activité récente (20 points max)
    final daysSinceActive = DateTime.now().difference(user2.lastActive).inDays;
    score += (20 - daysSinceActive).clamp(0, 20);
    
    // Score de fiabilité (20 points max)
    final reliabilityScore = user2.reliabilityScore ?? 100;
    score += (reliabilityScore / 5).round().clamp(0, 20);
    
    return score;
  }

  // Générer un ID de match unique
  static String _generateMatchId(String user1Id, String user2Id) {
    final sortedIds = [user1Id, user2Id]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Envoyer des notifications de match
  static Future<void> _sendMatchNotifications(String user1Id, String user2Id) async {
    final notifications = [
      {
        'userId': user1Id,
        'type': 'match',
        'fromUserId': user2Id,
        'createdAt': Timestamp.now(),
        'isRead': false,
      },
      {
        'userId': user2Id,
        'type': 'match',
        'fromUserId': user1Id,
        'createdAt': Timestamp.now(),
        'isRead': false,
      },
    ];

    for (final notification in notifications) {
      await _firestore.collection('notifications').add(notification);
    }
  }
}