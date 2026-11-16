import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'data_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  bool _isLoggedIn = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  List<UserModel> get predefinedUsers {
    final loaded = DataService().users;
    if (loaded.isNotEmpty) return loaded;
    return DataService().fallbackUsers;
  }

  void initDemoUser() {
    final list = predefinedUsers;
    _currentUser = list.isNotEmpty ? list.first : null;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final match = predefinedUsers.firstWhere(
      (u) =>
          u.email.toLowerCase() == email.trim().toLowerCase() &&
          (u.password.isEmpty || u.password == password.trim()),
      orElse: () => UserModel(
        id: 'USR-TN-${DateTime.now().millisecondsSinceEpoch % 10000}',
        name: email.split('@').first.toUpperCase(),
        email: email,
        password: password,
        phone: '+91 98400 11223',
        city: 'Chennai',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop',
      ),
    );

    _currentUser = match;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  void selectPredefinedUser(UserModel user) {
    _currentUser = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password, String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = UserModel(
      id: 'USR-TN-${DateTime.now().millisecondsSinceEpoch % 10000}',
      name: name,
      email: email,
      password: password,
      phone: phone,
      city: 'Chennai',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop',
    );
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  void loginAsGuest() {
    _currentUser = UserModel(
      id: 'GUEST-TN-01',
      name: 'Tamil Cinema Fan (Guest)',
      email: 'guest@cineverse.in',
      phone: '+91 90000 00000',
      city: 'Chennai',
      avatarUrl: '',
      tier: 'Standard Member',
      loyaltyPoints: 100,
      moviesWatched: 2,
      savedSeats: 0,
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  void updateProfile({String? name, String? phone}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: name, phone: phone);
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}

extension DataServiceFallbackUsers on DataService {
  List<UserModel> get fallbackUsers => [
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
