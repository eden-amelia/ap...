import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'room_destination.dart';
import 'room_scene.dart';

/// Horizontally scrollable virtual room menu - single continuous room, Spark-style
/// Supports both touch (drag) and mouse (wheel) scrolling
class RoomMenu extends StatefulWidget {
  final void Function(String route) onNavigate;

  const RoomMenu({
    super.key,
    required this.onNavigate,
  });

  @override
  State<RoomMenu> createState() => _RoomMenuState();
}

class _RoomMenuState extends State<RoomMenu> {
  late ScrollController _scrollController;

  /// All destinations in one continuous room. Position.dx: 0=left, 3=right. dy: 0-1
  static const List<RoomDestination> _destinations = [
    // Left third: Art Studio
    RoomDestination(
      route: '/canvas',
      label: 'New Canvas',
      emoji: '🖼️',
      icon: Icons.brush_rounded,
      position: Offset(0.25, 0.45),
      accentColors: [ArtCatColors.sparkLavender, ArtCatColors.sparkPurple],
    ),
    RoomDestination(
      route: '/prompts',
      label: 'Get Inspired',
      emoji: '✨',
      icon: Icons.lightbulb_rounded,
      position: Offset(0.7, 0.5),
      accentColors: [ArtCatColors.sparkPink, Color(0xFFE8A0B0)],
    ),
    // Middle third: Inspiration Nook
    RoomDestination(
      route: '/prompts',
      label: 'Daily Sparks',
      emoji: '💡',
      icon: Icons.auto_awesome,
      position: Offset(1.35, 0.42),
      accentColors: [ArtCatColors.sparkYellow, ArtCatColors.sparkPeach],
    ),
    RoomDestination(
      route: '/canvas',
      label: 'Start Drawing',
      emoji: '✏️',
      icon: Icons.edit_rounded,
      position: Offset(1.1, 0.58),
      accentColors: [ArtCatColors.sparkMint, Color(0xFF8FD9B8)],
    ),
    RoomDestination(
      route: '/gallery',
      label: 'My Gallery',
      emoji: '🎨',
      icon: Icons.photo_library_rounded,
      position: Offset(1.65, 0.52),
      accentColors: [ArtCatColors.sparkPurple, ArtCatColors.sparkPurpleDark],
    ),
    // Right third: Gallery
    RoomDestination(
      route: '/gallery',
      label: 'My Creations',
      emoji: '🖼️',
      icon: Icons.photo_library_rounded,
      position: Offset(2.2, 0.44),
      accentColors: [ArtCatColors.sparkMint, Color(0xFF8FD9B8)],
    ),
    RoomDestination(
      route: '/canvas',
      label: 'Create New',
      emoji: '🖌️',
      icon: Icons.brush_rounded,
      position: Offset(2.0, 0.58),
      accentColors: [ArtCatColors.sparkPink, Color(0xFFE8A0B0)],
    ),
    RoomDestination(
      route: '/prompts',
      label: 'Get Ideas',
      emoji: '✨',
      icon: Icons.auto_awesome,
      position: Offset(2.55, 0.5),
      accentColors: [ArtCatColors.sparkLavender, ArtCatColors.sparkPurple],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onObjectTap(RoomDestination destination) {
    widget.onNavigate(destination.route);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'ART CAT',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ArtCatColors.sparkPurpleDark,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        Text(
          'We Make Creating Easy',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ArtCatColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
        ),
        const SizedBox(height: 16),
        // Scrollable continuous room (touch + mouse wheel)
        Expanded(
          child: _MouseWheelScrollView(
            controller: _scrollController,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final viewportWidth = constraints.maxWidth;
                final roomWidth = viewportWidth * 3;
                return SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: roomWidth,
                    height: constraints.maxHeight,
                    child: RoomScene(
                      destinations: _destinations,
                      onObjectTap: _onObjectTap,
                      roomWidth: roomWidth,
                      viewportWidth: viewportWidth,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Wraps a horizontally scrollable child and translates vertical mouse wheel
/// to horizontal scroll. Supports both touch (drag) and mouse (wheel).
class _MouseWheelScrollView extends StatelessWidget {
  final ScrollController controller;
  final Widget child;

  const _MouseWheelScrollView({
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          final scrollDelta = event.scrollDelta.dy;
          if (scrollDelta != 0 && controller.hasClients) {
            final newOffset = (controller.offset - scrollDelta)
                .clamp(0.0, controller.position.maxScrollExtent);
            controller.position.jumpTo(newOffset);
          }
        }
      },
      child: child,
    );
  }
}
