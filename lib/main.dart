import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/utils/themes.dart';
import 'package:khadem/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: Routes.routes,
      theme: AppThemes.lightTheme,
    );
  }
}
