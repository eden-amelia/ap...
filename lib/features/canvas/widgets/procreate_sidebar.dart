import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/tools.dart';
import '../providers/canvas_provider.dart';

/// Procreate-style left sidebar: brush size, opacity, modify, undo, redo
class ProcreateSidebar extends StatelessWidget {
  const ProcreateSidebar({
    super.key,
    this.onModifyTap,
  });

  /// Modify button (eyedropper in Procreate) - optional
  final VoidCallback? onModifyTap;

  static const double _sidebarWidth = 48;
  static const double _sliderHeight = 80;

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, provider, _) {
        return Container(
          width: _sidebarWidth,
          margin: EdgeInsets.only(
            left: 8,
            bottom: MediaQuery.paddingOf(context).bottom + 8,
          ),
          decoration: BoxDecoration(
            color: ArtCatColors.procreateCharcoal,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ArtCatColors.procreateCharcoalLight.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Brush size slider (top) - vertical, up = larger
              Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    final delta = event.scrollDelta.dy;
                    final newSize = (provider.brushSize - delta.sign * 2)
                        .clamp(1.0, 50.0);
                    if (newSize != provider.brushSize) {
                      provider.setBrushSize(newSize);
                    }
                  }
                },
                child: SizedBox(
                  height: _sliderHeight,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        overlayColor: Colors.transparent,
                        thumbColor: ArtCatColors.primary,
                        activeTrackColor: ArtCatColors.primary.withOpacity(0.5),
                        inactiveTrackColor: ArtCatColors.procreateCharcoalLight,
                      ),
                      child: Slider(
                        value: provider.brushSize,
                        min: 1,
                        max: 50,
                        onChanged: provider.setBrushSize,
                      ),
                    ),
                  ),
                ),
              ),
              Tooltip(
                message: 'Brush size',
                child: SizedBox(
                  height: 20,
                  child: Center(
                    child: Text(
                      provider.brushSize.round().toString(),
                      style: TextStyle(
                        fontSize: 11,
                        color: ArtCatColors.procreateOnSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Brush opacity slider (bottom) - vertical
              Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    final delta = event.scrollDelta.dy;
                    final step = 0.05;
                    final newOpacity = (provider.brushOpacity - delta.sign * step)
                        .clamp(0.1, 1.0);
                    if ((newOpacity - provider.brushOpacity).abs() > 0.001) {
                      provider.setBrushOpacity(newOpacity);
                    }
                  }
                },
                child: SizedBox(
                  height: _sliderHeight,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        overlayColor: Colors.transparent,
                        thumbColor: ArtCatColors.secondary,
                        activeTrackColor: ArtCatColors.secondary.withOpacity(0.5),
                        inactiveTrackColor: ArtCatColors.procreateCharcoalLight,
                      ),
                      child: Slider(
                        value: provider.brushOpacity,
                        min: 0.1,
                        max: 1,
                        onChanged: provider.setBrushOpacity,
                      ),
                    ),
                  ),
                ),
              ),
              Tooltip(
                message: 'Brush opacity',
                child: SizedBox(
                  height: 20,
                  child: Center(
                    child: Text(
                      '${(provider.brushOpacity * 100).round()}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: ArtCatColors.procreateOnSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Modify button (square - Procreate style)
              if (onModifyTap != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Tooltip(
                    message: 'Eyedropper',
                    child: GestureDetector(
                      onTap: onModifyTap,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ArtCatColors.procreateCharcoalLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: ArtCatColors.procreateOnSurface.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.colorize,
                          size: 18,
                          color: ArtCatColors.procreateOnSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              // Undo
              Tooltip(
                message: 'Undo',
                child: IconButton(
                  icon: const Icon(Icons.undo),
                  color: provider.canUndo
                      ? ArtCatColors.procreateOnSurface
                      : ArtCatColors.procreateOnSurface.withOpacity(0.3),
                  iconSize: 24,
                  onPressed: provider.canUndo ? provider.undo : null,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
              // Redo
              Tooltip(
                message: 'Redo',
                child: IconButton(
                  icon: const Icon(Icons.redo),
                  color: provider.canRedo
                      ? ArtCatColors.procreateOnSurface
                      : ArtCatColors.procreateOnSurface.withOpacity(0.3),
                  iconSize: 24,
                  onPressed: provider.canRedo ? provider.redo : null,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
