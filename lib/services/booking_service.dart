import 'dart:math';
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../models/theatre_model.dart';
import '../models/seat_model.dart';
import '../models/booking_model.dart';
import 'data_service.dart';

class SnackItem {
  final String id;
  final String name;
  final String description;
  final double price; // in INR (₹)
  final String icon;

  const SnackItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
  });
}

class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  // Booking Draft
  MovieModel? selectedMovie;
  TheatreModel? selectedTheatre;
  ScreenModel? selectedScreen;
  String selectedShowtime = '06:15 PM';
  String selectedDate = 'Today, 14 Nov';
  List<SeatModel> selectedSeats = [];
  Map<String, int> selectedSnacks = {}; // itemId -> quantity
  String? appliedPromoCode;
  double promoDiscountPercent = 0.0;

  // Authentic Tamil Nadu Cinema Canteen Refreshments (in ₹)
  final List<SnackItem> availableSnacks = const [
    SnackItem(
      id: 'snk-tn-1',
      name: 'Famous Butter Popcorn (Large Tub)',
      description: 'Warm, crispy cinema popcorn with rich golden butter drizzle',
      price: 150.00,
      icon: '🍿',
    ),
    SnackItem(
      id: 'snk-tn-2',
      name: 'Crispy Veg Samosa (2 Pcs)',
      description: 'Spiced potato & green peas puff served with tangy mint chutney',
      price: 80.00,
      icon: '🥟',
    ),
    SnackItem(
      id: 'snk-tn-3',
      name: 'South Indian Filter Coffee',
      description: 'Traditional hot frothy decoction milk coffee in cinema tumbler',
      price: 60.00,
      icon: '☕',
    ),
    SnackItem(
      id: 'snk-tn-4',
      name: 'Chilled Fountain Soda (650ml)',
      description: 'Ice-cold Thums Up, Sprite or Coca-Cola with extra fizz',
      price: 90.00,
      icon: '🥤',
    ),
  ];

  // Confirmed Bookings list
  final List<BookingModel> _bookings = [];
  bool _seeded = false;

  List<BookingModel> get bookings {
    _ensureSeeded();
    return List.unmodifiable(_bookings);
  }

  List<BookingModel> get activeBookings {
    _ensureSeeded();
    return _bookings.where((b) => b.status == 'CONFIRMED').toList();
  }

  List<BookingModel> get pastBookings {
    _ensureSeeded();
    return _bookings.where((b) => b.status == 'COMPLETED' || b.status == 'CANCELLED').toList();
  }

  void _ensureSeeded() {
    if (!_seeded) {
      final initial = DataService().initialBookings;
      if (initial.isNotEmpty) {
        _bookings.addAll(initial);
      }
      _seeded = true;
    }
  }

  // Draft Mutations
  void setMovie(MovieModel movie) {
    selectedMovie = movie;
    notifyListeners();
  }

  void setTheatre(TheatreModel theatre) {
    selectedTheatre = theatre;
    if (theatre.screens.isNotEmpty) {
      selectedScreen = theatre.screens.first;
      if (selectedScreen!.showtimes.isNotEmpty) {
        selectedShowtime = selectedScreen!.showtimes.first.time;
      }
    }
    notifyListeners();
  }

  void setScreen(ScreenModel screen) {
    selectedScreen = screen;
    if (screen.showtimes.isNotEmpty) {
      selectedShowtime = screen.showtimes.first.time;
    }
    notifyListeners();
  }

  void setShowtime(String showtime) {
    selectedShowtime = showtime;
    notifyListeners();
  }

  void setDate(String date) {
    selectedDate = date;
    notifyListeners();
  }

  void toggleSeat(SeatModel seat) {
    final existingIndex = selectedSeats.indexWhere((s) => s.id == seat.id);
    if (existingIndex >= 0) {
      selectedSeats.removeAt(existingIndex);
    } else {
      selectedSeats.add(seat.copyWith(status: SeatStatus.selected));
    }
    notifyListeners();
  }

  void clearSeats() {
    selectedSeats.clear();
    notifyListeners();
  }

  void updateSnackQuantity(String snackId, int delta) {
    final current = selectedSnacks[snackId] ?? 0;
    final updated = current + delta;
    if (updated <= 0) {
      selectedSnacks.remove(snackId);
    } else {
      selectedSnacks[snackId] = updated;
    }
    notifyListeners();
  }

  bool applyPromoCode(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'CINEMA20' || clean == 'THALAIVAR20' || clean == 'VIP20') {
      appliedPromoCode = clean;
      promoDiscountPercent = 0.20; // 20%
      notifyListeners();
      return true;
    } else if (clean == 'FIRST10') {
      appliedPromoCode = clean;
      promoDiscountPercent = 0.10; // 10%
      notifyListeners();
      return true;
    }
    return false;
  }

  void removePromoCode() {
    appliedPromoCode = null;
    promoDiscountPercent = 0.0;
    notifyListeners();
  }

  // Price Calculations in INR (₹)
  double get ticketsSubtotal {
    if (selectedSeats.isEmpty) return 0.0;
    return selectedSeats.fold(0.0, (sum, seat) => sum + seat.price);
  }

  double get snacksSubtotal {
    double total = 0.0;
    selectedSnacks.forEach((snackId, qty) {
      final item = availableSnacks.firstWhere(
        (s) => s.id == snackId,
        orElse: () => const SnackItem(id: '', name: '', description: '', price: 0, icon: ''),
      );
      total += item.price * qty;
    });
    return total;
  }

  double get convenienceFee {
    if (selectedSeats.isEmpty) return 0.0;
    return 30.0 * selectedSeats.length; // ₹30 per ticket convenience fee
  }

  double get tax {
    final base = ticketsSubtotal + snacksSubtotal;
    return base * 0.18; // 18% GST in India
  }

  double get discountAmount {
    final base = ticketsSubtotal + snacksSubtotal;
    return base * promoDiscountPercent;
  }

  double get grandTotal {
    final total = ticketsSubtotal + snacksSubtotal + convenienceFee + tax - discountAmount;
    return total > 0 ? total : 0.0;
  }

  // Complete Booking
  BookingModel completeBooking({required String paymentMethod}) {
    _ensureSeeded();

    final rnd = Random();
    final bookingId = 'BK-TN-${rnd.nextInt(90000) + 10000}';
    final cityPrefix = (selectedTheatre?.city.substring(0, min(3, selectedTheatre!.city.length)) ?? 'CHN').toUpperCase();
    final bookingCode = 'CNV-$cityPrefix-${rnd.nextInt(900000) + 100000}';

    final movie = selectedMovie;
    final theatre = selectedTheatre;
    final screen = selectedScreen;

    final primarySeatTier = selectedSeats.isNotEmpty ? selectedSeats.first.tierName : 'Standard';

    final newBooking = BookingModel(
      id: bookingId,
      movieId: movie?.id ?? 'mov-tn-001',
      movieTitle: movie?.title ?? 'Amaran',
      posterUrl: movie?.posterUrl ?? '',
      backdropUrl: movie?.backdropUrl ?? '',
      theatreId: theatre?.id ?? 'th-tn-001',
      theatreName: theatre?.name ?? 'Sathyam Cinemas (SPI)',
      theatreAddress: theatre?.address ?? '8, Thiru Vi Ka Rd, Royapettah, Chennai',
      screen: screen?.name ?? 'Screen 1 – Sathyam Main',
      format: screen?.format ?? 'RDX 4K Dolby Atmos',
      showDate: selectedDate,
      showTime: selectedShowtime,
      seats: selectedSeats.map((s) => s.id).toList(),
      seatTier: primarySeatTier,
      ticketCount: selectedSeats.length,
      ticketPrice: selectedSeats.isNotEmpty ? selectedSeats.first.price : 190.0,
      convenienceFee: convenienceFee,
      tax: tax,
      discount: discountAmount,
      totalAmount: grandTotal,
      paymentMethod: paymentMethod,
      bookingTimestamp: DateTime.now().toIso8601String(),
      status: 'CONFIRMED',
      bookingCode: bookingCode,
    );

    _bookings.insert(0, newBooking);
    notifyListeners();
    return newBooking;
  }

  void cancelBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index >= 0) {
      _bookings[index].status = 'CANCELLED';
      notifyListeners();
    }
  }

  void resetDraft() {
    selectedSeats.clear();
    selectedSnacks.clear();
    appliedPromoCode = null;
    promoDiscountPercent = 0.0;
    notifyListeners();
  }
}
