import 'package:flutter/material.dart';

/// A pure Flutter vector widget that renders the Google "G" logo
/// without requiring any external raster assets (preventing 404 errors on Web).
class GoogleLogoIcon extends StatelessWidget {
  final double size;

  const GoogleLogoIcon({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    final strokeWidth = w * 0.22;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    // Blue section (Right to Top-Right)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Green section (Bottom)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Yellow section (Bottom-Left)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Red section (Top-Left to Top)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Draw arcs for the 4 Google colors
    // Red: 180° to 300° (-pi to -pi/3)
    canvas.drawArc(rect, -3.14159 * 0.75, 3.14159 * 0.55, false, redPaint);
    // Yellow: 120° to 180°
    canvas.drawArc(rect, 3.14159 * 0.65, 3.14159 * 0.55, false, yellowPaint);
    // Green: 30° to 120°
    canvas.drawArc(rect, 3.14159 * 0.1, 3.14159 * 0.55, false, greenPaint);
    // Blue: -30° to 30°
    canvas.drawArc(rect, -3.14159 * 0.2, 3.14159 * 0.3, false, bluePaint);

    // Horizontal bar for 'G'
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - w * 0.05, center.dy - strokeWidth / 2, radius + strokeWidth / 2 - (center.dx - w * 0.05), strokeWidth),
      Radius.circular(strokeWidth * 0.2),
    );
    canvas.drawRRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
