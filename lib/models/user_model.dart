class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String city;
  final String avatarUrl;
  final String tier; // e.g. 'CinePass VIP Thalaivar', 'CinePass Gold'
  final int loyaltyPoints;
  final int moviesWatched;
  final int savedSeats;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password = '',
    required this.phone,
    this.city = 'Chennai',
    required this.avatarUrl,
    this.tier = 'CinePass VIP Gold',
    this.loyaltyPoints = 580,
    this.moviesWatched = 14,
    this.savedSeats = 4,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? 'USR-TN-${DateTime.now().millisecondsSinceEpoch % 10000}',
      name: json['name'] as String? ?? 'Cinema Fan',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      phone: json['phone'] as String? ?? '+91 98401 23456',
      city: json['city'] as String? ?? 'Chennai',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      tier: json['tier'] as String? ?? 'CinePass VIP Gold',
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 500,
      moviesWatched: (json['moviesWatched'] as num?)?.toInt() ?? 10,
      savedSeats: (json['savedSeats'] as num?)?.toInt() ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'city': city,
      'avatarUrl': avatarUrl,
      'tier': tier,
      'loyaltyPoints': loyaltyPoints,
      'moviesWatched': moviesWatched,
      'savedSeats': savedSeats,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    String? phone,
    String? city,
    String? avatarUrl,
    String? tier,
    int? loyaltyPoints,
    int? moviesWatched,
    int? savedSeats,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tier: tier ?? this.tier,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      moviesWatched: moviesWatched ?? this.moviesWatched,
      savedSeats: savedSeats ?? this.savedSeats,
    );
  }
}
