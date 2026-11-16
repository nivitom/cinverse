import 'package:flutter/material.dart';

class AppColors {
  // BookMyShow Signature Primary Red (#E31E24)
  static const Color primary = Color(0xFFE31E24);
  static const Color primaryDark = Color(0xFFB81419);
  static const Color primaryLight = Color(0xFFFF383E);
  static const Color primaryHover = Color(0xFFCC171D);

  // BookMyShow White & Light Grey Theme (#FFFFFF, #F5F5F5)
  static const Color background = Color(0xFFFFFFFF); // Clean White Background
  static const Color backgroundSecondary = Color(0xFFF5F5F5); // Light Grey Secondary
  static const Color backgroundDeep = Color(0xFFEBEBEB);
  static const Color surface = Color(0xFFFFFFFF); // White Card & Tile Surface
  static const Color surfaceLight = Color(0xFFF5F5F5); // Light Grey Input / Chip
  static const Color surfaceBorder = Color(0xFFE5E5E5); // Subtle Divider & Border
  static const Color cardGradientStart = Color(0xFFFFFFFF);
  static const Color cardGradientEnd = Color(0xFFF9F9F9);

  // BookMyShow Pure White & Light Grey Named Constants
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color lightGreyDarker = Color(0xFFE0E0E0);
  static const Color lightGreyBorder = Color(0xFFE5E5E5);

  // BookMyShow Signature Black (#171717)
  static const Color black = Color(0xFF171717);
  static const Color darkSurface = Color(0xFF1F1F1F);
  static const Color darkSurfaceLight = Color(0xFF2C2C2C);

  // BookMyShow Typography & Text Colors (Black #171717 & Greys)
  static const Color textPrimary = Color(0xFF171717); // Signature Black
  static const Color textSecondary = Color(0xFF666666); // Dark Neutral Grey
  static const Color textMuted = Color(0xFF888888); // Subtle Grey
  static const Color textLight = Color(0xFFFFFFFF); // White on Red / Badges

  // BookMyShow Status & Accent Colors
  static const Color accentTeal = Color(0xFF1EA5BD); // BMS Available Teal
  static const Color accentNeon = Color(0xFF1EA5BD); // Alias
  static const Color accentGreen = Color(0xFF10B981); // Selected Green
  static const Color success = Color(0xFF10B981); // Success
  static const Color secondary = Color(0xFFE31E24); // Primary Accent Red
  static const Color gold = Color(0xFFF5B041); // Star / IMDb Rating
  static const Color warning = Color(0xFFF59E0B); // Amber / Fast Filling
  static const Color error = Color(0xFFE31E24); // Red / Sold Out

  // Seat Status Colors (BookMyShow Official White & Red Theme)
  static const Color seatAvailable = Color(0xFFFFFFFF);
  static const Color seatAvailableBorder = Color(0xFF1EA5BD); // Available Teal Outline
  static const Color seatSelected = Color(0xFF10B981); // BMS Selected Green
  static const Color seatBooked = Color(0xFFE0E0E0); // Sold Out Light Grey Fill
  static const Color seatBookedIcon = Color(0xFF9E9E9E); // Muted Icon

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE31E24), Color(0xFFB81419)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient whiteCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF9F9F9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cinemaGlowGradient = LinearGradient(
    colors: [Color(0x33E31E24), Color(0x00E31E24)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
