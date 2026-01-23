import 'package:flutter/material.dart';

/// Tool types available in the app
enum ToolType {
  pen,
  pencil,
  eraser,
  shape,
  fill,
}

/// Shape types for the shape tool
enum ShapeType {
  circle,
  square,
  triangle,
}

/// Pen styles available
enum PenStyle {
  round,
  normal,
}

/// Tool configuration
class ToolConfig {
  final ToolType type;
  final String name;
  final IconData icon;
  final bool isPremium;

  const ToolConfig({
    required this.type,
    required this.name,
    required this.icon,
    this.isPremium = false,
  });
}

/// Default tools available in the MVP
class ArtCatTools {
  ArtCatTools._();

  static const List<ToolConfig> basicTools = [
    ToolConfig(
      type: ToolType.pen,
      name: 'Pen',
      icon: Icons.edit,
    ),
    ToolConfig(
      type: ToolType.pencil,
      name: 'Pencil',
      icon: Icons.create,
    ),
    ToolConfig(
      type: ToolType.eraser,
      name: 'Eraser',
      icon: Icons.auto_fix_off,
    ),
    ToolConfig(
      type: ToolType.shape,
      name: 'Shape',
      icon: Icons.crop_square,
    ),
    ToolConfig(
      type: ToolType.fill,
      name: 'Fill',
      icon: Icons.format_color_fill,
    ),
  ];

  static const List<double> brushSizes = [2.0, 4.0, 8.0, 12.0, 20.0, 30.0];

  static const double defaultBrushSize = 4.0;
}
