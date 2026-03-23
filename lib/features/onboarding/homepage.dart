import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _kOrange     = Color(0xFFF77705);
const _kCream      = Color(0xFFFCF9F7);
const _kBrown      = Color(0xFF1C110C);
const _kBrownMid   = Color(0xFF9E7047);
const _kBrownLight = Color(0xFFE8D8CE);

class OnboardingHomePage extends StatefulWidget {
  const OnboardingHomePage({super.key});

  @override
  State<OnboardingHomePage> createState() => _OnboardingHomePageState();
}

class _OnboardingHomePageState extends State<OnboardingHomePage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoFade = CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut));

    _contentFade =
        CurvedAnimation(parent: _contentController, curve: Curves.easeOut);
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentController, curve: Curves.easeOutCubic));

    _logoController.forward().then((_) => _contentController.forward());
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _kCream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Hero Image ─────────────────────────────────────────────────
            Expanded(
              flex: 55,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/home.png',
                    fit: BoxFit.cover,
                  ),

                  // Gradient overlay — dark top for logo, fade to cream bottom
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.black.withValues(alpha: 0.10),
                          _kCream.withValues(alpha: 0.0),
                          _kCream,
                        ],
                        stops: const [0.0, 0.25, 0.65, 1.0],
                      ),
                    ),
                  ),

                  // ── Professional Wordmark Logo (top-center) ──────────────
                  Positioned(
                    top: 24,
                    left: 0,
                    right: 0,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: Center(child: _FixitWordmark()),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Content ─────────────────────────────────────────────
            Expanded(
              flex: 45,
              child: FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          24, 20, 24, bottomPad + 24),
                      child: Column(
                        children: [
                        // ── Tag ──────────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _kBrownLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '🇨🇲  Made for Cameroon',
                            style: TextStyle(
                              color: _kBrownMid,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Headline (centered) ──────────────────────────
                        Text(
                          'Your Skills,\nYour Earnings.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _kBrown,
                            fontSize: size.width < 360 ? 26 : 30,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Subtext (centered) ───────────────────────────
                        const Text(
                          'Find jobs. Offer services.\nGet paid — all in one place.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _kBrownMid,
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Get Started Button (responsive) ──────────────
                        _GetStartedButton(
                          onTap: () => context.go('/onboarding/1'),
                        ),
                        const SizedBox(height: 12),

                        // ── Sign In link ─────────────────────────────────
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              text: 'Already have an account? ',
                              style:
                                  TextStyle(color: _kBrownMid, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    color: _kOrange,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Professional FixIt Wordmark ───────────────────────────────────────────────
class _FixitWordmark extends StatelessWidget {
  const _FixitWordmark();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Wrench icon in orange pill
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kOrange,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: _kOrange.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.build_rounded, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 10),
          // Wordmark text
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Fix',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: 'It',
                  style: TextStyle(
                    color: _kOrange,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Responsive Get Started Button ─────────────────────────────────────────────
class _GetStartedButton extends StatefulWidget {
  final VoidCallback onTap;
  const _GetStartedButton({required this.onTap});

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: width,
          constraints: const BoxConstraints(maxWidth: 480),
          padding: EdgeInsets.symmetric(
            vertical: width < 360 ? 14 : 16,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE86E00), _kOrange, Color(0xFFFF9A3C)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _kOrange.withValues(alpha: 0.42),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width < 360 ? 15 : 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
