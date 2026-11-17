import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_container.dart';
import 'booking_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; // 0: RuPay/Card, 1: Google Pay, 2: PhonePe, 3: Paytm UPI
  bool _isProcessing = false;

  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _upiIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fillDemoCard();
  }

  void _fillDemoCard() {
    final userName = AuthService().currentUser?.name.toUpperCase() ?? 'KARTHIK RAMACHANDRAN';
    _cardNumberController.text = '5044 •••• •••• 8219';
    _cardHolderController.text = userName;
    _expiryController.text = '10/29';
    _cvvController.text = '742';
    _upiIdController.text = '${AuthService().currentUser?.email.split('@').first ?? 'karthik'}@okhdfcbank';
    setState(() {});
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(milliseconds: 1200));

    String paymentMethodName = 'RuPay Platinum (•• 8219)';
    if (_selectedMethod == 1) paymentMethodName = 'Google Pay UPI';
    if (_selectedMethod == 2) paymentMethodName = 'PhonePe UPI';
    if (_selectedMethod == 3) paymentMethodName = 'Paytm Payments';

    final newBooking = BookingService().completeBooking(paymentMethod: paymentMethodName);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingSuccessScreen(booking: newBooking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();
    final grandTotal = bookingService.grandTotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Options'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Order Overview Card
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.movie_creation_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bookingService.selectedMovie?.title ?? 'Kollywood Blockbuster',
                              style: AppTextStyles.titleMedium.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${bookingService.selectedTheatre?.name ?? 'Cinema'} • ${bookingService.selectedScreen?.name ?? 'Screen 1'}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppColors.surfaceBorder),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            '${bookingService.selectedDate} • ${bookingService.selectedShowtime}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        '${bookingService.selectedSeats.length} ${bookingService.selectedSeats.length == 1 ? 'Seat' : 'Seats'}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  if (bookingService.selectedSeats.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: bookingService.selectedSeats.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            s.id,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // Amount Header (BookMyShow Style)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount to Pay', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        '₹${grandTotal.toStringAsFixed(2)}',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 14, color: AppColors.accentGreen),
                        const SizedBox(width: 4),
                        Text(
                          'NPCI Secured',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Payment Methods Selector
            Text('Preferred Payment Methods', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMethodPill(0, Icons.credit_card_rounded, 'RuPay / Card'),
                const SizedBox(width: 8),
                _buildMethodPill(1, Icons.account_balance_wallet_rounded, 'GPay UPI'),
                const SizedBox(width: 8),
                _buildMethodPill(2, Icons.phone_android_rounded, 'PhonePe'),
                const SizedBox(width: 8),
                _buildMethodPill(3, Icons.qr_code_2_rounded, 'Paytm'),
              ],
            ),

            const SizedBox(height: 20),

            if (_selectedMethod == 0) ...[
              // Titanium RuPay Card Preview
              _buildRuPayCard(),

              const SizedBox(height: 18),

              // Form fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _cardNumberController,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
                      ),
                      onChanged: (v) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cardHolderController,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Name on Card',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                      ),
                      onChanged: (v) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryController,
                            style: AppTextStyles.bodyLarge,
                            decoration: const InputDecoration(
                              labelText: 'Valid Thru (MM/YY)',
                              prefixIcon: Icon(Icons.calendar_month, color: AppColors.primary),
                            ),
                            onChanged: (v) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            obscureText: true,
                            style: AppTextStyles.bodyLarge,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Quick Autofill Chip
              Center(
                child: ActionChip(
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  avatar: const Icon(Icons.auto_fix_high, size: 16, color: AppColors.primary),
                  label: Text('Autofill Demo RuPay Card', style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
                  onPressed: _fillDemoCard,
                ),
              ),
            ] else ...[
              // Instant Digital Wallet / UPI Card (BookMyShow Style)
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _selectedMethod == 1
                                ? Icons.account_balance_wallet_rounded
                                : _selectedMethod == 2
                                    ? Icons.phone_android_rounded
                                    : Icons.qr_code_2_rounded,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedMethod == 1
                                    ? 'Google Pay UPI'
                                    : _selectedMethod == 2
                                        ? 'PhonePe UPI'
                                        : 'Paytm UPI QR & Wallet',
                                style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
                              ),
                              Text(
                                'Instant UPI Intent & Autopay',
                                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _upiIdController,
                      style: AppTextStyles.bodyMedium,
                      decoration: const InputDecoration(
                        labelText: 'Virtual Payment Address (VPA / UPI ID)',
                        prefixIcon: Icon(Icons.alternate_email_rounded, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: AppColors.accentGreen),
                        const SizedBox(width: 6),
                        Text(
                          'Verified UPI Handle. No PIN required for demo.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.accentGreen),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      // BookMyShow Red Bottom Checkout Bar
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
        child: CustomButton(
          text: 'Pay ₹${grandTotal.toStringAsFixed(2)}',
          icon: Icons.check_circle_outline,
          isLoading: _isProcessing,
          onPressed: _isProcessing ? null : _processPayment,
        ),
      ),
    );
  }

  Widget _buildMethodPill(int index, IconData icon, String label) {
    final isSelected = _selectedMethod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuPayCard() {
    return Container(
      width: double.infinity,
      height: 195,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B3148), Color(0xFF1F2533), Color(0xFF151922)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Chip & Bank Name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Icon(Icons.memory, size: 18, color: Colors.black87),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'RuPay >> PLATINUM',
                      style: TextStyle(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Card Number
          Text(
            _cardNumberController.text.isEmpty
                ? '•••• •••• •••• ••••'
                : _cardNumberController.text,
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          // Bottom Row: Holder & Expiry
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARDHOLDER NAME',
                    style: TextStyle(fontSize: 8.5, letterSpacing: 1.2, color: Colors.white54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _cardHolderController.text.isEmpty ? 'KARTHIK RAMACHANDRAN' : _cardHolderController.text,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'EXPIRES',
                    style: TextStyle(fontSize: 8.5, letterSpacing: 1.2, color: Colors.white54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _expiryController.text.isEmpty ? '10/29' : _expiryController.text,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
