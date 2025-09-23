import 'package:flutter/material.dart';
import '../models/shop_item.dart';

class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final void Function(ShopItem)? onPurchase;
  final int? userCoins;

  const ShopItemCard({
    Key? key,
    required this.item,
    this.onPurchase,
    this.userCoins,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool canBuy = !item.isRealMoney && (userCoins ?? 0) >= item.price;

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            leading: Icon(item.icon, color: item.color),
            title: Text(item.name),
            subtitle: Text(item.description),
            trailing: item.isRealMoney
                ? Text(item.realPrice ?? '', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                : Text('${item.price} 🪙', style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: onPurchase != null && (item.isRealMoney || canBuy)
                ? () => onPurchase!(item)
                : null,
            child: Text(item.isRealMoney
                ? 'Acheter (€)'
                : canBuy
                    ? 'Acheter'
                    : 'Coins insuffisants'),
          ),
        ],
      ),
    );
  }
}
