import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/job.dart';
import '../../data/repositories/jobs_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/app_nav_bar.dart';

const _kOrange      = Color(0xFFF77705);
const _kOrangeDark  = Color(0xFFE86E00);
const _kOrangeLight = Color(0xFFFF9A3C);
const _kBrown       = Color(0xFF1C110C);
const _kBrownMid    = Color(0xFF9E7047);
const _kCream       = Color(0xFFFCF9F7);
const _kCreamDark   = Color(0xFFF4EDE5);
const _kBrownLight  = Color(0xFFE8D8CE);

class ViewJobsPage extends StatefulWidget {
  const ViewJobsPage({super.key});

  @override
  State<ViewJobsPage> createState() => _ViewJobsPageState();
}

class _ViewJobsPageState extends State<ViewJobsPage> with SingleTickerProviderStateMixin {
  final JobsRepository _jobsRepository = JobsRepository();
  bool _isLoadingJobs = true;

  String jobTypeFilter = '';
  bool sortByPayRange = false;

  List<Job> allJobs = [];
  List<Job> filteredJobs = [];
  String? _userProfession;
  List<String> _userSkills = [];
  final Set<String> _unlockedJobIds = {};

  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  final TextEditingController _searchController = TextEditingController();

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
    _loadJobs();
    _headerCtrl.forward();
  }

  Future<void> _loadUserProfile() async {
    final uid = AuthRepository.instance.currentUser?.id;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!mounted) return;
      final data = doc.data() ?? {};
      setState(() {
        _userProfession = (data['profession'] as String? ?? '').toLowerCase().trim();
        final raw = data['skills'];
        if (raw is List) {
          _userSkills = raw.map((e) => e.toString().toLowerCase().trim()).toList();
        } else if (raw is String) {
          _userSkills = raw.split(',').map((e) => e.toLowerCase().trim()).where((e) => e.isNotEmpty).toList();
        }
      });
    } catch (_) {}
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoadingJobs = true);
    await _loadUserProfile();
    final jobs = await _jobsRepository.getAllJobs();
    if (!mounted) return;
    // Filter: only show jobs matching user's profession or skills
    final matched = jobs.where((j) {
      if (_userProfession == null || _userProfession!.isEmpty) return true;
      final cat = j.category.toLowerCase().trim();
      final prof = _userProfession!.toLowerCase().trim();
      // Direct match
      if (cat == prof) return true;
      // One contains the other
      if (cat.contains(prof) || prof.contains(cat)) return true;
      // Stem match (first 4 chars)
      if (cat.length >= 4 && prof.length >= 4 && cat.substring(0, 4) == prof.substring(0, 4)) return true;
      // Skills match
      return _userSkills.any((s) {
        final skill = s.toLowerCase().trim();
        if (cat == skill) return true;
        if (cat.contains(skill) || skill.contains(cat)) return true;
        if (cat.length >= 4 && skill.length >= 4 && cat.substring(0, 4) == skill.substring(0, 4)) return true;
        return false;
      });
    }).toList();
    setState(() {
      allJobs = matched;
      filteredJobs = matched;
      _isLoadingJobs = false;
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      List<Job> temp = List.from(allJobs);
      if (jobTypeFilter.isNotEmpty) {
        final q = jobTypeFilter.toLowerCase();
        temp = temp.where((j) =>
          j.title.toLowerCase().contains(q) ||
          j.category.toLowerCase().contains(q) ||
          j.location.toLowerCase().contains(q)).toList();
      }
      temp.sort((a, b) => sortByPayRange
          ? b.title.toLowerCase().compareTo(a.title.toLowerCase())
          : a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      filteredJobs = temp;
    });
  }

  void _onApplyPressed(Job job) {
    context.go('/dashboard/apply-jobs', extra: {'jobId': job.id, 'jobTitle': job.title});
  }

  void _onViewFullDetails(Job job) {
    if (_unlockedJobIds.contains(job.id)) {
      _showJobDetailsSheet(job);
      return;
    }
    context.push('/payment', extra: <String, dynamic>{
      'purpose': 'view_job',
      'amount': 500,
      'jobTitle': job.title,
      'onSuccess': () async {
        context.pop();
        await Future.delayed(Duration.zero);
        if (!mounted) return;
        setState(() => _unlockedJobIds.add(job.id ?? ''));
        _showJobDetailsSheet(job);
      },
    });
  }

  void _showJobDetailsSheet(Job job) {
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _JobDetailsSheet(job: job, onApply: () {
          context.pop();
          _onApplyPressed(job);
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
              child: _JobsHeader(
                onBack: () => context.go('/dashboard/home'),
                slideAnim: _headerSlide,
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Builder(builder: (context) {
                final theme = Theme.of(context);
                return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredJobs.length} Jobs Found',
                    style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => sortByPayRange = !sortByPayRange);
                      _applyFilters();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sortByPayRange ? _kOrange : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            sortByPayRange ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                            size: 14,
                            color: sortByPayRange ? Colors.white : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sortByPayRange ? 'Z → A' : 'A → Z',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: sortByPayRange ? Colors.white : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
              }),
            ),
          ),
          _isLoadingJobs
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: _kOrange)))
              : filteredJobs.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('No jobs found', style: TextStyle(color: _kBrownMid, fontSize: 15))))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildJobCard(filteredJobs[index], index),
                        childCount: filteredJobs.length,
                      ),
                    ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      bottomNavigationBar: const AppNavBar(selectedIndex: 1),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Search by title, category, location...',
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: _kOrange, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (v) {
            jobTypeFilter = v;
            _applyFilters();
          },
        ),
      ),
    );
  }

  Widget _buildJobCard(Job job, int index) {
    final theme = Theme.of(context);
    String assetForCategory(String cat) {
      final c = cat.toLowerCase();
      if (c.contains('hair')) return 'assets/images/hair.png';
      if (c.contains('electric')) return 'assets/images/cable.png';
      if (c.contains('plumb')) return 'assets/images/tap.png';
      return 'assets/images/home.png';
    }

    final isUnlocked = _unlockedJobIds.contains(job.id);
    final expiry = job.expiresAt;
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final expiryStr = expiry != null
        ? '${months[expiry.month - 1]} ${expiry.day}, ${expiry.year}'
        : null;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 50).clamp(0, 350)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, 24 * (1 - value)), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
            ],
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
                      child: Image.asset(assetForCategory(job.category), width: 70, height: 70, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job.title,
                              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w700),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(job.description,
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _tag(Icons.category_rounded, job.category, true),
                              if (job.payRange != null)
                                _tag(Icons.payments_rounded, job.payRange!, false),
                              if (expiryStr != null)
                                _tag(Icons.calendar_today_rounded, expiryStr, false),
                              isUnlocked
                                  ? _tag(Icons.location_on_rounded, job.location, false)
                                  : _lockedTag(Icons.location_on_rounded, 'Location hidden'),
                              isUnlocked
                                  ? _tag(Icons.phone_rounded, job.contact ?? 'N/A', false)
                                  : _lockedTag(Icons.phone_rounded, 'Contact hidden'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _onViewFullDetails(job),
                        icon: Icon(
                          isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                          size: 16,
                          color: isUnlocked ? Colors.green : _kOrange,
                        ),
                        label: Text(
                          isUnlocked ? 'View Details' : 'Unlock · 500 FCFA',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isUnlocked ? Colors.green : _kOrange,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isUnlocked ? Colors.green : _kOrange),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kOrangeDark, _kOrange, _kOrangeLight],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: _kOrange.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _onApplyPressed(job),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Apply Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
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

  Widget _tag(IconData icon, String label, bool isPrimary) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary ? _kOrange.withValues(alpha: 0.12) : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isPrimary ? _kOrange : cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: isPrimary ? _kOrange : cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _lockedTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Icon(Icons.lock_rounded, size: 10, color: Colors.grey.shade400),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

// ─── Jobs Header ──────────────────────────────────────────────────────────────
class _JobsHeader extends StatelessWidget {
  final VoidCallback onBack;
  final Animation<Offset> slideAnim;

  const _JobsHeader({required this.onBack, required this.slideAnim});

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
            right: -10,
            bottom: -4,
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                'assets/images/Job offers-rafiki.png',
                height: 90,
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
                        Text('Browse', style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 11, fontWeight: FontWeight.w400, height: 1.1)),
                        const Text('Available Jobs',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3, height: 1.2)),
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
                    child: const Icon(Icons.work_outline_rounded, color: Colors.white, size: 20),
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

