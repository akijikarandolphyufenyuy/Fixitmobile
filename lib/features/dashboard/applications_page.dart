import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/application.dart';
import '../../data/models/job.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/applications_repository.dart';
import '../../data/repositories/jobs_repository.dart';
import '../widgets/app_nav_bar.dart';

const _kOrange      = Color(0xFFF77705);
const _kOrangeDark  = Color(0xFFE86E00);
const _kOrangeLight = Color(0xFFFF9A3C);
const _kBrown       = Color(0xFF1C110C);
const _kBrownMid    = Color(0xFF9E7047);
const _kCream       = Color(0xFFFCF9F7);
const _kCreamDark   = Color(0xFFF4EDE5);
const _kBrownLight  = Color(0xFFE8D8CE);

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({super.key});

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationRow {
  final Job job;
  final Application application;
  const _ApplicationRow({required this.job, required this.application});
}

class _ApplicationsPageState extends State<ApplicationsPage> with SingleTickerProviderStateMixin {
  String jobTypeFilter = '';

  final JobsRepository _jobsRepository = JobsRepository();
  final ApplicationsRepository _applicationsRepository = ApplicationsRepository();
  final AuthRepository _authRepository = AuthRepository.instance;

  bool _isLoading = true;
  List<_ApplicationRow> allApplicants = [];
  List<_ApplicationRow> filteredApplicants = [];

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
    _loadApplications();
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    final userId = _authRepository.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      setState(() { allApplicants = []; filteredApplicants = []; _isLoading = false; });
      return;
    }

    final postedJobs = await _jobsRepository.getJobsByPostedBy(userId);
    final List<_ApplicationRow> rows = [];
    for (final job in postedJobs) {
      if (job.id == null || job.id!.isEmpty) continue;
      final apps = await _applicationsRepository.getApplicationsByJob(job.id!);
      for (final app in apps) { rows.add(_ApplicationRow(job: job, application: app)); }
    }

    if (!mounted) return;
    setState(() { allApplicants = rows; filteredApplicants = List.from(rows); _isLoading = false; });
  }

  void _applyFilters() {
    setState(() {
      if (jobTypeFilter.isEmpty) {
        filteredApplicants = List.from(allApplicants);
      } else {
        final q = jobTypeFilter.toLowerCase();
        filteredApplicants = allApplicants.where((r) =>
          r.job.category.toLowerCase().contains(q) ||
          r.job.title.toLowerCase().contains(q)).toList();
      }
    });
  }

  Future<void> _acceptApplication(_ApplicationRow row) async {
    if (row.application.id != null && row.application.id!.isNotEmpty) {
      await _applicationsRepository.updateApplicationStatus(applicationId: row.application.id!, status: 'accepted');
    }
    if (!mounted) return;
    setState(() {
      allApplicants.removeWhere((r) => r.application.id == row.application.id);
      filteredApplicants.removeWhere((r) => r.application.id == row.application.id);
    });
    _showResultDialog(true, row.application.applicantName);
  }

  Future<void> _declineApplication(_ApplicationRow row) async {
    if (row.application.id != null && row.application.id!.isNotEmpty) {
      await _applicationsRepository.updateApplicationStatus(applicationId: row.application.id!, status: 'rejected');
    }
    if (!mounted) return;
    setState(() {
      allApplicants.removeWhere((r) => r.application.id == row.application.id);
      filteredApplicants.removeWhere((r) => r.application.id == row.application.id);
    });
    _showResultDialog(false, row.application.applicantName);
  }

  void _showResultDialog(bool accepted, String name) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: accepted ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  accepted ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: accepted ? Colors.green : Colors.red,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                accepted ? 'Application Accepted' : 'Application Declined',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                accepted ? '$name has been accepted for the position.' : '$name\'s application has been declined.',
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accepted ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              child: _ApplicationsHeader(
                onBack: () => context.go('/dashboard/home'),
                slideAnim: _headerSlide,
                pendingCount: filteredApplicants.length,
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildSearchBar()),
          _isLoading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: _kOrange)))
              : filteredApplicants.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_rounded, size: 64, color: _kBrownLight),
                            const SizedBox(height: 12),
                            const Text('No applications yet', style: TextStyle(color: _kBrownMid, fontSize: 16)),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildApplicantCard(filteredApplicants[index], index),
                        childCount: filteredApplicants.length,
                      ),
                    ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      bottomNavigationBar: const AppNavBar(selectedIndex: 3),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'Filter by job type or category...',
            hintStyle: TextStyle(color: _kBrownMid, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: _kOrange, size: 22),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (v) { jobTypeFilter = v; _applyFilters(); },
        ),
      ),
    );
  }

  Widget _buildApplicantCard(_ApplicationRow row, int index) {
    String assetForCategory(String cat) {
      final c = cat.toLowerCase();
      if (c.contains('hair')) return 'assets/images/hair.png';
      if (c.contains('electric')) return 'assets/images/cable.png';
      if (c.contains('plumb')) return 'assets/images/tap.png';
      return 'assets/images/home.png';
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 60).clamp(0, 360)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(assetForCategory(row.job.category), width: 64, height: 64, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(row.application.applicantName,
                              style: const TextStyle(color: _kBrown, fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Row(children: [
                            const Icon(Icons.email_rounded, size: 13, color: _kBrownMid),
                            const SizedBox(width: 4),
                            Expanded(child: Text(row.application.applicantEmail ?? '—',
                                style: const TextStyle(color: _kBrownMid, fontSize: 12), overflow: TextOverflow.ellipsis)),
                          ]),
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.phone_rounded, size: 13, color: _kBrownMid),
                            const SizedBox(width: 4),
                            Text(row.application.applicantPhone ?? '—',
                                style: const TextStyle(color: _kBrownMid, fontSize: 12)),
                          ]),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _kOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(row.job.category,
                          style: const TextStyle(color: _kOrange, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                if (row.application.coverLetter != null && row.application.coverLetter!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _kCreamDark, borderRadius: BorderRadius.circular(10)),
                    child: Text(row.application.coverLetter!,
                        style: const TextStyle(color: _kBrown, fontSize: 13, height: 1.5),
                        maxLines: 3, overflow: TextOverflow.ellipsis),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Accept',
                        icon: Icons.check_rounded,
                        gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                        onTap: () => _acceptApplication(row),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: 'Decline',
                        icon: Icons.close_rounded,
                        gradient: const [Color(0xFFEB3349), Color(0xFFF45C43)],
                        onTap: () => _declineApplication(row),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: gradient.first.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ─── Applications Header ──────────────────────────────────────────────────────
class _ApplicationsHeader extends StatelessWidget {
  final VoidCallback onBack;
  final Animation<Offset> slideAnim;
  final int pendingCount;

  const _ApplicationsHeader({
    required this.onBack,
    required this.slideAnim,
    required this.pendingCount,
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
          // Transparent image overlay
          Positioned(
            right: -8,
            bottom: -6,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/nn.png',
                height: 85,
                fit: BoxFit.contain,
              ),
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
                        Text('Manage', style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 12, fontWeight: FontWeight.w400)),
                        const SizedBox(height: 2),
                        const Text('Applications',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3, height: 1.1)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
                        ),
                        child: const Icon(Icons.description_rounded, color: Colors.white, size: 20),
                      ),
                      if (pendingCount > 0)
                        Positioned(
                          top: -2, right: -2,
                          child: Container(
                            width: 18, height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                pendingCount > 9 ? '9+' : '$pendingCount',
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                    ],
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
