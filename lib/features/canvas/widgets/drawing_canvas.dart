import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/tools.dart';
import '../models/stroke.dart';
import '../providers/canvas_provider.dart';

/// Procreate-style drawing canvas with smooth strokes, pressure sensitivity,
/// and two-finger tap to undo
class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final Set<int> _activePointers = {};
  int? _drawingPointer;
  int _pointersWhenTwoFingerStarted = 0;
  DateTime? _twoFingerDownTime;
  Offset? _lastPoint;
  DateTime? _lastMoveTime;

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, canvasProvider, child) {
        return Listener(
          onPointerDown: (event) => _handlePointerDown(context, event, canvasProvider),
          onPointerMove: (event) => _handlePointerMove(event, canvasProvider),
          onPointerUp: (event) => _handlePointerUp(context, event, canvasProvider),
          onPointerCancel: (event) => _handlePointerUp(context, event, canvasProvider),
          child: ClipRect(
            child: CustomPaint(
              painter: CanvasPainter(
                strokes: canvasProvider.artwork.strokes,
                currentStroke: canvasProvider.currentStroke,
                stabilisation: canvasProvider.stabilisation,
              ),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }

  void _handlePointerDown(
    BuildContext context,
    PointerDownEvent event,
    CanvasProvider provider,
  ) {
    _activePointers.add(event.pointer);

    if (_activePointers.length == 2 && _drawingPointer == null) {
      _twoFingerDownTime = DateTime.now();
      _pointersWhenTwoFingerStarted = 2;
    }

    if (_drawingPointer == null && _activePointers.length == 1) {
      _drawingPointer = event.pointer;
      _lastPoint = event.localPosition;
      _lastMoveTime = DateTime.now();
      final pressure = _getPressure(event);
      provider.startStroke(event.localPosition, pressure: pressure);
    }
  }

  void _handlePointerMove(PointerMoveEvent event, CanvasProvider provider) {
    if (event.pointer == _drawingPointer) {
      final pressure = _getPressure(event);
      double? velocity;
      if (pressure == null && _lastPoint != null && _lastMoveTime != null) {
        final now = DateTime.now();
        final dt = now.difference(_lastMoveTime!).inMicroseconds / 1000.0;
        if (dt > 0) {
          final dx = event.localPosition.dx - _lastPoint!.dx;
          final dy = event.localPosition.dy - _lastPoint!.dy;
          final distance = math.sqrt(dx * dx + dy * dy);
          velocity = distance / dt;
        }
      }
      _lastPoint = event.localPosition;
      _lastMoveTime = DateTime.now();
      provider.updateStroke(event.localPosition, pressure: pressure, velocity: velocity);
    }
  }

  void _handlePointerUp(
    BuildContext context,
    PointerEvent event,
    CanvasProvider provider,
  ) {
    if (event.pointer == _drawingPointer) {
      provider.endStroke();
      _drawingPointer = null;
      _lastPoint = null;
      _lastMoveTime = null;
    }

    _activePointers.remove(event.pointer);

    // Two-finger tap to undo (Procreate-style)
    if (_activePointers.isEmpty &&
        _pointersWhenTwoFingerStarted == 2 &&
        _twoFingerDownTime != null) {
      final elapsed = DateTime.now().difference(_twoFingerDownTime!);
      if (elapsed.inMilliseconds < 400 && provider.canUndo) {
        provider.undo();
      }
      _twoFingerDownTime = null;
      _pointersWhenTwoFingerStarted = 0;
    }
  }

  double? _getPressure(PointerEvent event) {
    final pressure = event.pressure;
    if (pressure > 0 && pressure < 1) {
      return pressure;
    }
    return null;
  }
}

/// Custom painter for rendering strokes with Catmull-Rom spline smoothing
class CanvasPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;
  final double stabilisation;

  CanvasPainter({
    required this.strokes,
    this.currentStroke,
    this.stabilisation = 50,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = ArtCatColors.canvasBackground,
    );

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    final paint = Paint()
      ..color = stroke.color.withOpacity(stroke.color.opacity * stroke.opacity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (stroke.toolType == ToolType.shape && stroke.points.length >= 2) {
      paint.strokeWidth = stroke.width;
      _drawShape(canvas, stroke, paint);
    } else if (stroke.toolType == ToolType.fill) {
      paint.style = PaintingStyle.fill;
      _drawFillShape(canvas, stroke, paint);
    } else {
      _drawFreehand(canvas, stroke, paint);
    }
  }

  void _drawFreehand(Canvas canvas, Stroke stroke, Paint paint) {
    if (stroke.points.isEmpty) return;

    final points = stroke.points;
    final hasVariableWidth = stroke.widths != null;

    if (points.length == 1) {
      final w = stroke.widthAt(0) / 2;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(points.first, w, paint);
      return;
    }

    final smoothPoints = _catmullRomSpline(points);

    if (hasVariableWidth) {
      _drawVariableWidthPath(canvas, smoothPoints, stroke, paint);
    } else {
      paint.strokeWidth = stroke.width;
      paint.style = PaintingStyle.stroke;
      _drawSmoothPath(canvas, smoothPoints, paint);
    }
  }

  /// Centripetal Catmull-Rom spline - Procreate-style smooth curves
  /// Stabilisation 0–100 controls smoothing (higher = smoother)
  List<Offset> _catmullRomSpline(List<Offset> points) {
    final divisionsPerSegment = 4 + (stabilisation / 100 * 20).round();
    if (points.length < 2) return points;
    if (points.length == 2) return points;

    const alpha = 0.5;

    double _distance(Offset a, Offset b) {
      return math.sqrt(
        (a.dx - b.dx) * (a.dx - b.dx) + (a.dy - b.dy) * (a.dy - b.dy),
      );
    }

    double _powDist(Offset a, Offset b) {
      final d = _distance(a, b);
      return math.pow(d, alpha).toDouble();
    }

    final result = <Offset>[points.first];

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];

      final t01 = _powDist(p0, p1);
      final t12 = _powDist(p1, p2);
      final t23 = _powDist(p2, p3);

      final m1 = Offset(
        (p2.dx - p1.dx) +
            t12 *
                ((p1.dx - p0.dx) / t01 -
                    (p2.dx - p0.dx) / (t01 + t12)),
        (p2.dy - p1.dy) +
            t12 *
                ((p1.dy - p0.dy) / t01 -
                    (p2.dy - p0.dy) / (t01 + t12)),
      );
      final m2 = Offset(
        (p2.dx - p1.dx) +
            t12 *
                ((p3.dx - p2.dx) / t23 -
                    (p3.dx - p1.dx) / (t12 + t23)),
        (p2.dy - p1.dy) +
            t12 *
                ((p3.dy - p2.dy) / t23 -
                    (p3.dy - p1.dy) / (t12 + t23)),
      );

      for (int j = 1; j <= divisionsPerSegment; j++) {
        final t = j / divisionsPerSegment;
        final t2 = t * t;
        final t3 = t2 * t;

        final a = Offset(
          2 * (p1.dx - p2.dx) + m1.dx + m2.dx,
          2 * (p1.dy - p2.dy) + m1.dy + m2.dy,
        );
        final b = Offset(
          -3 * (p1.dx - p2.dx) - 2 * m1.dx - m2.dx,
          -3 * (p1.dy - p2.dy) - 2 * m1.dy - m2.dy,
        );
        final c = m1;

        final pt = Offset(
          a.dx * t3 + b.dx * t2 + c.dx * t + p1.dx,
          a.dy * t3 + b.dy * t2 + c.dy * t + p1.dy,
        );
        result.add(pt);
      }
    }

    return result;
  }

  void _drawSmoothPath(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawVariableWidthPath(
    Canvas canvas,
    List<Offset> smoothPoints,
    Stroke stroke,
    Paint paint,
  ) {
    if (smoothPoints.length < 2) return;

    final widths = stroke.widths!;
    final numPoints = stroke.points.length;

    for (int i = 0; i < smoothPoints.length - 1; i++) {
      final t = i / (smoothPoints.length - 1);
      final srcIdx = (t * (numPoints - 1)).floor().clamp(0, numPoints - 1);
      final nextIdx = (srcIdx + 1).clamp(0, numPoints - 1);
      final localT = (t * (numPoints - 1)) - srcIdx;

      final w1 = stroke.widthAt(srcIdx);
      final w2 = stroke.widthAt(nextIdx);
      final segWidth = w1 + (w2 - w1) * localT;

      paint.strokeWidth = segWidth;
      paint.style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(smoothPoints[i].dx, smoothPoints[i].dy);
      path.lineTo(smoothPoints[i + 1].dx, smoothPoints[i + 1].dy);
      canvas.drawPath(path, paint);
    }
  }

  void _drawShape(Canvas canvas, Stroke stroke, Paint paint) {
    if (stroke.points.length < 2) return;

    final start = stroke.points.first;
    final end = stroke.points.last;
    final rect = Rect.fromPoints(start, end);

    switch (stroke.shapeType) {
      case ShapeType.circle:
        canvas.drawOval(rect, paint);
        break;
      case ShapeType.square:
        canvas.drawRect(rect, paint);
        break;
      case ShapeType.triangle:
        final path = Path();
        path.moveTo(rect.center.dx, rect.top);
        path.lineTo(rect.right, rect.bottom);
        path.lineTo(rect.left, rect.bottom);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case null:
        break;
    }
  }

  void _drawFillShape(Canvas canvas, Stroke stroke, Paint paint) {
    if (stroke.points.length < 2) return;

    final start = stroke.points.first;
    final end = stroke.points.last;
    final rect = Rect.fromPoints(start, end);

    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return strokes != oldDelegate.strokes ||
        currentStroke != oldDelegate.currentStroke ||
        stabilisation != oldDelegate.stabilisation;
  }
}
