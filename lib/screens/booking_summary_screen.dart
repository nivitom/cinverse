import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_container.dart';
import 'payment_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final TextEditingController _promoController = TextEditingController();
  String? _promoMessage;
  bool _isPromoSuccess = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo([String? directCode]) {
    final code = directCode ?? _promoController.text.trim();
    if (code.isEmpty) return;
    _promoController.text = code;

    final success = BookingService().applyPromoCode(code);
    setState(() {
      if (success) {
        _isPromoSuccess = true;
        _promoMessage = 'Promo "$code" applied! 20% discount deducted.';
      } else {
        _isPromoSuccess = false;
        _promoMessage = 'Invalid promo code. Try "CINEMA20" or "THALAIVAR20"';
      }
    });
  }

  void _proceedToPayment() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaymentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: BookingService(),
      builder: (context, child) {
        final bookingService = BookingService();
        final movie = bookingService.selectedMovie;
        final theatre = bookingService.selectedTheatre;
        final screen = bookingService.selectedScreen;
        final seats = bookingService.selectedSeats;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Booking Summary'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie & Theatre Card (BookMyShow M-Ticket Header Style)
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster Thumbnail
                      AppNetworkImage(
                        imageUrl: movie?.posterUrl ?? '',
                        width: 75,
                        height: 110,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(width: 14),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie?.title ?? 'Amaran',
                              style: AppTextStyles.titleMedium.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${movie?.language ?? 'Tamil'} • ${movie?.certificate ?? 'UA'} • ${movie?.duration ?? '2h 49m'}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    theatre?.name ?? 'Sathyam SPI Cinemas, Chennai',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${screen?.name ?? 'Audi 1'} (${screen?.format ?? 'Dolby Atmos'})',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Showtime & Seats Ribbon (BookMyShow Style)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            '${bookingService.selectedDate} • ${bookingService.selectedShowtime}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          seats.isEmpty ? 'No seat' : seats.map((s) => s.id).join(', '),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Food & Beverage Addons (BookMyShow Cinema Canteen)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add F&B Snacks', style: AppTextStyles.titleMedium),
                    Text('Optional', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 10),
                ...bookingService.availableSnacks.map((snack) {
                  final qty = bookingService.selectedSnacks[snack.id] ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(snack.icon, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snack.name,
                                style: AppTextStyles.titleMedium.copyWith(fontSize: 13.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${snack.price.toStringAsFixed(2)}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // BookMyShow Style Counter
                        Row(
                          children: [
                            if (qty > 0) ...[
                              InkWell(
                                onTap: () => bookingService.updateSnackQuantity(snack.id, -1),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.surfaceBorder),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.remove, size: 16, color: AppColors.textPrimary),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '$qty',
                                  style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                                ),
                              ),
                            ],
                            InkWell(
                              onTap: () => bookingService.updateSnackQuantity(snack.id, 1),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.add, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 18),

                // Promo Code Section with BMS Red Apply Button
                Text('Offers & Promo Codes', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: TextField(
                          controller: _promoController,
                          textCapitalization: TextCapitalization.characters,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Enter Promo Code (e.g. CINEMA20)',
                            hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _applyPromo(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Suggested Promo Chips
                Row(
                  children: [
                    Text('Tap to apply: ', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                    GestureDetector(
                      onTap: () => _applyPromo('CINEMA20'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'CINEMA20 (-20%)',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primaryLight, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _applyPromo('THALAIVAR20'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentTeal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'THALAIVAR20',
                          style: AppTextStyles.caption.copyWith(color: AppColors.accentTeal, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_promoMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _promoMessage!,
                    style: AppTextStyles.caption.copyWith(
                      color: _isPromoSuccess ? AppColors.accentGreen : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // Price Breakdown Card (BookMyShow Format in ₹)
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order Details', style: AppTextStyles.titleMedium),
                          const Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.textSecondary),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildBillRow(
                        'Ticket Price (${seats.length} ${seats.length == 1 ? 'seat' : 'seats'})',
                        '₹${bookingService.ticketsSubtotal.toStringAsFixed(2)}',
                      ),
                      if (bookingService.snacksSubtotal > 0) ...[
                        const SizedBox(height: 8),
                        _buildBillRow(
                          'Cinema Canteen Snacks',
                          '₹${bookingService.snacksSubtotal.toStringAsFixed(2)}',
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildBillRow(
                        'Integrated GST (18%)',
                        '₹${bookingService.tax.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _buildBillRow(
                        'Convenience Fee',
                        '₹${bookingService.convenienceFee.toStringAsFixed(2)}',
                      ),
                      if (bookingService.discountAmount > 0) ...[
                        const SizedBox(height: 8),
                        _buildBillRow(
                          'Promo Discount (${bookingService.appliedPromoCode})',
                          '-₹${bookingService.discountAmount.toStringAsFixed(2)}',
                          valueColor: AppColors.accentGreen,
                        ),
                      ],
                      const Divider(height: 22, color: AppColors.surfaceBorder),
                      _buildBillRow(
                        'Amount Payable',
                        '₹${bookingService.grandTotal.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // BookMyShow Bottom Payment Bar
          bottomSheet: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 14,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(
                top: BorderSide(color: AppColors.surfaceBorder, width: 0.8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Payable', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    Text(
                      '₹${bookingService.grandTotal.toStringAsFixed(2)}',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: CustomButton(
                    text: 'Proceed to Pay',
                    icon: Icons.lock_outline_rounded,
                    onPressed: _proceedToPayment,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)
              : AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.titleLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)
              : AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: valueColor ?? AppColors.textPrimary,
                ),
        ),
      ],
    );
  }
}
