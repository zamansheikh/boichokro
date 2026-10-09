import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens.dart';

/// The Boichokro mark: a book inside a "chokro" (wheel) of two chasing arcs,
/// one in the exchange colour and one in the donate colour.
///
/// Used on brand surfaces (splash, auth, onboarding) and as a progress ring:
/// pass [progress] (0..1) to show how far a hand-off has travelled.
class ChokroMark extends StatelessWidget {
  const ChokroMark({
    super.key,
    this.size = 96,
    this.onDark = false,
    this.icon = LucideIcons.bookOpen,
    this.progress,
  });

  final double size;

  /// Use on the brand gradient, where the ring must be light.
  final bool onDark;
  final IconData icon;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = context.colors;
    final first = onDark ? AppPalette.dark.exchange : palette.exchange;
    final second = onDark ? AppPalette.dark.donate : palette.donate;
    final track = onDark
        ? Colors.white.withValues(alpha: 0.14)
        : colors.outlineVariant;
    final center = onDark
        ? Colors.white.withValues(alpha: 0.1)
        : colors.primaryContainer;
    final iconColor = onDark ? palette.onHero : colors.onPrimaryContainer;

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ChokroPainter(
          first: first,
          second: second,
          track: track,
          progress: progress,
          progressColor: onDark ? palette.onHero : colors.primary,
        ),
        child: Center(
          child: Container(
            width: size * 0.62,
            height: size * 0.62,
            decoration: BoxDecoration(color: center, shape: BoxShape.circle),
            child: Icon(icon, size: size * 0.3, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class _ChokroPainter extends CustomPainter {
  _ChokroPainter({
    required this.first,
    required this.second,
    required this.track,
    required this.progress,
    required this.progressColor,
  });

  final Color first;
  final Color second;
  final Color track;
  final double? progress;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.055;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    if (progress != null) {
      canvas.drawArc(arcRect, 0, math.pi * 2, false, paint..color = track);
      final sweep = math.pi * 2 * progress!.clamp(0.0, 1.0);
      if (sweep > 0) {
        canvas.drawArc(
          arcRect,
          -math.pi / 2,
          sweep,
          false,
          paint..color = progressColor,
        );
      }
      return;
    }

    // Two arcs chasing each other around the wheel, each ending in an arrow.
    const gap = 0.42;
    const sweep = math.pi - gap;
    _arcWithArrow(
      canvas,
      arcRect,
      -math.pi / 2 + gap / 2,
      sweep,
      first,
      stroke,
    );
    _arcWithArrow(
      canvas,
      arcRect,
      math.pi / 2 + gap / 2,
      sweep,
      second,
      stroke,
    );
  }

  void _arcWithArrow(
    Canvas canvas,
    Rect rect,
    double start,
    double sweep,
    Color color,
    double stroke,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, start, sweep, false, paint);

    final end = start + sweep;
    final radius = rect.width / 2;
    final tip = rect.center + Offset(math.cos(end), math.sin(end)) * radius;
    final tangent = end + math.pi / 2;
    final head = stroke * 1.9;
    final path = Path()
      ..moveTo(
        tip.dx + math.cos(tangent) * head,
        tip.dy + math.sin(tangent) * head,
      )
      ..lineTo(
        tip.dx + math.cos(end) * head * 0.85,
        tip.dy + math.sin(end) * head * 0.85,
      )
      ..lineTo(
        tip.dx - math.cos(end) * head * 0.85,
        tip.dy - math.sin(end) * head * 0.85,
      )
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_ChokroPainter oldDelegate) {
    return oldDelegate.first != first ||
        oldDelegate.second != second ||
        oldDelegate.track != track ||
        oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
