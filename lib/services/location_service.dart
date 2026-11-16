import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CityItem {
  final String name;
  final String state;
  final String district;
  final String icon;
  final int theatreCount;
  final double latitude;
  final double longitude;

  const CityItem({
    required this.name,
    required this.state,
    required this.district,
    required this.icon,
    required this.theatreCount,
    required this.latitude,
    required this.longitude,
  });
}

class LocationResult {
  final bool success;
  final String city;
  final String message;

  LocationResult({
    required this.success,
    required this.city,
    required this.message,
  });
}

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  String _selectedCity = 'Chennai';
  bool _isLocating = false;

  bool get isLocating => _isLocating;
  String get selectedCity => _selectedCity;

  final List<CityItem> _cities = const [
    CityItem(
      name: 'Chennai',
      state: 'Tamil Nadu',
      district: 'Chennai District',
      icon: '🏛️',
      theatreCount: 68,
      latitude: 13.0827,
      longitude: 80.2707,
    ),
    CityItem(
      name: 'Coimbatore',
      state: 'Tamil Nadu',
      district: 'Coimbatore District',
      icon: '⛰️',
      theatreCount: 34,
      latitude: 11.0168,
      longitude: 76.9558,
    ),
    CityItem(
      name: 'Madurai',
      state: 'Tamil Nadu',
      district: 'Madurai District',
      icon: '🛕',
      theatreCount: 26,
      latitude: 9.9252,
      longitude: 78.1198,
    ),
    CityItem(
      name: 'Tiruchirappalli',
      state: 'Tamil Nadu',
      district: 'Trichy District',
      icon: '🏰',
      theatreCount: 18,
      latitude: 10.7905,
      longitude: 78.7047,
    ),
    CityItem(
      name: 'Salem',
      state: 'Tamil Nadu',
      district: 'Salem District',
      icon: '🏭',
      theatreCount: 15,
      latitude: 11.6643,
      longitude: 78.1460,
    ),
    CityItem(
      name: 'Tirunelveli',
      state: 'Tamil Nadu',
      district: 'Tirunelveli District',
      icon: '🍮',
      theatreCount: 12,
      latitude: 8.7139,
      longitude: 77.7567,
    ),
    CityItem(
      name: 'Vellore',
      state: 'Tamil Nadu',
      district: 'Vellore District',
      icon: '🛡️',
      theatreCount: 11,
      latitude: 12.9165,
      longitude: 79.1325,
    ),
    CityItem(
      name: 'Erode',
      state: 'Tamil Nadu',
      district: 'Erode District',
      icon: '🌾',
      theatreCount: 10,
      latitude: 11.3410,
      longitude: 77.7172,
    ),
    CityItem(
      name: 'Tiruppur',
      state: 'Tamil Nadu',
      district: 'Tiruppur District',
      icon: '🧵',
      theatreCount: 12,
      latitude: 11.1085,
      longitude: 77.3411,
    ),
    CityItem(
      name: 'Thanjavur',
      state: 'Tamil Nadu',
      district: 'Thanjavur District',
      icon: '👑',
      theatreCount: 9,
      latitude: 10.7870,
      longitude: 79.1378,
    ),
    CityItem(
      name: 'Dindigul',
      state: 'Tamil Nadu',
      district: 'Dindigul District',
      icon: '🔒',
      theatreCount: 8,
      latitude: 10.3673,
      longitude: 77.9803,
    ),
    CityItem(
      name: 'Kanchipuram',
      state: 'Tamil Nadu',
      district: 'Kanchipuram District',
      icon: '🥻',
      theatreCount: 7,
      latitude: 12.8342,
      longitude: 79.7036,
    ),
  ];

  List<CityItem> get cities => _cities;

  void selectCity(String city) {
    if (_selectedCity != city) {
      _selectedCity = city;
      notifyListeners();
    }
  }

  /// Detect actual GPS location using device sensors and geocoding
  Future<LocationResult> detectCurrentGPSLocation() async {
    _isLocating = true;
    notifyListeners();

    try {
      // 1. Check if device location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLocating = false;
        notifyListeners();
        return LocationResult(
          success: false,
          city: _selectedCity,
          message: 'Location service is disabled on device. Please enable GPS in system settings.',
        );
      }

      // 2. Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLocating = false;
          notifyListeners();
          return LocationResult(
            success: false,
            city: _selectedCity,
            message: 'Location permission was denied. Please allow permission to detect your city.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLocating = false;
        notifyListeners();
        return LocationResult(
          success: false,
          city: _selectedCity,
          message: 'Location permission permanently denied. Enable it in app settings.',
        );
      }

      // 3. Obtain actual current GPS position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );

      // 4. Reverse Geocode actual position to detect city name
      String? detectedCityName;
      try {
        final geocoder = Geocoding();
        final placemarks = await geocoder.placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          detectedCityName = place.locality?.isNotEmpty == true
              ? place.locality
              : place.subAdministrativeArea?.isNotEmpty == true
                  ? place.subAdministrativeArea
                  : place.administrativeArea;
        }
      } catch (_) {
        // In case reverse geocode network lookup has high latency, use coordinates
      }

      // 5. Match with known Tamil Nadu cities or coordinate proximity
      String matchedCity = _matchCity(detectedCityName, position.latitude, position.longitude);
      _selectedCity = matchedCity;
      _isLocating = false;
      notifyListeners();

      return LocationResult(
        success: true,
        city: matchedCity,
        message: 'Successfully detected your location: $matchedCity',
      );
    } catch (e) {
      _isLocating = false;
      notifyListeners();
      return LocationResult(
        success: false,
        city: _selectedCity,
        message: 'Could not fetch GPS coordinates: ${e.toString().split('\n').first}',
      );
    }
  }

  String _matchCity(String? detectedName, double lat, double lon) {
    if (detectedName != null && detectedName.isNotEmpty) {
      // Check if exact or partial match in TN cities
      for (final c in _cities) {
        if (c.name.toLowerCase() == detectedName.toLowerCase() ||
            detectedName.toLowerCase().contains(c.name.toLowerCase()) ||
            c.district.toLowerCase().contains(detectedName.toLowerCase())) {
          return c.name;
        }
      }
      // If the detected city is valid but not in predefined list, return detected city directly
      return detectedName;
    }

    // Proximity fallback based on minimum distance to Tamil Nadu city centers
    CityItem nearest = _cities.first;
    double minDistance = double.infinity;

    for (final c in _cities) {
      final d = _haversineDistance(lat, lon, c.latitude, c.longitude);
      if (d < minDistance) {
        minDistance = d;
        nearest = c;
      }
    }
    return nearest.name;
  }

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
