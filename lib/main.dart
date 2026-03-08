import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'shared/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(() async {
    await _init();
    runApp(const ArtCatApp());
  }, (error, stack) {
    // Surface startup errors when running from terminal (e.g. flutter run -d linux)
    debugPrint('Uncaught error: $error');
    debugPrint(stack.toString());
  });
}

Future<void> _init() async {
  await LocalStorage.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}
