import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/storage/local_storage.dart';
import '../../mascot/providers/mascot_provider.dart';
import '../../mascot/widgets/art_cat_mascot.dart';
import '../providers/canvas_provider.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/tools_panel.dart';

/// Main canvas screen for drawing
class CanvasScreen extends StatelessWidget {
  const CanvasScreen({super.key});

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
          // Art Cat mascot
          Positioned(
            right: 16,
            bottom: 220,
            child: Consumer<MascotProvider>(
              builder: (context, mascotProvider, _) => ArtCatMascot(
                onTap: () {
                  mascotProvider.showContextualTooltip('canvas');
                },
              ),
            ),
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
