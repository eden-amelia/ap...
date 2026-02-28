import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../canvas/models/artwork.dart';
import '../../canvas/providers/canvas_provider.dart';
import '../../mascot/providers/mascot_provider.dart';
import '../../mascot/widgets/art_cat_mascot.dart';
import '../../../shared/storage/local_storage.dart';

/// Gallery screen to view saved artworks
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Artwork> _artworks = [];

  @override
  void initState() {
    super.initState();
    _loadArtworks();
  }

  void _loadArtworks() {
    setState(() {
      _artworks = LocalStorage.getAllArtworks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gallery'),
        actions: [
          if (_artworks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearAllDialog(),
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_artworks.isEmpty)
            _EmptyGallery()
          else
            GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _artworks.length,
              itemBuilder: (context, index) {
                final artwork = _artworks[index];
                return _ArtworkCard(
                  artwork: artwork,
                  onTap: () => _openArtwork(artwork),
                  onDelete: () => _deleteArtwork(artwork),
                );
              },
            ),
          // Art Cat mascot
          Positioned(
            right: 16,
            bottom: 16,
            child: Consumer<MascotProvider>(
              builder: (context, mascotProvider, _) => ArtCatMascot(
                onTap: () {
                  mascotProvider.showContextualTooltip('gallery');
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/canvas'),
        icon: const Icon(Icons.add),
        label: const Text('New Art'),
      ),
    );
  }

  void _openArtwork(Artwork artwork) {
    context.read<CanvasProvider>().loadArtwork(artwork);
    Navigator.pushNamed(context, '/canvas');
  }

  void _deleteArtwork(Artwork artwork) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete artwork?'),
        content: Text('Are you sure you want to delete "${artwork.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await LocalStorage.deleteArtwork(artwork.id);
              Navigator.pop(context);
              _loadArtworks();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Artwork deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ArtCatColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all artworks?'),
        content: const Text(
          'This will permanently delete all your saved artworks. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await LocalStorage.clearAllArtworks();
              Navigator.pop(context);
              _loadArtworks();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ArtCatColors.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ArtCatColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '🖼️',
              style: TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No artworks yet!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Start creating and your masterpieces\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: ArtCatColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/canvas'),
            icon: const Icon(Icons.brush),
            label: const Text('Start Drawing'),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ArtworkCard extends StatelessWidget {
  final Artwork artwork;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ArtworkCard({
    required this.artwork,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onSecondaryTapUp: (_) => onDelete(),
      child: Container(
        decoration: BoxDecoration(
          color: ArtCatColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: ArtCatColors.canvasBackground,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: artwork.strokes.isEmpty
                      ? const Text(
                          '🎨',
                          style: TextStyle(fontSize: 32),
                        )
                      : _ArtworkPreview(artwork: artwork),
                ),
              ),
            ),
            // Info area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artwork.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (artwork.prompt != null &&
                            artwork.prompt!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              artwork.prompt!,
                              style: const TextStyle(
                                color: ArtCatColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Text(
                          _formatDate(artwork.updatedAt),
                          style: const TextStyle(
                            color: ArtCatColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: ArtCatColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _ArtworkPreview extends StatelessWidget {
  final Artwork artwork;

  const _ArtworkPreview({required this.artwork});

  @override
  Widget build(BuildContext context) {
    // Simple preview showing stroke count
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.brush,
          size: 32,
          color: ArtCatColors.primary,
        ),
        const SizedBox(height: 4),
        Text(
          '${artwork.strokes.length} strokes',
          style: const TextStyle(
            color: ArtCatColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
