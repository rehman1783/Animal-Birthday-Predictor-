import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A custom widget rendering a stylized golden Horseshoe icon
class HorseshoeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const HorseshoeIcon({
    super.key,
    this.size = 20.0,
    this.color = AppColors.primaryGold,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HorseshoePainter(color: color),
    );
  }
}

class _HorseshoePainter extends CustomPainter {
  final Color color;

  _HorseshoePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.16;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Draw the U-shaped horseshoe arc
    final path = Path();
    // Top-left heel
    path.moveTo(w * 0.22, h * 0.18);
    // Left side down to bottom curve
    path.cubicTo(w * 0.08, h * 0.52, w * 0.20, h * 0.90, w * 0.50, h * 0.90);
    // Right side up to top-right heel
    path.cubicTo(w * 0.80, h * 0.90, w * 0.92, h * 0.52, w * 0.78, h * 0.18);

    canvas.drawPath(path, paint);

    // Draw calkins / heel tips at the top
    final tipPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.22, h * 0.18), width: strokeWidth * 1.3, height: strokeWidth * 0.8),
        Radius.circular(strokeWidth * 0.3),
      ),
      tipPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.78, h * 0.18), width: strokeWidth * 1.3, height: strokeWidth * 0.8),
        Radius.circular(strokeWidth * 0.3),
      ),
      tipPaint,
    );

    // Nail holes (3 on left, 3 on right)
    final holeRadius = strokeWidth * 0.18;
    final holePaint = Paint()
      ..color = const Color(0xFF0A192F) // Background cutout contrast
      ..style = PaintingStyle.fill;

    final holes = [
      Offset(w * 0.20, h * 0.40),
      Offset(w * 0.23, h * 0.58),
      Offset(w * 0.33, h * 0.75),
      Offset(w * 0.80, h * 0.40),
      Offset(w * 0.77, h * 0.58),
      Offset(w * 0.67, h * 0.75),
    ];

    for (final hole in holes) {
      canvas.drawCircle(hole, holeRadius, holePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HorseshoePainter oldDelegate) => oldDelegate.color != color;
}
