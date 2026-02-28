import 'package:flutter/material.dart';

/// A destination in the room menu - tappable object that navigates to a route
class RoomDestination {
  final String route;
  final String label;
  final String emoji;
  final IconData icon;
  final Offset position; // Normalised 0-1 within room
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
