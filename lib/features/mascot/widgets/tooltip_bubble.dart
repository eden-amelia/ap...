import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../models/mascot_state.dart';

/// Speech bubble tooltip for the Art Cat
class TooltipBubble extends StatelessWidget {
  final MascotTooltip tooltip;
  final VoidCallback onDismiss;

  const TooltipBubble({
    super.key,
    required this.tooltip,
    required this.onDismiss,
  });

  static const double _maxBubbleWidth = 240;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDismiss,
      child: Container(
        constraints: const BoxConstraints(maxWidth: _maxBubbleWidth),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ArtCatColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  tooltip.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tooltip.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ArtCatColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                GestureDetector(
                  onTap: onDismiss,
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: ArtCatColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tooltip.message,
              style: const TextStyle(
                fontSize: 14,
                color: ArtCatColors.textSecondary,
              ),
              softWrap: true,
              overflow: TextOverflow.clip,
            ),
          ],
        ),
      ),
    );
  }
}
