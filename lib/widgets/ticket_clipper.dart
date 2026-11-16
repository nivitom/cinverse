import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class TicketClipper extends CustomClipper<Path> {
  final double punchRadius;
  final double punchYPositionFraction;

  const TicketClipper({
    this.punchRadius = 14.0,
    this.punchYPositionFraction = 0.70,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final punchY = h * punchYPositionFraction;
    final r = punchRadius;

    // Top-left corner
    path.moveTo(12, 0);
    path.quadraticBezierTo(0, 0, 0, 12);

    // Left edge to punch
    path.lineTo(0, punchY - r);
    // Left notch
    path.arcToPoint(
      Offset(0, punchY + r),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // Left edge to bottom-left corner
    path.lineTo(0, h - 12);
    path.quadraticBezierTo(0, h, 12, h);

    // Bottom edge
    path.lineTo(w - 12, h);
    path.quadraticBezierTo(w, h, w, h - 12);

    // Right edge to punch
    path.lineTo(w, punchY + r);
    // Right notch
    path.arcToPoint(
      Offset(w, punchY - r),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // Right edge to top-right corner
    path.lineTo(w, 12);
    path.quadraticBezierTo(w, 0, w - 12, 0);

    // Top edge back to start
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    this.color = AppColors.surfaceBorder,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
