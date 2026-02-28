import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/tools.dart';
import '../providers/canvas_provider.dart';

/// Procreate-style top bar: left = back, editing tools, right = painting tools + color
class ProcreateTopBar extends StatelessWidget {
  const ProcreateTopBar({
    super.key,
    this.onBackTap,
    this.onGalleryTap,
    this.onActionsTap,
  });

  final VoidCallback? onBackTap;
  final VoidCallback? onGalleryTap;
  final VoidCallback? onActionsTap;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.only(
        top: topPadding,
        left: 8,
        right: 8,
        bottom: 8,
      ),
      constraints: BoxConstraints(minHeight: 56 + topPadding),
      decoration: BoxDecoration(
        color: ArtCatColors.procreateCharcoal,
        border: Border(
          bottom: BorderSide(
            color: ArtCatColors.procreateCharcoalLight.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left: Back, Gallery, Actions (Procreate editing tools)
          _EditingTools(
            onBackTap: onBackTap,
            onGalleryTap: onGalleryTap,
            onActionsTap: onActionsTap,
          ),
          const Spacer(),
          // Right: Paint, Smudge, Erase, Shape, Fill, Color
          Consumer<CanvasProvider>(
            builder: (context, provider, _) => _PaintingTools(
              selectedTool: provider.selectedTool,
              selectedShape: provider.selectedShape,
              selectedColor: provider.selectedColor,
              onToolSelected: provider.selectTool,
              onShapeSelected: provider.selectShape,
              onColorSelected: provider.selectColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditingTools extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onGalleryTap;
  final VoidCallback? onActionsTap;

  const _EditingTools({
    this.onBackTap,
    this.onGalleryTap,
    this.onActionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onBackTap != null) ...[
          _ToolIconButton(
            icon: Icons.arrow_back_ios_new,
            tooltip: 'Back',
            onTap: onBackTap!,
          ),
          const SizedBox(width: 4),
        ],
        if (onGalleryTap != null)
          _ToolIconButton(
            icon: Icons.album_outlined,
            tooltip: 'Gallery',
            onTap: onGalleryTap!,
          ),
        const SizedBox(width: 4),
        if (onActionsTap != null)
          _ToolIconButton(
            icon: Icons.build,
            tooltip: 'Actions',
            onTap: onActionsTap!,
          ),
      ],
    );
  }
}

class _PaintingTools extends StatelessWidget {
  final ToolType selectedTool;
  final ShapeType selectedShape;
  final Color selectedColor;
  final ValueChanged<ToolType> onToolSelected;
  final ValueChanged<ShapeType> onShapeSelected;
  final ValueChanged<Color> onColorSelected;

  const _PaintingTools({
    required this.selectedTool,
    required this.selectedShape,
    required this.selectedColor,
    required this.onToolSelected,
    required this.onShapeSelected,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Paint (pen), Smudge (pencil), Erase, Shape, Fill
        ...ArtCatTools.basicTools.map((tool) {
          final isShapeTool = tool.type == ToolType.shape;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: isShapeTool
                ? _ShapeToolButton(
                    tool: tool,
                    isSelected: selectedTool == tool.type,
                    selectedShape: selectedShape,
                    onToolSelected: onToolSelected,
                    onShapeSelected: onShapeSelected,
                  )
                : _ToolIconButton(
                    icon: tool.icon,
                    tooltip: tool.name,
                    isSelected: selectedTool == tool.type,
                    onTap: () => onToolSelected(tool.type),
                  ),
          );
        }),
        const SizedBox(width: 8),
        // Color well - displays current colour, opens full picker
        _ColorWell(
          color: selectedColor,
          onColorSelected: onColorSelected,
        ),
      ],
    );
  }
}

class _ShapeToolButton extends StatelessWidget {
  final ToolConfig tool;
  final bool isSelected;
  final ShapeType selectedShape;
  final ValueChanged<ToolType> onToolSelected;
  final ValueChanged<ShapeType> onShapeSelected;

