/// Application-level user model, decoupled from FirebaseAuth's [User].
class AppUser {
  final String uid;
  final String? email;
  final String displayName;
  final String? photoUrl;
  final bool isGuest;

  /// True when this account manages a restaurant (sees the dashboard).
  final bool isRestaurantOwner;
  final String? ownedRestaurantId;

  const AppUser({
    required this.uid,
    this.email,
    required this.displayName,
    this.photoUrl,
    this.isGuest = false,
    this.isRestaurantOwner = false,
    this.ownedRestaurantId,
  });

  /// A throwaway identity for guest (browse-only) mode.
  factory AppUser.guest() {
    return const AppUser(
      uid: 'guest',
      displayName: 'Guest',
      isGuest: true,
    );
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] as String?,
      displayName: map['displayName'] as String? ?? 'Foodie',
      photoUrl: map['photoUrl'] as String?,
      isRestaurantOwner: map['isRestaurantOwner'] as bool? ?? false,
      ownedRestaurantId: map['ownedRestaurantId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isRestaurantOwner': isRestaurantOwner,
      'ownedRestaurantId': ownedRestaurantId,
    };
  }
}
