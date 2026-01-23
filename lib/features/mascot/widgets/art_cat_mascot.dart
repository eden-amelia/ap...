import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../providers/mascot_provider.dart';
import 'tooltip_bubble.dart';

/// The Art Cat mascot widget - an interactive cat character
class ArtCatMascot extends StatefulWidget {
  final VoidCallback? onTap;
  final double size;

  const ArtCatMascot({
    super.key,
    this.onTap,
    this.size = 60,
  });

  @override
  State<ArtCatMascot> createState() => _ArtCatMascotState();
}

class _ArtCatMascotState extends State<ArtCatMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward().then((_) => _bounceController.reverse());
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MascotProvider>(
      builder: (context, mascotProvider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Tooltip bubble
            if (mascotProvider.isTooltipVisible &&
                mascotProvider.currentTooltip != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TooltipBubble(
                  tooltip: mascotProvider.currentTooltip!,
                  onDismiss: mascotProvider.hideTooltip,
                ),
              ),
            // Cat mascot
            GestureDetector(
              onTap: _handleTap,
              child: AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bounceAnimation.value,
                    child: child,
                  );
                },
                child: _CatAvatar(
                  size: widget.size,
                  reaction: mascotProvider.reaction,
                  emoji: mascotProvider.reactionEmoji,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CatAvatar extends StatelessWidget {
  final double size;
  final MascotReaction reaction;
  final String emoji;

  const _CatAvatar({
    required this.size,
    required this.reaction,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ArtCatColors.primary,
            ArtCatColors.primaryDark,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ArtCatColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cat emoji
          Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: size * 0.5),
            ),
          ),
          // Paw print decoration
          Positioned(
            right: 4,
            bottom: 4,
            child: Text(
              '🐾',
              style: TextStyle(fontSize: size * 0.25),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact mascot for use in the app bar or navigation
class MiniArtCatMascot extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniArtCatMascot({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<MascotProvider>(
      builder: (context, mascotProvider, _) {
        return GestureDetector(
          onTap: () {
            mascotProvider.showContextualTooltip('welcome');
            onTap?.call();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              mascotProvider.reactionEmoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        );
      },
    );
  }
}
