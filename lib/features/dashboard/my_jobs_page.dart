import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
const _kBrownLight  = Color(0xFFE8D8CE);
const _kCream       = Color(0xFFFCF9F7);
const _kCreamDark   = Color(0xFFF4EDE5);

class MyJobsPage extends StatefulWidget {
  const MyJobsPage({super.key});

  @override
  State<MyJobsPage> createState() => _MyJobsPageState();
}

class _MyJobsPageState extends State<MyJobsPage>
    with SingleTickerProviderStateMixin {
  final _jobsRepo = JobsRepository();
  final _appsRepo = ApplicationsRepository();
  final _auth     = AuthRepository.instance;

  late AnimationController _headerCtrl;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;

  String _filter = 'All'; // All | Active | Closed

  double get _headerHeight {
    final top = WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return top + 72;
  }

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleStatus(Job job) async {
    if (job.id == null) return;
    HapticFeedback.mediumImpact();
    await _jobsRepo.toggleJobStatus(job.id!, !job.isClosed);
  }

  Future<void> _deleteJob(String jobId) async {
    HapticFeedback.mediumImpact();
    await _jobsRepo.deleteJob(jobId);
  }

  Future<void> _clearAll(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all jobs?'),
        content: const Text('This will permanently delete all your posted jobs.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete all', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await _jobsRepo.clearAllJobs(uid);
  }

  @override
  Widget build(BuildContext context) {
    final uid   = _auth.currentUser?.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg    = isDark ? const Color(0xFF1A1210) : _kCream;

    return Scaffold(
      backgroundColor: bg,
      body: uid == null
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder<List<Job>>(
              stream: _jobsRepo.streamJobsByPostedBy(uid),
              builder: (context, snap) {
                final all    = snap.data ?? [];
                final active = all.where((j) => !j.isClosed).length;
                final closed = all.where((j) => j.isClosed).length;

                final filtered = _filter == 'Active'
                    ? all.where((j) => !j.isClosed).toList()
                    : _filter == 'Closed'
                        ? all.where((j) => j.isClosed).toList()
                        : all;

                return CustomScrollView(
                  slivers: [
                    // ── Header ──────────────────────────────────────────────
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
                        child: _JobsHeader(
                          slideAnim: _headerSlide,
                          onPostJob: () => context.go('/dashboard/post-job'),
                          onBack: () => context.go('/dashboard/home'),
                        ),
                      ),
                    ),

                    // ── Filter bar ──────────────────────────────────────────
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _FilterBarDelegate(
                        selected: _filter,
                        counts: {'All': all.length, 'Active': active, 'Closed': closed},
                        onSelect: (f) => setState(() => _filter = f),
                        onClearAll: all.isEmpty ? null : () => _clearAll(uid),
                        isDark: isDark,
                      ),
                    ),

                    // ── List ────────────────────────────────────────────────
                    if (snap.connectionState == ConnectionState.waiting && all.isEmpty)
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2.5)),
                      )
                    else if (filtered.isEmpty)
                      SliverFillRemaining(child: _EmptyJobs(isDark: isDark, filter: _filter))
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final job = filtered[i];
                            return Dismissible(
                              key: ValueKey(job.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 28),
                                margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete job?'),
                                    content: Text('Delete "${job.title}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) => _deleteJob(job.id!),
                              child: _JobPostedCard(
                                job: job,
                                index: i,
                                isDark: isDark,
                                appsRepo: _appsRepo,
                                onToggle: () => _toggleStatus(job),
                              ),
                            );
                          },
                          childCount: filtered.length,
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                );
              },
            ),
      bottomNavigationBar: const AppNavBar(selectedIndex: 1),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _JobsHeader extends StatelessWidget {
  final Animation<Offset> slideAnim;
  final VoidCallback onBack;
  final VoidCallback onPostJob;

  const _JobsHeader({
    required this.slideAnim,
    required this.onBack,
    required this.onPostJob,
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
          SlideTransition(
            position: slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Back
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
                  // Title
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Jobs Posted',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        Text('Manage your listings',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  // Post Job
                  GestureDetector(
                    onTap: onPostJob,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('Post Job',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
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

// ─── Filter Bar ───────────────────────────────────────────────────────────────
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final String selected;
  final Map<String, int> counts;
  final ValueChanged<String> onSelect;
  final VoidCallback? onClearAll;
  final bool isDark;

  const _FilterBarDelegate({
    required this.selected,
    required this.counts,
    required this.onSelect,
    required this.onClearAll,
    required this.isDark,
  });

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  @override
  bool shouldRebuild(_FilterBarDelegate old) =>
      old.selected != selected || old.counts != counts || old.isDark != isDark;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final bg = isDark ? const Color(0xFF1A1210) : _kCream;
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Active', 'Closed'].map((f) {
                  final isSelected = selected == f;
                  final count = counts[f] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => onSelect(f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? _kOrange : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? _kOrange : _kBrownLight,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(f,
                                style: TextStyle(
                                    color: isSelected ? Colors.white : _kBrownMid,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : _kBrownLight.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('$count',
                                  style: TextStyle(
                                      color: isSelected ? Colors.white : _kBrownMid,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (onClearAll != null)
            GestureDetector(
              onTap: onClearAll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_sweep_rounded, size: 14, color: Colors.red.shade400),
                    const SizedBox(width: 4),
                    Text('Clear', style: TextStyle(color: Colors.red.shade400, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Job Posted Card ──────────────────────────────────────────────────────────
class _JobPostedCard extends StatelessWidget {
  final Job job;
  final int index;
  final bool isDark;
  final ApplicationsRepository appsRepo;
  final VoidCallback onToggle;

  const _JobPostedCard({
    required this.job,
    required this.index,
    required this.isDark,
    required this.appsRepo,
    required this.onToggle,
  });

  String _asset(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('hair'))     return 'assets/images/hair.png';
    if (c.contains('electric')) return 'assets/images/cable.png';
    if (c.contains('plumb'))    return 'assets/images/tap.png';
    return 'assets/images/home.png';
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF2C1F18) : Colors.white;
    final isClosed = job.isClosed;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 320 + (index * 60).clamp(0, 300)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isClosed
                  ? _kBrownLight.withValues(alpha: 0.5)
                  : _kOrange.withValues(alpha: 0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image banner ──────────────────────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.asset(
                      _asset(job.category),
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.55),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isClosed
                            ? Colors.black.withValues(alpha: 0.55)
                            : _kOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: isClosed ? Colors.grey.shade400 : Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isClosed ? 'Closed' : 'Active',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12, left: 14, right: 14,
                    child: Text(
                      job.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1))
                          ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // ── Details ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: _kBrownMid),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(job.location,
                              style: const TextStyle(color: _kBrownMid, fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (job.payRange != null && job.payRange!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A8F6E).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.payments_rounded, size: 12, color: Color(0xFF0A8F6E)),
                                const SizedBox(width: 4),
                                Text(job.payRange!,
                                    style: const TextStyle(
                                        color: Color(0xFF0A8F6E),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),

                    StreamBuilder<List>(
                      stream: job.id != null
                          ? appsRepo.streamApplicationsByJob(job.id!)
                          : const Stream.empty(),
                      builder: (context, appSnap) {
                        final apps     = appSnap.data ?? [];
                        final pending  = apps.where((a) => a.status == 'pending').length;
                        final accepted = apps.where((a) => a.status == 'accepted').length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _AppStatChip(
                                  icon: Icons.people_rounded,
                                  label: '${apps.length} applicants',
                                  color: _kBrownMid,
                                  bg: isDark ? const Color(0xFF3A2A20) : _kCreamDark,
                                ),
                                if (pending > 0) ...[
                                  const SizedBox(width: 8),
                                  _AppStatChip(
                                    icon: Icons.hourglass_top_rounded,
                                    label: '$pending pending',
                                    color: _kOrange,
                                    bg: _kOrange.withValues(alpha: 0.1),
                                  ),
                                ],
                                if (accepted > 0) ...[
                                  const SizedBox(width: 8),
                                  _AppStatChip(
                                    icon: Icons.check_circle_rounded,
                                    label: '$accepted hired',
                                    color: const Color(0xFF0A8F6E),
                                    bg: const Color(0xFF0A8F6E).withValues(alpha: 0.1),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child: _ActionButton(
                                    label: isClosed ? 'Reopen Job' : 'Close Job',
                                    icon: isClosed
                                        ? Icons.lock_open_rounded
                                        : Icons.lock_rounded,
                                    color: isClosed
                                        ? const Color(0xFF0A8F6E)
                                        : Colors.red.shade400,
                                    outlined: true,
                                    onTap: onToggle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Applicants',
                                    icon: Icons.people_alt_rounded,
                                    color: _kOrange,
                                    outlined: false,
                                    onTap: () => context.push(
                                      '/dashboard/job-applicants/${job.id}',
                                      extra: job.title,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  const _AppStatChip({required this.icon, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.outlined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(12),
          border: outlined ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: outlined ? color : Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: outlined ? color : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyJobs extends StatelessWidget {
  final bool isDark;
  final String filter;
  const _EmptyJobs({required this.isDark, required this.filter});

  @override
  Widget build(BuildContext context) {
    final isFiltered = filter != 'All';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
                color: _kOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.work_off_rounded, size: 40, color: _kOrange),
          ),
          const SizedBox(height: 20),
          Text(
            isFiltered ? 'No $filter jobs' : 'No jobs posted yet',
            style: TextStyle(
                color: isDark ? const Color(0xFFF5EDE5) : _kBrown,
                fontSize: 18,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered ? 'Try a different filter' : 'Post your first job to get started',
            style: const TextStyle(color: _kBrownMid, fontSize: 14),
          ),

        ],
      ),
    );
  }
}
