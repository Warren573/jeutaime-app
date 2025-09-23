import 'package:cloud_firestore/cloud_firestore.dart';

class Purchase {
  final String purchaseId;
  final String uid;
  final PurchaseType type;
  final int amount; // Pièces ou jours Premium
  final double cost; // Prix en EUR
  final String? stripeSessionId;
  final PurchaseStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  Purchase({
    required this.purchaseId,
    required this.uid,
    required this.type,
    required this.amount,
    required this.cost,
    this.stripeSessionId,
    this.status = PurchaseStatus.pending,
    required this.createdAt,
    this.completedAt,
  });

  factory Purchase.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Purchase(
      purchaseId: doc.id,
      uid: data['uid'] ?? '',
      type: PurchaseType.fromString(data['type'] ?? 'coins'),
      amount: data['amount'] ?? 0,
      cost: (data['cost'] ?? 0.0).toDouble(),
      stripeSessionId: data['stripeSessionId'],
      status: PurchaseStatus.fromString(data['status'] ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'type': type.value,
      'amount': amount,
      'cost': cost,
      'stripeSessionId': stripeSessionId,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null 
          ? Timestamp.fromDate(completedAt!) 
          : null,
    };
  }

  Purchase copyWith({
    PurchaseType? type,
    PurchaseStatus? status,
    String? stripeSessionId,
    DateTime? completedAt,
  }) {
    return Purchase(
      purchaseId: purchaseId,
      uid: uid,
      type: type ?? this.type,
      amount: amount,
      cost: cost,
      stripeSessionId: stripeSessionId ?? this.stripeSessionId,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

enum PurchaseType {
  coins('coins'),
  premium('premium');

  const PurchaseType(this.value);
  final String value;

  static PurchaseType fromString(String value) {
    return PurchaseType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PurchaseType.coins,
    );
  }

  String get displayName {
    switch (this) {
      case PurchaseType.coins:
        return 'Pièces';
      case PurchaseType.premium:
        return 'Premium';
    }
  }
}

enum PurchaseStatus {
  pending('pending'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const PurchaseStatus(this.value);
  final String value;

  static PurchaseStatus fromString(String value) {
    return PurchaseStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PurchaseStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case PurchaseStatus.pending:
        return 'En attente';
      case PurchaseStatus.completed:
        return 'Terminé';
      case PurchaseStatus.failed:
        return 'Échoué';
      case PurchaseStatus.cancelled:
        return 'Annulé';
    }
  }
}

// Packages de pièces disponibles
class CoinPackage {
  final String id;
  final int coins;
  final double price;
  final String name;
  final bool isPopular;

  const CoinPackage({
    required this.id,
    required this.coins,
    required this.price,
    required this.name,
    this.isPopular = false,
  });

  static const List<CoinPackage> availablePackages = [
    CoinPackage(
      id: 'starter',
      coins: 1000,
      price: 2.99,
      name: 'Pack Starter',
    ),
    CoinPackage(
      id: 'charme',
      coins: 2500,
      price: 6.99,
      name: 'Pack Charme',
      isPopular: true,
    ),
    CoinPackage(
      id: 'romance',
      coins: 5000,
      price: 12.99,
      name: 'Pack Romance',
    ),
    CoinPackage(
      id: 'elite',
      coins: 10000,
      price: 22.99,
      name: 'Pack Elite',
    ),
  ];

  // Calcul du bonus (pièces gratuites)
  int get bonusCoins {
    double expectedPrice = coins * 0.003; // 3 centimes par pièce de base
    if (price < expectedPrice) {
      return ((expectedPrice - price) / 0.003).round();
    }
    return 0;
  }

  // Calcul des économies en pourcentage
  double get savingsPercentage {
    double basePrice = coins * 0.003;
    if (basePrice <= price) return 0;
    return ((basePrice - price) / basePrice * 100);
  }
}