import 'package:flutter/material.dart';

/// A destination in the room menu - tappable object that navigates to a route
/// Position: dx is in "room units" (0 = left, 3 = right for a 3-screen room), dy is 0-1
class RoomDestination {
  final String route;
  final String label;
  final String emoji;
  final IconData icon;
  final Offset position;
  final List<Color> accentColors;

  const RoomDestination({
    required this.route,
    required this.label,
    required this.emoji,
    required this.icon,
    required this.position,
    required this.accentColors,
  });
}
