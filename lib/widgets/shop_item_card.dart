import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import '../theme/app_colors.dart';import '../models/economy.dart';

import '../config/ui_reference.dart';

class ShopItemCard extends StatelessWidget {

  final String title;class ShopItemCard extends StatelessWidget {

  final String description;  final ShopItem item;

  final int price;  final UserWallet wallet;

  final IconData icon;  final int userLevel;

  final Color color;  final List<String> userAchievements;

  final bool isPopular;  final VoidCallback onPurchase;

  final VoidCallback onBuy;

  const ShopItemCard({

  const ShopItemCard({    Key? key,

    Key? key,    required this.item,

    required this.title,    required this.wallet,

    required this.description,    required this.userLevel,

    required this.price,    required this.userAchievements,

    required this.icon,    required this.onPurchase,

    required this.color,  }) : super(key: key);

    this.isPopular = false,

    required this.onBuy,  @override

  }) : super(key: key);  Widget build(BuildContext context) {

    bool canAfford = EconomyService.canAfford(wallet, item);

  @override    bool canPurchase = item.canPurchase(wallet, userLevel, userAchievements);

  Widget build(BuildContext context) {    bool isLocked = !canPurchase;

    return Card(    

      elevation: isPopular ? 8 : 4,    return Card(

      margin: const EdgeInsets.all(8),      elevation: 6,

      child: Container(      shape: RoundedRectangleBorder(

        decoration: BoxDecoration(        borderRadius: BorderRadius.circular(16),

          borderRadius: BorderRadius.circular(12),        side: BorderSide(

          border: isPopular           color: item.rarity.color.withOpacity(0.3),

              ? Border.all(color: AppColors.goldAccent, width: 2)          width: 2,

              : null,        ),

        ),      ),

        child: Column(      child: Container(

          crossAxisAlignment: CrossAxisAlignment.start,        decoration: BoxDecoration(

          children: [          borderRadius: BorderRadius.circular(14),

            if (isPopular)          gradient: LinearGradient(

              Container(            begin: Alignment.topLeft,

                width: double.infinity,            end: Alignment.bottomRight,

                padding: const EdgeInsets.symmetric(vertical: 4),            colors: [

                decoration: const BoxDecoration(              item.rarity.color.withOpacity(0.1),

                  color: AppColors.goldAccent,              item.rarity.color.withOpacity(0.05),

                  borderRadius: BorderRadius.only(            ],

                    topLeft: Radius.circular(12),          ),

                    topRight: Radius.circular(12),        ),

                  ),        child: Stack(

                ),          children: [

                child: const Text(            // Badge de rareté

                  '🔥 POPULAIRE',            Positioned(

                  textAlign: TextAlign.center,              top: 8,

                  style: TextStyle(              right: 8,

                    color: Colors.white,              child: Container(

                    fontWeight: FontWeight.bold,                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

                    fontSize: 12,                decoration: BoxDecoration(

                  ),                  color: item.rarity.color,

                ),                  borderRadius: BorderRadius.circular(8),

              ),                ),

            Expanded(                child: Text(

              child: Padding(                  item.rarity.name,

                padding: const EdgeInsets.all(16),                  style: const TextStyle(

                child: Column(                    color: Colors.white,

                  crossAxisAlignment: CrossAxisAlignment.start,                    fontSize: 10,

                  children: [                    fontWeight: FontWeight.bold,

                    Container(                  ),

                      padding: const EdgeInsets.all(12),                ),

                      decoration: BoxDecoration(              ),

                        color: color.withOpacity(0.1),            ),

                        borderRadius: BorderRadius.circular(8),            

                      ),            // Contenu principal

                      child: Icon(            Padding(

                        icon,              padding: const EdgeInsets.all(12.0),

                        color: color,              child: Column(

                        size: 32,                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      ),                crossAxisAlignment: CrossAxisAlignment.start,

                    ),                children: [

                    const SizedBox(height: 12),                  // Icône et nom

                    Text(                  Column(

                      title,                    crossAxisAlignment: CrossAxisAlignment.start,

                      style: const TextStyle(                    children: [

                        fontSize: 16,                      Container(

                        fontWeight: FontWeight.bold,                        padding: const EdgeInsets.all(12),

                        color: AppColors.textDark,                        decoration: BoxDecoration(

                      ),                          color: item.rarity.color.withOpacity(0.2),

                    ),                          borderRadius: BorderRadius.circular(12),

                    const SizedBox(height: 8),                        ),

                    Expanded(                        child: Text(

                      child: Text(                          item.emoji,

                        description,                          style: const TextStyle(fontSize: 28),

                        style: TextStyle(                        ),

                          fontSize: 12,                      ),

                          color: AppColors.textDark.withOpacity(0.7),                      const SizedBox(height: 8),

                          height: 1.3,                      Text(

                        ),                        item.name,

                      ),                        style: TextStyle(

                    ),                          fontSize: 16,

                    const SizedBox(height: 12),                          fontWeight: FontWeight.bold,

                    Row(                          color: UIReference.textPrimary,

                      children: [                        ),

                        const Icon(                        maxLines: 2,

                          Icons.monetization_on,                        overflow: TextOverflow.ellipsis,

                          color: AppColors.goldAccent,                      ),

                          size: 16,                      const SizedBox(height: 4),

                        ),                      Text(

                        const SizedBox(width: 4),                        item.description,

                        Text(                        style: TextStyle(

                          price.toString(),                          fontSize: 12,

                          style: const TextStyle(                          color: UIReference.textSecondary,

                            fontSize: 16,                        ),

                            fontWeight: FontWeight.bold,                        maxLines: 2,

                            color: AppColors.goldAccent,                        overflow: TextOverflow.ellipsis,

                          ),                      ),

                        ),                      

                      ],                      // Prérequis si nécessaire

                    ),                      if (item.requiredLevel > 1 || item.requiredAchievements.isNotEmpty)

                  ],                        Padding(

                ),                          padding: const EdgeInsets.only(top: 4),

              ),                          child: Row(

            ),                            children: [

            Padding(                              Icon(

              padding: const EdgeInsets.all(16),                                Icons.lock_outline,

              child: SizedBox(                                size: 12,

                width: double.infinity,                                color: UIReference.textSecondary,

                child: ElevatedButton(                              ),

                  onPressed: onBuy,                              const SizedBox(width: 4),

                  style: ElevatedButton.styleFrom(                              Expanded(

                    backgroundColor: color,                                child: Text(

                    foregroundColor: Colors.white,                                  _getRequirementText(),

                    padding: const EdgeInsets.symmetric(vertical: 12),                                  style: TextStyle(

                    shape: RoundedRectangleBorder(                                    fontSize: 10,

                      borderRadius: BorderRadius.circular(8),                                    color: UIReference.textSecondary,

                    ),                                    fontStyle: FontStyle.italic,

                  ),                                  ),

                  child: const Text('Acheter'),                                  maxLines: 1,

                ),                                  overflow: TextOverflow.ellipsis,

              ),                                ),

            ),                              ),

          ],                            ],

        ),                          ),

      ),                        ),

    );                    ],

  }                  ),

}                  
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