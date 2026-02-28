import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../mascot/providers/mascot_provider.dart';
import '../../mascot/widgets/art_cat_mascot.dart';
import '../../../shared/storage/local_storage.dart';
import '../../../shared/widgets/help_sheet.dart';

/// Home screen with Spark (Moriah Elizabeth) inspired aesthetic
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
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
      backgroundColor: ArtCatColors.sparkBg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spark-style header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: () => _showHelpDialog(context),
                        tooltip: 'Help',
                        color: ArtCatColors.sparkPurpleDark,
                      ),
                      const Spacer(),
                      Text(
                        'ART CAT',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ArtCatColors.sparkPurpleDark,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'We Make Creating Easy',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: ArtCatColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Daily Spark - prominent prompt card
                  _DailySparkCard(
                    onTap: () => Navigator.pushNamed(context, '/prompts'),
                    onCanvasTap: () => Navigator.pushNamed(context, '/canvas'),
                  ),
                  const SizedBox(height: 28),

                  // Section: Your Creative Studio
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Your Creative Studio',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ArtCatColors.sparkPurpleDark,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Feature cards in Spark pastel style
                  _SparkFeatureCard(
                    icon: Icons.brush_rounded,
                    title: 'New Canvas',
                    subtitle: 'Start with a blank canvas',
                    gradient: const [ArtCatColors.sparkLavender, ArtCatColors.sparkPurple],
                    emoji: '✨',
                    onTap: () => Navigator.pushNamed(context, '/canvas'),
                  ),
                  const SizedBox(height: 10),

                  _SparkFeatureCard(
                    icon: Icons.auto_awesome,
                    title: 'Daily Sparks',
                    subtitle: 'Get inspired with creative prompts',
                    gradient: const [ArtCatColors.sparkPink, Color(0xFFE8A0B0)],
                    emoji: '💡',
                    onTap: () => Navigator.pushNamed(context, '/prompts'),
                  ),
                  const SizedBox(height: 10),

                  _SparkFeatureCard(
                    icon: Icons.photo_library_rounded,
                    title: 'My Creations',
                    subtitle: 'View your gallery',
                    gradient: const [ArtCatColors.sparkMint, Color(0xFF8FD9B8)],
                    emoji: '🎨',
                    onTap: () => Navigator.pushNamed(context, '/gallery'),
                  ),

                  const SizedBox(height: 28),

                  // Tap the cat tip - Spark style
                  _SparkTipBanner(
                    emoji: '🐱',
                    text: 'Tap Opie the cat for help anytime!',
                  ),

                  const SizedBox(height: 12),

                  _TipCard(
                    emoji: '🪣',
                    tip: 'Use the fill tool to colour in enclosed areas.',
                  ),
                  const SizedBox(height: 8),
                  _TipCard(
                    emoji: '↩️',
                    tip: 'Two-finger tap on the canvas to undo.',
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Opie-style cat mascot (bottom right, Spark placement)
            Positioned(
              right: 16,
              bottom: 16,
              child: Consumer<MascotProvider>(
                builder: (context, mascotProvider, _) => ArtCatMascot(
                  onTap: () {
                    mascotProvider.showContextualTooltip('welcome');
                  },
                  size: 64,
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

/// Daily Spark card - prominent creative prompt (Spark app style)
class _DailySparkCard extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onCanvasTap;

  const _DailySparkCard({
    required this.onTap,
    required this.onCanvasTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ArtCatColors.sparkYellow,
            ArtCatColors.sparkPeach,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ArtCatColors.sparkPurple.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('✨', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A Spark a Day',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5C4A3A),
                          ),
                    ),
                    Text(
                      'Keeps imagination at play!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B5A4A),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SparkMiniButton(
                  label: 'Get a Prompt',
                  onTap: onTap,
                  color: ArtCatColors.sparkPurple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SparkMiniButton(
                  label: 'Blank Canvas',
                  onTap: onCanvasTap,
                  color: ArtCatColors.sparkMint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SparkMiniButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _SparkMiniButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.4),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A3A2A),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Spark-style feature card with pastel gradient
class _SparkFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String emoji;
  final VoidCallback onTap;

  const _SparkFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gradient.first.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 4),
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF3D3D3D),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: ArtCatColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: gradient.first,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Spark-style tip banner
class _SparkTipBanner extends StatelessWidget {
  final String emoji;
  final String text;

  const _SparkTipBanner({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ArtCatColors.sparkLavender.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ArtCatColors.sparkPurple.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF4A3A3A),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ArtCatColors.sparkLavender.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
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
