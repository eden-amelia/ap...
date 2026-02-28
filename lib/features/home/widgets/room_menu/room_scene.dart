import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../mascot/providers/mascot_provider.dart';
import '../../../mascot/widgets/art_cat_mascot.dart';
import 'room_destination.dart';
import 'room_object.dart';

/// Single continuous room - wide background + tappable objects
class RoomScene extends StatelessWidget {
  final List<RoomDestination> destinations;
  final void Function(RoomDestination) onObjectTap;
  final double roomWidth;
  final double viewportWidth;

  const RoomScene({
    super.key,
    required this.destinations,
    required this.onObjectTap,
    required this.roomWidth,
    required this.viewportWidth,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Continuous room background
        SizedBox(
          width: roomWidth,
          height: height,
          child: CustomPaint(
            painter: _ContinuousRoomPainter(roomWidth: roomWidth, height: height),
          ),
        ),
        // Tappable objects
        ...destinations.map(
          (d) => RoomObject(
            destination: d,
            roomWidth: roomWidth,
            viewportWidth: viewportWidth,
            onTap: () => onObjectTap(d),
          ),
        ),
        // Cat mascot sitting in the room (on the floor, centre)
        Positioned(
          left: (1.0 / 3) * roomWidth - 32, // room unit 1.0 = centre-left
          top: height * 0.75 - 64 * 1.15, // Floor at ~0.75; sitting cat height = size * 1.15
          child: Consumer<MascotProvider>(
            builder: (context, mascotProvider, _) => ArtCatMascot(
              onTap: () => mascotProvider.showContextualTooltip('welcome'),
              size: 64,
              pose: MascotPose.sitting,
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints a continuous room background (walls, floor) across the full width
class _ContinuousRoomPainter extends CustomPainter {
  final double roomWidth;
  final double height;

  _ContinuousRoomPainter({
    required this.roomWidth,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Back wall - white
    final wallPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, roomWidth, height), wallPaint);

    // Floor - perspective trapezoid across full room
    final path = Path()
      ..moveTo(0, height * 0.75)
      ..lineTo(roomWidth, height * 0.7)
      ..lineTo(roomWidth, height + 20)
      ..lineTo(0, height + 20)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ArtCatColors.sparkPeach.withValues(alpha: 0.5),
            ArtCatColors.sparkYellow.withValues(alpha: 0.4),
          ],
        ).createShader(Rect.fromLTWH(0, 0, roomWidth, height)),
    );
  }

  @override
  bool shouldRepaint(covariant _ContinuousRoomPainter oldDelegate) =>
      oldDelegate.roomWidth != roomWidth || oldDelegate.height != height;
}
