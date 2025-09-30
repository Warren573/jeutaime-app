import 'package:flutter/material.dart';
import '../../models/economy.dart';
import '../../config/ui_reference.dart';
import '../../widgets/currency_display.dart';
import '../../widgets/daily_rewards_dialog.dart';
import '../../services/progression_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  UserWallet _wallet = EconomyService.getUserWallet();
  List<ShopItem> _allItems = [];
  ShopCategory _selectedCategory = ShopCategory.avatars;
  String _searchQuery = '';
  bool _showOnlyAffordable = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _allItems = EconomyService.getShopItems();
    
    // Afficher les récompenses quotidiennes au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyRewards();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkDailyRewards() {
    // Simulation - en réalité on vérifierait la dernière connexion
    bool hasClaimedToday = false; // Récupérer depuis les prefs
    
    if (!hasClaimedToday) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => DailyRewardsDialog(
          onRewardClaimed: (currencyId, amount) {
            setState(() {
              _wallet = _wallet.addCurrency(currencyId, amount, 'Récompense quotidienne');
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIReference.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildCategoryTabs(),
          _buildFilters(),
          Expanded(
            child: _buildItemsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransactionHistory(),
        backgroundColor: UIReference.primaryColor,
        foregroundColor: UIReference.white,
        icon: const Icon(Icons.history),
        label: const Text('Historique'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UIReference.primaryColor,
            UIReference.accentColor,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Boutique JeuTaime',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: UIReference.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_filteredItems.length} articles disponibles',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: UIReference.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showDailyRewards(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: UIReference.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: UIReference.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    color: UIReference.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Affichage des monnaies
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CurrencyDisplay(
                coins: _wallet.getCurrencyAmount('coins'),
                gems: _wallet.getCurrencyAmount('gems'),
                showLabels: true,
                showBackground: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: UIReference.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: UIReference.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: UIReference.primaryColor,
        unselectedLabelColor: UIReference.textSecondary,
        indicatorColor: UIReference.primaryColor,
        indicatorWeight: 3,
        tabs: ShopCategory.values.map((category) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(category.displayName),
              ],
            ),
          );
        }).toList(),
        onTap: (index) {
          setState(() {
            _selectedCategory = ShopCategory.values[index];
          });
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un article...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: UIReference.textSecondary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: UIReference.primaryColor),
                ),
                filled: true,
                fillColor: UIReference.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilterChip(
            label: const Text('Abordable'),
            selected: _showOnlyAffordable,
            onSelected: (selected) {
              setState(() {
                _showOnlyAffordable = selected;
              });
            },
            selectedColor: UIReference.primaryColor.withOpacity(0.2),
            checkmarkColor: UIReference.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    final items = _filteredItems;
    
    if (items.isEmpty) {
      return _buildEmptyState();
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _allItems = EconomyService.getShopItems();
          _wallet = EconomyService.getUserWallet();
        });
      },
      color: UIReference.primaryColor,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Text(item.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(item.name),
              subtitle: Text(item.description),
              trailing: ElevatedButton(
                onPressed: () => _purchaseItem(item),
                child: Text('${item.prices['coins'] ?? 0} 🪙'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: UIReference.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: UIReference.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun article trouvé',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: UIReference.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: UIReference.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<ShopItem> get _filteredItems {
    List<ShopItem> filtered = _allItems
        .where((item) => item.category == _selectedCategory)
        .toList();
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    
    if (_showOnlyAffordable) {
      filtered = filtered
          .where((item) => EconomyService.canAfford(_wallet, item))
          .toList();
    }
    
    // Trier par rareté puis par prix
    filtered.sort((a, b) {
      int rarityCompare = b.rarity.index.compareTo(a.rarity.index);
      if (rarityCompare != 0) return rarityCompare;
      
      int priceA = a.prices.values.isEmpty ? 0 : a.prices.values.first;
      int priceB = b.prices.values.isEmpty ? 0 : b.prices.values.first;
      return priceA.compareTo(priceB);
    });
    
    return filtered;
  }

  void _purchaseItem(ShopItem item) {
    final progressionService = ProgressionService();
    final userProgress = progressionService.getUserProgress();
    
    if (!item.canPurchase(_wallet, userProgress.level, userProgress.unlockedAchievements)) {
      _showPurchaseError(item);
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(child: Text(item.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            const SizedBox(height: 16),
            Text(
              'Prix : ${item.getPriceDisplay()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.rarity.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.rarity.name,
                style: TextStyle(
                  color: item.rarity.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmPurchase(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UIReference.primaryColor,
              foregroundColor: UIReference.white,
            ),
            child: const Text('Acheter'),
          ),
        ],
      ),
    );
  }

  void _confirmPurchase(ShopItem item) {
    try {
      // Décrémenter les monnaies
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
      
      // Animation de succès
      _showPurchaseSuccess(item);
      
    } catch (e) {
      _showPurchaseError(item);
    }
  }

  void _showPurchaseSuccess(ShopItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text('${item.name} acheté avec succès !'),
            ),
          ],
        ),
        backgroundColor: UIReference.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPurchaseError(ShopItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Impossible d\'acheter cet article'),
        backgroundColor: UIReference.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  void _showTransactionHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: UIReference.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: UIReference.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: UIReference.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Historique des transactions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: UIReference.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _wallet.transactionHistory.length,
                itemBuilder: (context, index) {
                  final transaction = _wallet.transactionHistory.reversed.toList()[index];
                  final currency = EconomyService.getCurrency(transaction.currencyId);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: transaction.isEarned
                            ? UIReference.successColor.withOpacity(0.2)
                            : UIReference.errorColor.withOpacity(0.2),
                        child: Icon(
                          transaction.isEarned ? Icons.add : Icons.remove,
                          color: transaction.isEarned
                              ? UIReference.successColor
                              : UIReference.errorColor,
                        ),
                      ),
                      title: Text(transaction.reason),
                      subtitle: Text(
                        _formatDate(transaction.timestamp),
                        style: TextStyle(color: UIReference.textSecondary),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${transaction.amount > 0 ? '+' : ''}${transaction.amount}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: transaction.isEarned
                                  ? UIReference.successColor
                                  : UIReference.errorColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currency?.symbol ?? '?',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
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

  int _getCurrentUserLevel() {
    final progressionService = ProgressionService();
    return progressionService.getUserProgress().level;
  }

  List<String> _getCurrentUserAchievements() {
    final progressionService = ProgressionService();
    return progressionService.getUserProgress().unlockedAchievements;
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
