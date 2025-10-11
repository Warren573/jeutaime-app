import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  final int currentCoins;
  final Function(int) onCoinsUpdated;

  const ShopScreen({
    super.key,
    required this.currentCoins,
    required this.onCoinsUpdated,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<Map<String, dynamic>> _coinPacks = [
    {
      'title': 'Pack Starter',
      'amount': 1000,
      'price': '2,99€',
      'bonus': 0,
      'icon': '💰',
    },
    {
      'title': 'Pack Charme',
      'amount': 2500,
      'price': '6,99€',
      'bonus': 0.15,
      'icon': '💎',
    },
    {
      'title': 'Pack Romance',
      'amount': 5000,
      'price': '12,99€',
      'bonus': 0.20,
      'icon': '💍',
    },
    {
      'title': 'Pack Elite',
      'amount': 10000,
      'price': '22,99€',
      'bonus': 0.30,
      'icon': '👑',
    },
  ];

  void _buyCoins(Map<String, dynamic> pack) {
    final amount = pack['amount'] as int;
    final bonus = pack['bonus'] as double;
    final totalAmount = (amount * (1 + bonus)).floor();
    final price = pack['price'] as String;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e1e),
        title: Text(
          '💰 Pack de $amount pièces',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💵 Prix : $price', style: const TextStyle(color: Colors.grey)),
            if (bonus > 0) ...[
              const SizedBox(height: 8),
              Text(
                '🎁 Bonus : +${(bonus * 100).floor()}%',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '💎 Total : $totalAmount pièces',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _processPurchase(totalAmount, price);
            },
            child: const Text('Acheter', style: TextStyle(color: Color(0xFFE91E63))),
          ),
        ],
      ),
    );
  }

  void _processPurchase(int amount, String price) {
    // Simulate payment processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFE91E63)),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading
      widget.onCoinsUpdated(amount);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1e1e1e),
          title: const Text('✅ Achat réussi !', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💰 +$amount pièces',
                style: const TextStyle(color: Colors.green),
              ),
              Text(
                '💳 $price débité',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                '🎉 Merci pour votre achat !',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Super !', style: TextStyle(color: Color(0xFFE91E63))),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('🛍️ Boutique', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vos pièces : ${widget.currentCoins} 🪙',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Packs de pièces',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.8,
                ),
                itemCount: _coinPacks.length,
                itemBuilder: (context, index) {
                  final pack = _coinPacks[index];
                  return _buildCoinPackCard(pack);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinPackCard(Map<String, dynamic> pack) {
    return InkWell(
      onTap: () => _buyCoins(pack),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1e1e1e),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(pack['icon'], style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 10),
            Text(
              pack['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${pack['amount']} pièces',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              pack['price'],
              style: const TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (pack['bonus'] > 0) ...[
              const SizedBox(height: 5),
              Text(
                '+${(pack['bonus'] * 100).floor()}% bonus',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}