class MenuItemEntity {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final bool available;
  final int calories;

  const MenuItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.available,
    required this.calories,
  });
}
