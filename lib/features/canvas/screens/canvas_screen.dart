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
import '../widgets/procreate_sidebar.dart';
import '../widgets/procreate_top_bar.dart';

/// Main canvas screen for drawing
class CanvasScreen extends StatefulWidget {
  /// Optional prompt to display in the banner when started from Art Prompts.
  final String? artPrompt;

  const CanvasScreen({super.key, this.artPrompt});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  static const double _mascotSize = 60;
  Offset? _mascotPosition;

  @override
  void initState() {
    super.initState();
    if (widget.artPrompt != null && widget.artPrompt!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CanvasProvider>().newArtwork(prompt: widget.artPrompt);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final topPadding = MediaQuery.paddingOf(context).top;
    const topBarContentHeight = 56.0;
    final topBarHeight = topPadding + topBarContentHeight;
    final defaultPos = Offset(
      screenSize.width - 16 - _mascotSize,
      topBarHeight + 16,
    );
    final position = _mascotPosition ?? defaultPos;

    return Scaffold(
      backgroundColor: ArtCatColors.procreateCharcoalDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Procreate-style: canvas fills screen, chrome overlays
          DrawingCanvas(
          onRequestContextMenu: (globalPosition) =>
              _showDrawingContextMenu(context, globalPosition),
        ),
        // Top bar (left: gallery/actions, right: tools/color)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Consumer<CanvasProvider>(
            builder: (context, provider, _) {
              final prompt = provider.artwork.prompt;
              final hasPrompt =
                  prompt != null && prompt.trim().isNotEmpty;
              return ProcreateTopBar(
                prompt: hasPrompt ? prompt : null,
                onBackTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, '/gallery');
                  }
                },
                onGalleryTap: () =>
                    Navigator.pushReplacementNamed(context, '/gallery'),
                onActionsTap: () => _showActionsMenu(context),
              );
            },
          ),
        ),
        // Left sidebar - brush size, opacity, modify, undo, redo
        Positioned(
          top: topBarHeight,
          left: 0,
          bottom: 0,
          child: ProcreateSidebar(
            onModifyTap: () => _showEyedropperInfo(context),
          ),
        ),
        // Art Cat mascot - Procreate keeps focus on art; mascot stays for charm
        if (context.watch<MascotProvider>().mascotVisibleOnCanvas)
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Consumer2<CanvasProvider, MascotProvider>(
              builder: (context, canvasProvider, mascotProvider, _) {
                final tooltipKeys = {
                  ToolType.pen: 'pen',
                  ToolType.pencil: 'pencil',
                  ToolType.eraser: 'eraser',
                  ToolType.shape: 'shape',
                  ToolType.fill: 'fill',
                };
                final key =
                    tooltipKeys[canvasProvider.selectedTool] ?? 'canvas';
                return ArtCatMascot(
                  size: _mascotSize,
                  positionedByLeadingEdge: true,
                  onPanStart: (_) {
                    if (_mascotPosition == null) {
                      setState(() => _mascotPosition = position);
                    }
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      final current = _mascotPosition ?? position;
                      _mascotPosition = Offset(
                        current.dx + details.delta.dx,
                        current.dy + details.delta.dy,
                      );
                    });
                  },
                  onTap: () =>
                      mascotProvider.showContextualTooltip(key),
                );
              },
            ),
          ),
        ],
      ),
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

  void _showDrawingContextMenu(
    BuildContext context,
    Offset globalPosition,
  ) {
    final screenSize = MediaQuery.sizeOf(context);
    final mascotProvider = context.read<MascotProvider>();
    final position = RelativeRect.fromLTRB(
      globalPosition.dx,
      globalPosition.dy,
      screenSize.width - globalPosition.dx,
      screenSize.height - globalPosition.dy,
    );

    showMenu<void>(
      context: context,
      position: position,
      items: [
        PopupMenuItem<void>(
          onTap: () {
            mascotProvider.setMascotVisibleOnCanvas(
              !mascotProvider.mascotVisibleOnCanvas,
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                mascotProvider.mascotVisibleOnCanvas
                    ? Icons.visibility_off
                    : Icons.visibility,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                mascotProvider.mascotVisibleOnCanvas
                    ? 'Hide mascot'
                    : 'Show mascot',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showActionsMenu(BuildContext context) {
    final canvasProvider = context.read<CanvasProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: ArtCatColors.procreateCharcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<CanvasProvider>(
                builder: (context, provider, _) => GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showTitleDialog(context, provider);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.artwork.title,
                              style: const TextStyle(
                                color: ArtCatColors.procreateOnSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (provider.artwork.prompt != null &&
                                provider.artwork.prompt!.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                provider.artwork.prompt!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: ArtCatColors.procreateOnSurface
                                      .withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.edit,
                        size: 20,
                        color: ArtCatColors.procreateOnSurface.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(color: ArtCatColors.procreateCharcoalLight),
            _ActionsTile(
              icon: Icons.save,
              title: 'Save artwork',
              onTap: () {
                Navigator.pop(context);
                _saveArtwork(context);
              },
            ),
            _ActionsTile(
              icon: Icons.add,
              title: 'New canvas',
              onTap: () {
                canvasProvider.newArtwork();
                Navigator.pop(context);
              },
            ),
            _ActionsTile(
              icon: Icons.straighten,
              title: 'Brush stabilisation',
              subtitle: '${canvasProvider.stabilisation.round()}%',
              onTap: () {
                Navigator.pop(context);
                _showStabilisationSheet(context);
              },
            ),
            _ActionsTile(
              icon: Icons.delete_outline,
              title: 'Clear canvas',
              onTap: () {
                Navigator.pop(context);
                _showClearDialog(context, canvasProvider);
              },
            ),
            _ActionsTile(
              icon: Icons.help_outline,
              title: 'Help',
              onTap: () {
                Navigator.pop(context);
                showHelpSheet(context);
              },
            ),
            _ActionsTile(
              icon: Icons.share,
              title: 'Share artwork',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon!')),
                );
              },
            ),
            _ActionsTile(
              icon: Icons.image,
              title: 'Export as image',
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

  void _showStabilisationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ArtCatColors.procreateCharcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Consumer<CanvasProvider>(
        builder: (context, provider, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stabilisation',
                style: TextStyle(
                  color: ArtCatColors.procreateOnSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Smooths brush strokes. Higher = smoother lines.',
                style: TextStyle(
                  color: ArtCatColors.procreateOnSurface.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: ArtCatColors.primary,
                  thumbColor: ArtCatColors.primary,
                ),
                child: Slider(
                  value: provider.stabilisation,
                  min: 0,
                  max: 100,
                  onChanged: provider.setStabilisation,
                ),
              ),
              Center(
                child: Text(
                  '${provider.stabilisation.round()}%',
                  style: TextStyle(
                    color: ArtCatColors.procreateOnSurface,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, CanvasProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ArtCatColors.procreateCharcoal,
        title: Text(
          'Clear canvas?',
          style: const TextStyle(color: ArtCatColors.procreateOnSurface),
        ),
        content: Text(
          'This will remove all your strokes. You can undo this action.',
          style: TextStyle(
            color: ArtCatColors.procreateOnSurface.withOpacity(0.9),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: ArtCatColors.procreateOnSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearCanvas();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ArtCatColors.primary,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showEyedropperInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Eyedropper: tap on the canvas to pick a colour (coming soon)',
        ),
        backgroundColor: ArtCatColors.procreateCharcoalLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ActionsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ActionsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: ArtCatColors.procreateOnSurface),
      title: Text(
        title,
        style: const TextStyle(color: ArtCatColors.procreateOnSurface),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: ArtCatColors.procreateOnSurface.withOpacity(0.7),
                fontSize: 12,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
