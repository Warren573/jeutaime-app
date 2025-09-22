import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/shop_item.dart';
import '../../widgets/shop_item_card.dart';

class ShopScreen extends StatefulWidget {
  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _userCoins = 1250; // Exemple

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shopping_bag, color: AppColors.romanticBar),
            SizedBox(width: 8),
            Text('Boutique', style: TextStyle(color: AppColors.seriousAccent)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text(
                  '$_userCoins',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.romanticBar,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.romanticBar,
          tabs: [
            Tab(text: 'Offrandes'),
            Tab(text: 'Premium'),
            Tab(text: 'Papeterie'),
            Tab(text: 'Bonus'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOfferingTab(),
          _buildPremiumTab(),
          _buildStationeryTab(),
          _buildBonusTab(),
        ],
      ),
    );
  }

  Widget _buildOfferingTab() {
    List<ShopItem> offerings = [
      ShopItem(
        id: '1',
        name: 'Rose Virtuelle',
        description: 'Offre une rose lors d\'une rencontre',
        price: 50,
        icon: Icons.local_florist,
        color: Colors.pink,
        category: 'offering',
      ),
      ShopItem(
        id: '2',
        name: 'Café Virtuel',
        description: 'Invite quelqu\'un pour un café symbolique',
        price: 30,
        icon: Icons.local_cafe,
        color: Colors.brown,
        category: 'offering',
      ),
      ShopItem(
        id: '3',
        name: 'Cœur Magique',
        description: 'Augmente tes chances de match',
        price: 100,
        icon: Icons.favorite,
        color: Colors.red,
        category: 'offering',
      ),
      ShopItem(
        id: '4',
        name: 'Étoile Filante',
        description: 'Fait un vœu pour ton crush',
        price: 75,
        icon: Icons.star,
        color: Colors.amber,
        category: 'offering',
      ),
    ];

    return _buildShopGrid(offerings);
  }

  Widget _buildPremiumTab() {
    List<ShopItem> premium = [
      ShopItem(
        id: '5',
        name: 'JeuTaime Premium',
        description: 'Accès illimité pendant 1 mois',
        price: 999,
        icon: Icons.diamond,
        color: Colors.purple,
        category: 'premium',
      ),
      ShopItem(
        id: '6',
        name: 'Super Visibilité',
        description: 'Profile mis en avant pendant 24h',
        price: 200,
        icon: Icons.visibility,
        color: Colors.orange,
        category: 'premium',
      ),
    ];

    return _buildShopGrid(premium);
  }

  Widget _buildStationeryTab() {
    List<ShopItem> stationery = [
      ShopItem(
        id: '7',
        name: 'Papier Romantique',
        description: 'Écris tes lettres sur du papier rose',
        price: 25,
        icon: Icons.note,
        color: Colors.pink,
        category: 'stationery',
      ),
      ShopItem(
        id: '8',
        name: 'Encre Dorée',
        description: 'Donne du style à tes messages',
        price: 40,
        icon: Icons.edit,
        color: Colors.amber,
        category: 'stationery',
      ),
    ];

    return _buildShopGrid(stationery);
  }

  Widget _buildBonusTab() {
    List<ShopItem> bonus = [
      ShopItem(
        id: '9',
        name: 'Pack de Coins',
        description: '500 coins supplémentaires',
        price: 0, // Gratuit mais payant en euros
        icon: Icons.monetization_on,
        color: Colors.green,
        category: 'coins',
        isRealMoney: true,
        realPrice: '2.99€',
      ),
    ];

    return _buildShopGrid(bonus);
  }

  Widget _buildShopGrid(List<ShopItem> items) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => ShopItemCard(
        item: items[index],
        onPurchase: (item) => _purchaseItem(item),
        userCoins: _userCoins,
      ),
    );
  }

  void _purchaseItem(ShopItem item) {
    if (_userCoins >= item.price) {
      setState(() {
        _userCoins -= item.price;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} acheté avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coins insuffisants !'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
