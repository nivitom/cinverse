import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class CinemaScreenWidget extends StatelessWidget {
  const CinemaScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          size: const Size(double.infinity, 42),
          painter: _CinemaScreenPainter(),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 1.5,
              color: AppColors.accentTeal.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              'All eyes this way please',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
                fontSize: 10.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 12,
              height: 1.5,
              color: AppColors.accentTeal.withValues(alpha: 0.6),
            ),
          ],
        ),
      ],
    );
  }
}

class _CinemaScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Soft projection beam
    final beamPath = Path();
    beamPath.moveTo(width * 0.12, 6);
    beamPath.quadraticBezierTo(width * 0.5, 20, width * 0.88, 6);
    beamPath.lineTo(width * 0.95, height);
    beamPath.lineTo(width * 0.05, height);
    beamPath.close();

    final beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.accentTeal.withValues(alpha: 0.15),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawPath(beamPath, beamPaint);

    // Screen Arc Path
    final screenPath = Path();
    screenPath.moveTo(width * 0.10, 6);
    screenPath.quadraticBezierTo(width * 0.5, 20, width * 0.90, 6);

    // Ambient glow
    final glowPaint = Paint()
      ..color = AppColors.accentTeal.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(screenPath, glowPaint);

    // Solid Crisp Screen line (BookMyShow clean curved teal arc)
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x331EA5BD),
          Color(0xFF1EA5BD),
          Color(0xFF0D9488),
          Color(0xFF1EA5BD),
          Color(0x331EA5BD),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    canvas.drawPath(screenPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
