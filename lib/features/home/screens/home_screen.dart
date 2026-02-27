import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../mascot/providers/mascot_provider.dart';
import '../../mascot/widgets/art_cat_mascot.dart';
import '../../../shared/storage/local_storage.dart';
import '../../../shared/widgets/help_sheet.dart';

/// Home screen with navigation to main features
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Show welcome tooltip on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (LocalStorage.isFirstLaunch) {
        context.read<MascotProvider>().showContextualTooltip('welcome');
        LocalStorage.markLaunched();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with help button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [ArtCatColors.primary, ArtCatColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '🐱',
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ART CAT',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: ArtCatColors.primary,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.help_outline),
                                onPressed: () => _showHelpDialog(context),
                                tooltip: 'Help',
                              ),
                            ],
                          ),
                          Text(
                            'Create something purrfect!',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Quick actions
                  Text(
                    'Start Creating',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Main feature cards
                  _FeatureCard(
                    icon: Icons.brush,
                    title: 'New Canvas',
                    subtitle: 'Start with a blank canvas',
                    gradient: const [ArtCatColors.primary, ArtCatColors.primaryDark],
                    onTap: () => Navigator.pushNamed(context, '/canvas'),
                  ),
                  const SizedBox(height: 12),

                  _FeatureCard(
                    icon: Icons.lightbulb,
                    title: 'Get Inspired',
                    subtitle: 'Generate art prompts',
                    gradient: const [ArtCatColors.secondary, ArtCatColors.secondaryDark],
                    onTap: () => Navigator.pushNamed(context, '/prompts'),
                  ),
                  const SizedBox(height: 12),

                  _FeatureCard(
                    icon: Icons.photo_library,
                    title: 'My Gallery',
                    subtitle: 'View your creations',
                    gradient: const [Color(0xFF4CAF50), Color(0xFF388E3C)],
                    onTap: () => Navigator.pushNamed(context, '/gallery'),
                  ),

                  const SizedBox(height: 32),

                  // Tips section
                  Text(
                    'Quick Tips',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  _TipCard(
                    emoji: '✏️',
                    tip: 'Tap the cat mascot anytime for help!',
                  ),
                  const SizedBox(height: 8),
                  _TipCard(
                    emoji: '🎨',
                    tip: 'Use the colour palette to pick your favourite colours.',
                  ),
                  const SizedBox(height: 8),
                  _TipCard(
                    emoji: '💡',
                    tip: 'Lock words in the prompt generator to keep them.',
                  ),
                  const SizedBox(height: 8),
                  _TipCard(
                    emoji: '🪣',
                    tip: 'Use the fill tool to colour in enclosed areas.',
                  ),
                  const SizedBox(height: 8),
                  _TipCard(
                    emoji: '↩️',
                    tip: 'Two-finger tap on the canvas to undo—Procreate style!',
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Art Cat mascot
            Positioned(
              right: 16,
              bottom: 16,
              child: Consumer<MascotProvider>(
                builder: (context, mascotProvider, _) => ArtCatMascot(
                  onTap: () {
                    mascotProvider.showContextualTooltip('welcome');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showHelpSheet(context);
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String emoji;
  final String tip;

  const _TipCard({required this.emoji, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ArtCatColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                color: ArtCatColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
