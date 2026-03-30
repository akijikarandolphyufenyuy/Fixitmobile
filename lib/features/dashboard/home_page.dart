import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

import '../../data/models/job.dart';
import '../../data/models/notification_item.dart';
import '../../data/repositories/jobs_repository.dart';
import '../../data/repositories/applications_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/notifications_repository.dart';
import '../widgets/app_nav_bar.dart';

// Brand colors
const _kOrange = Color(0xFFF77705);
const _kCream = Color(0xFFFCF9F7);
const _kCreamDark = Color(0xFFF4EDE5);
const _kBrown = Color(0xFF1C110C);
const _kBrownMid = Color(0xFF9E7047);
const _kBrownLight = Color(0xFFE8D8CE);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _profileImageFile;
  Timer? _timer;
  DateTime _now = DateTime.now().toUtc().add(const Duration(hours: 1));

  final JobsRepository _jobsRepo = JobsRepository();
  final ApplicationsRepository _appsRepo = ApplicationsRepository();
  final AuthRepository _authRepo = AuthRepository.instance;
  final NotificationsRepository _notifRepo = NotificationsRepository();

  bool _loadingJobs = true;
  bool _loadingMyJobs = true;
  bool _loadingApps = true;

  List<Job> _recentJobs = [];
  List<Job> _myJobs = [];
  int _pendingApps = 0;

  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(
        () => _now = DateTime.now().toUtc().add(const Duration(hours: 1)),
      );
    });

    _loadAll();
    _headerCtrl.forward();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadJobs(), _loadMyJobs(), _loadApps()]);
  }

  Future<void> _loadJobs() async {
    setState(() => _loadingJobs = true);
    final jobs = await _jobsRepo.getAllJobs();
    if (!mounted) return;
    setState(() {
      _recentJobs = jobs.take(5).toList();
      _loadingJobs = false;
    });
  }

  Future<void> _loadMyJobs() async {
    setState(() => _loadingMyJobs = true);
    final uid = _authRepo.currentUser?.id;
    if (uid == null) {
      setState(() => _loadingMyJobs = false);
      return;
    }
    final jobs = await _jobsRepo.getJobsByPostedBy(uid);
    if (!mounted) return;
    setState(() {
      _myJobs = jobs.take(3).toList();
      _loadingMyJobs = false;
    });
  }

  Future<void> _loadApps() async {
    setState(() => _loadingApps = true);
    final uid = _authRepo.currentUser?.id;
    if (uid == null) {
      setState(() => _loadingApps = false);
      return;
    }
    final jobs = await _jobsRepo.getJobsByPostedBy(uid);
    int count = 0;
    for (final job in jobs) {
      if (job.id == null) continue;
      final apps = await _appsRepo.getApplicationsByJob(job.id!);
      count += apps.where((a) => a.status == 'pending').length;
    }
    if (!mounted) return;
    setState(() {
      _pendingApps = count;
      _loadingApps = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _headerCtrl.dispose();
    super.dispose();
  }

  double get _headerHeight {
    final topPadding =
        WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return topPadding + 74;
  }

  String get _greeting {
    final h = _now.hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _pickProfileImage() async {
    final XFile? f = await _picker.pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _profileImageFile = File(f.path));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1210) : _kCream,
      body: RefreshIndicator(
        color: _kOrange,
        onRefresh: _loadAll,
        child: CustomScrollView(
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
                child: StreamBuilder<List<AppNotification>>(
                  stream: _authRepo.currentUser?.id != null
                      ? _notifRepo.streamNotifications(
                          _authRepo.currentUser!.id,
                        )
                      : const Stream.empty(),
                  builder: (context, snap) {
                    final unread = (snap.data ?? [])
                        .where((n) => !n.isRead)
                        .length;
                    return _HomeHeader(
                      displayName:
                          GoRouterState.of(context).extra as String? ?? '',
                      greeting: _greeting,
                      pendingApps: _pendingApps,
                      unreadNotifications: unread,
                      profileImageFile: _profileImageFile,
                      onAvatarTap: _pickProfileImage,
                      onBellTap: () => context.go('/dashboard/notifications'),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildQuickActions(isDark)),
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'Recent Jobs',
                '/dashboard/jobs',
                isDark,
              ),
            ),
            SliverToBoxAdapter(child: _buildRecentJobs(isDark)),
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'My Posted Jobs',
                '/dashboard/my-jobs',
                isDark,
              ),
            ),
            SliverToBoxAdapter(child: _buildMyJobs(isDark)),
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'Applications',
                '/dashboard/applications',
                isDark,
              ),
            ),
            SliverToBoxAdapter(child: _buildApplicationsSummary(isDark)),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
      bottomNavigationBar: StreamBuilder<List<AppNotification>>(
        stream: _authRepo.currentUser?.id != null
            ? _notifRepo.streamNotifications(_authRepo.currentUser!.id)
            : const Stream.empty(),
        builder: (context, snap) {
          final count = (snap.data ?? []).where((n) => !n.isRead).length;
          return AppNavBar(selectedIndex: 0, notificationCount: count);
        },
      ),
    );
  }

  // ── Quick Actions ────────────────────────────────────────────────────────────
  Widget _buildQuickActions(bool isDark) {
    final cardBg = isDark ? const Color(0xFF2C1F18) : Colors.white;
    final labelColor = isDark ? const Color(0xFFF5EDE5) : _kBrown;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _DashboardCard(
            icon: Icons.work_rounded,
            label: 'Browse Jobs',
            value: _loadingJobs ? null : '${_recentJobs.length}+ open',
            accentColor: _kOrange,
            cardBg: cardBg,
            labelColor: labelColor,
            onTap: () => context.go('/dashboard/jobs'),
          ),
          _DashboardCard(
            icon: Icons.add_circle_outline_rounded,
            label: 'Post a Job',
            value: 'Hire now',
            accentColor: const Color(0xFF2C7BE5),
            cardBg: cardBg,
            labelColor: labelColor,
            onTap: () => context.go('/dashboard/post-job'),
          ),
          _DashboardCard(
            icon: Icons.description_outlined,
            label: 'Applications',
            value: _loadingApps ? null : '$_pendingApps pending',
            accentColor: const Color(0xFF0A8F6E),
            cardBg: cardBg,
            labelColor: labelColor,
            onTap: () => context.go('/dashboard/applications'),
          ),
          _DashboardCard(
            icon: Icons.business_center_outlined,
            label: 'My Jobs',
            value: _loadingMyJobs ? null : '${_myJobs.length} posted',
            accentColor: const Color(0xFF7B5EA7),
            cardBg: cardBg,
            labelColor: labelColor,
            onTap: () => context.go('/dashboard/my-jobs'),
          ),
        ],
      ),
    );
  }

  // ── Section Title ────────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, String route, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? const Color(0xFFF5EDE5) : _kBrown,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: () => context.go(route),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _kOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'See all',
                style: TextStyle(
                  color: _kOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent Jobs ──────────────────────────────────────────────────────────────
  Widget _buildRecentJobs(bool isDark) {
    if (_loadingJobs) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2.5),
        ),
      );
    }
    if (_recentJobs.isEmpty) {
      return _EmptyState(
        message: 'No jobs available yet',
        icon: Icons.work_off_rounded,
        isDark: isDark,
      );
    }
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 8),
        itemCount: _recentJobs.length,
        itemBuilder: (context, i) =>
            _JobHorizontalCard(job: _recentJobs[i], index: i, isDark: isDark),
      ),
    );
  }

  // ── My Jobs ──────────────────────────────────────────────────────────────────
  Widget _buildMyJobs(bool isDark) {
    if (_loadingMyJobs) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2.5),
        ),
      );
    }
    if (_myJobs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: _PostJobPrompt(isDark: isDark),
      );
    }
    return Column(
      children: _myJobs
          .asMap()
          .entries
          .map((e) => _MyJobCard(job: e.value, index: e.key, isDark: isDark))
          .toList(),
    );
  }

  // ── Applications Summary ─────────────────────────────────────────────────────
  Widget _buildApplicationsSummary(bool isDark) {
    final bg = isDark ? const Color(0xFF2C1F18) : _kCreamDark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: GestureDetector(
        onTap: () => context.go('/dashboard/applications'),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kBrownLight.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _kOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: _kOrange,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Applications',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFF5EDE5) : _kBrown,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _loadingApps
                          ? 'Loading...'
                          : '$_pendingApps applicants waiting for review',
                      style: const TextStyle(color: _kBrownMid, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _kOrange,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dashboard Card ───────────────────────────────────────────────────────────
class _DashboardCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color accentColor;
  final Color cardBg;
  final Color labelColor;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.cardBg,
    required this.labelColor,
    required this.onTap,
    this.value,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          decoration: BoxDecoration(
            color: widget.cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.labelColor.withValues(alpha: 0.60),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (widget.value != null)
                      Text(
                        widget.value!,
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Container(
                        width: 48,
                        height: 10,
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
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

// ─── Horizontal Job Card ──────────────────────────────────────────────────────
class _JobHorizontalCard extends StatelessWidget {
  final Job job;
  final int index;
  final bool isDark;

  const _JobHorizontalCard({
    required this.job,
    required this.index,
    required this.isDark,
  });

  String _asset(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('hair')) return 'assets/images/hair.png';
    if (c.contains('electric')) return 'assets/images/cable.png';
    if (c.contains('plumb')) return 'assets/images/tap.png';
    return 'assets/images/home.png';
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF2C1F18) : Colors.white;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 80).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(20 * (1 - v), 0),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: () => context.go('/dashboard/jobs'),
        child: Container(
          width: 200,
          margin: const EdgeInsets.only(right: 12, bottom: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  _asset(job.category),
                  height: 90,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: TextStyle(
                        color: isDark ? const Color(0xFFF5EDE5) : _kBrown,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: _kBrownMid,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            job.location,
                            style: const TextStyle(
                              color: _kBrownMid,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _kOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        job.category,
                        style: const TextStyle(
                          color: _kOrange,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

// ─── My Job Card ──────────────────────────────────────────────────────────────
class _MyJobCard extends StatelessWidget {
  final Job job;
  final int index;
  final bool isDark;

  const _MyJobCard({
    required this.job,
    required this.index,
    required this.isDark,
  });

  String _asset(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('hair')) return 'assets/images/hair.png';
    if (c.contains('electric')) return 'assets/images/cable.png';
    if (c.contains('plumb')) return 'assets/images/tap.png';
    return 'assets/images/home.png';
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF2C1F18) : Colors.white;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 80).clamp(0, 300)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - v)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: GestureDetector(
          onTap: () => context.go('/dashboard/applications'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    _asset(job.category),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFF5EDE5) : _kBrown,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: _kBrownMid,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            job.location,
                            style: const TextStyle(
                              color: _kBrownMid,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _kOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(
                      color: _kOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Post Job Prompt ──────────────────────────────────────────────────────────
class _PostJobPrompt extends StatelessWidget {
  final bool isDark;
  const _PostJobPrompt({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/dashboard/post-job'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C1F18) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBrownLight.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _kOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_circle_outline_rounded,
                color: _kOrange,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Post Your First Job',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFF5EDE5) : _kBrown,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Tap to post a job and find skilled workers',
                    style: TextStyle(color: _kBrownMid, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _kOrange, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isDark;

  const _EmptyState({
    required this.message,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: _kBrownLight),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(color: _kBrownMid, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Header Widget ───────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  final String displayName;
  final String greeting;
  final int pendingApps;
  final int unreadNotifications;
  final File? profileImageFile;
  final VoidCallback onAvatarTap;
  final VoidCallback onBellTap;

  const _HomeHeader({
    required this.displayName,
    required this.greeting,
    required this.pendingApps,
    required this.unreadNotifications,
    required this.profileImageFile,
    required this.onAvatarTap,
    required this.onBellTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final firstName = displayName.isNotEmpty
        ? displayName.split(' ').first
        : 'there';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE86E00), _kOrange, Color(0xFFFF9A3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(top: topPadding),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onAvatarTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: profileImageFile != null
                      ? Image.file(profileImageFile!, fit: BoxFit.cover)
                      : Image.asset(
                          'assets/images/profile.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Hey, $firstName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        child: const Text(
                          '👋',
                          style: TextStyle(fontSize: 16, height: 1.2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBellTap,
                borderRadius: BorderRadius.circular(22),
                splashColor: Colors.white.withValues(alpha: 0.25),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (unreadNotifications > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              unreadNotifications > 9
                                  ? '9+'
                                  : '$unreadNotifications',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
