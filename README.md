# CINEVERSE – Movie Ticket Booking Mobile App

A modern, cinema-style Movie Ticket Booking mobile application built with **Flutter** and **Dart**, inspired by the signature **BookMyShow Red & White UI design** (`#E31E24`, `#FFFFFF`, `#171717`, `#F5F5F5`).

Dedicated to **Tamil Nadu** cinema entertainment, featuring major Kollywood blockbusters, realistic Tamil Nadu multiplexes/single-screens, and full offline static JSON architecture.

---

## 🌟 Features

- **BookMyShow UI Theme**: Signature Red & White theme with crisp typography, rounded cards, bottom navigation, and authentic theatrical release posters.
- **Tamil Nadu Focus**: Pre-seeded with authentic Kollywood blockbusters (*Amaran*, *The Greatest of All Time*, *Leo*, *Vettaiyan*, *Jailer*, *Vikram*, *Coolie*, *Thug Life*), top Tamil Nadu cinema chains (SPI Sathyam, Palazzo, Rohini, Broadway EPIQ, Vettri), and districts.
- **GPS Location Detection**: Real device GPS geolocation detection across Tamil Nadu districts with manual city selector fallback.
- **Interactive Seat Selection**: Curved cinema screen projection beam, real-time seat tier selection (Recliners, Prime, Classic), status tracking (Available, Selected, Sold), and live pricing in Indian Rupees (₹).
- **Cinema Canteen & F&B**: In-cart popcorn, filter coffee, samosas, and cold drinks with live quantity updates.
- **Promo Codes**: Interactive coupon code redemption (`CINEMA20`, `THALAIVAR20`) with instant 20% discount calculation.
- **M-Ticket Pass & QR Gate**: Digital perforated cutout M-Ticket with generated booking codes (`CNV-`), turnstile QR code, and cancellation option.
- **Predefined Demo Accounts**: Exactly 4 preconfigured Tamil Nadu user profiles with 1-tap autofill login for testing.

---

## 📱 Screens (13 Screens)

1. **Splash Screen**: Animated CINEVERSE logo with two-tone branding.
2. **Onboarding Screen**: Feature showcase with interactive indicator dots.
3. **Authentication Screen**: Sign-in / registration with 4 preconfigured demo user profiles and guest login option.
4. **Home Screen**: Live location chip, Kollywood category strip, trending carousel banner, genre filters, and movie cards.
5. **Movie Details Screen**: Backdrop hero banner, format selector, storyline synopsis, trailer modal, and cast & crew gallery.
6. **Location Selection Screen**: Live GPS detector and searchable Tamil Nadu city/district list.
7. **Theatre Selection Screen**: Multiplex listings with distance, amenities badges, and screen counts.
8. **Date & Showtime Selection Screen**: 8-day horizontal calendar strip and showtime chips categorized by seat availability.
9. **Interactive Seat Selection Screen**: Interactive seat layout with tier pricing and real-time total calculator.
10. **Booking Summary Screen**: Ticket summary, F&B snack addons, promo code apply, and tax breakdown.
11. **Payment Screen**: RuPay Platinum card visualization and UPI options (GPay, PhonePe, Paytm).
12. **Booking Success Screen**: Cutout perforated M-Ticket with turnstile QR code and wallet download.
13. **My Bookings Screen**: Tabbed view of active M-Tickets and past booking history with cancellation support.
14. **Profile Screen**: User stats, loyalty points, city settings, and notifications toggle.

---

## 🔑 Demo Login Credentials

| User | Email | Password | Location | Tier |
|---|---|---|---|---|
| Karthik Ramachandran | `karthik.tn@cineverse.in` | `Cinema@123` | Chennai | CinePass VIP Thalaivar |
| Ananya Sundaram | `ananya.chennai@cineverse.in` | `Ananya@456` | Chennai | CinePass Gold Member |
| Vijay Anand | `vijayanand@cineverse.in` | `Vijay@789` | Madurai | CinePass Silver Member |
| Priya Murugan | `priya.cbe@cineverse.in` | `Priya@321` | Coimbatore | CinePass Premier Club |

---

## 🏗️ Architecture & Project Structure

Organized into clean, maintainable layers:

```
lib/
├── main.dart                  # Application entry point
├── models/                    # Data models (Movie, Theatre, Seat, Booking, User)
├── screens/                   # 14 complete Flutter UI screens
├── services/                  # Business logic (AuthService, BookingService, LocationService, DataService)
├── utils/                     # Theming, BookMyShow colors, typography
└── widgets/                   # Reusable components (MovieCard, SeatWidget, CustomButton, BottomBar, etc.)
assets/
└── data/                      # Static JSON datasets (movies.json, theatres.json, bookings.json, users.json)
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.13+ or higher
- Dart 3.0+
- Android Studio / VS Code / Antigravity IDE

### Installation & Run

```bash
# Clone the repository
git clone https://github.com/nivitom/cinverse.git

# Navigate into the project directory
cd cinverse

# Install dependencies
flutter pub get

# Run analyzer
flutter analyze

# Run unit and widget tests
flutter test

# Run the app on connected emulator or device
flutter run
```

---

## 📄 License
This project is developed for educational and portfolio demonstration purposes. All movie titles and imagery belong to their respective copyright holders.
