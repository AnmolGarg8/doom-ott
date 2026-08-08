class UserModel {
  final String id;
  final String? email;
  final String? phone;
  final String name;
  final String? profilePicture;
  final bool isSubscribed;
  final String subscriptionTier; // 'Free', 'Premium', 'VIP'

  UserModel({
    required this.id,
    this.email,
    this.phone,
    required this.name,
    this.profilePicture,
    required this.isSubscribed,
    required this.subscriptionTier,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      name: json['name'] as String? ?? 'User',
      profilePicture:
          json['profile_picture'] as String? ??
          json['profilePicture'] as String?,
      isSubscribed:
          json['is_subscribed'] as bool? ??
          json['isSubscribed'] as bool? ??
          false,
      subscriptionTier:
          json['subscription_tier'] as String? ??
          json['subscriptionTier'] as String? ??
          'Free',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'profile_picture': profilePicture,
      'profilePicture': profilePicture,
      'is_subscribed': isSubscribed,
      'isSubscribed': isSubscribed,
      'subscription_tier': subscriptionTier,
      'subscriptionTier': subscriptionTier,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    String? profilePicture,
    bool? isSubscribed,
    String? subscriptionTier,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
    );
  }
}
