import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

class StripeService {
  static StripeService? _instance;
  static StripeService get instance => _instance ??= StripeService._();
  
  StripeService._();
  
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  
  // Produits disponibles
  static const Map<String, Map<String, dynamic>> PRODUCTS = {
    'premium_1_month': {
      'name': 'JeuTaime Premium - 1 Mois',
      'description': 'Accès complet pendant 1 mois',
      'price': 9.99,
      'currency': 'EUR',
      'duration': 30,
      'features': [
        'Swipe illimité',
        'Super Likes gratuits',
        'Voir qui vous a liké',
        'Boost de profil',
        'Accès prioritaire aux bars',
        'Lettres premium',
      ],
    },
    'premium_3_months': {
      'name': 'JeuTaime Premium - 3 Mois',
      'description': 'Accès complet pendant 3 mois (-20%)',
      'price': 23.99,
      'currency': 'EUR',
      'duration': 90,
      'features': [
        'Tous les avantages Premium',
        'Badge exclusif',
        'Support prioritaire',
        'Statistiques avancées',
      ],
    },
    'premium_1_year': {
      'name': 'JeuTaime Premium - 1 An',
      'description': 'Accès complet pendant 1 an (-50%)',
      'price': 59.99,
      'currency': 'EUR',
      'duration': 365,
      'features': [
        'Tous les avantages Premium',
        'Badge VIP exclusif',
        'Accès beta aux nouvelles fonctionnalités',
        'Concierge personnel',
      ],
    },
    'coins_100': {
      'name': '100 Pièces d\'Or',
      'description': 'Petit boost de pièces',
      'price': 1.99,
      'currency': 'EUR',
      'coins': 100,
    },
    'coins_500': {
      'name': '500 Pièces d\'Or',
      'description': 'Boost de pièces populaire',
      'price': 8.99,
      'currency': 'EUR',
      'coins': 500,
    },
    'coins_1000': {
      'name': '1000 Pièces d\'Or',
      'description': 'Grand boost de pièces',
      'price': 15.99,
      'currency': 'EUR',
      'coins': 1000,
    },
    'verification_photo': {
      'name': 'Certification Photo Premium',
      'description': 'Certification rapide par expert',
      'price': 4.99,
      'currency': 'EUR',
      'service': 'photo_verification',
    },
  };
  
