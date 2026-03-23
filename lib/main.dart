// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme_provider.dart';
import 'firebase_options.dart';
import 'app_router.dart';
import 'core/fcm_service.dart';
import 'data/repositories/auth_repository.dart';
import 'features/onboarding/splash_screen.dart';

// ─── Brand Colors ─────────────────────────────────────────────────────────────
const kOrange      = Color(0xFFF77705);
const kOrangeLight = Color(0xFFFF9A3C);
const kCream       = Color(0xFFFCF9F7);
const kCreamDark   = Color(0xFFF4EDE5);
const kBrown       = Color(0xFF1C110C);
const kBrownMid    = Color(0xFF9E7047);
const kBrownLight  = Color(0xFFE8D8CE);
// ──────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(FixitApp(authRepository: AuthRepository.instance));
}

class FixitApp extends StatefulWidget {
  final AuthRepository authRepository;
  const FixitApp({super.key, required this.authRepository});

  @override
  State<FixitApp> createState() => _FixitAppState();
}

class _FixitAppState extends State<FixitApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initFcm();
  }

  Future<void> _initFcm() async {
    await FcmService.instance.init(
      onForegroundMessage: _showInAppPopup,
    );
  }

  void _showInAppPopup(RemoteMessage message) {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    final title = message.notification?.title ?? message.data['title'] ?? 'Notification';
    final body  = message.notification?.body  ?? message.data['message'] ?? '';
    _InAppNotificationOverlay.show(ctx, title: title, body: body);
  }

  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: widget.authRepository.waitForInit(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          );
        }

        final router = AppRouter.build(widget.authRepository);

        return ThemeProvider(
          toggleTheme: _toggleThemeMode,
          child: MaterialApp.router(
            title: 'Fixit',
            themeMode: _themeMode,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            scrollBehavior: const ScrollBehavior().copyWith(scrollbars: false, overscroll: false),
          ),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary:              kOrange,
        onPrimary:            Colors.white,
        primaryContainer:     Color(0xFFFFE0C2),
        onPrimaryContainer:   Color(0xFF4A1800),
        secondary:            kBrownMid,
        onSecondary:          Colors.white,
        secondaryContainer:   kBrownLight,
        onSecondaryContainer: kBrown,
        tertiary:             kOrangeLight,
        onTertiary:           Colors.white,
        surface:              kCream,
        onSurface:            kBrown,
        surfaceContainerHighest: Color(0xFFF4EDE5),
        onSurfaceVariant:     kBrownMid,
        outline:              kBrownLight,
        outlineVariant:       Color(0xFFE8D8CE),
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: kCream,
      textTheme: GoogleFonts.lexendTextTheme(base.textTheme).apply(bodyColor: kBrown, displayColor: kBrown),
      appBarTheme: const AppBarTheme(backgroundColor: kCream, foregroundColor: kBrown, elevation: 0, centerTitle: true),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF4EDE5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        hintStyle: const TextStyle(color: kBrownMid),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary:              kOrange,
        onPrimary:            Colors.white,
        primaryContainer:     const Color(0xFF7A3800),
        onPrimaryContainer:   const Color(0xFFFFDBC8),
        secondary:            kBrownMid,
        onSecondary:          Colors.white,
        tertiary:             kOrangeLight,
        onTertiary:           Colors.white,
        surface:              const Color(0xFF1A1210),
        onSurface:            const Color(0xFFF5EDE5),
        surfaceContainerHighest: const Color(0xFF2C1F18),
        onSurfaceVariant:     const Color(0xFFBB9070),
        outline:              const Color(0xFF5C3D28),
        outlineVariant:       const Color(0xFF3D2518),
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF1A1210),
      textTheme: GoogleFonts.lexendTextTheme(base.textTheme).apply(bodyColor: const Color(0xFFF5EDE5), displayColor: const Color(0xFFF5EDE5)),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1A1210), foregroundColor: Color(0xFFF5EDE5), elevation: 0, centerTitle: true),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}

// ─── In-App Notification Popup Overlay ───────────────────────────────────────
class _InAppNotificationOverlay {
  static OverlayEntry? _entry;

  static void show(BuildContext context, {required String title, required String body}) {
    _entry?.remove();
    _entry = OverlayEntry(
      builder: (_) => _InAppBanner(
        title: title,
        body: body,
        onDismiss: () { _entry?.remove(); _entry = null; },
      ),
    );
    Overlay.of(context).insert(_entry!);
    Future.delayed(const Duration(seconds: 4), () {
      _entry?.remove();
      _entry = null;
    });
  }
}

class _InAppBanner extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onDismiss;

  const _InAppBanner({required this.title, required this.body, required this.onDismiss});

  @override
  State<_InAppBanner> createState() => _InAppBannerState();
}

class _InAppBannerState extends State<_InAppBanner> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Positioned(
      top: top + 12,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE86E00), kOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: kOrange.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 6)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(widget.body, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.8), size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
