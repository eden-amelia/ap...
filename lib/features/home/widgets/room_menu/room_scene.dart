import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'room_destination.dart';
import 'room_object.dart';

/// A single "room" in the virtual studio - background + tappable objects
class RoomScene extends StatelessWidget {
  final List<RoomDestination> destinations;
  final void Function(RoomDestination) onObjectTap;
  final int roomIndex;
  final double scrollOffset; // 0–1 for parallax
  final String roomTitle;

  const RoomScene({
    super.key,
    required this.destinations,
    required this.onObjectTap,
    required this.roomIndex,
    this.scrollOffset = 0,
    this.roomTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Room background layers (parallax)
            _RoomBackground(scrollOffset: scrollOffset),
            // Tappable objects
            ...destinations.map(
              (d) => RoomObject(
                destination: d,
                onTap: () => onObjectTap(d),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Room background with floor, walls, and decorative elements
class _RoomBackground extends StatelessWidget {
  final double scrollOffset;

  const _RoomBackground({required this.scrollOffset});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return ClipRect(
      child: CustomPaint(
        size: size,
        painter: _RoomPainter(scrollOffset: scrollOffset),
      ),
    );
  }
}

class _RoomPainter extends CustomPainter {
  final double scrollOffset;

  _RoomPainter({required this.scrollOffset});

  @override
  void paint(Canvas canvas, Size size) {
    // Back wall - soft gradient (parallax: shifts slightly)
    final wallOffset = scrollOffset * 20;
    final wallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ArtCatColors.sparkLavender.withValues(alpha: 0.6),
          ArtCatColors.sparkBg,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
      Rect.fromLTWH(-wallOffset, 0, size.width + 40, size.height),
      wallPaint,
    );

    // Floor - perspective trapezoid (creative studio floor)
    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..lineTo(size.width, size.height * 0.7)
      ..lineTo(size.width, size.height + 20)
      ..lineTo(0, size.height + 20)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ArtCatColors.sparkPeach.withValues(alpha: 0.5),
            ArtCatColors.sparkYellow.withValues(alpha: 0.4),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Decorative elements - soft shapes (windows, shelves)
    _drawDecorativeCircle(
      canvas,
      Offset(size.width * 0.2, size.height * 0.2),
      40,
      ArtCatColors.sparkPink.withValues(alpha: 0.2),
    );
    _drawDecorativeCircle(
      canvas,
      Offset(size.width * 0.8, size.height * 0.25),
      50,
      ArtCatColors.sparkMint.withValues(alpha: 0.2),
    );
    _drawDecorativeCircle(
      canvas,
      Offset(size.width * 0.5, size.height * 0.35),
      35,
      ArtCatColors.sparkPurple.withValues(alpha: 0.15),
    );
  }

  void _drawDecorativeCircle(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RoomPainter oldDelegate) =>
      oldDelegate.scrollOffset != scrollOffset;
}
