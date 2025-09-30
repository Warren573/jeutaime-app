import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_service.dart';

class PhotoVerificationService {
  static PhotoVerificationService? _instance;
  static PhotoVerificationService get instance => _instance ??= PhotoVerificationService._();
  
  PhotoVerificationService._();
  
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  final FirebaseStorage _storage = FirebaseService.instance.storage;
  
  static const int VERIFICATION_COST = 25; // Coût en pièces
  static const int PREMIUM_VERIFICATION_PRIORITY = 1; // Priorité haute
  static const int STANDARD_VERIFICATION_PRIORITY = 3; // Priorité normale
  
  // Soumettre une photo pour vérification
  Future<Map<String, dynamic>> submitPhotoForVerification({
    required String userId,
    required File photoFile,
    bool isPremium = false,
  }) async {
    try {
      // Vérifier si l'utilisateur a déjà une vérification en cours
      final existingVerification = await _firestore
          .collection('photoVerifications')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['pending', 'reviewing'])
          .get();
      
      if (existingVerification.docs.isNotEmpty) {
        return {'success': false, 'error': 'Vérification déjà en cours'};
      }
      
      // Upload de l'image vers Firebase Storage
      final fileName = 'verification_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('verifications/$fileName');
      
      final uploadTask = await storageRef.putFile(photoFile);
      final photoUrl = await uploadTask.ref.getDownloadURL();
      
      // Créer la demande de vérification
      final verificationData = {
        'userId': userId,
        'photoUrl': photoUrl,
        'fileName': fileName,
        'status': 'pending', // pending, reviewing, approved, rejected
        'isPremium': isPremium,
        'priority': isPremium ? PREMIUM_VERIFICATION_PRIORITY : STANDARD_VERIFICATION_PRIORITY,
        'submittedAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
        'reviewedBy': null,
        'rejectionReason': null,
        'verificationScore': null,
        'metadata': {
          'fileSize': await photoFile.length(),
          'userAgent': 'mobile_app',
        },
      };
      
      final docRef = await _firestore.collection('photoVerifications').add(verificationData);
      
      // Déduire les pièces si nécessaire (sauf si Premium)
      if (!isPremium) {
        await _deductVerificationCost(userId);
      }
      
      // Ajouter à la queue de vérification
      await _addToVerificationQueue(docRef.id, isPremium);
      
      return {
        'success': true,
        'verificationId': docRef.id,
        'estimatedWaitTime': isPremium ? '2-6 heures' : '24-48 heures',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Déduire le coût de vérification
  Future<void> _deductVerificationCost(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'coins': FieldValue.increment(-VERIFICATION_COST),
        'totalCoinsSpent': FieldValue.increment(VERIFICATION_COST),
      });
    } catch (e) {
      print('Erreur déduction coût vérification: $e');
    }
  }
  
  // Ajouter à la queue de vérification
  Future<void> _addToVerificationQueue(String verificationId, bool isPremium) async {
    try {
      final queueData = {
        'verificationId': verificationId,
        'priority': isPremium ? PREMIUM_VERIFICATION_PRIORITY : STANDARD_VERIFICATION_PRIORITY,
        'addedAt': FieldValue.serverTimestamp(),
        'status': 'queued',
      };
      
      await _firestore.collection('verificationQueue').add(queueData);
    } catch (e) {
      print('Erreur ajout queue: $e');
    }
  }
  
  // Obtenir les vérifications en attente (pour les modérateurs)
  Stream<QuerySnapshot> getPendingVerifications() {
    return _firestore
        .collection('photoVerifications')
        .where('status', whereIn: ['pending', 'reviewing'])
        .orderBy('priority')
        .orderBy('submittedAt')
        .snapshots();
  }
  
  // Commencer la révision d'une photo (modérateur)
  Future<Map<String, dynamic>> startReview(String verificationId, String moderatorId) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final verificationRef = _firestore.collection('photoVerifications').doc(verificationId);
        final verificationDoc = await transaction.get(verificationRef);
        
        if (!verificationDoc.exists) {
          return {'success': false, 'error': 'Vérification introuvable'};
        }
        
        final data = verificationDoc.data()!;
        
        if (data['status'] != 'pending') {
          return {'success': false, 'error': 'Vérification déjà en cours ou terminée'};
        }
        
        transaction.update(verificationRef, {
          'status': 'reviewing',
          'reviewStartedAt': FieldValue.serverTimestamp(),
          'reviewedBy': moderatorId,
        });
        
        return {'success': true, 'photoUrl': data['photoUrl']};
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Approuver une vérification photo
  Future<Map<String, dynamic>> approveVerification({
    required String verificationId,
    required String moderatorId,
    required int verificationScore, // 1-100
    String? notes,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final verificationRef = _firestore.collection('photoVerifications').doc(verificationId);
        final verificationDoc = await transaction.get(verificationRef);
        
        if (!verificationDoc.exists) {
          return {'success': false, 'error': 'Vérification introuvable'};
        }
        
        final verificationData = verificationDoc.data()!;
        final userId = verificationData['userId'] as String;
        
        // Mettre à jour la vérification
        transaction.update(verificationRef, {
          'status': 'approved',
          'reviewedAt': FieldValue.serverTimestamp(),
          'reviewedBy': moderatorId,
          'verificationScore': verificationScore,
          'moderatorNotes': notes,
        });
        
        // Mettre à jour le profil utilisateur
        final userRef = _firestore.collection('users').doc(userId);
        transaction.update(userRef, {
          'isPhotoVerified': true,
          'photoVerifiedAt': FieldValue.serverTimestamp(),
          'verificationScore': verificationScore,
          'profileBadges': FieldValue.arrayUnion(['verified_photo']),
        });
        
        // Récompenser l'utilisateur
        transaction.update(userRef, {
          'coins': FieldValue.increment(50), // Bonus de vérification
          'achievements': FieldValue.arrayUnion(['photo_verified']),
        });
        
        // Retirer de la queue
        await _removeFromQueue(verificationId);
        
        return {'success': true, 'message': 'Photo approuvée avec succès'};
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Rejeter une vérification photo
  Future<Map<String, dynamic>> rejectVerification({
    required String verificationId,
    required String moderatorId,
    required String reason,
    String? detailedFeedback,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final verificationRef = _firestore.collection('photoVerifications').doc(verificationId);
        final verificationDoc = await transaction.get(verificationRef);
        
        if (!verificationDoc.exists) {
          return {'success': false, 'error': 'Vérification introuvable'};
        }
        
        final verificationData = verificationDoc.data()!;
        final userId = verificationData['userId'] as String;
        final isPremium = verificationData['isPremium'] as bool;
        
        // Mettre à jour la vérification
        transaction.update(verificationRef, {
          'status': 'rejected',
          'reviewedAt': FieldValue.serverTimestamp(),
          'reviewedBy': moderatorId,
          'rejectionReason': reason,
          'detailedFeedback': detailedFeedback,
        });
        
        // Rembourser les pièces si c'était payant
        if (!isPremium) {
          final userRef = _firestore.collection('users').doc(userId);
          transaction.update(userRef, {
            'coins': FieldValue.increment(VERIFICATION_COST), // Remboursement
          });
        }
        
        // Retirer de la queue
        await _removeFromQueue(verificationId);
        
        return {'success': true, 'message': 'Photo rejetée', 'reason': reason};
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Retirer de la queue de vérification
  Future<void> _removeFromQueue(String verificationId) async {
    try {
      final queueItems = await _firestore
          .collection('verificationQueue')
          .where('verificationId', isEqualTo: verificationId)
          .get();
      
      for (final item in queueItems.docs) {
        await item.reference.delete();
      }
    } catch (e) {
      print('Erreur suppression queue: $e');
    }
  }
  
  // Obtenir le statut de vérification d'un utilisateur
  Future<Map<String, dynamic>> getVerificationStatus(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return {'isVerified': false, 'hasOngoingVerification': false};
      }
      
      final userData = userDoc.data()!;
      final isVerified = userData['isPhotoVerified'] ?? false;
      
      // Vérifier s'il y a une vérification en cours
      final ongoingVerification = await _firestore
          .collection('photoVerifications')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['pending', 'reviewing'])
          .orderBy('submittedAt', descending: true)
          .limit(1)
          .get();
      
      Map<String, dynamic> result = {
        'isVerified': isVerified,
        'hasOngoingVerification': ongoingVerification.docs.isNotEmpty,
      };
      
      if (isVerified) {
        result['verifiedAt'] = userData['photoVerifiedAt'];
        result['verificationScore'] = userData['verificationScore'];
      }
      
      if (ongoingVerification.docs.isNotEmpty) {
        final verificationData = ongoingVerification.docs.first.data();
        result['ongoingStatus'] = verificationData['status'];
        result['submittedAt'] = verificationData['submittedAt'];
        result['isPremium'] = verificationData['isPremium'];
      }
      
      return result;
    } catch (e) {
      print('Erreur statut vérification: $e');
      return {'isVerified': false, 'hasOngoingVerification': false};
    }
  }
  
  // Obtenir l'historique des vérifications d'un utilisateur
  Future<List<Map<String, dynamic>>> getVerificationHistory(String userId) async {
    try {
      final verifications = await _firestore
          .collection('photoVerifications')
          .where('userId', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .get();
      
      return verifications.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Erreur historique vérifications: $e');
      return [];
    }
  }
  
  // Statistiques de vérification (pour admin)
  Future<Map<String, dynamic>> getVerificationStats() async {
    try {
      final allVerifications = await _firestore.collection('photoVerifications').get();
      
      Map<String, int> statusCount = {};
      int premiumCount = 0;
      double averageScore = 0;
      int scoredVerifications = 0;
      
      for (final doc in allVerifications.docs) {
        final data = doc.data();
        final status = data['status'] as String;
        statusCount[status] = (statusCount[status] ?? 0) + 1;
        
        if (data['isPremium'] == true) {
          premiumCount++;
        }
        
        final score = data['verificationScore'] as int?;
        if (score != null) {
          averageScore += score;
          scoredVerifications++;
        }
      }
      
      if (scoredVerifications > 0) {
        averageScore = averageScore / scoredVerifications;
      }
      
      return {
        'totalVerifications': allVerifications.size,
        'statusBreakdown': statusCount,
        'premiumVerifications': premiumCount,
        'averageScore': averageScore.round(),
        'approvalRate': statusCount['approved'] != null 
            ? (statusCount['approved']! / allVerifications.size * 100).round()
            : 0,
      };
    } catch (e) {
      print('Erreur stats vérification: $e');
      return {};
    }
  }
  
  // Nettoyer les anciennes images de vérification
  Future<void> cleanupOldVerificationImages() async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: 90));
      
      final oldVerifications = await _firestore
          .collection('photoVerifications')
          .where('status', whereIn: ['approved', 'rejected'])
          .where('reviewedAt', isLessThan: cutoffDate)
          .get();
      
      for (final verification in oldVerifications.docs) {
        final data = verification.data();
        final fileName = data['fileName'] as String;
        
        try {
          // Supprimer l'image du storage
          await _storage.ref().child('verifications/$fileName').delete();
          
          // Mettre à jour le document pour indiquer que l'image est supprimée
          await verification.reference.update({
            'imageDeleted': true,
            'imageDeletedAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('Erreur suppression image $fileName: $e');
        }
      }
    } catch (e) {
      print('Erreur nettoyage images: $e');
    }
  }
  
  // Générer un rapport de modération
  Future<Map<String, dynamic>> generateModerationReport(String moderatorId) async {
    try {
      final verifications = await _firestore
          .collection('photoVerifications')
          .where('reviewedBy', isEqualTo: moderatorId)
          .get();
      
      int approved = 0;
      int rejected = 0;
      double totalReviewTime = 0;
      int timedReviews = 0;
      
      for (final doc in verifications.docs) {
        final data = doc.data();
        final status = data['status'] as String;
        
        if (status == 'approved') approved++;
        if (status == 'rejected') rejected++;
        
        final reviewStarted = data['reviewStartedAt'] as Timestamp?;
        final reviewEnded = data['reviewedAt'] as Timestamp?;
        
        if (reviewStarted != null && reviewEnded != null) {
          final reviewTime = reviewEnded.toDate().difference(reviewStarted.toDate());
          totalReviewTime += reviewTime.inMinutes;
          timedReviews++;
        }
      }
      
      return {
        'moderatorId': moderatorId,
        'totalReviews': verifications.size,
        'approved': approved,
        'rejected': rejected,
        'approvalRate': verifications.size > 0 
            ? (approved / verifications.size * 100).round()
            : 0,
        'averageReviewTime': timedReviews > 0 
            ? (totalReviewTime / timedReviews).round()
            : 0,
      };
    } catch (e) {
      print('Erreur rapport modération: $e');
      return {};
    }
  }
}