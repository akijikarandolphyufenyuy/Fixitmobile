import 'package:flutter/material.dart';

const _kOrange     = Color(0xFFF77705);
const _kOrangeDeep = Color(0xFFE86E00);
const _kCream      = Color(0xFFFCF9F7);
const _kBrown      = Color(0xFF1C110C);
const _kBrownMid   = Color(0xFF9E7047);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _taglineFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Logo mark ──────────────────────────────────────────────────
            ScaleTransition(
              scale: _scale,
              child: FadeTransition(
                opacity: _fade,
                child: _LogoMark(),
              ),
            ),
            const SizedBox(height: 20),
            // ── App name ───────────────────────────────────────────────────
            FadeTransition(
              opacity: _fade,
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Fix',
                      style: TextStyle(
                        color: _kBrown,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: 'It',
                      style: TextStyle(
                        color: _kOrange,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ── Tagline ────────────────────────────────────────────────────
            FadeTransition(
              opacity: _taglineFade,
              child: const Text(
                'Find work. Post jobs. Get paid.',
                style: TextStyle(
                  color: _kBrownMid,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            const SizedBox(height: 56),
            // ── Loading indicator ──────────────────────────────────────────
            FadeTransition(
              opacity: _taglineFade,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: _kOrange.withValues(alpha: 0.7),
                  strokeWidth: 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logo mark widget ──────────────────────────────────────────────────────────
// Uses asset if available, falls back to the icon-based mark.
class _LogoMark extends StatelessWidget {
  const _LogoMark();

  static const _logoPath = 'assets/logos/app_icon.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kOrangeDeep, _kOrange, Color(0xFFFF9A3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kOrange.withValues(alpha: 0.38),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          _logoPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.build_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),
      ),
    );
  }
}
