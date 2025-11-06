class RestaurantEntity {
  final String id;
  final String name;
  final String cuisine;
  final bool halal;
  final double rating;
  final String priceRange;
  final String image;
  final String location;
  final String description;

  RestaurantEntity({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.halal,
    required this.rating,
    required this.priceRange,
    required this.image,
    required this.location,
    required this.description,
  });
}
