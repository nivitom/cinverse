class CastMember {
  final String name;
  final String role;
  final String imageUrl;

  CastMember({
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      name: json['name'] as String? ?? 'Actor',
      role: json['role'] as String? ?? 'Character',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'imageUrl': imageUrl,
    };
  }
}

class MovieModel {
  final String id;
  final String title;
  final List<String> genre;
  final double rating;
  final String votes;
  final String duration;
  final String releaseDate;
  final String certificate;
  final String language;
  final List<String> formats;
  final bool isFeatured;
  final bool isNowShowing;
  final bool isUpcoming;
  final String posterUrl;
  final String backdropUrl;
  final String synopsis;
  final String director;
  final double price;
  final List<CastMember> cast;

  MovieModel({
    required this.id,
    required this.title,
    required this.genre,
    required this.rating,
    required this.votes,
    required this.duration,
    required this.releaseDate,
    required this.certificate,
    required this.language,
    required this.formats,
    required this.isFeatured,
    required this.isNowShowing,
    required this.isUpcoming,
    required this.posterUrl,
    required this.backdropUrl,
    required this.synopsis,
    required this.director,
    required this.price,
    required this.cast,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Movie',
      genre: (json['genre'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 8.0,
      votes: json['votes'] as String? ?? '10K',
      duration: json['duration'] as String? ?? '2h 00m',
      releaseDate: json['releaseDate'] as String? ?? '',
      certificate: json['certificate'] as String? ?? 'UA',
      language: json['language'] as String? ?? 'English',
      formats: (json['formats'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['2D'],
      isFeatured: json['isFeatured'] as bool? ?? false,
      isNowShowing: json['isNowShowing'] as bool? ?? true,
      isUpcoming: json['isUpcoming'] as bool? ?? false,
      posterUrl: json['posterUrl'] as String? ?? '',
      backdropUrl: json['backdropUrl'] as String? ?? '',
      synopsis: json['synopsis'] as String? ?? '',
      director: json['director'] as String? ?? 'Director',
      price: (json['price'] as num?)?.toDouble() ?? 12.00,
      cast: (json['cast'] as List<dynamic>?)
              ?.map((item) => CastMember.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'rating': rating,
      'votes': votes,
      'duration': duration,
      'releaseDate': releaseDate,
      'certificate': certificate,
      'language': language,
      'formats': formats,
      'isFeatured': isFeatured,
      'isNowShowing': isNowShowing,
      'isUpcoming': isUpcoming,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'synopsis': synopsis,
      'director': director,
      'price': price,
      'cast': cast.map((c) => c.toJson()).toList(),
    };
  }
}
