class RatingEntity {
  final String userId;
  final String vendorId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  RatingEntity({
    required this.userId,
    required this.vendorId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}