  // Créer une session de paiement
  Future<Map<String, dynamic>> createPaymentSession({
    required String userId,
    required String productId,
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      if (!PRODUCTS.containsKey(productId)) {
        return {'success': false, 'error': 'Produit inexistant'};
      }
      
      final product = PRODUCTS[productId]!;
      
      // Créer la session de paiement dans Firestore
      final sessionData = {
        'userId': userId,
        'productId': productId,
        'product': product,
        'status': 'pending',
        'amount': product['price'],
        'currency': product['currency'],
        'createdAt': FieldValue.serverTimestamp(),
        'successUrl': successUrl,
        'cancelUrl': cancelUrl,
        'metadata': {
          'user_id': userId,
          'product_id': productId,
        },
      };
      
      final sessionRef = await _firestore.collection('paymentSessions').add(sessionData);
      
      // En production, ici on appellerait l'API Stripe
      // Pour la démo, on simule une URL de paiement
      final checkoutUrl = _generateDemoCheckoutUrl(sessionRef.id, productId);
      
      return {
        'success': true,
        'sessionId': sessionRef.id,
        'checkoutUrl': checkoutUrl,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Générer une URL de démo pour le checkout
  String _generateDemoCheckoutUrl(String sessionId, String productId) {
    // En démo, on redirige vers une page de confirmation
    return 'https://jeutaime-demo.com/checkout?session_id=$sessionId&product=$productId';
  }
  
  // Traiter un paiement réussi
  Future<Map<String, dynamic>> processSuccessfulPayment(String sessionId) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final sessionRef = _firestore.collection('paymentSessions').doc(sessionId);
        final sessionDoc = await transaction.get(sessionRef);
        
        if (!sessionDoc.exists) {
          return {'success': false, 'error': 'Session introuvable'};
        }
        
        final sessionData = sessionDoc.data()!;
        
        if (sessionData['status'] != 'pending') {
          return {'success': false, 'error': 'Paiement déjà traité'};
        }
        
        final userId = sessionData['userId'] as String;
        final productId = sessionData['productId'] as String;
        final product = sessionData['product'] as Map<String, dynamic>;
        
        // Marquer le paiement comme réussi
        transaction.update(sessionRef, {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
        
        // Appliquer les avantages selon le produit
        await _applyProductBenefits(transaction, userId, productId, product);
        
        // Enregistrer la transaction
        transaction.set(_firestore.collection('transactions').doc(), {
          'userId': userId,
          'sessionId': sessionId,
          'productId': productId,
          'amount': product['price'],
          'currency': product['currency'],
          'type': 'purchase',
          'status': 'completed',
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        return {'success': true, 'message': 'Paiement traité avec succès'};
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Appliquer les avantages d'un produit
  Future<void> _applyProductBenefits(
    Transaction transaction,
    String userId,
    String productId,
    Map<String, dynamic> product,
  ) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    if (productId.startsWith('premium_')) {
      // Abonnement Premium
      final duration = product['duration'] as int;
      final expiresAt = DateTime.now().add(Duration(days: duration));
      
      transaction.update(userRef, {
        'isPremium': true,
        'premiumExpiresAt': expiresAt,
        'premiumPlan': productId,
        'premiumFeatures': product['features'],
      });
      
    } else if (productId.startsWith('coins_')) {
      // Achat de pièces
      final coins = product['coins'] as int;
      
      transaction.update(userRef, {
        'coins': FieldValue.increment(coins),
        'totalCoinsPurchased': FieldValue.increment(coins),
      });
      
    } else if (productId == 'verification_photo') {
      // Certification photo premium
      transaction.update(userRef, {
        'hasPremiumVerification': true,
        'premiumVerificationPurchasedAt': FieldValue.serverTimestamp(),
      });
    }
  }
  
  // Vérifier le statut Premium d'un utilisateur
  Future<Map<String, dynamic>> checkPremiumStatus(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return {'isPremium': false};
      }
      
      final userData = userDoc.data()!;
      final isPremium = userData['isPremium'] ?? false;
      
      if (!isPremium) {
        return {'isPremium': false};
      }
      
      final expiresAt = userData['premiumExpiresAt'] as Timestamp?;
      
      if (expiresAt == null) {
        return {'isPremium': false};
      }
      
      final now = DateTime.now();
      final expiry = expiresAt.toDate();
      
      if (now.isAfter(expiry)) {
        // Premium expiré, mettre à jour
        await _firestore.collection('users').doc(userId).update({
          'isPremium': false,
          'premiumExpiredAt': FieldValue.serverTimestamp(),
        });
        
        return {'isPremium': false, 'expired': true};
      }
      
      return {
        'isPremium': true,
        'plan': userData['premiumPlan'],
        'expiresAt': expiry,
        'features': userData['premiumFeatures'],
        'daysRemaining': expiry.difference(now).inDays,
      };
    } catch (e) {
      print('Erreur vérification premium: $e');
      return {'isPremium': false};
    }
  }
  
  // Obtenir l'historique des transactions d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    try {
      final transactions = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();
      
      return transactions.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Erreur historique transactions: $e');
      return [];
    }
  }
  
  // Traiter un remboursement
  Future<Map<String, dynamic>> processRefund(String transactionId, String reason) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final transactionRef = _firestore.collection('transactions').doc(transactionId);
        final transactionDoc = await transaction.get(transactionRef);
        
        if (!transactionDoc.exists) {
          return {'success': false, 'error': 'Transaction introuvable'};
        }
        
        final transactionData = transactionDoc.data()!;
        
        if (transactionData['status'] != 'completed') {
          return {'success': false, 'error': 'Transaction non remboursable'};
        }
        
        final userId = transactionData['userId'] as String;
        final productId = transactionData['productId'] as String;
        
        // Marquer comme remboursée
        transaction.update(transactionRef, {
          'status': 'refunded',
          'refundedAt': FieldValue.serverTimestamp(),
          'refundReason': reason,
        });
        
        // Retirer les avantages
        await _removeProductBenefits(transaction, userId, productId);
        
        return {'success': true, 'message': 'Remboursement traité'};
      });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Retirer les avantages d'un produit (pour remboursement)
  Future<void> _removeProductBenefits(
    Transaction transaction,
    String userId,
    String productId,
  ) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    if (productId.startsWith('premium_')) {
      transaction.update(userRef, {
        'isPremium': false,
        'premiumCancelledAt': FieldValue.serverTimestamp(),
        'premiumCancelReason': 'refund',
      });
    } else if (productId.startsWith('coins_')) {
      // Note: On ne retire pas les pièces déjà dépensées
      // Cela nécessiterait une logique plus complexe
    }
  }
  
  // Obtenir les statistiques de revenus (admin)
  Future<Map<String, dynamic>> getRevenueStats() async {
    try {
      final completedTransactions = await _firestore
          .collection('transactions')
          .where('status', isEqualTo: 'completed')
          .get();
      
      double totalRevenue = 0;
      Map<String, int> productSales = {};
      Map<String, double> monthlyRevenue = {};
      
      for (final doc in completedTransactions.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num).toDouble();
        final productId = data['productId'] as String;
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final monthKey = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}';
        
        totalRevenue += amount;
        productSales[productId] = (productSales[productId] ?? 0) + 1;
        monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + amount;
      }
      
      return {
        'totalRevenue': totalRevenue,
        'totalTransactions': completedTransactions.size,
        'productSales': productSales,
        'monthlyRevenue': monthlyRevenue,
        'averageTransactionValue': totalRevenue / completedTransactions.size,
      };
    } catch (e) {
      print('Erreur stats revenus: $e');
      return {};
    }
  }
  
  // Nettoyer les sessions expirées
  Future<void> cleanupExpiredSessions() async {
    try {
      final cutoffTime = DateTime.now().subtract(Duration(hours: 24));
      
      final expiredSessions = await _firestore
          .collection('paymentSessions')
          .where('status', isEqualTo: 'pending')
          .where('createdAt', isLessThan: cutoffTime)
          .get();
      
      for (final session in expiredSessions.docs) {
        await session.reference.update({
          'status': 'expired',
          'expiredAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Erreur nettoyage sessions: $e');
    }
  }
  
  // Créer un code promo
  Future<String?> createPromoCode({
    required String code,
    required double discountPercent,
    required DateTime expiresAt,
    int? maxUses,
    List<String>? applicableProducts,
  }) async {
    try {
      final promoData = {
        'code': code.toUpperCase(),
        'discountPercent': discountPercent,
        'expiresAt': expiresAt,
        'maxUses': maxUses,
        'currentUses': 0,
        'applicableProducts': applicableProducts,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      final docRef = await _firestore.collection('promoCodes').add(promoData);
      return docRef.id;
    } catch (e) {
      print('Erreur création code promo: $e');
      return null;
    }
  }
  
  // Appliquer un code promo
  Future<Map<String, dynamic>> applyPromoCode(String code, String productId) async {
    try {
      final promoQuery = await _firestore
          .collection('promoCodes')
          .where('code', isEqualTo: code.toUpperCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (promoQuery.docs.isEmpty) {
        return {'success': false, 'error': 'Code promo invalide'};
      }
      
      final promoDoc = promoQuery.docs.first;
      final promoData = promoDoc.data();
      
      // Vérifier l'expiration
      final expiresAt = (promoData['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        return {'success': false, 'error': 'Code promo expiré'};
      }
      
      // Vérifier le nombre d'utilisations
      final maxUses = promoData['maxUses'] as int?;
      final currentUses = promoData['currentUses'] as int;
      
      if (maxUses != null && currentUses >= maxUses) {
        return {'success': false, 'error': 'Code promo épuisé'};
      }
      
      // Vérifier l'applicabilité au produit
      final applicableProducts = promoData['applicableProducts'] as List<String>?;
      if (applicableProducts != null && !applicableProducts.contains(productId)) {
        return {'success': false, 'error': 'Code promo non applicable à ce produit'};
      }
      
      final originalPrice = PRODUCTS[productId]!['price'] as double;
      final discountPercent = promoData['discountPercent'] as double;
      final discountAmount = originalPrice * (discountPercent / 100);
      final finalPrice = originalPrice - discountAmount;
      
      return {
        'success': true,
        'originalPrice': originalPrice,
        'discountPercent': discountPercent,
        'discountAmount': discountAmount,
        'finalPrice': finalPrice,
        'promoId': promoDoc.id,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}