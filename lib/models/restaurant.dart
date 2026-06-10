import 'package:cloud_firestore/cloud_firestore.dart';

/// A restaurant that publishes a menu on BiteNear.
class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final String logoUrl;
  final String coverUrl;
  final double latitude;
  final double longitude;
  final String address;
  final String phone;
  final double rating; // aggregate 0..5
  final int reviewCount;
  final Map<String, String> hours; // e.g. {"Mon": "9:00 - 22:00"}

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.logoUrl,
    required this.coverUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.phone,
    this.rating = 0,
    this.reviewCount = 0,
    this.hours = const {},
  });

  factory Restaurant.fromMap(String id, Map<String, dynamic> map) {
    final geo = map['location'] as GeoPoint?;
    return Restaurant(
      id: id,
      name: map['name'] as String? ?? '',
      cuisine: map['cuisine'] as String? ?? '',
      logoUrl: map['logoUrl'] as String? ?? '',
      coverUrl: map['coverUrl'] as String? ?? '',
      latitude: geo?.latitude ?? (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: geo?.longitude ?? (map['longitude'] as num?)?.toDouble() ?? 0,
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      hours: Map<String, String>.from(map['hours'] as Map? ?? const {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cuisine': cuisine,
      'logoUrl': logoUrl,
      'coverUrl': coverUrl,
      'location': GeoPoint(latitude, longitude),
      'address': address,
      'phone': phone,
      'rating': rating,
      'reviewCount': reviewCount,
      'hours': hours,
    };
  }
}
