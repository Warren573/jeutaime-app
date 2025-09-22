class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color color;
  final String category;
  final bool isRealMoney;
  final String? realPrice;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
    required this.category,
    this.isRealMoney = false,
    this.realPrice,
  });
}
