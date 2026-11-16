import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/ticket_clipper.dart';
import '../widgets/app_network_image.dart';
import '../widgets/custom_button.dart';
import 'main_navigation_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingSuccessScreen({super.key, required this.booking});

  void _downloadTicket(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.accentGreen, size: 20),
            SizedBox(width: 8),
            Text('CINEVERSE M-Ticket saved to phone wallet.'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 0)),
      (route) => false,
    );
  }

  void _goToBookings(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 2)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            children: [
              // Success Icon (BookMyShow Style Green Circle with Red Sparkle)
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.accentGreen, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.check_rounded, size: 40, color: AppColors.accentGreen),
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Booking Confirmed!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Show this M-Ticket at cinema entrance gate',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
              ),

              const SizedBox(height: 20),

              // CINEVERSE Digital Cutout Movie Ticket Card (BMS Style)
              ClipPath(
                clipper: const TicketClipper(punchRadius: 14, punchYPositionFraction: 0.70),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Red M-Ticket Header Ribbon
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'M-TICKET • CONFIRMED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              booking.bookingCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Movie & Booking Info
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppNetworkImage(
                                  imageUrl: booking.posterUrl,
                                  width: 68,
                                  height: 94,
                                  borderRadius: BorderRadius.circular(8),
                                  fallbackTitle: booking.movieTitle,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking.movieTitle,
                                        style: AppTextStyles.titleMedium.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceLight,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${booking.format} • Tamil',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        booking.theatreName,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                      Text(
                                        booking.theatreAddress,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 12),

                            // 4-box Metadata Grid
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTicketMeta('DATE', booking.showDate),
                                _buildTicketMeta('TIME', booking.showTime),
                                _buildTicketMeta('SCREEN', booking.screen.split('–').first.trim()),
                                _buildTicketMeta('SEATS', booking.seats.join(', '), highlight: true),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Perforated Dashed Line
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomPaint(
                          size: const Size(double.infinity, 1),
                          painter: DashedLinePainter(
                            color: AppColors.surfaceBorder,
                            dashWidth: 6,
                            dashSpace: 4,
                          ),
                        ),
                      ),

                      // Bottom Half: Barcode & QR Code Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('TOTAL PAID', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${booking.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      booking.paymentMethod,
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.surfaceBorder),
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 42,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Simulated Barcode graphic
                            Container(
                              height: 30,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(36, (i) {
                                  final isThick = i % 3 == 0;
                                  return Container(
                                    width: isThick ? 2.5 : 1.2,
                                    height: 22,
                                    color: AppColors.textPrimary,
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Scan at cinema turnstile or ticket counter',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              CustomButton(
                text: 'Download M-Ticket',
                icon: Icons.download_rounded,
                isOutlined: true,
                onPressed: () => _downloadTicket(context),
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'View My Bookings',
                icon: Icons.confirmation_number_outlined,
                onPressed: () => _goToBookings(context),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => _goToHome(context),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketMeta(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: highlight ? AppColors.accentGreen : AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
