import 'package:flutter/material.dart';

/// Modèle pour les articles de la boutique JeuTaime
/// Supporte les achats virtuels et réels avec sérialisation JSON
class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color color;
  final String category;
  final bool isRealMoney;
  final String? realPrice;
  final bool isAvailable;
  final DateTime? availableUntil;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
    required this.category,
    this.isRealMoney = false,
    this.realPrice,
    this.isAvailable = true,
    this.availableUntil,
  });

  /// Crée un ShopItem à partir d'un JSON
  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      icon: _parseIcon(json['iconName'] as String),
      color: Color(json['colorValue'] as int),
      category: json['category'] as String,
      isRealMoney: json['isRealMoney'] as bool? ?? false,
      realPrice: json['realPrice'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      availableUntil: json['availableUntil'] != null 
          ? DateTime.parse(json['availableUntil'] as String)
          : null,
    );
  }

  /// Convertit le ShopItem en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'iconName': _iconToString(icon),
      'colorValue': color.value,
      'category': category,
      'isRealMoney': isRealMoney,
      'realPrice': realPrice,
      'isAvailable': isAvailable,
      'availableUntil': availableUntil?.toIso8601String(),
    };
  }

  /// Parsing d'icône depuis un nom
  static IconData _parseIcon(String iconName) {
    switch (iconName) {
      case 'favorite': return Icons.favorite;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'stars': return Icons.stars;
      case 'emoji_emotions': return Icons.emoji_emotions;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'auto_awesome': return Icons.auto_awesome;
      case 'diamond': return Icons.diamond;
      case 'celebration': return Icons.celebration;
      default: return Icons.shopping_bag;
    }
  }

  /// Conversion d'icône vers string
  static String _iconToString(IconData icon) {
    if (icon == Icons.favorite) return 'favorite';
    if (icon == Icons.card_giftcard) return 'card_giftcard';
    if (icon == Icons.stars) return 'stars';
    if (icon == Icons.emoji_emotions) return 'emoji_emotions';
    if (icon == Icons.local_fire_department) return 'local_fire_department';
    if (icon == Icons.auto_awesome) return 'auto_awesome';
    if (icon == Icons.diamond) return 'diamond';
    if (icon == Icons.celebration) return 'celebration';
    return 'shopping_bag';
  }

  /// Copie le ShopItem avec des modifications
  ShopItem copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    IconData? icon,
    Color? color,
    String? category,
    bool? isRealMoney,
    String? realPrice,
    bool? isAvailable,
    DateTime? availableUntil,
  }) {
    return ShopItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      isRealMoney: isRealMoney ?? this.isRealMoney,
      realPrice: realPrice ?? this.realPrice,
      isAvailable: isAvailable ?? this.isAvailable,
      availableUntil: availableUntil ?? this.availableUntil,
    );
  }
}
