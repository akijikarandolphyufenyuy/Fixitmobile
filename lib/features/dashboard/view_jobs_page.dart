import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/job.dart';
import '../../data/repositories/jobs_repository.dart';
import '../widgets/app_nav_bar.dart';

const _kOrange      = Color(0xFFF77705);
const _kOrangeDark  = Color(0xFFE86E00);
const _kOrangeLight = Color(0xFFFF9A3C);
const _kBrown       = Color(0xFF1C110C);
const _kBrownMid    = Color(0xFF9E7047);
const _kCream       = Color(0xFFFCF9F7);
const _kCreamDark   = Color(0xFFF4EDE5);

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

  Future<void> _loadJobs() async {
    setState(() => _isLoadingJobs = true);
    final jobs = await _jobsRepository.getAllJobs();
    if (!mounted) return;
    setState(() {
      allJobs = jobs;
      filteredJobs = jobs;
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredJobs.length} Jobs Found',
                    style: const TextStyle(color: _kBrown, fontSize: 16, fontWeight: FontWeight.w700),
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
                        color: sortByPayRange ? _kOrange : _kCreamDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            sortByPayRange ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                            size: 14,
                            color: sortByPayRange ? Colors.white : _kBrownMid,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sortByPayRange ? 'Z → A' : 'A → Z',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: sortByPayRange ? Colors.white : _kBrownMid,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by title, category, location...',
            hintStyle: TextStyle(color: _kBrownMid, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: _kOrange, size: 22),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    String assetForCategory(String cat) {
      final c = cat.toLowerCase();
      if (c.contains('hair')) return 'assets/images/hair.png';
      if (c.contains('electric')) return 'assets/images/cable.png';
      if (c.contains('plumb')) return 'assets/images/tap.png';
      return 'assets/images/home.png';
    }

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
            color: Colors.white,
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
                              style: const TextStyle(color: _kBrown, fontSize: 16, fontWeight: FontWeight.w700),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(job.description,
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: _kBrownMid, fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _tag(Icons.category_rounded, job.category, true),
                              const SizedBox(width: 6),
                              _tag(Icons.location_on_rounded, job.location, false),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Apply Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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

  Widget _tag(IconData icon, String label, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary ? _kOrange.withValues(alpha: 0.12) : _kCreamDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isPrimary ? _kOrange : _kBrownMid),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: isPrimary ? _kOrange : _kBrownMid)),
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
                        Text('Browse', style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 12, fontWeight: FontWeight.w400)),
                        const SizedBox(height: 2),
                        const Text('Available Jobs',
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
