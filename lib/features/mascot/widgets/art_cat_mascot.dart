import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../providers/mascot_provider.dart';
import 'tooltip_bubble.dart';

/// Placement of the tooltip bubble relative to the cat mascot
enum _BubblePlacement { left, right, top, bottom }

/// Visual variant of the mascot
enum MascotPose {
  /// Circular head/avatar - for floating overlays
  avatar,
  /// Full-body sitting cat - for room floor, etc.
  sitting,
}

/// Bubble dimensions for layout - must match TooltipBubble
const double _bubbleMaxWidth = 240;
const double _bubbleGap = 8;
const double _bubbleEstHeight = 120;

/// The Art Cat mascot widget - an interactive cat character
class ArtCatMascot extends StatefulWidget {
  final VoidCallback? onTap;
  final double size;
  /// Avatar = head only; sitting = full cat on floor
  final MascotPose pose;
  /// True when parent uses [Positioned] with left/top (e.g. canvas). Keeps cat fixed when bubble expands.
  final bool positionedByLeadingEdge;
  /// Optional pan callbacks for draggable mascot (e.g. canvas). When set, pan is applied only to the cat
  /// so the bubble can receive taps.
  final void Function(DragStartDetails)? onPanStart;
  final void Function(DragUpdateDetails)? onPanUpdate;

  const ArtCatMascot({
    super.key,
    this.onTap,
    this.size = 60,
    this.pose = MascotPose.avatar,
    this.positionedByLeadingEdge = false,
    this.onPanStart,
    this.onPanUpdate,
  });

  @override
  State<ArtCatMascot> createState() => _ArtCatMascotState();
}

class _ArtCatMascotState extends State<ArtCatMascot> {
  final GlobalKey _mascotKey = GlobalKey();

  (double, double, Offset, Offset) _expandedLayout(_BubblePlacement placement) {
    final mascotH = widget.pose == MascotPose.sitting ? widget.size * 1.15 : widget.size;
    final w = widget.size + _bubbleGap + _bubbleMaxWidth;
    final h = mascotH + _bubbleGap + _bubbleEstHeight;
    switch (placement) {
      case _BubblePlacement.right:
      case _BubblePlacement.bottom:
        return (w, h, Offset.zero, Offset.zero);
      case _BubblePlacement.left:
        final t = widget.positionedByLeadingEdge ? Offset(-(w - widget.size), 0) : Offset.zero;
        return (w, h, Offset(w - widget.size, 0), t);
      case _BubblePlacement.top:
        final t = widget.positionedByLeadingEdge ? Offset(0, -(h - widget.size)) : Offset.zero;
        return (w, h, Offset(0, h - widget.size), t);
    }
  }

  _BubblePlacement _choosePlacement(Size screenSize) {
    final box = _mascotKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return _BubblePlacement.left;
    }
    final pos = box.localToGlobal(Offset.zero);
    final catW = box.size.width;
    final catH = box.size.height;
    final spaceLeft = pos.dx;
    final spaceRight = screenSize.width - pos.dx - catW;
    final spaceTop = pos.dy;
    final spaceBottom = screenSize.height - pos.dy - catH;

    final maxHorizontal = spaceLeft > spaceRight ? spaceLeft : spaceRight;
    final maxVertical = spaceTop > spaceBottom ? spaceTop : spaceBottom;

    if (maxHorizontal >= maxVertical) {
      return spaceRight >= spaceLeft ? _BubblePlacement.right : _BubblePlacement.left;
    } else {
      return spaceBottom >= spaceTop ? _BubblePlacement.bottom : _BubblePlacement.top;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MascotProvider>(
      builder: (context, mascotProvider, child) {
        final showBubble = mascotProvider.isTooltipVisible &&
            mascotProvider.currentTooltip != null;

        if (showBubble) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        }

        final placement = showBubble
            ? _choosePlacement(MediaQuery.sizeOf(context))
            : _BubblePlacement.right;

        // When bubble is visible, expand bounds so bubble is within hit area and has space for text
        final mascotH = widget.pose == MascotPose.sitting ? widget.size * 1.15 : widget.size;
        final (width, height, catOffset, translate) = showBubble
            ? _expandedLayout(placement)
            : (widget.size, mascotH, Offset.zero, Offset.zero);

        final stack = SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Cat mascot - positioned so it stays visually fixed
              Positioned(
                left: catOffset.dx,
                top: catOffset.dy,
                child: GestureDetector(
                  key: _mascotKey,
                  onPanStart: widget.onPanStart,
                  onPanUpdate: widget.onPanUpdate,
                  onTap: () {
                    if (showBubble) {
                      mascotProvider.hideTooltip();
                    } else {
                      widget.onTap?.call();
                    }
                  },
                  child: widget.pose == MascotPose.sitting
                      ? _SittingCatAvatar(
                          size: widget.size,
                          reaction: mascotProvider.reaction,
                          emoji: mascotProvider.reactionEmoji,
                        )
                      : _CatAvatar(
                          size: widget.size,
                          reaction: mascotProvider.reaction,
                          emoji: mascotProvider.reactionEmoji,
                        ),
                ),
              ),
              // Tooltip bubble - positioned on optimal side with proper constraints
              if (showBubble)
                _PositionedBubble(
                  placement: placement,
                  catSize: widget.size,
                  catOffset: catOffset,
                  child: TooltipBubble(
                    tooltip: mascotProvider.currentTooltip!,
                    onDismiss: mascotProvider.hideTooltip,
                  ),
                ),
            ],
          ),
        );

        return translate != Offset.zero
            ? Transform.translate(offset: translate, child: stack)
            : stack;
      },
    );
  }
}

