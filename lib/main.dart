// ============================================================
// RailGuide — App Entry Point (Updated)
// main.dart
//
// Added TrainProvider to MultiProvider
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/language_provider.dart';
import 'providers/train_provider.dart'; // ← NEW
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const RailGuideApp());
}

class RailGuideApp extends StatelessWidget {
  const RailGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider( 
      providers: [
        ChangeNotifierProvider(create: (_) => RailAuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => TrainProvider()), // ← NEW
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, _) {
          return MaterialApp(
            title: 'RailGuide',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            locale: langProvider.currentLocale,
            supportedLocales: LanguageProvider.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}