// ─── Job Details Sheet (shown after payment) ──────────────────────────────────
class _JobDetailsSheet extends StatelessWidget {
  final Job job;
  final VoidCallback onApply;

  const _JobDetailsSheet({required this.job, required this.onApply});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final expiry = job.expiresAt;
    final expiryStr = expiry != null
        ? '${months[expiry.month - 1]} ${expiry.day}, ${expiry.year}'
        : 'No expiry set';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_open_rounded, color: Colors.green, size: 13),
                    SizedBox(width: 4),
                    Text('Unlocked', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.pop(),
                child: Icon(Icons.close_rounded, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(job.title,
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(job.description,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14, height: 1.5)),
          const SizedBox(height: 20),
          _detailRow(Icons.category_rounded, 'Category', job.category, theme),
          _detailRow(Icons.location_on_rounded, 'Location', job.location, theme),
          if (job.payRange != null)
            _detailRow(Icons.payments_rounded, 'Pay Range', job.payRange!, theme),
          _detailRow(Icons.calendar_today_rounded, 'Expires', expiryStr, theme),
          if (job.contact != null)
            _detailRow(Icons.phone_rounded, 'Contact', job.contact!, theme),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kOrangeDark, _kOrange, _kOrangeLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: _kOrange.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 5))],
              ),
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Apply for this Job', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w500)),
                Text(value, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
