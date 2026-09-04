import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/reading_store.dart';
import 'jal_drishti_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ReadingStore.load();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const JalDrishtiApp());
}