/// Positions the bubble adjacent to the cat based on placement
class _PositionedBubble extends StatelessWidget {
  final _BubblePlacement placement;
  final double catSize;
  final Offset catOffset;
  final Widget child;

  const _PositionedBubble({
    required this.placement,
    required this.catSize,
    required this.catOffset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    // Ensure bubble has bounded width for text wrapping
    final constrainedChild = SizedBox(
      width: _bubbleMaxWidth,
      child: child,
    );
    switch (placement) {
      case _BubblePlacement.right:
        return Positioned(
          left: catOffset.dx + catSize + gap,
          top: catOffset.dy,
          bottom: 0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: constrainedChild,
          ),
        );
      case _BubblePlacement.left:
        return Positioned(
          left: 0,
          right: catSize + gap,
          top: catOffset.dy,
          bottom: 0,
          child: Align(
            alignment: Alignment.centerRight,
            child: constrainedChild,
          ),
        );
      case _BubblePlacement.bottom:
        return Positioned(
          top: catOffset.dy + catSize + gap,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: constrainedChild,
          ),
        );
      case _BubblePlacement.top:
        return Positioned(
          top: 0,
          bottom: catSize + gap,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: constrainedChild,
          ),
        );
    }
  }
}

/// Sitting cat silhouette - body, head, ears, with emoji face. For room floor placement.
class _SittingCatAvatar extends StatelessWidget {
  final double size;
  final MascotReaction reaction;
  final String emoji;

  const _SittingCatAvatar({
    required this.size,
    required this.reaction,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: CustomPaint(
        painter: _SittingCatPainter(
          primary: ArtCatColors.primary,
          primaryDark: ArtCatColors.primaryDark,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: size * 0.08),
            child: Text(
              emoji,
              style: TextStyle(fontSize: size * 0.35),
            ),
          ),
        ),
      ),
    );
  }
}

class _SittingCatPainter extends CustomPainter {
  final Color primary;
  final Color primaryDark;

  _SittingCatPainter({required this.primary, required this.primaryDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;

    // Body - rounded sitting blob (wider at bottom)
    final bodyPath = Path()
      ..moveTo(centerX - w * 0.28, h * 0.55)
      ..quadraticBezierTo(centerX - w * 0.35, h * 0.75, centerX - w * 0.2, h * 0.92)
      ..quadraticBezierTo(centerX, h * 0.98, centerX + w * 0.2, h * 0.92)
      ..quadraticBezierTo(centerX + w * 0.35, h * 0.75, centerX + w * 0.28, h * 0.55)
      ..quadraticBezierTo(centerX + w * 0.22, h * 0.35, centerX, h * 0.42)
      ..quadraticBezierTo(centerX - w * 0.22, h * 0.35, centerX - w * 0.28, h * 0.55);
    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primaryDark],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Head - circle
    final headCenter = Offset(centerX, h * 0.22);
    final headRadius = w * 0.26;
    canvas.drawCircle(
      headCenter,
      headRadius,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primaryDark],
        ).createShader(Rect.fromCircle(center: headCenter, radius: headRadius)),
    );

    // Left ear
    final earPath = Path()
      ..moveTo(centerX - w * 0.2, h * 0.08)
      ..lineTo(centerX - w * 0.38, h * 0.2)
      ..lineTo(centerX - w * 0.12, h * 0.2)
      ..close();
    canvas.drawPath(earPath, Paint()..color = primaryDark);

    // Right ear
    final earPathR = Path()
      ..moveTo(centerX + w * 0.2, h * 0.08)
      ..lineTo(centerX + w * 0.38, h * 0.2)
      ..lineTo(centerX + w * 0.12, h * 0.2)
      ..close();
    canvas.drawPath(earPathR, Paint()..color = primaryDark);

    // Curled tail
    final tailPath = Path()
      ..moveTo(centerX + w * 0.28, h * 0.5)
      ..quadraticBezierTo(centerX + w * 0.5, h * 0.35, centerX + w * 0.45, h * 0.15)
      ..quadraticBezierTo(centerX + w * 0.4, h * 0.05, centerX + w * 0.3, h * 0.12);
    canvas.drawPath(
      tailPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.1
        ..strokeCap = StrokeCap.round
        ..color = primaryDark,
    );

    // Shadow under cat
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, h * 0.96), width: w * 0.5, height: h * 0.06),
      Paint()..color = Colors.black.withOpacity(0.15),
    );
  }

  @override
  bool shouldRepaint(covariant _SittingCatPainter old) =>
      old.primary != primary || old.primaryDark != primaryDark;
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
