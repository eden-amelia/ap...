import 'package:flutter/material.dart';
import '../../../core/constants/tools.dart';

/// Represents a single stroke on the canvas
/// Supports per-point widths for pressure-sensitive drawing (Procreate-style)
class Stroke {
  final String id;
  final List<Offset> points;
  final Color color;
  final double width;
  /// Per-point widths for pressure-sensitive strokes. When null, uses uniform [width].
  final List<double>? widths;
  final ToolType toolType;
  final ShapeType? shapeType;

  const Stroke({
    required this.id,
    required this.points,
    required this.color,
    required this.width,
    this.widths,
    required this.toolType,
    this.shapeType,
  });

  /// Create a copy with additional point (and optional pressure-based width)
  Stroke copyWithPoint(Offset point, {double? pressureWidth}) {
    final newWidths = pressureWidth != null
        ? [...?widths, pressureWidth]
        : widths != null
            ? [...widths!, width]
            : null;
    return Stroke(
      id: id,
      points: [...points, point],
      color: color,
      width: width,
      widths: newWidths,
      toolType: toolType,
      shapeType: shapeType,
    );
  }

  /// Create a copy with new properties
  Stroke copyWith({
    String? id,
    List<Offset>? points,
    Color? color,
    double? width,
    List<double>? widths,
    ToolType? toolType,
    ShapeType? shapeType,
  }) {
    return Stroke(
      id: id ?? this.id,
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
      widths: widths ?? this.widths,
      toolType: toolType ?? this.toolType,
      shapeType: shapeType ?? this.shapeType,
    );
  }

  /// Get effective width at point index (for pressure-sensitive strokes)
  double widthAt(int index) {
    if (widths != null && index < widths!.length) {
      return widths![index];
    }
    return width;
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
      'color': color.value,
      'width': width,
      if (widths != null) 'widths': widths,
      'toolType': toolType.index,
      'shapeType': shapeType?.index,
    };
  }

  /// Create from JSON
  factory Stroke.fromJson(Map<String, dynamic> json) {
    return Stroke(
      id: json['id'] as String,
      points: (json['points'] as List)
          .map((p) => Offset(p['dx'] as double, p['dy'] as double))
          .toList(),
      color: Color(json['color'] as int),
      width: json['width'] as double,
      widths: json['widths'] != null
          ? (json['widths'] as List).map((w) => (w as num).toDouble()).toList()
          : null,
      toolType: ToolType.values[json['toolType'] as int],
      shapeType: json['shapeType'] != null
          ? ShapeType.values[json['shapeType'] as int]
          : null,
    );
  }
}
