import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Brand colors
const _kOrange     = Color(0xFFF77705);
const _kCream      = Color(0xFFFCF9F7);
const _kCreamDark  = Color(0xFFF4EDE5);
const _kBrown      = Color(0xFF1C110C);
const _kBrownMid   = Color(0xFF9E7047);
const _kBrownLight = Color(0xFFE8D8CE);

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  static const _pages = [
    _OnboardingData(
      image: 'assets/images/ub1.png',
      title: 'Post a Job in Minutes',
      subtitle: 'Need help? Connect instantly with skilled workers near you. Fast. Simple. Local.',
    ),
    _OnboardingData(
      image: 'assets/images/ub2.png',
      title: 'Turn Skills Into Income',
      subtitle: 'Get discovered, apply for jobs, and grow your reputation. Your talent deserves the spotlight.',
    ),
    _OnboardingData(
      image: 'assets/images/ub3.png',
      title: 'Get Paid Securely',
      subtitle: 'Earn safely through MoMo or Orange Money. No delays. Trusted by the local community.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    } else {
      _onGetStarted();
    }
  }

  void _onSkip() => context.go('/login');

  void _onGetStarted() => context.push('/signup');

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: _kCream,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── Page View ──────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                  _fadeController.reset();
                  _fadeController.forward();
                },
                itemBuilder: (context, index) => _OnboardingSlide(
                  data: _pages[index],
                  size: size,
                ),
              ),
            ),

            // ── Bottom Controls ────────────────────────────────────────────
            Container(
              color: _kCream,
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) => _Dot(isActive: i == _currentPage)),
                  ),
                  const SizedBox(height: 28),

                  // Buttons
                  isLast
                      ? _GetStartedButton(onTap: _onGetStarted)
                      : Row(
                          children: [
                            _SkipButton(onTap: _onSkip),
                            const Spacer(),
                            _NextButton(onTap: _onNext),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Slide ────────────────────────────────────────────────────────────────────
class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData data;
  final Size size;

  const _OnboardingSlide({required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image
        Expanded(
          flex: 6,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(data.image, fit: BoxFit.cover),
              // Gradient overlay at bottom
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [_kCream, _kCream.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Text
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _kBrown,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _kBrownMid,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Dot Indicator ────────────────────────────────────────────────────────────
class _Dot extends StatelessWidget {
  final bool isActive;
  const _Dot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? _kOrange : _kBrownLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─── Buttons ──────────────────────────────────────────────────────────────────
class _SkipButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SkipButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: _kCreamDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Skip',
          style: TextStyle(color: _kBrownMid, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NextButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: _kOrange,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: _kOrange.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Next', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GetStartedButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _kOrange,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _kOrange.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: const Center(
          child: Text(
            'Get Started',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.3),
          ),
        ),
      ),
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────
class _OnboardingData {
  final String image;
  final String title;
  final String subtitle;
  const _OnboardingData({required this.image, required this.title, required this.subtitle});
}
