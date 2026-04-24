import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_nav_bar.dart';

const _kOrange      = Color(0xFFF77705);
const _kOrangeDark  = Color(0xFFE86E00);
const _kOrangeLight = Color(0xFFFF9A3C);
const _kBrown       = Color(0xFF1C110C);
const _kBrownMid    = Color(0xFF9E7047);
const _kCream       = Color(0xFFFCF9F7);
const _kBrownLight  = Color(0xFFE8D8CE);

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with SingleTickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  double get _headerHeight {
    final topPadding = WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return topPadding + 72;
  }

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0.12, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: _headerHeight,
            collapsedHeight: _headerHeight,
            toolbarHeight: _headerHeight,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FadeTransition(
              opacity: _headerFade,
              child: _AboutHeader(
                onBack: () => context.go('/dashboard/settings'),
                slideAnim: _headerSlide,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroBanner(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('What is Fixit?'),
                  const SizedBox(height: 12),
                  _buildAboutCard(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('How to Use Fixit'),
                  const SizedBox(height: 12),
                  _buildGuideCard(),
                  const SizedBox(height: 28),
                  _buildVersionBadge(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppNavBar(selectedIndex: 4),
    );
  }

  // ── Hero Banner ──────────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kOrangeDark, _kOrange, _kOrangeLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: _kOrange.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fixit', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  const SizedBox(height: 6),
                  Text('Connecting skilled workers\nwith people who need them.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 14, height: 1.5)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Text('Made for Cameroon 🇨🇲',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Opacity(
              opacity: 0.25,
              child: Image.asset('assets/images/home.png', height: 80, width: 80, fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }

  // ── About Card ───────────────────────────────────────────────────────────────
  Widget _buildAboutCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fixit is a local job marketplace built for Cameroon. It bridges the gap between skilled tradespeople — plumbers, electricians, carpenters, hair dressers, farmers, and more — and individuals or businesses who need their services.',
              style: TextStyle(color: _kBrown, fontSize: 14, height: 1.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'Whether you\'re looking for work or looking to hire, Fixit makes it fast, simple, and trusted. Payments are supported through MoMo and Orange Money, keeping everything local and secure.',
              style: TextStyle(color: _kBrownMid, fontSize: 14, height: 1.7),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _featurePill(Icons.bolt_rounded, 'Fast Hiring'),
                _featurePill(Icons.verified_rounded, 'Trusted'),
                _featurePill(Icons.place_rounded, 'Local'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _featurePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _kOrange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _kOrange, size: 14),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: _kOrange, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Guide Card ───────────────────────────────────────────────────────────────
  Widget _buildGuideCard() {
    final steps = [
      _GuideStep(
        number: '1',
        icon: Icons.person_add_rounded,
        title: 'Create Your Account',
        desc: 'Sign up with your email. Fill in your name, profession, and location so employers or workers can find you.',
        gradient: [const Color(0xFF6C63FF), const Color(0xFF9B8FFF)],
      ),
      _GuideStep(
        number: '2',
        icon: Icons.search_rounded,
        title: 'Browse Available Jobs',
        desc: 'Go to the Jobs tab to see all open listings. Filter by category, location, or pay range to find the right fit.',
        gradient: [_kOrangeDark, _kOrangeLight],
      ),
      _GuideStep(
        number: '3',
        icon: Icons.send_rounded,
        title: 'Apply for a Job',
        desc: 'Tap "Apply Now" on any job card. Fill in your details and cover letter, then submit your application.',
        gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      ),
      _GuideStep(
        number: '4',
        icon: Icons.add_circle_outline_rounded,
        title: 'Post a Job',
        desc: 'Need to hire? Tap the Post tab. Fill in the job title, type, location, description, and expiration date.',
        gradient: [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
      ),
      _GuideStep(
        number: '5',
        icon: Icons.description_rounded,
        title: 'Manage Applications',
        desc: 'In the Applications tab, review people who applied to your jobs. Accept or decline with one tap.',
        gradient: [const Color(0xFFEB3349), const Color(0xFFF45C43)],
      ),
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: steps.asMap().entries.map((e) {
            final isLast = e.key == steps.length - 1;
            return Column(
              children: [
                _buildGuideStep(e.value),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.only(left: 68),
                    child: Divider(height: 1, color: _kBrownLight.withValues(alpha: 0.6)),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGuideStep(_GuideStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: step.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(step.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: _kOrange.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(step.number,
                            style: const TextStyle(color: _kOrange, fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(step.title,
                          style: const TextStyle(color: _kBrown, fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(step.desc, style: const TextStyle(color: _kBrownMid, fontSize: 13, height: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Version Badge ────────────────────────────────────────────────────────────
  Widget _buildVersionBadge() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _kBrownLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Version 1.0.0', style: TextStyle(color: _kBrownMid, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          const Text('© 2025 Fixit. All rights reserved.',
              style: TextStyle(color: _kBrownMid, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(color: _kBrownMid, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
    );
  }
}

class _GuideStep {
  final String number;
  final IconData icon;
  final String title;
  final String desc;
  final List<Color> gradient;
  const _GuideStep({required this.number, required this.icon, required this.title, required this.desc, required this.gradient});
}

// ─── About Header ─────────────────────────────────────────────────────────────
class _AboutHeader extends StatelessWidget {
  final VoidCallback onBack;
  final Animation<Offset> slideAnim;

  const _AboutHeader({required this.onBack, required this.slideAnim});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kOrangeDark, _kOrange, _kOrangeLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(top: topPadding),
      child: Stack(
        children: [
          Positioned(
            right: -8, bottom: -6,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/ub1.png', height: 85, fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: SlideTransition(
              position: slideAnim,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(22),
                      splashColor: Colors.white.withValues(alpha: 0.25),
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Fixit App', style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 12, fontWeight: FontWeight.w400)),
                        const SizedBox(height: 2),
                        const Text('About Fixit',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3, height: 1.1)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
