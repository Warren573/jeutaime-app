import 'package:flutter/material.dart';
import '../models/economy.dart';
import '../widgets/shop_item_card.dart';
import '../widgets/currency_display.dart';
import '../widgets/daily_rewards_dialog.dart';
import '../config/ui_reference.dart';

class EconomyTestScreen extends StatefulWidget {
  const EconomyTestScreen({super.key});

  @override
  State<EconomyTestScreen> createState() => _EconomyTestScreenState();
}

class _EconomyTestScreenState extends State<EconomyTestScreen> {
  UserWallet _wallet = EconomyService.getUserWallet();
  int _selectedCurrencyIndex = 0;
  String get _selectedCurrencyId => EconomyService.currencies[_selectedCurrencyIndex].id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Système d\'Économie'),
        backgroundColor: UIReference.primaryColor,
        foregroundColor: UIReference.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Monnaies
            Text(
              'Monnaies disponibles :',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: EconomyService.currencies.map((currency) {
                int amount = _wallet.getCurrencyAmount(currency.id);
                return CurrencyDisplay(
                  currency: currency,
                  amount: amount,
                  showAnimation: true,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Section Simulateur de Gains
            Text(
              'Simulateur de gains :',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Sélecteur de devise
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: UIReference.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: UIReference.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Sélectionner une devise :',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: EconomyService.currencies.asMap().entries.map((entry) {
                      int index = entry.key;
                      Currency currency = entry.value;
                      bool isSelected = index == _selectedCurrencyIndex;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCurrencyIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? currency.color.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? currency.color : Colors.grey.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(currency.symbol, style: const TextStyle(fontSize: 20)),
                              Text(currency.name, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Boutons d'actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addCurrency(10),
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text('Ajouter +10'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: () => _addCurrency(50),
                  icon: const Icon(Icons.add_circle),
                  label: Text('Ajouter +50'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: () => _addCurrency(100),
                  icon: const Icon(Icons.add_box),
                  label: Text('Ajouter +100'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: _simulateEarningActions,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Actions Auto'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                ElevatedButton.icon(
                  onPressed: _showDailyRewards,
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text('Récompenses'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                ),
                ElevatedButton.icon(
                  onPressed: _resetWallet,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Exemples d'articles
            Text(
              'Articles de boutique :',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: 4, // Afficher seulement 4 articles
              itemBuilder: (context, index) {
                final items = EconomyService.getShopItems();
                if (index >= items.length) return const SizedBox.shrink();
                
                final item = items[index];
                return ShopItemCard(
                  item: item,
                  wallet: _wallet,
                  userLevel: 5, // Niveau de test
                  userAchievements: ['first_letter', 'early_bird'],
                  onPurchase: () => _purchaseItem(item),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Historique des transactions
            Text(
              'Historique des transactions :',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: UIReference.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: UIReference.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _wallet.transactionHistory.isEmpty
                  ? const Center(
                      child: Text('Aucune transaction'),
                    )
                  : ListView.builder(
                      itemCount: _wallet.transactionHistory.length,
                      itemBuilder: (context, index) {
                        final transaction = _wallet.transactionHistory.reversed.toList()[index];
                        final currency = EconomyService.getCurrency(transaction.currencyId);
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transaction.isEarned
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            child: Icon(
                              transaction.isEarned ? Icons.add : Icons.remove,
                              color: transaction.isEarned ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(transaction.reason),
                          subtitle: Text(_formatDate(transaction.timestamp)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${transaction.amount > 0 ? '+' : ''}${transaction.amount}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: transaction.isEarned ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(currency?.symbol ?? '?'),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _addCurrency(int amount) {
    final currency = EconomyService.currencies[_selectedCurrencyIndex];
    setState(() {
      _wallet = _wallet.addCurrency(
        currency.id, 
        amount, 
        'Test +$amount ${currency.name}'
      );
    });
    
    // Feedback visuel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(currency.symbol, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text('+$amount ${currency.name} ajouté(es) !'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _simulateEarningActions() {
    // Simuler plusieurs actions de gain
    final actions = [
      {'currency': 'coins', 'amount': 25, 'reason': 'Match réussi'},
      {'currency': 'hearts', 'amount': 3, 'reason': 'Message romantique envoyé'},
      {'currency': 'coins', 'amount': 15, 'reason': 'Profil complété'},
      {'currency': 'gems', 'amount': 1, 'reason': 'Objectif hebdomadaire'},
      {'currency': 'hearts', 'amount': 5, 'reason': 'Lettre d\'amour rédigée'},
    ];
    
    for (var action in actions) {
      Future.delayed(Duration(milliseconds: actions.indexOf(action) * 500), () {
        if (mounted) {
          setState(() {
            _wallet = _wallet.addCurrency(
              action['currency'] as String,
              action['amount'] as int,
              action['reason'] as String,
            );
          });
        }
      });
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🎯 Simulation d\'actions automatiques en cours...'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetWallet() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset du portefeuille'),
        content: const Text('Voulez-vous vraiment réinitialiser toutes vos devises ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _wallet = UserWallet(
                  currencies: {
                    'coins': 250,  // Montant initial
                    'hearts': 10,
                    'gems': 2,
                  },
                  transactionHistory: [],
                  lastUpdated: DateTime.now(),
                );
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('💰 Portefeuille réinitialisé !'),
                  backgroundColor: Colors.blue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _purchaseItem(ShopItem item) {
    try {
      UserWallet newWallet = _wallet;
      for (String currencyId in item.prices.keys) {
        int price = item.prices[currencyId]!;
        newWallet = newWallet.spendCurrency(
          currencyId,
          price,
          'Achat ${item.name}',
          item: item,
        );
      }
      
      setState(() {
        _wallet = newWallet;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} acheté avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Impossible d\'acheter cet article'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDailyRewards() {
    showDialog(
      context: context,
      builder: (context) => DailyRewardsDialog(
        onRewardClaimed: (currencyId, amount) {
          setState(() {
            _wallet = _wallet.addCurrency(currencyId, amount, 'Récompense quotidienne');
          });
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inDays}j';
    }
  }
}