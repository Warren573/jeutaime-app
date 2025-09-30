import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'coin_service.dart';

class AntiGhostingService {
  static AntiGhostingService? _instance;
  static AntiGhostingService get instance => _instance ??= AntiGhostingService._();
  
  AntiGhostingService._();
  
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  
  // Constantes du système anti-ghosting
  static const int WARNING_THRESHOLD_HOURS = 24; // 24h pour répondre
  static const int STRIKE_THRESHOLD_HOURS = 48; // 48h = strike
  static const int BAN_THRESHOLD_STRIKES = 3; // 3 strikes = ban
  static const int STRIKE_EXPIRY_DAYS = 30; // Les strikes expirent après 30 jours
  static const int REWARD_COINS = 50; // Récompense pour les victimes
  static const int PENALTY_COINS = 30; // Pénalité pour les ghosteurs

  static Future<void> checkForGhosting() async {
    try {
      const ghostingThresholdHours = 48;
      final cutoffTime = DateTime.now().subtract(const Duration(hours: ghostingThresholdHours));
      
      // Récupérer les threads actifs avec dernière activité trop ancienne
      final firestore = FirebaseService.instance.firestore;
      final staleThreads = await firestore
          .collection('letterThreads')
          .where('isActive', isEqualTo: true)
          .where('lastActivity', isLessThan: Timestamp.fromDate(cutoffTime))
          .get();

      for (final threadDoc in staleThreads.docs) {
        final threadData = threadDoc.data();
        final currentTurn = threadData['currentTurn'] as String?;
        final participants = List<String>.from(threadData['participants'] ?? []);
        final lastActivity = (threadData['lastActivity'] as Timestamp).toDate();

        if (currentTurn != null && participants.length == 2) {
          await _processGhosting(
            threadId: threadDoc.id,
            ghosterId: currentTurn,
            victimId: participants.firstWhere((id) => id != currentTurn),
            lastActivity: lastActivity,
          );
        }
      }
    } catch (e) {
      print('Erreur vérification ghosting: $e');
    }
  }

  static Future<void> _processGhosting({
    required String threadId,
    required String ghosterId,
    required String victimId,
    required DateTime lastActivity,
  }) async {
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
                'coins': FieldValue.increment(-PENALTY_COINS),
        'reliabilityScore': FieldValue.increment(-daysSinceLastActivity * 2),
        'stats.ghostingCount': FieldValue.increment(1),
      });

      // Récompenser la victime
      final victimRef = _firestore.collection('users').doc(victimId);
      transaction.update(victimRef, {
                'coins': FieldValue.increment(REWARD_COINS),
        'reliabilityScore': FieldValue.increment(5),
        'stats.victimCount': FieldValue.increment(1),
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

  // Obtenir les statistiques d'un utilisateur
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final _firestore = FirebaseService.instance.firestore;
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
}
