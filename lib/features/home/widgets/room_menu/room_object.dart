import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'room_destination.dart';

/// A tappable object in the virtual room - styled like a studio prop
/// Positioned in a continuous room; position.dx is in room units (0..3)
class RoomObject extends StatelessWidget {
  final RoomDestination destination;
  final double roomWidth;
  final double viewportWidth;
  final VoidCallback onTap;
  final bool isHighlighted;

  const RoomObject({
    super.key,
    required this.destination,
    required this.roomWidth,
    required this.viewportWidth,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final objectSize = size.shortestSide * 0.22;
    // position.dx: 0..3 (room segments), dy: 0..1 (normalised height)
    final left = (destination.position.dx / 3) * roomWidth - objectSize / 2;
    final top = destination.position.dy * size.height - objectSize / 2;

    return Positioned(
      left: left.clamp(16.0, roomWidth - objectSize - 16),
      top: top.clamp(80.0, size.height - objectSize - 80),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: objectSize,
            height: objectSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: destination.accentColors,
              ),
              borderRadius: BorderRadius.circular(objectSize * 0.2),
              boxShadow: [
                BoxShadow(
                  color: destination.accentColors.first.withValues(alpha: 0.35),
                  blurRadius: isHighlighted ? 20 : 12,
                  offset: Offset(0, isHighlighted ? 6 : 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(-2, -2),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: Tooltip(
              message: destination.label,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      destination.emoji,
                      style: TextStyle(fontSize: objectSize * 0.4),
                    ),
                    SizedBox(height: objectSize * 0.05),
                    Icon(
                      destination.icon,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: objectSize * 0.25,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
