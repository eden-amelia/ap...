import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/tools.dart';
import '../models/artwork.dart';
import '../models/stroke.dart';

/// Manages the canvas state and drawing operations
class CanvasProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  // Current artwork
  Artwork _artwork;
  Artwork get artwork => _artwork;

  // Current stroke being drawn
  Stroke? _currentStroke;
  Stroke? get currentStroke => _currentStroke;

  // Undo/Redo stacks
  final List<Artwork> _undoStack = [];
  final List<Artwork> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  // Tool settings
  ToolType _selectedTool = ToolType.pen;
  ToolType get selectedTool => _selectedTool;

  Color _selectedColor = ArtCatColors.basicPalette[0];
  Color get selectedColor => _selectedColor;

  double _brushSize = ArtCatTools.defaultBrushSize;
  double get brushSize => _brushSize;

  double _brushOpacity = 1.0;
  double get brushOpacity => _brushOpacity;

  double _stabilisation = 50;
  double get stabilisation => _stabilisation;

  ShapeType _selectedShape = ShapeType.circle;
  ShapeType get selectedShape => _selectedShape;

  CanvasProvider() : _artwork = Artwork.empty(id: const Uuid().v4());

  /// Start a new artwork
  /// [prompt] Optional prompt when started from Art Prompts
  void newArtwork({String? prompt}) {
    _saveToUndoStack();
    _artwork = Artwork.empty(id: _uuid.v4(), prompt: prompt);
    _redoStack.clear();
    notifyListeners();
  }

  /// Load an existing artwork
  void loadArtwork(Artwork artwork) {
    _saveToUndoStack();
    _artwork = artwork;
    _redoStack.clear();
    notifyListeners();
  }

  /// Start drawing a stroke
  /// [pressure] 0–1 from stylus; null uses velocity-based or uniform width
  /// [velocity] pixels/ms for velocity-based width (Procreate-style, works on desktop)
  void startStroke(Offset point, {double? pressure, double? velocity}) {
    final baseWidth =
        _selectedTool == ToolType.eraser ? _brushSize * 2 : _brushSize;
    final effectiveWidth = _effectiveWidth(baseWidth, pressure, velocity);
    final useVariableWidth = pressure != null || velocity != null;

    _currentStroke = Stroke(
      id: _uuid.v4(),
      points: [point],
      color: _selectedTool == ToolType.eraser ? Colors.white : _selectedColor,
      width: baseWidth,
      opacity: _brushOpacity,
      widths: useVariableWidth ? [effectiveWidth] : null,
      toolType: _selectedTool,
      shapeType: _selectedTool == ToolType.shape ? _selectedShape : null,
    );
    notifyListeners();
  }

  /// Continue drawing the current stroke
  void updateStroke(Offset point, {double? pressure, double? velocity}) {
    if (_currentStroke == null) return;
    final baseWidth =
        _currentStroke!.toolType == ToolType.eraser
            ? _brushSize * 2
            : _brushSize;
    final effectiveWidth = _effectiveWidth(baseWidth, pressure, velocity);
    final useVariableWidth = pressure != null || velocity != null;

    _currentStroke = _currentStroke!.copyWithPoint(
      point,
      pressureWidth: useVariableWidth ? effectiveWidth : null,
    );
    notifyListeners();
  }

  double _effectiveWidth(double baseWidth, double? pressure, double? velocity) {
    if (pressure != null) {
      return baseWidth * (0.25 + 0.75 * pressure.clamp(0.0, 1.0));
    }
    if (velocity != null) {
      // Procreate-style: fast strokes = thinner, slow = thicker
      const scale = 2.0;
      final factor = 1 / (1 + velocity * scale);
      return baseWidth * (0.35 + 0.65 * factor);
    }
    return baseWidth;
  }

  void setBrushOpacity(double opacity) {
    _brushOpacity = opacity.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setStabilisation(double value) {
    _stabilisation = value.clamp(0.0, 100.0);
    notifyListeners();
  }

  /// Finish the current stroke
  void endStroke() {
    if (_currentStroke == null) return;

    // Only add strokes with more than 1 point (or shapes)
    if (_currentStroke!.points.length > 1 ||
        _currentStroke!.toolType == ToolType.shape) {
      _saveToUndoStack();
      _artwork = _artwork.addStroke(_currentStroke!);
      _redoStack.clear();
    }

    _currentStroke = null;
    notifyListeners();
  }

  /// Undo last stroke
  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_artwork);
    _artwork = _undoStack.removeLast();
    notifyListeners();
  }

  /// Redo last undone stroke
  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_artwork);
    _artwork = _redoStack.removeLast();
    notifyListeners();
  }

  /// Clear the canvas
  void clearCanvas() {
    _saveToUndoStack();
    _artwork = _artwork.clear();
    _redoStack.clear();
    notifyListeners();
  }

  /// Select a tool
  void selectTool(ToolType tool) {
    _selectedTool = tool;
    notifyListeners();
  }

  /// Select a colour
  void selectColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  /// Set brush size
  void setBrushSize(double size) {
    _brushSize = size;
    notifyListeners();
  }

  /// Select a shape type
  void selectShape(ShapeType shape) {
    _selectedShape = shape;
    notifyListeners();
  }

  /// Set artwork title
  void setTitle(String title) {
    _artwork = _artwork.copyWith(title: title);
    notifyListeners();
  }

  void _saveToUndoStack() {
    _undoStack.add(_artwork);
    // Limit undo stack size
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }
  }
}
