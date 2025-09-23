import 'package:flutter/material.dart';
import '../models/shop_item.dart';
import '../theme/app_colors.dart';

class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final Function(ShopItem) onPurchase;
  final int userCoins;

  const ShopItemCard({
    Key? key,
    required this.item,
    required this.onPurchase,
    required this.userCoins,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool canAfford = userCoins >= item.price;
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              item.color.withOpacity(0.1),
              item.color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône et nom
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 28,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.seriousAccent,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              
              // Prix et bouton d'achat
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Prix
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isRealMoney ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.isRealMoney ? Icons.euro : Icons.monetization_on,
                          size: 16,
                          color: item.isRealMoney ? Colors.green : Colors.amber,
                        ),
                        SizedBox(width: 4),
                        Text(
                          item.isRealMoney ? item.realPrice ?? '0€' : '${item.price}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item.isRealMoney ? Colors.green : Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Bouton d'achat
                  ElevatedButton(
                    onPressed: (!item.isRealMoney && !canAfford) ? null : () => onPurchase(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford || item.isRealMoney 
                          ? item.color 
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      item.isRealMoney ? 'Acheter' : (canAfford ? 'Acheter' : 'Pas assez'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}