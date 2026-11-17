import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cineverse/models/movie_model.dart';
import 'package:cineverse/models/theatre_model.dart';
import 'package:cineverse/models/seat_model.dart';
import 'package:cineverse/services/booking_service.dart';
import 'package:cineverse/services/auth_service.dart';
import 'package:cineverse/services/location_service.dart';
import 'package:cineverse/widgets/seat_item_widget.dart';
import 'package:cineverse/widgets/custom_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Model Tests', () {
    test('MovieModel parses Tamil blockbuster json properly', () {
      final json = {
        'id': 'mov-tn-001',
        'title': 'Amaran',
        'genre': ['Action', 'Biography', 'Drama'],
        'rating': 9.4,
        'votes': '218K',
        'duration': '2h 47m',
        'releaseDate': '2024-10-31',
        'certificate': 'UA 16+',
        'language': 'Tamil (Dolby Atmos 7.1)',
        'formats': ['IMAX', 'Dolby Atmos', '2D Digital'],
        'isFeatured': true,
        'isNowShowing': true,
        'isUpcoming': false,
        'posterUrl': '',
        'backdropUrl': '',
        'synopsis': 'The heroic life of Major Mukund Varadarajan AC in Kashmir.',
        'director': 'Rajkumar Periasamy',
        'price': 190.00,
        'cast': [
          {'name': 'Sivakarthikeyan', 'role': 'Major Mukund', 'imageUrl': ''},
          {'name': 'Sai Pallavi', 'role': 'Indhu', 'imageUrl': ''}
        ],
      };

      final movie = MovieModel.fromJson(json);
      expect(movie.id, 'mov-tn-001');
      expect(movie.title, 'Amaran');
      expect(movie.language, 'Tamil (Dolby Atmos 7.1)');
      expect(movie.price, 190.00);
      expect(movie.cast.length, 2);
    });

    test('TheatreModel parses Tamil Nadu theatres json properly', () {
      final json = {
        'id': 'theatre-sathyam-chennai',
        'name': 'Sathyam SPI Cinemas, Royapettah',
        'chain': 'SPI Cinemas',
        'city': 'Chennai',
        'distance': '3.2 km away',
        'address': '8, Thiruvika Rd, Royapettah, Chennai, Tamil Nadu 600014',
        'amenities': ['Dolby Atmos', 'RGB Laser 4K', 'Gourmet Popcorn', 'M-Ticket'],
        'screens': [
          {
            'screenId': 'scr-01',
            'name': 'Sathyam Audi 1',
            'format': 'Dolby Atmos 7.1',
            'basePrice': 190.0,
            'showtimes': [
              {'id': 'st-1', 'time': '10:30 AM', 'type': 'Dolby Atmos', 'fillingFast': false},
              {'id': 'st-2', 'time': '02:15 PM', 'type': 'Dolby Atmos', 'fillingFast': true}
            ]
          }
        ]
      };

      final theatre = TheatreModel.fromJson(json);
      expect(theatre.name, contains('Sathyam'));
      expect(theatre.city, 'Chennai');
      expect(theatre.screens.first.showtimes.length, 2);
    });
  });

  group('AuthService Tests', () {
    test('AuthService contains exactly 4 predefined static Tamil Nadu accounts', () {
      final authService = AuthService();
      final users = authService.predefinedUsers;

      expect(users.length, 4);
      expect(users[0].name, 'Karthik Ramachandran');
      expect(users[0].email, 'karthik.tn@cineverse.in');
      expect(users[0].password, 'Cinema@123');

      expect(users[1].name, 'Ananya Sundaram');
      expect(users[1].email, 'ananya.chennai@cineverse.in');

      expect(users[2].name, 'Vijay Anand');
      expect(users[2].email, 'vijayanand@cineverse.in');

      expect(users[3].name, 'Priya Murugan');
      expect(users[3].email, 'priya.cbe@cineverse.in');
    });

    test('AuthService login successfully authenticates demo account', () async {
      final authService = AuthService();
      final success = await authService.login('karthik.tn@cineverse.in', 'Cinema@123');
      expect(success, true);
      expect(authService.currentUser?.name, 'Karthik Ramachandran');
    });
  });

  group('LocationService Tests', () {
    test('LocationService restricts cities to Tamil Nadu major districts', () {
      final locService = LocationService();
      final cities = locService.cities;

      expect(cities.length, greaterThanOrEqualTo(10));
      expect(cities.any((c) => c.name == 'Chennai'), true);
      expect(cities.any((c) => c.name == 'Coimbatore'), true);
      expect(cities.any((c) => c.name == 'Madurai'), true);
      expect(cities.any((c) => c.name == 'Tiruchirappalli'), true);
      expect(cities.any((c) => c.name == 'Salem'), true);
      expect(cities.any((c) => c.name == 'Tirunelveli'), true);

      // Verify all states are Tamil Nadu
      for (final city in cities) {
        expect(city.state, 'Tamil Nadu');
      }
    });

    test('LocationService selects city properly', () {
      final locService = LocationService();
      locService.selectCity('Coimbatore');
      expect(locService.selectedCity, 'Coimbatore');
    });
  });

  group('BookingService & Currency Tests', () {
    test('BookingService calculates INR (₹) prices, snacks, GST 18%, and promo discounts correctly', () {
      final bookingService = BookingService();
      bookingService.resetDraft();

      final seat1 = SeatModel(
        id: 'A1',
        row: 'A',
        number: 1,
        tier: SeatTier.vip,
        price: 240.00, // ₹240
      );
      final seat2 = SeatModel(
        id: 'A2',
        row: 'A',
        number: 2,
        tier: SeatTier.vip,
        price: 240.00, // ₹240
      );

      bookingService.toggleSeat(seat1);
      bookingService.toggleSeat(seat2);

      expect(bookingService.selectedSeats.length, 2);
      expect(bookingService.ticketsSubtotal, 480.00);
      expect(bookingService.convenienceFee, 60.00); // ₹30 * 2 seats

      // Add snacks (Famous Butter Popcorn ₹150)
      bookingService.updateSnackQuantity('snk-tn-1', 1);
      expect(bookingService.snacksSubtotal, 150.00);

      // Apply 20% promo
      final promoApplied = bookingService.applyPromoCode('CINEMA20');
      expect(promoApplied, true);
      expect(bookingService.promoDiscountPercent, 0.20);
      // 20% discount on order (480 + 150 = 630 * 0.20 = 126.0)
      expect(bookingService.discountAmount, 126.00);

      // Verify Grand Total calculation
      final expectedTax = (480.00 + 150.00) * 0.18;
      expect(bookingService.tax, expectedTax);
      final expectedTotal = 480.00 + 150.00 + 60.00 + expectedTax - 126.00;
      expect(bookingService.grandTotal, closeTo(expectedTotal, 0.01));
    });

    test('BookingService completes booking and generates valid M-Ticket', () {
      final bookingService = BookingService();
      final movie = MovieModel(
        id: 'm1',
        title: 'Amaran',
        genre: ['Action'],
        rating: 9.4,
        votes: '218K',
        duration: '2h 47m',
        releaseDate: '2024-10-31',
        certificate: 'UA',
        language: 'Tamil',
        formats: ['Dolby Atmos'],
        isFeatured: true,
        isNowShowing: true,
        isUpcoming: false,
        posterUrl: '',
        backdropUrl: '',
        synopsis: 'Synopsis',
        director: 'Director',
        price: 190.0,
        cast: [],
      );

      bookingService.selectedMovie = movie;
      final seat = SeatModel(id: 'E4', row: 'E', number: 4, tier: SeatTier.premium, price: 190.0);
      bookingService.toggleSeat(seat);

      final booking = bookingService.completeBooking(paymentMethod: 'RuPay Platinum');
      expect(booking.movieTitle, 'Amaran');
      expect(booking.bookingCode, startsWith('CNV-'));
      expect(booking.paymentMethod, 'RuPay Platinum');
      expect(bookingService.activeBookings.any((b) => b.id == booking.id), true);

      // Test cancellation
      bookingService.cancelBooking(booking.id);
      expect(bookingService.pastBookings.any((b) => b.id == booking.id && b.status == 'CANCELLED'), true);
    });

    test('BookingService requestedSeatCount restricts 1 to 10 and resets properly', () {
      final bookingService = BookingService();
      bookingService.setRequestedSeatCount(5);
      expect(bookingService.requestedSeatCount, 5);

      bookingService.setRequestedSeatCount(0); // below min
      expect(bookingService.requestedSeatCount, 1);

      bookingService.setRequestedSeatCount(15); // above max
      expect(bookingService.requestedSeatCount, 10);

      bookingService.resetDraft();
      expect(bookingService.requestedSeatCount, 2);
      expect(bookingService.selectedSeats.isEmpty, true);
    });

    test('BookingService calculates ticket prices dynamically based on seat tiers', () {
      final bookingService = BookingService();
      bookingService.resetDraft();

      final vipSeat = SeatModel(id: 'A1', row: 'A', number: 1, tier: SeatTier.vip, price: 250.0);
      final primeSeat = SeatModel(id: 'B1', row: 'B', number: 1, tier: SeatTier.premium, price: 220.0);
      final classicSeat = SeatModel(id: 'E1', row: 'E', number: 1, tier: SeatTier.standard, price: 190.0);

      bookingService.toggleSeat(vipSeat);
      expect(bookingService.ticketsSubtotal, 250.0);

      bookingService.toggleSeat(primeSeat);
      expect(bookingService.ticketsSubtotal, 470.0);

      bookingService.toggleSeat(classicSeat);
      expect(bookingService.ticketsSubtotal, 660.0);

      // Deselect primeSeat
      bookingService.toggleSeat(primeSeat);
      expect(bookingService.ticketsSubtotal, 440.0);
      expect(bookingService.selectedSeats.length, 2);
    });
  });

  group('Widget Tests', () {
    testWidgets('CustomButton renders with text and responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Book Tickets',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Book Tickets'), findsOneWidget);
      await tester.tap(find.text('Book Tickets'));
      expect(tapped, true);
    });

    testWidgets('SeatItemWidget renders properly across states', (tester) async {
      final availableSeat = SeatModel(id: 'B3', row: 'B', number: 3, tier: SeatTier.standard, price: 140.0, status: SeatStatus.available);
      final selectedSeat = SeatModel(id: 'B4', row: 'B', number: 4, tier: SeatTier.standard, price: 140.0, status: SeatStatus.selected);
      final bookedSeat = SeatModel(id: 'B5', row: 'B', number: 5, tier: SeatTier.standard, price: 140.0, status: SeatStatus.booked);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                SeatItemWidget(seat: availableSeat, onTap: () {}),
                SeatItemWidget(seat: selectedSeat, onTap: () {}),
                SeatItemWidget(seat: bookedSeat, onTap: () {}),
              ],
            ),
          ),
        ),
      );

      // Available seat displays seat number '3' and white fill
      expect(find.text('3'), findsOneWidget);
      // Selected seat displays checkmark icon and red fill
      expect(find.byIcon(Icons.check), findsOneWidget);
      // Booked seat displays close icon and grey fill
      expect(find.byIcon(Icons.close), findsOneWidget);

      final containers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).toList();
      final availableBox = containers[0].decoration as BoxDecoration;
      final selectedBox = containers[1].decoration as BoxDecoration;
      final bookedBox = containers[2].decoration as BoxDecoration;

      expect(availableBox.color, Colors.white);
      expect(selectedBox.color, const Color(0xFFE31E24)); // Red
      expect(bookedBox.color, const Color(0xFFE0E0E0)); // Grey
    });
  });
}
