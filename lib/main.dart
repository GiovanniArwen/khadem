import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:khadem/core/routes/routes.dart';
import 'package:khadem/core/services/local/shared_pref.dart';
import 'package:khadem/core/utils/themes.dart';
import 'package:khadem/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPref.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ar');
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
