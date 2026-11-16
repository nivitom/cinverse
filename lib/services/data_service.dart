import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/movie_model.dart';
import '../models/theatre_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  List<MovieModel> _movies = [];
  List<TheatreModel> _theatres = [];
  List<BookingModel> _initialBookings = [];
  List<UserModel> _users = [];
  bool _isLoaded = false;

  List<MovieModel> get movies => _movies;
  List<TheatreModel> get theatres => _theatres;
  List<BookingModel> get initialBookings => _initialBookings;
  List<UserModel> get users => _users;
  bool get isLoaded => _isLoaded;

  Future<void> loadAllData() async {
    if (_isLoaded) return;
    try {
      await Future.wait([
        _loadMovies(),
        _loadTheatres(),
        _loadBookings(),
        _loadUsers(),
      ]);
      _isLoaded = true;
    } catch (e) {
      _isLoaded = true;
    }
  }

  Future<void> _loadMovies() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/movies.json');
      final List<dynamic> list = json.decode(jsonString);
      _movies = list.map((item) => MovieModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      _movies = _fallbackMovies();
    }
  }

  Future<void> _loadTheatres() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/theatres.json');
      final List<dynamic> list = json.decode(jsonString);
      _theatres = list.map((item) => TheatreModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      _theatres = _fallbackTheatres();
    }
  }

  Future<void> _loadBookings() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/bookings.json');
      final List<dynamic> list = json.decode(jsonString);
      _initialBookings = list.map((item) => BookingModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      _initialBookings = [];
    }
  }

  Future<void> _loadUsers() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/users.json');
      final List<dynamic> list = json.decode(jsonString);
      _users = list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      _users = _fallbackUsers();
    }
  }

  List<UserModel> _fallbackUsers() {
    return [
      UserModel(
        id: 'USR-TN-1001',
        name: 'Karthik Ramachandran',
        email: 'karthik.tn@cineverse.in',
        password: 'Cinema@123',
        phone: '+91 98401 23456',
        city: 'Chennai',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop',
        tier: 'CinePass VIP Thalaivar',
        loyaltyPoints: 1250,
        moviesWatched: 28,
        savedSeats: 4,
      ),
      UserModel(
        id: 'USR-TN-1002',
        name: 'Ananya Sundaram',
        email: 'ananya.chennai@cineverse.in',
        password: 'Ananya@456',
        phone: '+91 97890 87654',
        city: 'Chennai',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=300&auto=format&fit=crop',
        tier: 'CinePass Gold Member',
        loyaltyPoints: 840,
        moviesWatched: 16,
        savedSeats: 2,
      ),
      UserModel(
        id: 'USR-TN-1003',
        name: 'Vijay Anand',
        email: 'vijayanand@cineverse.in',
        password: 'Vijay@789',
        phone: '+91 94432 11223',
        city: 'Madurai',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=300&auto=format&fit=crop',
        tier: 'CinePass Silver Member',
        loyaltyPoints: 420,
        moviesWatched: 9,
        savedSeats: 3,
      ),
      UserModel(
        id: 'USR-TN-1004',
        name: 'Priya Murugan',
        email: 'priya.cbe@cineverse.in',
        password: 'Priya@321',
        phone: '+91 98940 99887',
        city: 'Coimbatore',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
        tier: 'CinePass Premier Club',
        loyaltyPoints: 960,
        moviesWatched: 21,
        savedSeats: 6,
      ),
    ];
  }

  List<MovieModel> _fallbackMovies() {
    return [
      MovieModel(
        id: 'mov-tn-001',
        title: 'Amaran',
        genre: ['Action', 'Biography', 'Drama'],
        rating: 9.4,
        votes: '218.4K',
        duration: '2h 47m',
        releaseDate: '2024-10-31',
        certificate: 'UA 16+',
        language: 'Tamil (Dolby Atmos 7.1)',
        formats: ['IMAX 2D', 'Dolby Atmos', '2D Digital'],
        isFeatured: true,
        isNowShowing: true,
        isUpcoming: false,
        posterUrl: 'https://upload.wikimedia.org/wikipedia/en/5/54/Amaran_2024_poster.jpg',
        backdropUrl: 'https://upload.wikimedia.org/wikipedia/en/5/54/Amaran_2024_poster.jpg',
        synopsis: 'The heroic life of Major Mukund Varadarajan AC of the 44th Rashtriya Rifles in Kashmir.',
        director: 'Rajkumar Periasamy',
        price: 190.00,
        cast: [
          CastMember(name: 'Sivakarthikeyan', role: 'Major Mukund Varadarajan AC', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Sivakarthikeyan_at_the_Kashmora_Success_Meet.jpg/440px-Sivakarthikeyan_at_the_Kashmora_Success_Meet.jpg'),
          CastMember(name: 'Sai Pallavi', role: 'Indhu Rebecca Varghese', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Sai_Pallavi_at_Gargi_Press_Meet.jpg/440px-Sai_Pallavi_at_Gargi_Press_Meet.jpg'),
        ],
      ),
      MovieModel(
        id: 'mov-tn-002',
        title: 'The Greatest of All Time (GOAT)',
        genre: ['Sci-Fi', 'Action', 'Spy Thriller'],
        rating: 9.1,
        votes: '342.1K',
        duration: '3h 03m',
        releaseDate: '2024-09-05',
        certificate: 'UA 16+',
        language: 'Tamil (Dolby Atmos)',
        formats: ['IMAX 2D', 'Dolby Atmos', 'EPIQ', '2D Digital'],
        isFeatured: true,
        isNowShowing: true,
        isUpcoming: false,
        posterUrl: 'https://upload.wikimedia.org/wikipedia/en/1/1e/The_Greatest_of_All_Time.jpg',
        backdropUrl: 'https://upload.wikimedia.org/wikipedia/en/1/1e/The_Greatest_of_All_Time.jpg',
        synopsis: 'A seasoned field operative from SATS retires following a tragic mission, only to face a clone from his past.',
        director: 'Venkat Prabhu',
        price: 220.00,
        cast: [
          CastMember(name: 'Thalapathy Vijay', role: 'Gandhi & Jeevan', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Vijay_at_the_Varisu_Audio_Launch.jpg/440px-Vijay_at_the_Varisu_Audio_Launch.jpg'),
        ],
      ),
      MovieModel(
        id: 'mov-tn-003',
        title: 'Leo: Bloody Sweet',
        genre: ['Action', 'Crime', 'Thriller'],
        rating: 9.3,
        votes: '480.9K',
        duration: '2h 44m',
        releaseDate: '2023-10-19',
        certificate: 'UA 16+',
        language: 'Tamil (Dolby Atmos)',
        formats: ['IMAX 2D', 'Dolby Atmos', '4DX', '2D Digital'],
        isFeatured: true,
        isNowShowing: true,
        isUpcoming: false,
        posterUrl: 'https://upload.wikimedia.org/wikipedia/en/7/75/Leo_%282023_Indian_film%29.jpg',
        backdropUrl: 'https://upload.wikimedia.org/wikipedia/en/7/75/Leo_%282023_Indian_film%29.jpg',
        synopsis: 'A mild-mannered cafe owner in Himachal Pradesh is confronted by dangerous mobsters claiming he is a ruthless enforcer.',
        director: 'Lokesh Kanagaraj',
        price: 200.00,
        cast: [
          CastMember(name: 'Thalapathy Vijay', role: 'Parthiban / Leo Das', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Vijay_at_the_Varisu_Audio_Launch.jpg/440px-Vijay_at_the_Varisu_Audio_Launch.jpg'),
        ],
      ),
      MovieModel(
        id: 'mov-tn-004',
        title: 'Vettaiyan',
        genre: ['Action', 'Social Drama', 'Investigation'],
        rating: 9.0,
        votes: '194.2K',
        duration: '2h 43m',
        releaseDate: '2024-10-10',
        certificate: 'UA 16+',
        language: 'Tamil (Dolby Atmos)',
        formats: ['IMAX 2D', 'Dolby Atmos', '2D Digital'],
        isFeatured: true,
        isNowShowing: true,
        isUpcoming: false,
        posterUrl: 'https://upload.wikimedia.org/wikipedia/en/6/68/Vettaiyan_poster.jpg',
        backdropUrl: 'https://upload.wikimedia.org/wikipedia/en/6/68/Vettaiyan_poster.jpg',
        synopsis: 'SP Athiyan IPS, an encounter specialist, investigates a web of high-profile corruption and corporate educational scandals.',
        director: 'T.J. Gnanavel',
        price: 210.00,
        cast: [
          CastMember(name: 'Superstar Rajinikanth', role: 'SP Athiyan IPS', imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Rajinikanth_at_the_2019_International_Film_Festival_of_India.jpg/440px-Rajinikanth_at_the_2019_International_Film_Festival_of_India.jpg'),
        ],
      ),
    ];
  }

  List<TheatreModel> _fallbackTheatres() {
    return [
      TheatreModel(
        id: 'th-tn-001',
        name: 'Sathyam Cinemas (SPI)',
        chain: 'PVR INOX SPI',
        city: 'Chennai',
        distance: '2.4 km away',
        address: '8, Thiru Vi Ka Rd, Royapettah, Chennai, TN 600014',
        rating: 4.9,
        totalScreens: 6,
        amenities: ['RDX 4K Laser', 'Dolby Atmos', 'Famous Sathyam Popcorn'],
        screens: [
          ScreenModel(
            screenId: 'SCR-SATHYAM-1',
            name: 'Screen 1 – Sathyam Main',
            format: 'RDX 4K Dolby Atmos',
            basePrice: 190.00,
            showtimes: [
              ShowtimeModel(time: '09:30 AM', status: 'Available'),
              ShowtimeModel(time: '01:15 PM', status: 'Filling Fast'),
              ShowtimeModel(time: '05:00 PM', status: 'Almost Full'),
            ],
          ),
        ],
      ),
    ];
  }
}
