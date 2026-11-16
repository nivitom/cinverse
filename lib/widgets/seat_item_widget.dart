import 'package:flutter/material.dart';
import '../models/seat_model.dart';
import '../utils/app_colors.dart';

class SeatItemWidget extends StatelessWidget {
  final SeatModel seat;
  final VoidCallback onTap;

  const SeatItemWidget({
    super.key,
    required this.seat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color fillColor;
    Color borderColor;
    Color textColor;

    switch (seat.status) {
      case SeatStatus.selected:
        fillColor = AppColors.accentGreen; // BookMyShow green for selected seat
        borderColor = AppColors.accentGreen;
        textColor = Colors.white;
        break;
      case SeatStatus.booked:
        fillColor = AppColors.seatBooked;
        borderColor = AppColors.surfaceBorder;
        textColor = AppColors.seatBookedIcon;
        break;
      case SeatStatus.available:
        if (seat.tier == SeatTier.vip) {
          fillColor = Colors.white;
          borderColor = AppColors.gold;
          textColor = AppColors.gold;
        } else if (seat.tier == SeatTier.premium) {
          fillColor = Colors.white;
          borderColor = AppColors.accentTeal;
          textColor = AppColors.textPrimary;
        } else {
          fillColor = Colors.white;
          borderColor = AppColors.accentGreen.withValues(alpha: 0.8);
          textColor = AppColors.textPrimary;
        }
        break;
    }

    final isBooked = seat.status == SeatStatus.booked;
    final isSelected = seat.status == SeatStatus.selected;

    return GestureDetector(
      onTap: isBooked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 32,
        height: 32,
        margin: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(seat.tier == SeatTier.vip ? 8 : 6),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentGreen.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isBooked
              ? Icon(Icons.close, size: 14, color: textColor)
              : isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${seat.number}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
        ),
      ),
    );
  }
}