  const _ShapeToolButton({
    required this.tool,
    required this.isSelected,
    required this.selectedShape,
    required this.onToolSelected,
    required this.onShapeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tool.name,
      child: GestureDetector(
        onTap: () => onToolSelected(tool.type),
        onLongPress: () => _showShapePopover(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? ArtCatColors.procreateCharcoalLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            tool.icon,
            size: 24,
            color: isSelected
                ? ArtCatColors.procreateOnSurface
                : ArtCatColors.procreateOnSurface.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  void _showShapePopover(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ArtCatColors.procreateCharcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shape',
                style: TextStyle(
                  color: ArtCatColors.procreateOnSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShapeOption(
                    icon: Icons.circle_outlined,
                    label: 'Circle',
                    isSelected: selectedShape == ShapeType.circle,
                    onTap: () {
                      onShapeSelected(ShapeType.circle);
                      Navigator.pop(context);
                    },
                  ),
                  _ShapeOption(
                    icon: Icons.crop_square,
                    label: 'Square',
                    isSelected: selectedShape == ShapeType.square,
                    onTap: () {
                      onShapeSelected(ShapeType.square);
                      Navigator.pop(context);
                    },
                  ),
                  _ShapeOption(
                    icon: Icons.change_history,
                    label: 'Triangle',
                    isSelected: selectedShape == ShapeType.triangle,
                    onTap: () {
                      onShapeSelected(ShapeType.triangle);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShapeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShapeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? ArtCatColors.procreateCharcoalLight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? ArtCatColors.primary
                    : ArtCatColors.procreateCharcoalLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              icon,
              size: 28,
              color: ArtCatColors.procreateOnSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ArtCatColors.procreateOnSurface.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolIconButton({
    required this.icon,
    required this.tooltip,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? ArtCatColors.procreateCharcoalLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 24,
            color: isSelected
                ? ArtCatColors.procreateOnSurface
                : ArtCatColors.procreateOnSurface.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}

/// Color well - shows current colour with inset/well styling, opens full picker
class _ColorWell extends StatelessWidget {
  final Color color;
  final ValueChanged<Color> onColorSelected;

  const _ColorWell({
    required this.color,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Colour',
      child: GestureDetector(
        onTap: () => _showColorPicker(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ArtCatColors.procreateCharcoalLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ArtCatColors.procreateOnSurface.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              // Inner shadow / well effect
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 2,
                offset: const Offset(0, 1),
                spreadRadius: -1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Color.lerp(
                  color,
                  color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  0.3,
                )!,
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ArtCatColors.procreateCharcoal,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ColorPickerSheet(
        initialColor: color,
        onColorSelected: onColorSelected,
      ),
    );
  }
}

class _ColorPickerSheet extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerSheet({
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<_ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<_ColorPickerSheet> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor);
  }

  void _updateColor(HSVColor hsv) {
    setState(() => _hsv = hsv);
    widget.onColorSelected(hsv.toColor());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current colour well display
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: ArtCatColors.procreateCharcoalLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ArtCatColors.procreateOnSurface.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: _hsv.toColor(),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Hue slider
            Text(
              'Hue',
              style: TextStyle(
                color: ArtCatColors.procreateOnSurface.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                overlayColor: Colors.transparent,
                activeTrackColor: HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor(),
                inactiveTrackColor: ArtCatColors.procreateCharcoalLight,
              ),
              child: Slider(
                value: _hsv.hue,
                min: 0,
                max: 360,
                onChanged: (h) => _updateColor(_hsv.withHue(h)),
              ),
            ),
            const SizedBox(height: 12),
            // Saturation / value picker (2D)
            Text(
              'Saturation & brightness',
              style: TextStyle(
                color: ArtCatColors.procreateOnSurface.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 120,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  return GestureDetector(
                    onPanStart: (d) => _pickAt(d.localPosition, size),
                    onPanUpdate: (d) => _pickAt(d.localPosition, size),
                    onTapDown: (d) => _pickAt(d.localPosition, size),
                    child: CustomPaint(
                      size: size,
                      painter: _SaturationValuePainter(
                        hue: _hsv.hue,
                        saturation: _hsv.saturation,
                        value: _hsv.value,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Quick palette swatches
            Text(
              'Palette',
              style: TextStyle(
                color: ArtCatColors.procreateOnSurface.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ArtCatColors.basicPalette.map((c) {
                final isSelected = _colorClose(c, _hsv.toColor());
                return GestureDetector(
                  onTap: () {
                    _updateColor(HSVColor.fromColor(c));
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? ArtCatColors.procreateOnSurface
                            : ArtCatColors.procreateCharcoalLight,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  bool _colorClose(Color a, Color b) =>
      (a.red - b.red).abs() < 10 &&
      (a.green - b.green).abs() < 10 &&
      (a.blue - b.blue).abs() < 10;

  void _pickAt(Offset pos, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final s = (pos.dx / size.width).clamp(0.0, 1.0);
    final v = 1 - (pos.dy / size.height).clamp(0.0, 1.0);
    _updateColor(_hsv.withSaturation(s).withValue(v));
  }

}

class _SaturationValuePainter extends CustomPainter {
  final double hue;
  final double saturation;
  final double value;

  _SaturationValuePainter({
    required this.hue,
    required this.saturation,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Saturation: left (0) = white, right (1) = full hue
    final satGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        HSVColor.fromAHSV(1, hue, 0, 1).toColor(),
        HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
      ],
    );
    canvas.drawRect(rect, Paint()..shader = satGradient.createShader(rect));
    // Value: top (1) = bright, bottom (0) = black
    final valueGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, Colors.black],
    );
    canvas.drawRect(rect, Paint()..shader = valueGradient.createShader(rect));
    // Selector dot at current s/v
    final dotX = saturation.clamp(0.0, 1.0) * size.width;
    final dotY = (1 - value.clamp(0.0, 1.0)) * size.height;
    canvas.drawCircle(
      Offset(dotX, dotY),
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SaturationValuePainter old) =>
      old.hue != hue || old.saturation != saturation || old.value != value;
}
