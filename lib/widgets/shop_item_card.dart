import 'package:flutter/material.dart';
import '../../models/shop_item.dart';

class ShopItemCard extends StatelessWidget {
  final ShopItem item;

  const ShopItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(item.icon, color: item.color),
        title: Text(item.name),
        subtitle: Text(item.description),
        trailing: Text(item.isRealMoney ? (item.realPrice ?? '') : '${item.price}'),
      ),
    );
  }
}
