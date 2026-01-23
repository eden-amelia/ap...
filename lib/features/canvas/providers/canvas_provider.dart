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

  ShapeType _selectedShape = ShapeType.circle;
  ShapeType get selectedShape => _selectedShape;

  CanvasProvider() : _artwork = Artwork.empty(id: const Uuid().v4());

  /// Start a new artwork
  void newArtwork() {
    _saveToUndoStack();
    _artwork = Artwork.empty(id: _uuid.v4());
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
  void startStroke(Offset point) {
    _currentStroke = Stroke(
      id: _uuid.v4(),
      points: [point],
      color: _selectedTool == ToolType.eraser ? Colors.white : _selectedColor,
      width: _selectedTool == ToolType.eraser ? _brushSize * 2 : _brushSize,
      toolType: _selectedTool,
      shapeType: _selectedTool == ToolType.shape ? _selectedShape : null,
    );
    notifyListeners();
  }

  /// Continue drawing the current stroke
  void updateStroke(Offset point) {
    if (_currentStroke == null) return;
    _currentStroke = _currentStroke!.copyWithPoint(point);
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
