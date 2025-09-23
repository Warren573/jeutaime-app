import 'package:cloud_firestore/cloud_firestore.dart';

const int ghostingThresholdHours = 72; // 3 jours
const int ghostingPenalty = 50; // Pièces perdues
const int victimBonus = 25; // Pièces gagnées par la victime
const int activeUserBonus = 10; // Bonus pour utilisateur actif

class AntiGhostingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> checkForGhosting() async {
    try {
      final cutoffTime = DateTime.now().subtract(Duration(hours: ghostingThresholdHours));
      
      // Récupérer les threads actifs avec dernière activité trop ancienne
      final staleThreads = await _firestore
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
        'coins': FieldValue.increment(-ghostingPenalty),
        'reliabilityScore': FieldValue.increment(-daysSinceLastActivity * 2),
        'stats.ghostingCount': FieldValue.increment(1),
      });

      // Récompenser la victime
      final victimRef = _firestore.collection('users').doc(victimId);
      transaction.update(victimRef, {
        'coins': FieldValue.increment(victimBonus),
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
}
