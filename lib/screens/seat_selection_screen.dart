
import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../models/theatre_model.dart';
import '../models/seat_model.dart';
import '../services/booking_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/cinema_screen_painter.dart';
import '../widgets/seat_item_widget.dart';
import '../widgets/custom_button.dart';
import 'booking_summary_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final MovieModel movie;
  final TheatreModel theatre;
  final ScreenModel screen;
  final String showtime;
  final String date;
  final int requestedSeatCount;

  const SeatSelectionScreen({
    super.key,
    required this.movie,
    required this.theatre,
    required this.screen,
    required this.showtime,
    required this.date,
    this.requestedSeatCount = 2,
  });

  @override
  State<SeatSelectionScreen> createState() =>
      _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  late List<List<SeatModel>> _seatMatrix;

  @override
  void initState() {
    super.initState();
    BookingService().clearSeats();
    _generateSeatLayout();
  }

  void _generateSeatLayout() {
    final rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final basePrice = widget.screen.basePrice;

    final bookedIds = {
      'A3', 'B4', 'B5', 'D2',
      'D7', 'F3', 'F4', 'G5'
    };

    _seatMatrix = [];

    for (var r in rows) {
      final List<SeatModel> rowSeats = [];

      SeatTier tier = SeatTier.standard;
      double price = basePrice;

      if (r == 'A') {
        tier = SeatTier.vip;
        price = basePrice + 60.0;
      } else if (r == 'B' || r == 'C' || r == 'D') {
        tier = SeatTier.premium;
        price = basePrice + 30.0;
      } else {
        tier = SeatTier.standard;
        price = basePrice;
      }

      for (int num = 1; num <= 8; num++) {
        final id = '$r$num';
        final isBooked = bookedIds.contains(id);

        rowSeats.add(
          SeatModel(
            id: id,
            row: r,
            number: num,
            tier: tier,
            price: price,
            status: isBooked
                ? SeatStatus.booked
                : SeatStatus.available,
          ),
        );
      }

      _seatMatrix.add(rowSeats);
    }
  }

  void _toggleSeat(SeatModel seat) {
    if (seat.status == SeatStatus.booked) return;

    final bookingService = BookingService();

    if (seat.status == SeatStatus.selected) {
      setState(() {
        seat.status = SeatStatus.available;
      });
      bookingService.toggleSeat(seat);
      return;
    }

    // Attempting to select an available seat
    if (bookingService.selectedSeats.length < widget.requestedSeatCount) {
      setState(() {
        seat.status = SeatStatus.selected;
      });
      bookingService.toggleSeat(seat);
    } else if (widget.requestedSeatCount == 1) {
      // Single seat switch
      for (var row in _seatMatrix) {
        for (var s in row) {
          if (s.status == SeatStatus.selected) {
            s.status = SeatStatus.available;
          }
        }
      }
      setState(() {
        seat.status = SeatStatus.selected;
      });
      bookingService.clearSeats();
      bookingService.toggleSeat(seat);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.black,
          content: Text(
            'You chose ${widget.requestedSeatCount} seats. Tap a selected seat to unselect it.',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _proceedToCheckout() {
    final bookingService = BookingService();

    if (bookingService.selectedSeats.length != widget.requestedSeatCount) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.black,
          content: Text(
            'Please select exactly ${widget.requestedSeatCount} seats (${bookingService.selectedSeats.length} selected).',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BookingSummaryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movie.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              '${widget.theatre.name} • ${widget.showtime}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            child: CinemaScreenWidget(),
          ),

          _buildSelectionStatusBanner(bookingService.selectedSeats.length),

          const SizedBox(height: 4),

          _buildSeatLegend(),

          const SizedBox(height: 8),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  child: Column(
                    children: [
                      _buildTierHeader(
                        'RECLINERS – ₹${(widget.screen.basePrice + 60).toStringAsFixed(0)}',
                        AppColors.gold,
                      ),

                      _buildSeatRow(_seatMatrix[0]),

                      const SizedBox(height: 16),

                      _buildTierHeader(
                        'PRIME – ₹${(widget.screen.basePrice + 30).toStringAsFixed(0)}',
                        AppColors.accentTeal,
                      ),

                      _buildSeatRow(_seatMatrix[1]),
                      _buildSeatRow(_seatMatrix[2]),
                      _buildSeatRow(_seatMatrix[3]),

                      const SizedBox(height: 16),

                      _buildTierHeader(
                        'CLASSIC – ₹${widget.screen.basePrice.toStringAsFixed(0)}',
                        AppColors.textSecondary,
                      ),

                      _buildSeatRow(_seatMatrix[4]),
                      _buildSeatRow(_seatMatrix[5]),
                      _buildSeatRow(_seatMatrix[6]),
                      _buildSeatRow(_seatMatrix[7]),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          _buildBottomActionCard(bookingService),
        ],
      ),
    );
  }

  Widget _buildSelectionStatusBanner(int selectedCount) {
    final remaining = widget.requestedSeatCount - selectedCount;
    final isComplete = selectedCount == widget.requestedSeatCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.accentGreen.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isComplete
              ? AppColors.accentGreen.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle_rounded : Icons.event_seat_rounded,
                size: 16,
                color: isComplete ? AppColors.accentGreen : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isComplete
                    ? 'All $selectedCount seats selected'
                    : 'Select $remaining more seat${remaining > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isComplete ? AppColors.accentGreen : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            '$selectedCount / ${widget.requestedSeatCount} Seats',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isComplete ? AppColors.accentGreen : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierHeader(String title, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 1,
            color: accent.withValues(alpha: 0.4),
          ),

          const SizedBox(width: 8),

          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                fontSize: 10.5,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Container(
            width: 20,
            height: 1,
            color: accent.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  // FIXED: Responsive seat row
  Widget _buildSeatRow(List<SeatModel> rowSeats) {
    final rowLetter = rowSeats.first.row;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              child: Text(
                rowLetter,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ),

            ...rowSeats.sublist(0, 4).map(
                  (s) => SeatItemWidget(
                seat: s,
                onTap: () => _toggleSeat(s),
              ),
            ),

            const SizedBox(width: 20),

            ...rowSeats.sublist(4, 8).map(
                  (s) => SeatItemWidget(
                seat: s,
                onTap: () => _toggleSeat(s),
              ),
            ),

            SizedBox(
              width: 18,
              child: Text(
                rowLetter,
                textAlign: TextAlign.right,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.surfaceBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendChip(
            Colors.white,
            AppColors.seatAvailableBorder,
            'Available',
          ),

          const SizedBox(width: 16),

          _buildLegendChip(
            AppColors.seatSelected,
            AppColors.seatSelected,
            'Selected',
          ),

          const SizedBox(width: 16),

          _buildLegendChip(
            AppColors.seatBooked,
            AppColors.surfaceBorder,
            'Sold',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendChip(
      Color fill,
      Color border,
      String label,
      ) {
    return Row(
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: border,
              width: 1.2,
            ),
          ),
        ),

        const SizedBox(width: 5),

        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionCard(
      BookingService bookingService,
      ) {
    final selected = bookingService.selectedSeats;
    final total = bookingService.ticketsSubtotal;
    final isComplete = selected.length == widget.requestedSeatCount;
    final remaining = widget.requestedSeatCount - selected.length;

    final buttonText = isComplete
        ? 'Pay ₹${total.toStringAsFixed(0)}'
        : (selected.isEmpty
            ? 'Select ${widget.requestedSeatCount} Seats'
            : 'Select $remaining more seat${remaining > 1 ? 's' : ''}');

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(
            color: AppColors.surfaceBorder,
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.chair_rounded,
                  size: 15,
                  color: AppColors.accentGreen,
                ),

                const SizedBox(width: 6),

                Text(
                  '${selected.length} of ${widget.requestedSeatCount} Seat(s): ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: selected.map((s) {
                        return Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.accentGreen,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            s.id,
                            style: const TextStyle(
                              color: AppColors.accentGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],

          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10.5,
                      ),
                    ),

                    const SizedBox(height: 1),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '₹${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 6,
                child: CustomButton(
                  text: buttonText,
                  icon: isComplete ? Icons.check_circle_outline : Icons.chair_rounded,
                  onPressed: isComplete ? _proceedToCheckout : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
