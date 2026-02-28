import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../mascot/providers/mascot_provider.dart';
import '../../mascot/widgets/art_cat_mascot.dart';
import '../../../shared/storage/local_storage.dart';
import '../../../shared/widgets/help_sheet.dart';
import '../widgets/room_menu/room_menu.dart';

/// Home screen with Spark-style room menu - scroll through virtual rooms, tap objects to navigate
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

  void _navigate(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArtCatColors.sparkBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Help button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () => _showHelpDialog(context),
                    tooltip: 'Help',
                    color: ArtCatColors.sparkPurpleDark,
                  ),
                ),
                Expanded(
                  child: RoomMenu(onNavigate: _navigate),
                ),
              ],
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
