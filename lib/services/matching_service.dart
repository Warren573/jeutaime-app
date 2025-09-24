import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';

enum MatchQuality {
  perfect, // 90-100%
  excellent, // 80-89%
  good, // 70-79%
  average, // 60-69%
  low, // 50-59%
}

class MatchingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Algorithme de matching principal
  static Future<List<UserModel>> getRecommendations({
    int limit = 10,
    double maxDistance = 50.0,
    List<String> excludeUserIds = const [],
  }) async {
    final currentUser = await _getCurrentUserData();
    if (currentUser == null) return [];

    try {
      // Récupérer les utilisateurs potentiels
      final potentialMatches = await _getPotentialMatches(
        currentUser,
        maxDistance,
        excludeUserIds,
        limit * 3, // Récupérer plus pour avoir du choix après filtrage
      );

      // Calculer les scores de compatibilité
      final matchesWithScores = await _calculateCompatibilityScores(currentUser, potentialMatches);

      // Trier par score et retourner les meilleurs
      matchesWithScores.sort((a, b) => b['score'].compareTo(a['score']));
      
      return matchesWithScores
          .take(limit)
          .map((match) => match['user'] as UserModel)
          .toList();
    } catch (e) {
      print('Erreur recommandations: $e');
      return [];
    }
  }

  // Traiter un swipe/like
  static Future<bool> processSwipe({
    required String targetUserId,
    required bool isLike,
    String? barId,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      // Enregistrer l'action
      await _firestore.collection('swipes').add({
        'fromUserId': currentUser.uid,
        'toUserId': targetUserId,
        'isLike': isLike,
        'barId': barId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (isLike) {
        // Vérifier s'il y a match mutuel
        final mutualLike = await _firestore
            .collection('swipes')
            .where('fromUserId', isEqualTo: targetUserId)
            .where('toUserId', isEqualTo: currentUser.uid)
            .where('isLike', isEqualTo: true)
            .get();

        if (mutualLike.docs.isNotEmpty) {
          // C'est un match !
          await _createMatch(currentUser.uid, targetUserId, barId);
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Erreur swipe: $e');
      return false;
    }
  }

  // Créer un match
  static Future<void> _createMatch(String user1Id, String user2Id, String? barId) async {
    try {
      // Récupérer les données des utilisateurs
      final user1Doc = await _firestore.collection('users').doc(user1Id).get();
      final user2Doc = await _firestore.collection('users').doc(user2Id).get();

      if (!user1Doc.exists || !user2Doc.exists) return;

      final user1Data = user1Doc.data()!;
      final user2Data = user2Doc.data()!;

      // Créer le match
      final matchId = await _firestore.collection('matches').add({
        'user1Id': user1Id,
        'user2Id': user2Id,
        'user1Name': user1Data['name'],
        'user2Name': user2Data['name'],
        'user1Photo': user1Data['profile']?['photos']?[0] ?? '',
        'user2Photo': user2Data['profile']?['photos']?[0] ?? '',
        'barId': barId,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Créer la conversation automatiquement
      await ChatService.createConversation(
        otherUserId: user1Id == _auth.currentUser?.uid ? user2Id : user1Id,
        otherUserName: user1Id == _auth.currentUser?.uid 
            ? user2Data['name'] 
            : user1Data['name'],
        otherUserPhoto: user1Id == _auth.currentUser?.uid 
            ? (user2Data['profile']?['photos']?[0] ?? '')
            : (user1Data['profile']?['photos']?[0] ?? ''),
        matchId: matchId.id,
      );

      // Récompenser les utilisateurs
      await _rewardMatch(user1Id);
      await _rewardMatch(user2Id);

      // Envoyer notifications (TODO)
      
    } catch (e) {
      print('Erreur création match: $e');
    }
  }

  // Calculer le score de compatibilité entre deux utilisateurs
  static Future<double> calculateCompatibilityScore(
    UserModel user1,
    UserModel user2,
  ) async {
    double totalScore = 0;
    int factors = 0;

    // 1. Âge (20%)
    final ageDifference = (user1.age - user2.age).abs();
    double ageScore = 0;
    if (ageDifference <= 2) ageScore = 100;
    else if (ageDifference <= 5) ageScore = 80;
    else if (ageDifference <= 10) ageScore = 60;
    else if (ageDifference <= 15) ageScore = 40;
    else ageScore = 20;
    
    totalScore += ageScore * 0.20;
    factors++;

    // 2. Intérêts communs (25%)
    final commonInterests = user1.interests
        .where((interest) => user2.interests.contains(interest))
        .length;
    final totalInterests = (user1.interests.length + user2.interests.length) / 2;
    final interestScore = totalInterests > 0 
        ? (commonInterests / totalInterests) * 100 
        : 50;
    
    totalScore += interestScore * 0.25;
    factors++;

    // 3. Langage d'amour (15%)
    double loveLanguageScore = user1.loveLanguage == user2.loveLanguage ? 100 : 
                               _areLoveLanguagesCompatible(user1.loveLanguage, user2.loveLanguage) ? 75 : 50;
    
    totalScore += loveLanguageScore * 0.15;
    factors++;

    // 4. Distance géographique (15%)
    double distanceScore = 100; // Par défaut si pas de géolocalisation
    // TODO: Implémenter calcul de distance réelle
    
    totalScore += distanceScore * 0.15;
    factors++;

    // 5. Activité et fiabilité (15%)
    final daysSinceActive1 = DateTime.now().difference(user1.lastActive).inDays;
    final daysSinceActive2 = DateTime.now().difference(user2.lastActive).inDays;
    
    double activityScore = 100;
    if (daysSinceActive1 > 7 || daysSinceActive2 > 7) activityScore = 70;
    if (daysSinceActive1 > 30 || daysSinceActive2 > 30) activityScore = 40;
    
    final reliabilityScore = (user1.reliabilityScore + user2.reliabilityScore) / 2;
    final combinedActivityScore = (activityScore + reliabilityScore) / 2;
    
    totalScore += combinedActivityScore * 0.15;
    factors++;

    // 6. Préférences de recherche (10%)
    double lookingForScore = 100;
    if (user1.lookingFor.isNotEmpty && user2.lookingFor.isNotEmpty) {
      lookingForScore = user1.lookingFor == user2.lookingFor ? 100 : 50;
    }
    
    totalScore += lookingForScore * 0.10;
    factors++;

    return totalScore;
  }

  // Récupérer les matches de l'utilisateur actuel
  static Future<List<Map<String, dynamic>>> getUserMatches() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    try {
      final matches = await _firestore
          .collection('matches')
          .where('user1Id', isEqualTo: userId)
          .get();
      
      final matches2 = await _firestore
          .collection('matches')
          .where('user2Id', isEqualTo: userId)
          .get();

      final allMatches = [...matches.docs, ...matches2.docs];
      
      return allMatches.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Erreur récupération matches: $e');
      return [];
    }
  }

  // Obtenir les statistiques de matching
  static Future<Map<String, dynamic>> getMatchingStats() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};

    try {
      // Compter les swipes
      final swipesQuery = await _firestore
          .collection('swipes')
          .where('fromUserId', isEqualTo: userId)
          .get();

      final likes = swipesQuery.docs.where((doc) => doc.data()['isLike'] == true).length;
      final dislikes = swipesQuery.docs.length - likes;

      // Compter les matches
      final matches = await getUserMatches();
      
      // Calculer le taux de succès
      final successRate = likes > 0 ? (matches.length / likes * 100) : 0;

      return {
        'totalSwipes': swipesQuery.docs.length,
        'likes': likes,
        'dislikes': dislikes,
        'matches': matches.length,
        'successRate': successRate.round(),
      };
    } catch (e) {
      print('Erreur stats matching: $e');
      return {};
    }
  }

  // Méthodes privées

  static Future<UserModel?> _getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Erreur récupération utilisateur: $e');
    }
    return null;
  }

  static Future<List<UserModel>> _getPotentialMatches(
    UserModel currentUser,
    double maxDistance,
    List<String> excludeUserIds,
    int limit,
  ) async {
    try {
      // Récupérer les utilisateurs dans les préférences d'âge
      final minAge = currentUser.preferences['ageMin'] ?? 18;
      final maxAge = currentUser.preferences['ageMax'] ?? 35;

      // Exclure les utilisateurs déjà swipés
      final swipedUsers = await _getSwipedUserIds(currentUser.uid);
      final allExcluded = [...excludeUserIds, currentUser.uid, ...swipedUsers];

      Query query = _firestore
          .collection('users')
          .where('age', isGreaterThanOrEqualTo: minAge)
          .where('age', isLessThanOrEqualTo: maxAge)
          .where('lastActive', isGreaterThan: DateTime.now().subtract(Duration(days: 30)))
          .limit(limit);

      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => !allExcluded.contains(user.uid))
          .toList();
    } catch (e) {
      print('Erreur récupération matches potentiels: $e');
      return [];
    }
  }

  static Future<List<String>> _getSwipedUserIds(String userId) async {
    try {
      final swipes = await _firestore
          .collection('swipes')
          .where('fromUserId', isEqualTo: userId)
          .get();

      return swipes.docs
          .map((doc) => doc.data()['toUserId'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> _calculateCompatibilityScores(
    UserModel currentUser,
    List<UserModel> potentialMatches,
  ) async {
    List<Map<String, dynamic>> results = [];

    for (UserModel user in potentialMatches) {
      final score = await calculateCompatibilityScore(currentUser, user);
      results.add({
        'user': user,
        'score': score,
        'quality': _getMatchQuality(score),
      });
    }

    return results;
  }

  static MatchQuality _getMatchQuality(double score) {
    if (score >= 90) return MatchQuality.perfect;
    if (score >= 80) return MatchQuality.excellent;
    if (score >= 70) return MatchQuality.good;
    if (score >= 60) return MatchQuality.average;
    return MatchQuality.low;
  }

  static bool _areLoveLanguagesCompatible(String lang1, String lang2) {
    // Définir les compatibilités entre langages d'amour
    const compatibilities = {
      'Paroles valorisantes': ['Paroles valorisantes', 'Temps de qualité'],
      'Temps de qualité': ['Temps de qualité', 'Paroles valorisantes', 'Toucher physique'],
      'Cadeaux': ['Cadeaux', 'Services rendus'],
      'Services rendus': ['Services rendus', 'Cadeaux'],
      'Toucher physique': ['Toucher physique', 'Temps de qualité'],
    };

    return compatibilities[lang1]?.contains(lang2) ?? false;
  }

  static Future<void> _rewardMatch(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'coins': FieldValue.increment(10), // 10 coins par match
        'stats.totalMatches': FieldValue.increment(1),
        'stats.reliabilityScore': FieldValue.increment(1), // Boost pour être actif
      });
    } catch (e) {
      print('Erreur récompense match: $e');
    }
  }

  // Nettoyage périodique (à appeler depuis un Cloud Function)
  static Future<void> cleanupOldData() async {
    try {
      final oldDate = DateTime.now().subtract(Duration(days: 90));
      
      // Supprimer les vieux swipes
      final oldSwipes = await _firestore
          .collection('swipes')
          .where('timestamp', isLessThan: Timestamp.fromDate(oldDate))
          .get();

      final batch = _firestore.batch();
      for (var doc in oldSwipes.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
    } catch (e) {
      print('Erreur nettoyage: $e');
    }
  }
}