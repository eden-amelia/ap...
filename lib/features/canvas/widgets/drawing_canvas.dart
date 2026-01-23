import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/tools.dart';
import '../models/stroke.dart';
import '../providers/canvas_provider.dart';

/// The main drawing canvas widget
class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, canvasProvider, child) {
        return GestureDetector(
          onPanStart: (details) {
            canvasProvider.startStroke(details.localPosition);
          },
          onPanUpdate: (details) {
            canvasProvider.updateStroke(details.localPosition);
          },
          onPanEnd: (details) {
            canvasProvider.endStroke();
          },
          child: ClipRect(
            child: CustomPaint(
              painter: CanvasPainter(
                strokes: canvasProvider.artwork.strokes,
                currentStroke: canvasProvider.currentStroke,
              ),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for rendering strokes
class CanvasPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;

  CanvasPainter({
    required this.strokes,
    this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = ArtCatColors.canvasBackground,
    );

    // Draw all completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // Draw current stroke
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.toolType == ToolType.shape && stroke.points.length >= 2) {
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

    if (stroke.points.length == 1) {
      // Draw a dot for single point
      canvas.drawCircle(
        stroke.points.first,
        stroke.width / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    // Draw smooth path through points
    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

    for (int i = 1; i < stroke.points.length - 1; i++) {
      final p0 = stroke.points[i];
      final p1 = stroke.points[i + 1];
      final midPoint = Offset(
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );
      path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
    }

    // Last point
    if (stroke.points.length > 1) {
      path.lineTo(stroke.points.last.dx, stroke.points.last.dy);
    }

    canvas.drawPath(path, paint);
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

    // Default to circle for fill tool
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return strokes != oldDelegate.strokes ||
        currentStroke != oldDelegate.currentStroke;
  }
}
