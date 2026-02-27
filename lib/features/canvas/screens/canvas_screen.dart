import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/tools.dart';
import '../../../shared/storage/local_storage.dart';
import '../../../shared/widgets/help_sheet.dart';
import '../../mascot/providers/mascot_provider.dart';
import '../../mascot/widgets/art_cat_mascot.dart';
import '../providers/canvas_provider.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/tools_panel.dart';

/// Main canvas screen for drawing
class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  static const double _mascotSize = 60;
  Offset? _mascotPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<CanvasProvider>(
          builder: (context, provider, _) => GestureDetector(
            onTap: () => _showTitleDialog(context, provider),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  provider.artwork.title,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.edit, size: 16),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveArtwork(context),
            tooltip: 'Save artwork',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
            tooltip: 'More options',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Drawing canvas
          const Positioned.fill(
            child: DrawingCanvas(),
          ),
          // Art Cat mascot - draggable, shows tool-specific help when tapped
          LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final defaultPos = Offset(
                size.width - 16 - _mascotSize,
                size.height - 220 - _mascotSize,
              );
              final position = _mascotPosition ?? defaultPos;
              final clampedLeft = position.dx.clamp(0.0, size.width - _mascotSize);
              final clampedTop = position.dy.clamp(0.0, size.height - _mascotSize);

              return Positioned(
                left: clampedLeft,
                top: clampedTop,
                child: GestureDetector(
                  onPanStart: (_) {
                    if (_mascotPosition == null) {
                      setState(() => _mascotPosition = Offset(clampedLeft, clampedTop));
                    }
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      final current = _mascotPosition ?? Offset(clampedLeft, clampedTop);
                      _mascotPosition = Offset(
                        (current.dx + details.delta.dx)
                            .clamp(0.0, size.width - _mascotSize),
                        (current.dy + details.delta.dy)
                            .clamp(0.0, size.height - _mascotSize),
                      );
                    });
                  },
                  child: Consumer2<CanvasProvider, MascotProvider>(
                    builder: (context, canvasProvider, mascotProvider, _) {
                      final tooltipKeys = {
                        ToolType.pen: 'pen',
                        ToolType.pencil: 'pencil',
                        ToolType.eraser: 'eraser',
                        ToolType.shape: 'shape',
                        ToolType.fill: 'fill',
                      };
                      final key = tooltipKeys[canvasProvider.selectedTool] ?? 'canvas';
                      return ArtCatMascot(
                        size: _mascotSize,
                        onTap: () => mascotProvider.showContextualTooltip(key),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const ToolsPanel(),
    );
  }

  void _showTitleDialog(BuildContext context, CanvasProvider provider) {
    final controller = TextEditingController(text: provider.artwork.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename artwork'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter artwork title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.setTitle(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveArtwork(BuildContext context) {
    final canvasProvider = context.read<CanvasProvider>();
    final mascotProvider = context.read<MascotProvider>();

    // Save artwork to local storage
    LocalStorage.saveArtwork(canvasProvider.artwork);

    // Trigger celebration animation
    mascotProvider.setReaction(MascotReaction.celebrating);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Artwork saved!'),
        backgroundColor: ArtCatColors.success,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Gallery',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/gallery');
          },
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                showHelpSheet(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New canvas'),
              onTap: () {
                context.read<CanvasProvider>().newArtwork();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share artwork'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Export as image'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
