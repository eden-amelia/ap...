import 'stroke.dart';

/// Represents a complete artwork with all strokes
class Artwork {
  final String id;
  final String title;
  final List<Stroke> strokes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? thumbnailPath;

  const Artwork({
    required this.id,
    required this.title,
    required this.strokes,
    required this.createdAt,
    required this.updatedAt,
    this.thumbnailPath,
  });

  /// Create a new empty artwork
  factory Artwork.empty({required String id, String title = 'Untitled'}) {
    final now = DateTime.now();
    return Artwork(
      id: id,
      title: title,
      strokes: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a copy with modifications
  Artwork copyWith({
    String? id,
    String? title,
    List<Stroke>? strokes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? thumbnailPath,
  }) {
    return Artwork(
      id: id ?? this.id,
      title: title ?? this.title,
      strokes: strokes ?? this.strokes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  /// Add a stroke to the artwork
  Artwork addStroke(Stroke stroke) {
    return copyWith(strokes: [...strokes, stroke]);
  }

  /// Remove the last stroke (undo)
  Artwork removeLastStroke() {
    if (strokes.isEmpty) return this;
    return copyWith(strokes: strokes.sublist(0, strokes.length - 1));
  }

  /// Clear all strokes
  Artwork clear() {
    return copyWith(strokes: const []);
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'strokes': strokes.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'thumbnailPath': thumbnailPath,
    };
  }

  /// Create from JSON
  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: json['id'] as String,
      title: json['title'] as String,
      strokes: (json['strokes'] as List)
          .map((s) => Stroke.fromJson(s as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }
}
