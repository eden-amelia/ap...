import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'shared/storage/local_storage.dart';

void main() async {
  // Ensure Flutter is initialised
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise local storage
  await LocalStorage.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ArtCatApp());
}
