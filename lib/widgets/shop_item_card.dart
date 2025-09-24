import 'package:flutter/material.dart';
import '../models/economy.dart';
import '../config/ui_reference.dart';

class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final UserWallet wallet;
  final int userLevel;
  final List<String> userAchievements;
  final VoidCallback onPurchase;

  const ShopItemCard({
    Key? key,
    required this.item,
    required this.wallet,
    required this.userLevel,
    required this.userAchievements,
    required this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool canAfford = EconomyService.canAfford(wallet, item);
    bool canPurchase = item.canPurchase(wallet, userLevel, userAchievements);
    bool isLocked = !canPurchase;
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: item.rarity.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              item.rarity.color.withOpacity(0.1),
              item.rarity.color.withOpacity(0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Badge de rareté
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.rarity.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.rarity.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Contenu principal
            Padding(
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.rarity.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: UIReference.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: UIReference.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Prérequis si nécessaire
                      if (item.requiredLevel > 1 || item.requiredAchievements.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 12,
                                color: UIReference.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _getRequirementText(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: UIReference.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Prix et bouton d'achat
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Affichage des prix
                      if (item.prices.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: item.prices.entries.map((entry) {
                            final currency = EconomyService.getCurrency(entry.key);
                            if (currency == null) return const SizedBox.shrink();
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: currency.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: currency.color.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currency.symbol,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    entry.value.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: currency.color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Bouton d'achat
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: canPurchase ? onPurchase : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canPurchase
                                ? (canAfford ? item.rarity.color : UIReference.textSecondary)
                                : UIReference.textSecondary.withOpacity(0.5),
                            foregroundColor: UIReference.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: canPurchase ? 2 : 0,
                          ),
                          child: Text(
                            _getButtonText(canPurchase, canAfford),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Overlay de verrouillage
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: UIReference.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock,
                          color: UIReference.white,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verrouillé',
                          style: TextStyle(
                            color: UIReference.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getRequirementText() {
    if (item.requiredLevel > userLevel) {
      return 'Niveau ${item.requiredLevel} requis';
    }
    
    if (item.requiredAchievements.isNotEmpty) {
      for (String achievement in item.requiredAchievements) {
        if (!userAchievements.contains(achievement)) {
          return 'Succès requis: $achievement';
        }
      }
    }
    
    return '';
  }

  String _getButtonText(bool canPurchase, bool canAfford) {
    if (!canPurchase) {
      if (item.requiredLevel > userLevel) {
        return 'Niveau ${item.requiredLevel}';
      }
      return 'Verrouillé';
    }
    
    if (!canAfford) {
      return 'Fonds insuffisants';
    }
    
    return 'Acheter';
  }
}