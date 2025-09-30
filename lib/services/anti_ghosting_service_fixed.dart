import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class AntiGhostingService {
  static AntiGhostingService? _instance;
  static AntiGhostingService get instance => _instance ??= AntiGhostingService._();
  
  AntiGhostingService._();
  
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  
  // Constantes
  static const int DEFAULT_GHOSTING_PENALTY = 50;
  static const int DEFAULT_VICTIM_BONUS = 25;
  static const int DEFAULT_GHOSTING_THRESHOLD_HOURS = 48;
  
  // Obtenir les statistiques d'un utilisateur
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return {
          'strikes': 0,
          'reputation': 100,
          'status': 'active',
          'totalReports': 0,
          'totalReported': 0,
        };
      }
      
      final userData = userDoc.data()!;
      final antiGhostingStats = userData['antiGhostingStats'] as Map<String, dynamic>? ?? {};
      
      return {
        'strikes': antiGhostingStats['totalStrikes'] ?? 0,
        'reputation': antiGhostingStats['reputation'] ?? 100,
        'status': antiGhostingStats['status'] ?? 'active',
        'totalReports': antiGhostingStats['totalReports'] ?? 0,
        'totalReported': antiGhostingStats['totalReported'] ?? 0,
        'lastStrikeAt': antiGhostingStats['lastStrikeAt'],
        'positiveInteractions': userData['stats']?['positiveInteractions'] ?? 0,
      };
    } catch (e) {
      print('Erreur getUserStats: $e');
      return {
        'strikes': 0,
        'reputation': 100,
        'status': 'active',
        'totalReports': 0,
        'totalReported': 0,
      };
    }
  }
  
  // Signaler un utilisateur
  Future<Map<String, dynamic>> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    required String description,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // Vérifier si déjà signalé récemment
        final existingReport = await _firestore
            .collection('reports')
            .where('reporterId', isEqualTo: reporterId)
            .where('reportedUserId', isEqualTo: reportedUserId)
            .where('timestamp', isGreaterThan: DateTime.now().subtract(const Duration(days: 7)))
            .limit(1)
            .get();
        
        if (existingReport.docs.isNotEmpty) {
          return {'success': false, 'error': 'Vous avez déjà signalé cet utilisateur récemment'};
        }
        
        // Créer le signalement
        final reportData = {
          'reporterId': reporterId,
          'reportedUserId': reportedUserId,
          'reason': reason,
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending',
          'processed': false,
        };
        
        await _firestore.collection('reports').add(reportData);
        
        // Mettre à jour les statistiques
        final reporterRef = _firestore.collection('users').doc(reporterId);
        transaction.update(reporterRef, {
          'antiGhostingStats.totalReports': FieldValue.increment(1),
        });
        
        final reportedRef = _firestore.collection('users').doc(reportedUserId);
        transaction.update(reportedRef, {
          'antiGhostingStats.totalReported': FieldValue.increment(1),
        });
        
        return {'success': true};
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Ajouter un strike à un utilisateur
  Future<Map<String, dynamic>> addStrike({
    required String userId,
    required String reason,
    String? evidence,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          return {'success': false, 'error': 'Utilisateur introuvable'};
        }
        
        final userData = userDoc.data()!;
        final antiGhostingStats = userData['antiGhostingStats'] as Map<String, dynamic>? ?? {};
        final currentStrikes = antiGhostingStats['totalStrikes'] ?? 0;
        final newStrikes = currentStrikes + 1;
        
        // Déterminer le nouveau statut
        String status = 'active';
        List<String> penalties = [];
        
        if (newStrikes >= 3) {
          status = 'banned';
          penalties = ['ACCOUNT_SUSPENDED', 'PROFILE_HIDDEN', 'MATCHES_BLOCKED'];
        } else if (newStrikes >= 2) {
          status = 'restricted';
          penalties = ['LIMITED_MATCHES', 'REDUCED_VISIBILITY', 'WARNING_BADGE'];
        } else {
          status = 'warning';
          penalties = ['WARNING_NOTIFICATION'];
        }
        
        // Mettre à jour l'utilisateur
        transaction.update(userRef, {
          'antiGhostingStats.totalStrikes': newStrikes,
          'antiGhostingStats.status': status,
          'antiGhostingStats.lastStrikeAt': FieldValue.serverTimestamp(),
          'antiGhostingStats.penalties': penalties,
          'antiGhostingStats.reputation': FieldValue.increment(-20),
          'coins': FieldValue.increment(-DEFAULT_GHOSTING_PENALTY),
        });
        
        // Enregistrer le strike
        transaction.set(_firestore.collection('strikes').doc(), {
          'userId': userId,
          'reason': reason,
          'evidence': evidence,
          'timestamp': FieldValue.serverTimestamp(),
          'strikeNumber': newStrikes,
          'resultingStatus': status,
          'penalties': penalties,
        });
        
        return {
          'success': true,
          'newStrikes': newStrikes,
          'status': status,
          'penalties': penalties,
        };
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Récompenser un bon comportement
  Future<bool> rewardGoodBehavior(String userId, String reason) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'antiGhostingStats.reputation': FieldValue.increment(10),
        'antiGhostingStats.positiveActions': FieldValue.increment(1),
        'coins': FieldValue.increment(10),
        'stats.positiveInteractions': FieldValue.increment(1),
      });
      
      await _firestore.collection('positiveActions').add({
        'userId': userId,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
        'reward': 10,
      });
      
      return true;
    } catch (e) {
      print('Erreur rewardGoodBehavior: $e');
      return false;
    }
  }
  
  // Vérifier les timeouts et appliquer les pénalités automatiques
  static Future<void> checkForGhosting() async {
    try {
      const ghostingThresholdHours = DEFAULT_GHOSTING_THRESHOLD_HOURS;
      final cutoffTime = DateTime.now().subtract(const Duration(hours: ghostingThresholdHours));
      
      final _firestore = FirebaseService.instance.firestore;
      final staleThreads = await _firestore
          .collection('letterThreads')
          .where('isActive', isEqualTo: true)
          .where('lastActivityAt', isLessThan: cutoffTime)
          .get();
      
      for (final threadDoc in staleThreads.docs) {
        final threadData = threadDoc.data();
        final lastActivity = (threadData['lastActivityAt'] as Timestamp).toDate();
        final participants = List<String>.from(threadData['participants']);
        final currentTurn = threadData['currentTurn'] as String;
        
        await _processGhosting(
          threadDoc.id,
          currentTurn,
          participants.firstWhere((p) => p != currentTurn),
          lastActivity,
        );
      }
    } catch (e) {
      print('Erreur checkForGhosting: $e');
    }
  }
  
  // Traiter un cas de ghosting
  static Future<void> _processGhosting(
    String threadId,
    String ghosterId,
    String victimId,
    DateTime lastActivity,
  ) async {
    final daysSinceLastActivity = DateTime.now().difference(lastActivity).inDays;
    
    final _firestore = FirebaseService.instance.firestore;
    await _firestore.runTransaction((transaction) async {
      // Marquer le thread comme ghosté
      transaction.update(
        _firestore.collection('letterThreads').doc(threadId),
        {
          'isActive': false,
          'status': 'ghosted',
          'ghostedAt': Timestamp.now(),
          'ghosterId': ghosterId,
          'daysSinceLastMessage': daysSinceLastActivity,
        },
      );

      // Pénaliser le ghosteur
      final ghosterRef = _firestore.collection('users').doc(ghosterId);
      transaction.update(ghosterRef, {
        'coins': FieldValue.increment(-DEFAULT_GHOSTING_PENALTY),
        'reliabilityScore': FieldValue.increment(-daysSinceLastActivity * 2),
        'antiGhostingStats.totalStrikes': FieldValue.increment(1),
        'antiGhostingStats.ghostingCount': FieldValue.increment(1),
      });

      // Récompenser la victime
      final victimRef = _firestore.collection('users').doc(victimId);
      transaction.update(victimRef, {
        'coins': FieldValue.increment(DEFAULT_VICTIM_BONUS),
        'antiGhostingStats.victimCompensations': FieldValue.increment(1),
      });
    });
  }

  static List<String> getVisibilityPenalties(double reliabilityScore) {
    if (reliabilityScore < 500) {
      return ['RESTRICTED_VISIBILITY', 'LIMITED_MATCHES', 'WARNING_BADGE'];
    } else if (reliabilityScore < 800) {
      return ['REDUCED_VISIBILITY'];
    } else if (reliabilityScore > 1500) {
      return ['BOOSTED_VISIBILITY', 'PRIORITY_MATCHES', 'TRUSTED_BADGE'];
    }
    return [];
  }
}