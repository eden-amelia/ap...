import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'room_destination.dart';
import 'room_scene.dart';

/// Horizontally scrollable virtual room menu - Spark-style navigation
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
  late PageController _pageController;

  static const List<List<RoomDestination>> _rooms = [
    // Room 1: Art Studio (Canvas)
    [
      RoomDestination(
        route: '/canvas',
        label: 'New Canvas',
        emoji: '🖼️',
        icon: Icons.brush_rounded,
        position: Offset(0.5, 0.45),
        accentColors: [ArtCatColors.sparkLavender, ArtCatColors.sparkPurple],
      ),
      RoomDestination(
        route: '/prompts',
        label: 'Get Inspired',
        emoji: '✨',
        icon: Icons.lightbulb_rounded,
        position: Offset(0.8, 0.55),
        accentColors: [ArtCatColors.sparkPink, Color(0xFFE8A0B0)],
      ),
    ],
    // Room 2: Inspiration Nook (Prompts)
    [
      RoomDestination(
        route: '/prompts',
        label: 'Daily Sparks',
        emoji: '💡',
        icon: Icons.auto_awesome,
        position: Offset(0.5, 0.4),
        accentColors: [ArtCatColors.sparkYellow, ArtCatColors.sparkPeach],
      ),
      RoomDestination(
        route: '/canvas',
        label: 'Start Drawing',
        emoji: '✏️',
        icon: Icons.edit_rounded,
        position: Offset(0.25, 0.6),
        accentColors: [ArtCatColors.sparkMint, Color(0xFF8FD9B8)],
      ),
      RoomDestination(
        route: '/gallery',
        label: 'My Gallery',
        emoji: '🎨',
        icon: Icons.photo_library_rounded,
        position: Offset(0.75, 0.55),
        accentColors: [ArtCatColors.sparkPurple, ArtCatColors.sparkPurpleDark],
      ),
    ],
    // Room 3: Gallery
    [
      RoomDestination(
        route: '/gallery',
        label: 'My Creations',
        emoji: '🖼️',
        icon: Icons.photo_library_rounded,
        position: Offset(0.5, 0.4),
        accentColors: [ArtCatColors.sparkMint, Color(0xFF8FD9B8)],
      ),
      RoomDestination(
        route: '/canvas',
        label: 'Create New',
        emoji: '🖌️',
        icon: Icons.brush_rounded,
        position: Offset(0.3, 0.6),
        accentColors: [ArtCatColors.sparkPink, Color(0xFFE8A0B0)],
      ),
      RoomDestination(
        route: '/prompts',
        label: 'Get Ideas',
        emoji: '✨',
        icon: Icons.auto_awesome,
        position: Offset(0.7, 0.55),
        accentColors: [ArtCatColors.sparkLavender, ArtCatColors.sparkPurple],
      ),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ART CAT',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ArtCatColors.sparkPurpleDark,
                      letterSpacing: 1.2,
                    ),
              ),
            ],
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
        // Page indicator
        _PageIndicator(
          pageCount: _rooms.length,
          pageController: _pageController,
        ),
        const SizedBox(height: 8),
        // Scrollable room
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _rooms.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: RoomScene(
                  destinations: _rooms[index],
                  onObjectTap: (d) => _onObjectTap(d),
                  roomIndex: index,
                  roomTitle: _roomTitle(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _roomTitle(int index) {
    switch (index) {
      case 0:
        return 'Art Studio';
      case 1:
        return 'Inspiration';
      case 2:
        return 'Gallery';
      default:
        return '';
    }
  }
}

class _PageIndicator extends StatelessWidget {
  final int pageCount;
  final PageController pageController;

  const _PageIndicator({
    required this.pageCount,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        final page = pageController.hasClients && pageController.position.hasContentDimensions
            ? (pageController.page ?? 0.0).round().clamp(0, pageCount - 1)
            : 0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pageCount,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == page
                    ? ArtCatColors.sparkPurpleDark
                    : ArtCatColors.sparkLavender.withValues(alpha: 0.5),
              ),
            ),
          ),
        );
      },
    );
  }
}
