import 'package:cloud_firestore/cloud_firestore.dart';

/// A dish-level review written by a user.
class Review {
  final String id;
  final String dishId;
  final String restaurantId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double rating; // 1..5
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.dishId,
    required this.restaurantId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(String id, Map<String, dynamic> map) {
    return Review(
      id: id,
      dishId: map['dishId'] as String? ?? '',
      restaurantId: map['restaurantId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'Anonymous',
      userPhotoUrl: map['userPhotoUrl'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      comment: map['comment'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dishId': dishId,
      'restaurantId': restaurantId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
