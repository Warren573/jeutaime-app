import 'package:flutter/material.dart';

class ShopItemCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Item boutique'),
        subtitle: Text('Description'),
      ),
    );
  }
}
