import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class ReferralService {
  static ReferralService? _instance;
  static ReferralService get instance => _instance ??= ReferralService._();
  
  ReferralService._();
  
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  
  // Récompenses du système de parrainage
  static const int REFERRER_REWARD = 100; // Pièces pour celui qui parraine
  static const int REFEREE_REWARD = 50; // Pièces pour le nouveau utilisateur
  static const int MILESTONE_REWARDS = 200; // Bonus par palier (5, 10, 25 parrainages)
  static const List<int> MILESTONES = [5, 10, 25, 50, 100];
  
  // Générer un code de parrainage unique
  Future<String?> generateReferralCode(String userId) async {
    try {
      // Vérifier si l'utilisateur a déjà un code
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final existingCode = userData['referralCode'] as String?;
        
        if (existingCode != null) {
          return existingCode;
        }
      }
      
      // Générer un nouveau code unique
      String code;
      bool isUnique = false;
      int attempts = 0;
      
      do {
        code = _generateUniqueCode();
        
        // Vérifier l'unicité
        final existingCode = await _firestore
            .collection('users')
            .where('referralCode', isEqualTo: code)
            .limit(1)
            .get();
        
        isUnique = existingCode.docs.isEmpty;
        attempts++;
        
        if (attempts > 10) {
          throw Exception('Impossible de générer un code unique');
        }
      } while (!isUnique);
      
      // Sauvegarder le code
      await _firestore.collection('users').doc(userId).update({
        'referralCode': code,
        'referralStats': {
          'totalReferrals': 0,
          'successfulReferrals': 0,
          'totalRewardsEarned': 0,
          'createdAt': FieldValue.serverTimestamp(),
        },
      });
      
      return code;
    } catch (e) {
      print('Erreur génération code parrainage: $e');
      return null;
    }
  }
  
  // Générer un code aléatoire
  String _generateUniqueCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }
  
  // Utiliser un code de parrainage lors de l'inscription
  Future<Map<String, dynamic>> useReferralCode(String newUserId, String referralCode) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // Trouver le parrain
        final referrerQuery = await _firestore
            .collection('users')
            .where('referralCode', isEqualTo: referralCode.toUpperCase())
            .limit(1)
            .get();
        
        if (referrerQuery.docs.isEmpty) {
          return {'success': false, 'error': 'Code de parrainage invalide'};
        }
        
        final referrerDoc = referrerQuery.docs.first;
        final referrerId = referrerDoc.id;
        
        // Vérifier que l'utilisateur ne se parraine pas lui-même
        if (referrerId == newUserId) {
          return {'success': false, 'error': 'Vous ne pouvez pas utiliser votre propre code'};
        }
        
        // Vérifier si le nouveau utilisateur a déjà utilisé un code
        final newUserRef = _firestore.collection('users').doc(newUserId);
        final newUserDoc = await transaction.get(newUserRef);
        
        if (newUserDoc.exists) {
          final userData = newUserDoc.data()!;
          if (userData['referredBy'] != null) {
            return {'success': false, 'error': 'Vous avez déjà utilisé un code de parrainage'};
          }
        }
        
        // Mettre à jour le nouveau utilisateur
        transaction.update(newUserRef, {
          'referredBy': referrerId,
          'referralCodeUsed': referralCode,
          'referredAt': FieldValue.serverTimestamp(),
          'coins': FieldValue.increment(REFEREE_REWARD),
          'referralRewards': {
            'signupBonus': REFEREE_REWARD,
            'totalEarned': REFEREE_REWARD,
          },
        });
        
        // Mettre à jour le parrain
        final referrerRef = _firestore.collection('users').doc(referrerId);
        final referrerData = referrerDoc.data();
        final currentStats = referrerData['referralStats'] as Map<String, dynamic>? ?? {};
        final currentTotalReferrals = currentStats['totalReferrals'] ?? 0;
        final newTotalReferrals = currentTotalReferrals + 1;
        
        transaction.update(referrerRef, {
          'coins': FieldValue.increment(REFERRER_REWARD),
          'referralStats.totalReferrals': newTotalReferrals,
          'referralStats.successfulReferrals': FieldValue.increment(1),
          'referralStats.totalRewardsEarned': FieldValue.increment(REFERRER_REWARD),
          'referralStats.lastReferralAt': FieldValue.serverTimestamp(),
        });
        
        // Créer l'enregistrement de parrainage
        transaction.set(_firestore.collection('referrals').doc(), {
          'referrerId': referrerId,
          'refereeId': newUserId,
          'referralCode': referralCode,
          'timestamp': FieldValue.serverTimestamp(),
          'referrerReward': REFERRER_REWARD,
          'refereeReward': REFEREE_REWARD,
          'status': 'active',
        });
        
        // Vérifier les paliers de récompense
        final milestoneReward = _checkMilestoneReward(newTotalReferrals);
        if (milestoneReward > 0) {
          transaction.update(referrerRef, {
            'coins': FieldValue.increment(milestoneReward),
            'referralStats.milestoneRewards': FieldValue.increment(milestoneReward),
            'achievements': FieldValue.arrayUnion(['referral_milestone_$newTotalReferrals']),
          });
        }
        
        return {
          'success': true,
          'referrerReward': REFERRER_REWARD,
          'refereeReward': REFEREE_REWARD,
          'milestoneReward': milestoneReward,
          'totalReferrals': newTotalReferrals,
        };
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Vérifier les récompenses de palier
  int _checkMilestoneReward(int totalReferrals) {
    if (MILESTONES.contains(totalReferrals)) {
      return MILESTONE_REWARDS * (MILESTONES.indexOf(totalReferrals) + 1);
    }
    return 0;
  }
  
  // Obtenir les statistiques de parrainage d'un utilisateur
  Future<Map<String, dynamic>> getReferralStats(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return {};
      }
      
      final userData = userDoc.data()!;
      final referralCode = userData['referralCode'] as String?;
      final referralStats = userData['referralStats'] as Map<String, dynamic>? ?? {};
      
      // Obtenir la liste des parrainés
      final referrals = await _firestore
          .collection('referrals')
          .where('referrerId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      
      // Calculer les statistiques détaillées
      Map<String, int> monthlyReferrals = {};
      int activeReferrals = 0;
      
      for (final referral in referrals.docs) {
        final data = referral.data();
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final monthKey = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}';
        
        monthlyReferrals[monthKey] = (monthlyReferrals[monthKey] ?? 0) + 1;
        
        if (data['status'] == 'active') {
          activeReferrals++;
        }
      }
      
      // Calculer le prochain palier
      final currentTotal = referralStats['totalReferrals'] ?? 0;
      final nextMilestone = MILESTONES.firstWhere(
        (milestone) => milestone > currentTotal,
        orElse: () => -1,
      );
      
      return {
        'referralCode': referralCode,
        'totalReferrals': currentTotal,
        'successfulReferrals': referralStats['successfulReferrals'] ?? 0,
        'totalRewardsEarned': referralStats['totalRewardsEarned'] ?? 0,
        'activeReferrals': activeReferrals,
        'monthlyBreakdown': monthlyReferrals,
        'nextMilestone': nextMilestone > 0 ? nextMilestone : null,
        'referralsUntilNextMilestone': nextMilestone > 0 ? nextMilestone - currentTotal : 0,
        'referrals': referrals.docs.map((doc) => doc.data()).toList(),
      };
    } catch (e) {
      print('Erreur stats parrainage: $e');
      return {};
    }
  }
  
  // Obtenir le classement des parrains
  Future<List<Map<String, dynamic>>> getTopReferrers({int limit = 10}) async {
    try {
      final users = await _firestore
          .collection('users')
          .where('referralStats.totalReferrals', isGreaterThan: 0)
          .orderBy('referralStats.totalReferrals', descending: true)
          .limit(limit)
          .get();
      
      List<Map<String, dynamic>> leaderboard = [];
      
      for (int i = 0; i < users.docs.length; i++) {
        final doc = users.docs[i];
        final data = doc.data();
        final stats = data['referralStats'] as Map<String, dynamic>;
        
        leaderboard.add({
          'rank': i + 1,
          'userId': doc.id,
          'username': data['username'] ?? 'Utilisateur ${doc.id.substring(0, 6)}',
          'totalReferrals': stats['totalReferrals'],
          'totalRewardsEarned': stats['totalRewardsEarned'],
          'referralCode': data['referralCode'],
        });
      }
      
      return leaderboard;
    } catch (e) {
      print('Erreur classement parrains: $e');
      return [];
    }
  }
  
  // Créer une campagne de parrainage spéciale
  Future<String?> createReferralCampaign({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required int bonusMultiplier, // Multiplicateur des récompenses
    List<String>? targetUserSegments,
  }) async {
    try {
      final campaignData = {
        'name': name,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
        'bonusMultiplier': bonusMultiplier,
        'targetUserSegments': targetUserSegments,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'stats': {
          'totalReferrals': 0,
          'totalRewardsDistributed': 0,
          'participatingUsers': 0,
        },
      };
      
      final docRef = await _firestore.collection('referralCampaigns').add(campaignData);
      return docRef.id;
    } catch (e) {
      print('Erreur création campagne: $e');
      return null;
    }
  }
  
  // Participer à une campagne de parrainage
  Future<Map<String, dynamic>> joinReferralCampaign(String userId, String campaignId) async {
    try {
      final campaignDoc = await _firestore.collection('referralCampaigns').doc(campaignId).get();
      
      if (!campaignDoc.exists) {
        return {'success': false, 'error': 'Campagne introuvable'};
      }
      
      final campaignData = campaignDoc.data()!;
      final now = DateTime.now();
      final startDate = (campaignData['startDate'] as Timestamp).toDate();
      final endDate = (campaignData['endDate'] as Timestamp).toDate();
      
      if (now.isBefore(startDate)) {
        return {'success': false, 'error': 'La campagne n\'a pas encore commencé'};
      }
      
      if (now.isAfter(endDate)) {
        return {'success': false, 'error': 'La campagne est terminée'};
      }
      
      // Ajouter l'utilisateur à la campagne
      await _firestore.collection('users').doc(userId).update({
        'activeCampaigns': FieldValue.arrayUnion([campaignId]),
      });
      
      await _firestore.collection('referralCampaigns').doc(campaignId).update({
        'stats.participatingUsers': FieldValue.increment(1),
      });
      
      return {
        'success': true,
        'campaign': campaignData,
        'bonusMultiplier': campaignData['bonusMultiplier'],
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Valider un parrainage (vérifier que le nouveau utilisateur est actif)
  Future<void> validateReferral(String referralId) async {
    try {
      final referralDoc = await _firestore.collection('referrals').doc(referralId).get();
      
      if (!referralDoc.exists) return;
      
      final referralData = referralDoc.data()!;
      final refereeId = referralData['refereeId'] as String;
      
      // Vérifier l'activité du nouveau utilisateur (par exemple, 7 jours actifs)
      final refereeDoc = await _firestore.collection('users').doc(refereeId).get();
      
      if (!refereeDoc.exists) return;
      
      final refereeData = refereeDoc.data()!;
      final referredAt = (referralData['timestamp'] as Timestamp).toDate();
      final daysSinceReferral = DateTime.now().difference(referredAt).inDays;
      
      // Si l'utilisateur est actif depuis 7 jours, valider le parrainage
      if (daysSinceReferral >= 7) {
        final lastActive = refereeData['lastActiveAt'] as Timestamp?;
        
        if (lastActive != null) {
          final daysSinceActive = DateTime.now().difference(lastActive.toDate()).inDays;
          
          if (daysSinceActive <= 3) { // Actif dans les 3 derniers jours
            await _firestore.collection('referrals').doc(referralId).update({
              'status': 'validated',
              'validatedAt': FieldValue.serverTimestamp(),
            });
            
            // Bonus de validation pour le parrain
            final referrerId = referralData['referrerId'] as String;
            await _firestore.collection('users').doc(referrerId).update({
              'coins': FieldValue.increment(25), // Bonus de validation
              'referralStats.validatedReferrals': FieldValue.increment(1),
            });
          }
        }
      }
    } catch (e) {
      print('Erreur validation parrainage: $e');
    }
  }
  
  // Obtenir les statistiques globales de parrainage
  Future<Map<String, dynamic>> getGlobalReferralStats() async {
    try {
      final referrals = await _firestore.collection('referrals').get();
      final campaigns = await _firestore.collection('referralCampaigns').get();
      
      int totalReferrals = referrals.size;
      int activeReferrals = 0;
      int validatedReferrals = 0;
      double totalRewardsDistributed = 0;
      
      Map<String, int> monthlyReferrals = {};
      
      for (final referral in referrals.docs) {
        final data = referral.data();
        final status = data['status'] as String;
        
        if (status == 'active') activeReferrals++;
        if (status == 'validated') validatedReferrals++;
        
        totalRewardsDistributed += (data['referrerReward'] as int).toDouble();
        totalRewardsDistributed += (data['refereeReward'] as int).toDouble();
        
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final monthKey = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}';
        monthlyReferrals[monthKey] = (monthlyReferrals[monthKey] ?? 0) + 1;
      }
      
      return {
        'totalReferrals': totalReferrals,
        'activeReferrals': activeReferrals,
        'validatedReferrals': validatedReferrals,
        'totalRewardsDistributed': totalRewardsDistributed,
        'validationRate': totalReferrals > 0 ? (validatedReferrals / totalReferrals * 100).round() : 0,
        'monthlyBreakdown': monthlyReferrals,
        'activeCampaigns': campaigns.docs.where((doc) => doc.data()['isActive'] == true).length,
        'averageReferralsPerUser': totalReferrals > 0 ? (totalReferrals / _getUniqueReferrersCount(referrals.docs)).round() : 0,
      };
    } catch (e) {
      print('Erreur stats globales parrainage: $e');
      return {};
    }
  }
  
  // Compter les parrains uniques
  int _getUniqueReferrersCount(List<QueryDocumentSnapshot> referrals) {
    Set<String> uniqueReferrers = {};
    for (final referral in referrals) {
      final data = referral.data() as Map<String, dynamic>;
      uniqueReferrers.add(data['referrerId'] as String);
    }
    return uniqueReferrers.length;
  }
  
  // Récompenser les parrains les plus actifs
  Future<void> rewardTopReferrers() async {
    try {
      final topReferrers = await getTopReferrers(limit: 5);
      
      for (int i = 0; i < topReferrers.length; i++) {
        final referrer = topReferrers[i];
        final userId = referrer['userId'] as String;
        final rank = referrer['rank'] as int;
        
        int bonus = 0;
        String achievement = '';
        
        switch (rank) {
          case 1:
            bonus = 500;
            achievement = 'top_referrer_gold';
            break;
          case 2:
            bonus = 250;
            achievement = 'top_referrer_silver';
            break;
          case 3:
            bonus = 100;
            achievement = 'top_referrer_bronze';
            break;
          default:
            bonus = 50;
            achievement = 'top_referrer_honor';
        }
        
        await _firestore.collection('users').doc(userId).update({
          'coins': FieldValue.increment(bonus),
          'achievements': FieldValue.arrayUnion([achievement]),
          'referralStats.monthlyBonus': bonus,
        });
      }
    } catch (e) {
      print('Erreur récompense top parrains: $e');
    }
  }
}