import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/canvas/providers/canvas_provider.dart';
import 'features/canvas/screens/canvas_screen.dart';
import 'features/gallery/screens/gallery_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/mascot/providers/mascot_provider.dart';
import 'features/prompts/providers/prompt_provider.dart';
import 'features/prompts/screens/prompt_screen.dart';

/// Main ART CAT application widget
class ArtCatApp extends StatelessWidget {
  const ArtCatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CanvasProvider()),
        ChangeNotifierProvider(create: (_) => MascotProvider()),
        ChangeNotifierProvider(create: (_) => PromptProvider()),
      ],
      child: MaterialApp(
        title: 'ART CAT',
        debugShowCheckedModeBanner: false,
        theme: ArtCatTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/canvas': (context) => const CanvasScreen(),
          '/prompts': (context) => const PromptScreen(),
          '/gallery': (context) => const GalleryScreen(),
        },
      ),
    );
  }
}
