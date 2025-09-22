import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class BarService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer les utilisateurs d'un bar spécifique
  static Future<List<UserModel>> getUsersInBar(String barId, {String filter = 'all'}) async {
    try {
      Query query = _firestore.collection('users')
        .where('currentBar', isEqualTo: barId)
        .where('lastActive', isGreaterThan: DateTime.now().subtract(Duration(hours: 24)))
        .limit(20);

      // Filtres spécifiques par bar
      if (barId == 'romantic' && filter != 'all') {
        query = query.where('profile.interests', arrayContains: _getFilterInterest(filter));
      }

      QuerySnapshot snapshot = await query.get();
      
      List<UserModel> users = snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .where((user) => user.uid != _auth.currentUser?.uid) // Exclure l'utilisateur actuel
        .toList();

      // Tri par compatibilité pour le bar romantique
      if (barId == 'romantic') {
        users.sort((a, b) => b.reliabilityScore.compareTo(a.reliabilityScore));
      }

      return users;
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
      return [];
    }
  }

  // Entrer dans un bar
  static Future<void> enterBar(String barId) async {
    if (_auth.currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'currentBar': barId,
        'lastActive': FieldValue.serverTimestamp(),
      });

      // Enregistrer l'entrée dans les statistiques du bar
      await _firestore.collection('bar_stats').doc(barId).set({
        'totalEntries': FieldValue.increment(1),
        'currentUsers': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {
      print('Erreur lors de l\'entrée dans le bar: $e');
    }
  }

  // Sortir d'un bar
  static Future<void> exitBar(String barId) async {
    if (_auth.currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'currentBar': '',
        'lastActive': FieldValue.serverTimestamp(),
      });

      // Mettre à jour les statistiques
      await _firestore.collection('bar_stats').doc(barId).update({
        'currentUsers': FieldValue.increment(-1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print('Erreur lors de la sortie du bar: $e');
    }
  }

  // Liker un utilisateur
  static Future<bool> likeUser(String targetUserId, String barId) async {
    if (_auth.currentUser == null) return false;

    try {
      String currentUserId = _auth.currentUser!.uid;
      
      // Enregistrer le like
      await _firestore.collection('likes').add({
        'fromUser': currentUserId,
        'toUser': targetUserId,
        'barId': barId,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'like',
      });

      // Vérifier s'il y a match (like mutuel)
      QuerySnapshot mutualLike = await _firestore.collection('likes')
        .where('fromUser', isEqualTo: targetUserId)
        .where('toUser', isEqualTo: currentUserId)
        .get();

      if (mutualLike.docs.isNotEmpty) {
        // C'est un match ! Créer une conversation
        await _createMatch(currentUserId, targetUserId, barId);
        return true; // Match trouvé
      }

      return false; // Pas de match
    } catch (e) {
      print('Erreur lors du like: $e');
      return false;
    }
  }

  // Créer un match
  static Future<void> _createMatch(String user1, String user2, String barId) async {
    try {
      await _firestore.collection('matches').add({
        'users': [user1, user2],
        'barId': barId,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'conversationStarted': false,
      });

      // Notifier les deux utilisateurs
      await _sendMatchNotification(user1, user2);
      await _sendMatchNotification(user2, user1);

      // Récompenser avec des coins
      await _rewardMatch(user1);
      await _rewardMatch(user2);

    } catch (e) {
      print('Erreur lors de la création du match: $e');
    }
  }

  // Envoyer notification de match
  static Future<void> _sendMatchNotification(String userId, String matchedUserId) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': 'match',
        'title': '🎉 Nouveau Match !',
        'message': 'Vous avez un match ! Commencez la conversation.',
        'data': {'matchedUserId': matchedUserId},
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      print('Erreur notification: $e');
    }
  }

  // Récompenser un match
  static Future<void> _rewardMatch(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'coins': FieldValue.increment(10), // 10 coins par match
        'stats.totalMatches': FieldValue.increment(1),
      });
    } catch (e) {
      print('Erreur récompense: $e');
    }
  }

  // Obtenir les statistiques d'un bar
  static Future<Map<String, dynamic>> getBarStats(String barId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('bar_stats').doc(barId).get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        // Créer les stats par défaut
        Map<String, dynamic> defaultStats = {
          'totalEntries': 0,
          'currentUsers': 0,
          'totalMatches': 0,
          'satisfactionRate': 4.5,
          'lastUpdated': FieldValue.serverTimestamp(),
        };
        
        await _firestore.collection('bar_stats').doc(barId).set(defaultStats);
        return defaultStats;
      }
    } catch (e) {
      print('Erreur stats bar: $e');
      return {'currentUsers': 0, 'totalMatches': 0, 'satisfactionRate': 4.0};
    }
  }

  // Obtenir l'intérêt correspondant au filtre
  static String _getFilterInterest(String filter) {
    switch (filter) {
      case 'poetry': return 'Poésie';
      case 'music': return 'Musique';
      case 'sunset': return 'Couchers de soleil';
      case 'books': return 'Lecture';
      default: return '';
    }
  }

  // Vérifier l'accès au bar mystère
  static Future<bool> canAccessMysteryBar(String userId) async {
    try {
      // Vérifier si l'utilisateur a résolu l'énigme du jour
      DocumentSnapshot puzzle = await _firestore
        .collection('daily_puzzles')
        .doc(DateTime.now().toString().substring(0, 10)) // YYYY-MM-DD
        .get();

      if (!puzzle.exists) return false;

      DocumentSnapshot userProgress = await _firestore
        .collection('user_puzzles')
        .doc('${userId}_${DateTime.now().toString().substring(0, 10)}')
        .get();

      return userProgress.exists && userProgress.get('solved') == true;
    } catch (e) {
      print('Erreur accès bar mystère: $e');
      return false;
    }
  }

  // Enregistrer un ghosting
  static Future<void> reportGhosting(String ghosterId, String victimId) async {
    try {
      // Sanctionner le ghosteur
      await _firestore.collection('users').doc(ghosterId).update({
        'stats.ghostingScore': FieldValue.increment(-10),
        'stats.reliabilityScore': FieldValue.increment(-5),
        'coins': FieldValue.increment(-20), // Perte de coins
      });

      // Récompenser la victime
      await _firestore.collection('users').doc(victimId).update({
        'stats.ghostingScore': FieldValue.increment(5),
        'stats.reliabilityScore': FieldValue.increment(2),
        'coins': FieldValue.increment(10), // Coins de compensation
      });

      // Enregistrer le report
      await _firestore.collection('ghosting_reports').add({
        'ghosterId': ghosterId,
        'victimId': victimId,
        'timestamp': FieldValue.serverTimestamp(),
        'processed': true,
      });

    } catch (e) {
      print('Erreur report ghosting: $e');
    }
  }

  // Stream des utilisateurs en temps réel
  static Stream<List<UserModel>> getUsersInBarStream(String barId) {
    return _firestore.collection('users')
      .where('currentBar', isEqualTo: barId)
      .where('lastActive', isGreaterThan: DateTime.now().subtract(Duration(hours: 2)))
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .where((user) => user.uid != _auth.currentUser?.uid)
        .toList());
  }
}
