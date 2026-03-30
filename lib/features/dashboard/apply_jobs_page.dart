import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/application.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/applications_repository.dart';
import '../widgets/app_nav_bar.dart';

const _kOrange      = Color(0xFFF77705);
const _kOrangeDark  = Color(0xFFE86E00);
const _kOrangeLight = Color(0xFFFF9A3C);
const _kBrown       = Color(0xFF1C110C);
const _kBrownMid    = Color(0xFF9E7047);
const _kBrownLight  = Color(0xFFE8D8CE);
const _kCream       = Color(0xFFFCF9F7);
const _kCreamDark   = Color(0xFFF4EDE5);

class ApplyJobsPage extends StatefulWidget {
  const ApplyJobsPage({super.key});

  @override
  State<ApplyJobsPage> createState() => _ApplyJobsPageState();
}

class _ApplyJobsPageState extends State<ApplyJobsPage>
    with SingleTickerProviderStateMixin {
  final _applicationsRepository = ApplicationsRepository();
  final _authRepository = AuthRepository.instance;

  String? _jobId;
  String? _jobTitle;
  bool _isSubmitting = false;

  final _fullNameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _coverLetterCtrl = TextEditingController();

  late AnimationController _headerCtrl;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;

  double get _headerHeight {
    final top = WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return top + 72;
  }

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is Map) {
      _jobId    = extra['jobId']?.toString();
      _jobTitle = extra['jobTitle']?.toString();
    }
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _coverLetterCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final jobId = _jobId;
    if (jobId == null || jobId.isEmpty) {
      _showSnack('Job information is missing', isError: true);
      return;
    }

    final applicantId = _authRepository.currentUser?.id;
    if (applicantId == null || applicantId.isEmpty) {
      _showSnack('Please log in to apply', isError: true);
      return;
    }

    if (_fullNameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty) {
      _showSnack('Please fill in all required fields', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _applicationsRepository.applyForJob(Application(
        jobId: jobId,
        applicantId: applicantId,
        applicantName: _fullNameCtrl.text.trim(),
        applicantEmail: _emailCtrl.text.trim(),
        applicantPhone: _phoneCtrl.text.trim(),
        coverLetter: _coverLetterCtrl.text.trim().isEmpty ? null : _coverLetterCtrl.text.trim(),
        status: 'pending',
        dateApplied: DateTime.now(),
      ));
      if (!mounted) return;
      _showSnack('Application sent${_jobTitle != null ? ' for $_jobTitle' : ''}!', isError: false);
      context.go('/dashboard/jobs');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to submit: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
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
              child: _ApplyHeader(
                jobTitle: _jobTitle,
                slideAnim: _headerSlide,
                onBack: () => context.go('/dashboard/jobs'),
              ),
            ),
          ),

          // ── Form ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job title chip
                  if (_jobTitle != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _kOrange.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _kOrange.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.work_outline_rounded, color: _kOrange, size: 15),
                          const SizedBox(width: 6),
                          Text(_jobTitle!,
                              style: const TextStyle(color: _kOrange, fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  _sectionLabel('Personal Information'),
                  const SizedBox(height: 12),
                  _buildCard(context, [
                    _InputRow(
                      icon: Icons.person_rounded,
                      hint: 'Full Name',
                      controller: _fullNameCtrl,
                    ),
                    _divider(context),
                    _InputRow(
                      icon: Icons.email_rounded,
                      hint: 'Email Address',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _divider(context),
                    _InputRow(
                      icon: Icons.phone_rounded,
                      hint: 'Phone Number',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _sectionLabel('Cover Letter'),
                  const SizedBox(height: 12),
                  _buildCard(context, [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _coverLetterCtrl,
                        maxLines: 5,
                        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14, height: 1.5),
                        decoration: InputDecoration(
                          hintText: 'Tell the employer why you\'re the right fit for this job...',
                          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppNavBar(selectedIndex: 1),
    );
  }

  Widget _sectionLabel(String label) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      label.toUpperCase(),
      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
    );
  }

  Widget _buildCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(height: 1, color: cs.outlineVariant),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _isSubmitting
              ? const LinearGradient(colors: [_kBrownLight, _kBrownLight])
              : const LinearGradient(
                  colors: [_kOrangeDark, _kOrange, _kOrangeLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isSubmitting
              ? []
              : [BoxShadow(color: _kOrange.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : () { HapticFeedback.mediumImpact(); _submit(); },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isSubmitting
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : const Text('Submit Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

// ─── Input Row ────────────────────────────────────────────────────────────────
class _InputRow extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _InputRow({
    required this.icon,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _kOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _kOrange, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(color: cs.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Apply Header ─────────────────────────────────────────────────────────────
class _ApplyHeader extends StatelessWidget {
  final String? jobTitle;
  final Animation<Offset> slideAnim;
  final VoidCallback onBack;

  const _ApplyHeader({
    required this.jobTitle,
    required this.slideAnim,
    required this.onBack,
  });

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
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              child: Opacity(
                opacity: 0.15,
                child: Image.asset('assets/images/nn.png', fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SlideTransition(
              position: slideAnim,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Apply for Job',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        if (jobTitle != null)
                          Text(jobTitle!,
                              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
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
