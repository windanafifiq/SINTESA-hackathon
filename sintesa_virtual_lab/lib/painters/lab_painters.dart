import 'package:flutter/material.dart';

/// Painter for an Erlenmeyer flask / beaker
class FlaskPainter extends CustomPainter {
  final Color liquidColor;
  final double fillLevel; // 0.0 to 1.0
  final bool showLabel;
  final String label;
  final bool isHighlighted;
  final bool hasKunyit;

  FlaskPainter({
    required this.liquidColor,
    this.fillLevel = 0.6,
    this.showLabel = true,
    this.label = '',
    this.isHighlighted = false,
    this.hasKunyit = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Flask outline path (Erlenmeyer shape)
    final flaskPath = Path();
    // Neck top
    flaskPath.moveTo(w * 0.35, h * 0.02);
    flaskPath.lineTo(w * 0.65, h * 0.02);
    // Neck
    flaskPath.lineTo(w * 0.65, h * 0.30);
    // Shoulder curve
    flaskPath.quadraticBezierTo(w * 0.80, h * 0.38, w * 0.95, h * 0.65);
    // Bottom right
    flaskPath.lineTo(w * 0.97, h * 0.92);
    // Bottom flat
    flaskPath.quadraticBezierTo(w * 0.97, h * 0.98, w * 0.87, h * 0.98);
    flaskPath.lineTo(w * 0.13, h * 0.98);
    flaskPath.quadraticBezierTo(w * 0.03, h * 0.98, w * 0.03, h * 0.92);
    // Bottom left
    flaskPath.lineTo(w * 0.05, h * 0.65);
    // Shoulder curve left
    flaskPath.quadraticBezierTo(w * 0.20, h * 0.38, w * 0.35, h * 0.30);
    flaskPath.close();

    // Clip to flask shape for liquid
    canvas.save();
    canvas.clipPath(flaskPath);

    // Draw liquid fill
    final liquidTop = h * (1.0 - fillLevel * 0.65 - 0.05);
    final liquidPaint = Paint()
      ..color = liquidColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, liquidTop, w, h - liquidTop),
      liquidPaint,
    );

    // Liquid shimmer/highlight
    final shimmerPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.15, liquidTop + 2, w * 0.25, 8),
      shimmerPaint,
    );

    canvas.restore();

    // Draw flask outline
    final outlinePaint = Paint()
      ..color = isHighlighted
          ? const Color(0xFF5779AF)
          : const Color(0xFF8090B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighlighted ? 2.5 : 1.8;
    canvas.drawPath(flaskPath, outlinePaint);

    // Flask glass gradient (subtle)
    final glassPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    final highlightPath = Path();
    highlightPath.moveTo(w * 0.38, h * 0.03);
    highlightPath.lineTo(w * 0.50, h * 0.03);
    highlightPath.lineTo(w * 0.50, h * 0.28);
    highlightPath.quadraticBezierTo(w * 0.58, h * 0.36, w * 0.65, h * 0.55);
    highlightPath.lineTo(w * 0.55, h * 0.55);
    highlightPath.quadraticBezierTo(w * 0.48, h * 0.36, w * 0.38, h * 0.28);
    highlightPath.close();
    canvas.drawPath(highlightPath, glassPaint);

    // Draw kunyit drop indicator
    if (hasKunyit) {
      final dotPaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w * 0.80, h * 0.15), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(FlaskPainter oldDelegate) =>
      oldDelegate.liquidColor != liquidColor ||
      oldDelegate.isHighlighted != isHighlighted ||
      oldDelegate.hasKunyit != hasKunyit;
}

/// Painter for sendok preparat (lab spoon/spatula)
class SendokPainter extends CustomPainter {
  final bool hasLiquid;
  final Color liquidColor;

  SendokPainter({this.hasLiquid = true, this.liquidColor = const Color(0xFFFFD700)});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final paint = Paint()
      ..color = const Color(0xFFB0C4DE)
      ..style = PaintingStyle.fill;

    // Handle (long rod)
    final handlePaint = Paint()
      ..color = const Color(0xFF9090A0)
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    // Draw handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.45, h * 0.10, w * 0.10, h * 0.65),
        const Radius.circular(4),
      ),
      handlePaint,
    );

    // Draw spoon head (oval at bottom)
    canvas.drawOval(
      Rect.fromLTWH(w * 0.20, h * 0.72, w * 0.60, h * 0.22),
      paint,
    );

    // Liquid in spoon (kunyit extract)
    if (hasLiquid) {
      final liquidPaint = Paint()
        ..color = liquidColor
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromLTWH(w * 0.25, h * 0.76, w * 0.50, h * 0.14),
        liquidPaint,
      );
    }

    // Spoon outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF607080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.20, h * 0.72, w * 0.60, h * 0.22),
      outlinePaint,
    );
  }

  @override
  bool shouldRepaint(SendokPainter oldDelegate) =>
      oldDelegate.hasLiquid != hasLiquid ||
      oldDelegate.liquidColor != liquidColor;
}

/// Painter for kunyit (turmeric root)
class KunyitPainter extends CustomPainter {
  final bool isGround;

  KunyitPainter({this.isGround = false});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    if (!isGround) {
      // Draw whole turmeric root
      final rootPaint = Paint()
        ..color = const Color(0xFFE8A000)
        ..style = PaintingStyle.fill;

      // Main body
      final bodyPath = Path();
      bodyPath.addOval(Rect.fromLTWH(w * 0.15, h * 0.30, w * 0.60, h * 0.45));
      canvas.drawPath(bodyPath, rootPaint);

      // Knobs
      canvas.drawOval(
          Rect.fromLTWH(w * 0.65, h * 0.35, w * 0.25, h * 0.25), rootPaint);
      canvas.drawOval(
          Rect.fromLTWH(w * 0.15, h * 0.55, w * 0.20, h * 0.20), rootPaint);

      // Surface details
      final detailPaint = Paint()
        ..color = const Color(0xFFC07800)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawArc(
          Rect.fromLTWH(w * 0.22, h * 0.38, w * 0.42, h * 0.30),
          0,
          3.14,
          false,
          detailPaint);
    } else {
      // Ground kunyit paste
      final pastePaint = Paint()
        ..color = const Color(0xFFFFB300)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
          Rect.fromLTWH(w * 0.10, h * 0.40, w * 0.80, h * 0.35), pastePaint);

      // Highlight
      final highlightPaint = Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
          Rect.fromLTWH(w * 0.20, h * 0.44, w * 0.40, h * 0.15),
          highlightPaint);
    }
  }

  @override
  bool shouldRepaint(KunyitPainter oldDelegate) =>
      oldDelegate.isGround != isGround;
}
