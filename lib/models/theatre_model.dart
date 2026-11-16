class ShowtimeModel {
  final String time;
  final String status; // 'Available', 'Filling Fast', 'Almost Full', 'Sold Out'

  ShowtimeModel({
    required this.time,
    required this.status,
  });

  factory ShowtimeModel.fromJson(Map<String, dynamic> json) {
    return ShowtimeModel(
      time: json['time'] as String? ?? '12:00 PM',
      status: json['status'] as String? ?? 'Available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'status': status,
    };
  }
}

class ScreenModel {
  final String screenId;
  final String name;
  final String format; // 'IMAX 3D Laser', 'Dolby Cinema', '4DX', '2D'
  final double basePrice;
  final List<ShowtimeModel> showtimes;

  ScreenModel({
    required this.screenId,
    required this.name,
    required this.format,
    required this.basePrice,
    required this.showtimes,
  });

  factory ScreenModel.fromJson(Map<String, dynamic> json) {
    return ScreenModel(
      screenId: json['screenId'] as String? ?? 'SCR-1',
      name: json['name'] as String? ?? 'Screen 1',
      format: json['format'] as String? ?? '2D Digital',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 12.0,
      showtimes: (json['showtimes'] as List<dynamic>?)
              ?.map((s) => ShowtimeModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'screenId': screenId,
      'name': name,
      'format': format,
      'basePrice': basePrice,
      'showtimes': showtimes.map((s) => s.toJson()).toList(),
    };
  }
}

class TheatreModel {
  final String id;
  final String name;
  final String chain;
  final String city;
  final String distance;
  final String address;
  final double rating;
  final int totalScreens;
  final List<String> amenities;
  final List<ScreenModel> screens;

  TheatreModel({
    required this.id,
    required this.name,
    required this.chain,
    required this.city,
    required this.distance,
    required this.address,
    required this.rating,
    required this.totalScreens,
    required this.amenities,
    required this.screens,
  });

  factory TheatreModel.fromJson(Map<String, dynamic> json) {
    return TheatreModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Cinema',
      chain: json['chain'] as String? ?? 'Chain',
      city: json['city'] as String? ?? 'New York',
      distance: json['distance'] as String? ?? '2.0 km away',
      address: json['address'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      totalScreens: (json['totalScreens'] as num?)?.toInt() ?? 4,
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      screens: (json['screens'] as List<dynamic>?)
              ?.map((s) => ScreenModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'chain': chain,
      'city': city,
      'distance': distance,
      'address': address,
      'rating': rating,
      'totalScreens': totalScreens,
      'amenities': amenities,
      'screens': screens.map((s) => s.toJson()).toList(),
    };
  }
}
