import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/tools.dart';
import '../providers/canvas_provider.dart';

/// Bottom toolbar for drawing tools
class ToolsPanel extends StatelessWidget {
  final VoidCallback? onMascotTap;

  const ToolsPanel({super.key, this.onMascotTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<CanvasProvider>(
      builder: (context, canvasProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: ArtCatColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tools row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...ArtCatTools.basicTools.map((tool) => _ToolButton(
                          tool: tool,
                          isSelected: canvasProvider.selectedTool == tool.type,
                          onTap: () => canvasProvider.selectTool(tool.type),
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                // Colour palette row
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ArtCatColors.basicPalette.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final color = ArtCatColors.basicPalette[index];
                      final isSelected =
                          canvasProvider.selectedColor == color;
                      return _ColorButton(
                        color: color,
                        isSelected: isSelected,
                        onTap: () => canvasProvider.selectColor(color),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Brush size and actions row
                Row(
                  children: [
                    // Brush size slider
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.brush, size: 18),
                          Expanded(
                            child: Slider(
                              value: canvasProvider.brushSize,
                              min: 1,
                              max: 50,
                              onChanged: (value) =>
                                  canvasProvider.setBrushSize(value),
                              activeColor: ArtCatColors.primary,
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text(
                              canvasProvider.brushSize.round().toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action buttons
                    IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed:
                          canvasProvider.canUndo ? canvasProvider.undo : null,
                      tooltip: 'Undo',
                    ),
                    IconButton(
                      icon: const Icon(Icons.redo),
                      onPressed:
                          canvasProvider.canRedo ? canvasProvider.redo : null,
                      tooltip: 'Redo',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _showClearDialog(context, canvasProvider),
                      tooltip: 'Clear canvas',
                    ),
                  ],
                ),
                // Shape selector (only visible when shape tool selected)
                if (canvasProvider.selectedTool == ToolType.shape) ...[
                  const SizedBox(height: 8),
                  _ShapeSelector(
                    selectedShape: canvasProvider.selectedShape,
                    onShapeSelected: canvasProvider.selectShape,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, CanvasProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear canvas?'),
        content: const Text(
            'This will remove all your strokes. You can undo this action.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearCanvas();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final ToolConfig tool;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolButton({
    required this.tool,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? ArtCatColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          tool.icon,
          color: isSelected ? Colors.white : ArtCatColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? ArtCatColors.primary : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ArtCatColors.primary.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
      ),
    );
  }
}

class _ShapeSelector extends StatelessWidget {
  final ShapeType selectedShape;
  final Function(ShapeType) onShapeSelected;

  const _ShapeSelector({
    required this.selectedShape,
    required this.onShapeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Shape: ', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 12),
        _ShapeButton(
          icon: Icons.circle_outlined,
          isSelected: selectedShape == ShapeType.circle,
          onTap: () => onShapeSelected(ShapeType.circle),
        ),
        const SizedBox(width: 8),
        _ShapeButton(
          icon: Icons.crop_square,
          isSelected: selectedShape == ShapeType.square,
          onTap: () => onShapeSelected(ShapeType.square),
        ),
        const SizedBox(width: 8),
        _ShapeButton(
          icon: Icons.change_history,
          isSelected: selectedShape == ShapeType.triangle,
          onTap: () => onShapeSelected(ShapeType.triangle),
        ),
      ],
    );
  }
}

class _ShapeButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShapeButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? ArtCatColors.secondary
              : ArtCatColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : ArtCatColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
