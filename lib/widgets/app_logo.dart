import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget that draws the iTop Mobile app logo in a sci-fi style.
///
/// Uses [CustomPainter] to render the logo as a vector graphic,
/// without external assets or extra dependencies.
///
/// Design: dark hexagon with neon circuits, HUD shield, and cyan glow.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 120,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _SciFiLogoPainter(),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.1),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'iTOP',
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF00E5FF),
                    letterSpacing: size * 0.04,
                  ),
                ),
                TextSpan(
                  text: ' MOBILE',
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w200,
                    color: Colors.grey[400],
                    letterSpacing: size * 0.03,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Colori sci-fi ─────────────────────────────────────────────────────
const _cyanNeon = Color(0xFF00E5FF);
const _cyanDim = Color(0xFF006978);
const _magentaNeon = Color(0xFFD500F9);
const _bgDark1 = Color(0xFF0A0E1A);
const _bgDark2 = Color(0xFF0D1B2A);
const _bgDark3 = Color(0xFF1B2838);

class _SciFiLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2); // centro

    canvas.save();
    // Clip al bordo arrotondato
    final clipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s, s),
      Radius.circular(s * 0.22),
    );
    canvas.clipRRect(clipRect);

    _drawBackground(canvas, s);
    _drawGridLines(canvas, s);
    _drawCircuitTraces(canvas, s, c);
    _drawHexRing(canvas, s, c);
    _drawShield(canvas, s, c);
    _drawCheckmark(canvas, s, c);
    _drawItBranding(canvas, s);
    _drawCornerAccents(canvas, s);
    _drawScanLine(canvas, s);

    canvas.restore();

    // Bordo esterno glow
    _drawOuterBorder(canvas, s);
  }

  // ── Sfondo con gradiente scuro ──────────────────────────────────────
  void _drawBackground(Canvas canvas, double s) {
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.3),
        radius: 1.2,
        colors: [_bgDark3, _bgDark2, _bgDark1],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, s, s));
    canvas.drawRect(Rect.fromLTWH(0, 0, s, s), bgPaint);
  }

  // ── Griglia sottile stile HUD ───────────────────────────────────────
  void _drawGridLines(Canvas canvas, double s) {
    final gridPaint = Paint()
      ..color = _cyanNeon.withAlpha(10)
      ..strokeWidth = s * 0.002;

    final step = s / 12;
    for (double i = step; i < s; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, s), gridPaint);
      canvas.drawLine(Offset(0, i), Offset(s, i), gridPaint);
    }
  }

  // ── Tracce circuito decorative ──────────────────────────────────────
  void _drawCircuitTraces(Canvas canvas, double s, Offset c) {
    final tracePaint = Paint()
      ..color = _cyanNeon.withAlpha(30)
      ..strokeWidth = s * 0.004
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Traccia in alto a sinistra – angolare
    final t1 = Path()
      ..moveTo(s * 0.08, s * 0.22)
      ..lineTo(s * 0.18, s * 0.22)
      ..lineTo(s * 0.18, s * 0.12)
      ..lineTo(s * 0.30, s * 0.12);
    canvas.drawPath(t1, tracePaint);

    // Nodo (piccolo cerchio al termine)
    canvas.drawCircle(
      Offset(s * 0.30, s * 0.12),
      s * 0.008,
      Paint()..color = _cyanNeon.withAlpha(60),
    );

    // Traccia in basso a destra
    final t2 = Path()
      ..moveTo(s * 0.92, s * 0.78)
      ..lineTo(s * 0.82, s * 0.78)
      ..lineTo(s * 0.82, s * 0.88)
      ..lineTo(s * 0.70, s * 0.88);
    canvas.drawPath(t2, tracePaint);
    canvas.drawCircle(
      Offset(s * 0.70, s * 0.88),
      s * 0.008,
      Paint()..color = _cyanNeon.withAlpha(60),
    );

    // Traccia in basso a sinistra
    final t3 = Path()
      ..moveTo(s * 0.10, s * 0.85)
      ..lineTo(s * 0.10, s * 0.75)
      ..lineTo(s * 0.20, s * 0.75);
    canvas.drawPath(t3, tracePaint);
    canvas.drawCircle(
      Offset(s * 0.20, s * 0.75),
      s * 0.006,
      Paint()..color = _magentaNeon.withAlpha(50),
    );

    // Traccia in alto a destra
    final t4 = Path()
      ..moveTo(s * 0.90, s * 0.15)
      ..lineTo(s * 0.80, s * 0.15)
      ..lineTo(s * 0.80, s * 0.25);
    canvas.drawPath(t4, tracePaint);
    canvas.drawCircle(
      Offset(s * 0.80, s * 0.25),
      s * 0.006,
      Paint()..color = _magentaNeon.withAlpha(50),
    );
  }

  // ── Anello esagonale ────────────────────────────────────────────────
  void _drawHexRing(Canvas canvas, double s, Offset c) {
    final r = s * 0.38;

    // Glow esterno
    canvas.drawPath(
      _hexPath(c, r + s * 0.01),
      Paint()
        ..color = _cyanNeon.withAlpha(20)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.03)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.02,
    );

    // Anello principale
    canvas.drawPath(
      _hexPath(c, r),
      Paint()
        ..color = _cyanNeon.withAlpha(50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.005,
    );

    // Anello interno sottile
    canvas.drawPath(
      _hexPath(c, r * 0.88),
      Paint()
        ..color = _cyanNeon.withAlpha(20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.002,
    );

    // Punti ai vertici dell'esagono
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final px = c.dx + r * math.cos(angle);
      final py = c.dy + r * math.sin(angle);
      canvas.drawCircle(
        Offset(px, py),
        s * 0.01,
        Paint()..color = _cyanNeon.withAlpha(110),
      );
      // Glow sui vertici
      canvas.drawCircle(
        Offset(px, py),
        s * 0.022,
        Paint()
          ..color = _cyanNeon.withAlpha(25)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.01),
      );
    }
  }

  Path _hexPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  // ── Shield / scudo centrale ─────────────────────────────────────────
  void _drawShield(Canvas canvas, double s, Offset c) {
    final shieldPath = Path();
    final w = s * 0.22;
    final h = s * 0.28;
    final top = c.dy - h * 0.48;

    // Forma scudo: punta in basso, lati curvi
    shieldPath.moveTo(c.dx, top);
    shieldPath.lineTo(c.dx + w, top + h * 0.15);
    shieldPath.quadraticBezierTo(
      c.dx + w * 0.95,
      top + h * 0.7,
      c.dx,
      top + h,
    );
    shieldPath.quadraticBezierTo(
      c.dx - w * 0.95,
      top + h * 0.7,
      c.dx - w,
      top + h * 0.15,
    );
    shieldPath.close();

    // Glow dello scudo
    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = _cyanNeon.withAlpha(18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.04),
    );

    // Riempimento scudo semi-trasparente
    canvas.drawPath(
      shieldPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _cyanNeon.withAlpha(22),
            _bgDark1.withAlpha(180),
          ],
        ).createShader(Rect.fromLTWH(c.dx - w, top, w * 2, h)),
    );

    // Bordo scudo
    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = _cyanNeon.withAlpha(120)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.006,
    );

    // Linea orizzontale decorativa nello scudo
    final lineY = top + h * 0.25;
    canvas.drawLine(
      Offset(c.dx - w * 0.6, lineY),
      Offset(c.dx + w * 0.6, lineY),
      Paint()
        ..color = _cyanNeon.withAlpha(35)
        ..strokeWidth = s * 0.002,
    );
  }

  // ── Checkmark futuristico ───────────────────────────────────────────
  void _drawCheckmark(Canvas canvas, double s, Offset c) {
    final checkPath = Path()
      ..moveTo(c.dx - s * 0.09, c.dy + s * 0.01)
      ..lineTo(c.dx - s * 0.02, c.dy + s * 0.10)
      ..lineTo(c.dx + s * 0.11, c.dy - s * 0.08);

    // Glow del checkmark
    canvas.drawPath(
      checkPath,
      Paint()
        ..color = _cyanNeon.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.05
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.025),
    );

    // Main checkmark
    canvas.drawPath(
      checkPath,
      Paint()
        ..color = _cyanNeon
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.028
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Brighter center highlight
    canvas.drawPath(
      checkPath,
      Paint()
        ..color = Colors.white.withAlpha(160)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.008
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  // ── Branding "iTop Mobile" ───────────────────────────────────────
  void _drawItBranding(Canvas canvas, double s) {
    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: 'iTop',
          style: TextStyle(
            fontSize: s * 0.09,
            fontWeight: FontWeight.w700,
            color: _cyanNeon,
            letterSpacing: s * 0.003,
          ),
        ),
        TextSpan(
          text: ' Mobile',
          style: TextStyle(
            fontSize: s * 0.09,
            fontWeight: FontWeight.w300,
            color: _cyanNeon.withAlpha(140),
            letterSpacing: s * 0.003,
          ),
        ),
      ],
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    final textX = (s - textPainter.width) / 2;
    final textY = s * 0.76;

    // Glow dietro il testo
    final glowSpan = TextSpan(
      children: [
        TextSpan(
          text: 'iTop',
          style: TextStyle(
            fontSize: s * 0.09,
            fontWeight: FontWeight.w700,
            color: _cyanNeon.withAlpha(30),
            letterSpacing: s * 0.003,
          ),
        ),
        TextSpan(
          text: ' Mobile',
          style: TextStyle(
            fontSize: s * 0.09,
            fontWeight: FontWeight.w300,
            color: _cyanNeon.withAlpha(20),
            letterSpacing: s * 0.003,
          ),
        ),
      ],
    );
    final glowPainter = TextPainter(
      text: glowSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    // Disegno glow (sfocato tramite multipli offset)
    for (final dx in [-1.0, 0.0, 1.0]) {
      for (final dy in [-1.0, 0.0, 1.0]) {
        glowPainter.paint(canvas, Offset(textX + dx, textY + dy));
      }
    }

    // Testo principale
    textPainter.paint(canvas, Offset(textX, textY));

    // Linea sotto il branding
    final lineW = textPainter.width * 0.8;
    final lineY = textY + textPainter.height + s * 0.025;
    canvas.drawLine(
      Offset(s / 2 - lineW / 2, lineY),
      Offset(s / 2 + lineW / 2, lineY),
      Paint()
        ..shader = LinearGradient(
          colors: [
            _cyanNeon.withAlpha(0),
            _cyanNeon.withAlpha(60),
            _cyanNeon.withAlpha(0),
          ],
        ).createShader(
          Rect.fromLTWH(s / 2 - lineW / 2, 0, lineW, 1),
        )
        ..strokeWidth = s * 0.003,
    );
  }

  // ── Accenti angolari stile HUD ──────────────────────────────────────
  void _drawCornerAccents(Canvas canvas, double s) {
    final len = s * 0.08;
    final margin = s * 0.06;
    final paint = Paint()
      ..color = _cyanNeon.withAlpha(55)
      ..strokeWidth = s * 0.004
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
        Offset(margin, margin), Offset(margin + len, margin), paint);
    canvas.drawLine(
        Offset(margin, margin), Offset(margin, margin + len), paint);

    // Top-right
    canvas.drawLine(
        Offset(s - margin, margin), Offset(s - margin - len, margin), paint);
    canvas.drawLine(
        Offset(s - margin, margin), Offset(s - margin, margin + len), paint);

    // Bottom-left
    canvas.drawLine(
        Offset(margin, s - margin), Offset(margin + len, s - margin), paint);
    canvas.drawLine(
        Offset(margin, s - margin), Offset(margin, s - margin - len), paint);

    // Bottom-right
    canvas.drawLine(Offset(s - margin, s - margin),
        Offset(s - margin - len, s - margin), paint);
    canvas.drawLine(Offset(s - margin, s - margin),
        Offset(s - margin, s - margin - len), paint);
  }

  // ── Scan line orizzontale ───────────────────────────────────────────
  void _drawScanLine(Canvas canvas, double s) {
    final y = s * 0.35;
    canvas.drawLine(
      Offset(0, y),
      Offset(s, y),
      Paint()
        ..shader = LinearGradient(
          colors: [
            _cyanNeon.withAlpha(0),
            _cyanNeon.withAlpha(12),
            _cyanNeon.withAlpha(0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, s, 1))
        ..strokeWidth = s * 0.015,
    );
  }

  // ── Bordo esterno con glow ──────────────────────────────────────────
  void _drawOuterBorder(Canvas canvas, double s) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s, s),
      Radius.circular(s * 0.22),
    );

    // Glow
    canvas.drawRRect(
      rect,
      Paint()
        ..color = _cyanNeon.withAlpha(25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.02
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.015),
    );

    // Bordo netto
    canvas.drawRRect(
      rect,
      Paint()
        ..color = _cyanNeon.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.004,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
