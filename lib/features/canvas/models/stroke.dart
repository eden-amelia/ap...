import 'package:flutter/material.dart';
import '../../../core/constants/tools.dart';

/// Represents a single stroke on the canvas
class Stroke {
  final String id;
  final List<Offset> points;
  final Color color;
  final double width;
  final ToolType toolType;
  final ShapeType? shapeType;

  const Stroke({
    required this.id,
    required this.points,
    required this.color,
    required this.width,
    required this.toolType,
    this.shapeType,
  });

  /// Create a copy with additional points
  Stroke copyWithPoint(Offset point) {
    return Stroke(
      id: id,
      points: [...points, point],
      color: color,
      width: width,
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
    ToolType? toolType,
    ShapeType? shapeType,
  }) {
    return Stroke(
      id: id ?? this.id,
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
      toolType: toolType ?? this.toolType,
      shapeType: shapeType ?? this.shapeType,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
      'color': color.value,
      'width': width,
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
      toolType: ToolType.values[json['toolType'] as int],
      shapeType: json['shapeType'] != null
          ? ShapeType.values[json['shapeType'] as int]
          : null,
    );
  }
}
