import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class CoinService {
  static CoinService? _instance;
  static CoinService get instance => _instance ??= CoinService._();
  
  CoinService._();
  
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  
  // Gains de pièces selon votre vision
  static const int DAILY_BONUS = 50;
  static const int SMILE_RECEIVED = 25;
  static const int CHALLENGE_COMPLETED = 100;
  static const int REFERRAL_BONUS_SPONSOR = 500;
  static const int REFERRAL_BONUS_REFERRED = 200;
  
  // Coûts selon votre vision
  static const int SMILE_COST = 25;
  static const int LETTER_COST = 30;
  static const int GIFT_COST = 50;
  
  // Récupérer les pièces de l'utilisateur
  Future<int> getUserCoins(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['coins'] ?? 0;
    } catch (e) {
      print('Erreur récupération pièces: $e');
      return 0;
    }
  }
  
  // Ajouter des pièces
  Future<bool> addCoins(String userId, int amount, String reason) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          throw Exception('Utilisateur non trouvé');
        }
        
        final currentCoins = userDoc.data()?['coins'] ?? 0;
        final newCoins = currentCoins + amount;
        
        transaction.update(userRef, {'coins': newCoins});
        
        // Enregistrer la transaction
        transaction.set(_firestore.collection('coinTransactions').doc(), {
          'userId': userId,
          'amount': amount,
          'type': 'gain',
          'reason': reason,
          'timestamp': FieldValue.serverTimestamp(),
          'balanceAfter': newCoins,
        });
      });
      
      return true;
    } catch (e) {
      print('Erreur ajout pièces: $e');
      return false;
    }
  }
  
  // Dépenser des pièces
  Future<bool> spendCoins(String userId, int amount, String reason) async {
    try {
      bool success = false;
      
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          throw Exception('Utilisateur non trouvé');
        }
        
        final currentCoins = userDoc.data()?['coins'] ?? 0;
        
        if (currentCoins < amount) {
          success = false;
          return;
        }
        
        final newCoins = currentCoins - amount;
        transaction.update(userRef, {'coins': newCoins});
        
        // Enregistrer la transaction
        transaction.set(_firestore.collection('coinTransactions').doc(), {
          'userId': userId,
          'amount': -amount,
          'type': 'depense',
          'reason': reason,
          'timestamp': FieldValue.serverTimestamp(),
          'balanceAfter': newCoins,
        });
        
        success = true;
      });
      
      return success;
    } catch (e) {
      print('Erreur dépense pièces: $e');
      return false;
    }
  }
  
  // Bonus quotidien
  Future<bool> claimDailyBonus(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final lastBonus = userDoc.data()?['lastDailyBonus'] as Timestamp?;
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      if (lastBonus != null) {
        final lastBonusDate = lastBonus.toDate();
        final lastBonusDay = DateTime(lastBonusDate.year, lastBonusDate.month, lastBonusDate.day);
        
        if (lastBonusDay.isAtSameMomentAs(today)) {
          return false; // Déjà réclamé aujourd'hui
        }
      }
      
      // Donner le bonus
      final success = await addCoins(userId, DAILY_BONUS, 'Bonus quotidien');
      
      if (success) {
        await _firestore.collection('users').doc(userId).update({
          'lastDailyBonus': FieldValue.serverTimestamp(),
        });
      }
      
      return success;
    } catch (e) {
      print('Erreur bonus quotidien: $e');
      return false;
    }
  }
  
  // Historique des transactions
  Stream<QuerySnapshot> getCoinTransactions(String userId) {
    return _firestore
        .collection('coinTransactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }
  
  // Vérifier si l'utilisateur peut se permettre une action
  Future<bool> canAfford(String userId, int cost) async {
    final coins = await getUserCoins(userId);
    return coins >= cost;
  }
  
  // Actions spécifiques selon votre vision
  Future<bool> sendSmile(String fromUserId, String toUserId) async {
    final canPay = await canAfford(fromUserId, SMILE_COST);
    if (!canPay) return false;
    
    final spent = await spendCoins(fromUserId, SMILE_COST, 'Sourire envoyé');
    if (spent) {
      // Donner bonus à celui qui reçoit
      await addCoins(toUserId, SMILE_RECEIVED, 'Sourire reçu');
    }
    
    return spent;
  }
  
  Future<bool> sendLetter(String fromUserId, String toUserId) async {
    final canPay = await canAfford(fromUserId, LETTER_COST);
    if (!canPay) return false;
    
    return await spendCoins(fromUserId, LETTER_COST, 'Lettre envoyée');
  }
  
  Future<bool> sendGift(String fromUserId, String toUserId) async {
    final canPay = await canAfford(fromUserId, GIFT_COST);
    if (!canPay) return false;
    
    return await spendCoins(fromUserId, GIFT_COST, 'Cadeau envoyé');
  }
}