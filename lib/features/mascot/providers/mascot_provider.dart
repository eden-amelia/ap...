import 'package:flutter/material.dart';
import '../models/mascot_state.dart';

export '../models/mascot_state.dart' show MascotReaction;

/// Manages the Art Cat mascot state
class MascotProvider extends ChangeNotifier {
  MascotReaction _reaction = MascotReaction.idle;
  MascotReaction get reaction => _reaction;

  MascotTooltip? _currentTooltip;
  MascotTooltip? get currentTooltip => _currentTooltip;

  bool _isTooltipVisible = false;
  bool get isTooltipVisible => _isTooltipVisible;

  bool _tooltipsEnabled = true;
  bool get tooltipsEnabled => _tooltipsEnabled;

  bool _mascotVisibleOnCanvas = true;
  bool get mascotVisibleOnCanvas => _mascotVisibleOnCanvas;

  /// Show or hide the mascot on the canvas (drawing) screen
  void setMascotVisibleOnCanvas(bool visible) {
    if (_mascotVisibleOnCanvas != visible) {
      _mascotVisibleOnCanvas = visible;
      notifyListeners();
    }
  }

  /// Set the mascot's reaction
  void setReaction(MascotReaction reaction) {
    _reaction = reaction;
    notifyListeners();

    // Auto-reset to idle after a delay for celebratory reactions
    if (reaction == MascotReaction.celebrating ||
        reaction == MascotReaction.excited) {
      Future.delayed(const Duration(seconds: 2), () {
        if (_reaction == reaction) {
          _reaction = MascotReaction.happy;
          notifyListeners();
        }
      });
    }
  }

  /// Show a tooltip for a specific context
  void showContextualTooltip(String context) {
    if (!_tooltipsEnabled) return;

    _currentTooltip = MascotTooltips.getTooltip(context);
    _isTooltipVisible = true;
    _reaction = MascotReaction.happy;
    notifyListeners();
  }

  /// Show a custom tooltip
  void showCustomTooltip(MascotTooltip tooltip) {
    _currentTooltip = tooltip;
    _isTooltipVisible = true;
    _reaction = MascotReaction.happy;
    notifyListeners();
  }

  /// Hide the current tooltip
  void hideTooltip() {
    _isTooltipVisible = false;
    _reaction = MascotReaction.idle;
    notifyListeners();
  }

  /// Toggle tooltips on/off
  void toggleTooltips() {
    _tooltipsEnabled = !_tooltipsEnabled;
    if (!_tooltipsEnabled) {
      _isTooltipVisible = false;
    }
    notifyListeners();
  }

  /// Get emoji representation of current reaction
  String get reactionEmoji {
    switch (_reaction) {
      case MascotReaction.idle:
        return '🐱';
      case MascotReaction.happy:
        return '😸';
      case MascotReaction.excited:
        return '😻';
      case MascotReaction.thinking:
        return '🤔';
      case MascotReaction.celebrating:
        return '🎉';
      case MascotReaction.sleeping:
        return '😴';
      case MascotReaction.curious:
        return '😺';
    }
  }
}
