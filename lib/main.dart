// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Needed for kDebugMode (though not used now)

import 'theme_provider.dart';
import 'firebase_options.dart';
import 'app_router.dart';
import 'data/repositories/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase FIRST
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- Firebase Emulator Setup REMOVED ---
  // App will now use PRODUCTION Firebase Auth (even in debug mode)

  // Get the *single instance* of your AuthRepository
  final authRepository = AuthRepository.instance;

  runApp(FixitApp(authRepository: authRepository));
}

class FixitApp extends StatefulWidget {
  final AuthRepository authRepository;

  const FixitApp({super.key, required this.authRepository});

  @override
  State<FixitApp> createState() => _FixitAppState();
}

class _FixitAppState extends State<FixitApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: widget.authRepository.waitForInit(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final router = AppRouter.build(widget.authRepository);

        return ThemeProvider(
          toggleTheme: _toggleThemeMode,
          child: MaterialApp.router(
            title: 'Fixit',
            themeMode: _themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.orange,
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.orange,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.grey[850],
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            scrollBehavior: const ScrollBehavior().copyWith(
              scrollbars: false,
              overscroll: false,
            ),
          ),
        );
      },
    );
  }
}
