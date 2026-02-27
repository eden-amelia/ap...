import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Reusable help bottom sheet shown across the app
void showHelpSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: ArtCatColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Text('🐱', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Text(
                  'Need help?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ArtCatColors.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the Art Cat mascot anytime for contextual tips.',
              style: TextStyle(
                color: ArtCatColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick reference',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: const [
                  _HelpItem(
                    emoji: '✏️',
                    title: 'Pen & Pencil',
                    tip: 'Draw with the size slider to adjust stroke thickness.',
                  ),
                  _HelpItem(
                    emoji: '🧹',
                    title: 'Eraser',
                    tip: 'Remove mistakes—undo works too!',
                  ),
                  _HelpItem(
                    emoji: '⬡',
                    title: 'Shapes',
                    tip: 'Drag to draw circles, squares, or triangles.',
                  ),
                  _HelpItem(
                    emoji: '🪣',
                    title: 'Fill',
                    tip: 'Tap enclosed areas to fill with colour.',
                  ),
                  _HelpItem(
                    emoji: '↩️',
                    title: 'Undo & Redo',
                    tip: 'Use the buttons or two-finger tap on the canvas.',
                  ),
                  _HelpItem(
                    emoji: '🌈',
                    title: 'Colours',
                    tip: 'Pick from the palette or use opacity for transparency.',
                  ),
                  _HelpItem(
                    emoji: '💡',
                    title: 'Prompts',
                    tip: 'Lock words you like, then shuffle the rest for new ideas.',
                  ),
                  _HelpItem(
                    emoji: '🖼️',
                    title: 'Gallery',
                    tip: 'Your saved artworks are all in one place.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HelpItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String tip;

  const _HelpItem({
    required this.emoji,
    required this.title,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tip,
                  style: TextStyle(
                    color: ArtCatColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
