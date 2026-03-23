import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/application.dart';
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
const _kGreen       = Color(0xFF0A8F6E);

class JobApplicantsPage extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const JobApplicantsPage({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<JobApplicantsPage> createState() => _JobApplicantsPageState();
}

class _JobApplicantsPageState extends State<JobApplicantsPage>
    with SingleTickerProviderStateMixin {
  final _appsRepo = ApplicationsRepository();
  final _firestore = FirebaseFirestore.instance;

  late AnimationController _headerCtrl;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;

  String _filter = 'All'; // All | Pending | Accepted | Declined

  double get _headerHeight {
    final top = WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return top + 140;
  }

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
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

  Future<Map<String, dynamic>> _fetchApplicantProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<void> _updateStatus(Application app, String status) async {
    if (app.id == null) return;
    HapticFeedback.mediumImpact();
    await _appsRepo.updateApplicationStatus(
        applicationId: app.id!, status: status);
  }

  Future<void> _confirmAction(Application app, String status) async {
    final isAccept = status == 'accepted';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAccept ? 'Accept applicant?' : 'Decline applicant?',
          style: const TextStyle(
              color: _kBrown, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          isAccept
              ? 'You are about to accept ${app.applicantName}\'s application.'
              : 'You are about to decline ${app.applicantName}\'s application.',
          style: const TextStyle(color: _kBrownMid, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: _kBrownMid)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isAccept ? 'Accept' : 'Decline',
              style: TextStyle(
                  color: isAccept ? _kGreen : Colors.red.shade400,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) await _updateStatus(app, status);
  }

  List<Application> _applyFilter(List<Application> all) {
    switch (_filter) {
      case 'Pending':  return all.where((a) => a.status == 'pending').toList();
      case 'Accepted': return all.where((a) => a.status == 'accepted').toList();
      case 'Declined': return all.where((a) => a.status == 'rejected').toList();
      default:         return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF1A1210) : _kCream;

    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<List<Application>>(
        stream: _appsRepo.streamApplicationsByJob(widget.jobId),
        builder: (context, snap) {
          final all      = snap.data ?? [];
          final filtered = _applyFilter(all);
          final pending  = all.where((a) => a.status == 'pending').length;

          return CustomScrollView(
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
                  child: _ApplicantsHeader(
                    slideAnim: _headerSlide,
                    jobTitle: widget.jobTitle,
                    total: all.length,
                    pending: pending,
                  ),
                ),
              ),

              // Filter chips
              SliverToBoxAdapter(
                child: _FilterRow(
                  selected: _filter,
                  counts: {
                    'All': all.length,
                    'Pending': all.where((a) => a.status == 'pending').length,
                    'Accepted': all.where((a) => a.status == 'accepted').length,
                    'Declined': all.where((a) => a.status == 'rejected').length,
                  },
                  onSelect: (f) => setState(() => _filter = f),
                ),
              ),

              if (snap.connectionState == ConnectionState.waiting &&
                  all.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: _kOrange, strokeWidth: 2.5)),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                    child: _EmptyApplicants(filter: _filter, isDark: isDark))
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ApplicantCard(
                      application: filtered[i],
                      index: i,
                      isDark: isDark,
                      fetchProfile: _fetchApplicantProfile,
                      onAccept: () => _confirmAction(filtered[i], 'accepted'),
                      onDecline: () => _confirmAction(filtered[i], 'rejected'),
                    ),
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
class _ApplicantsHeader extends StatelessWidget {
  final Animation<Offset> slideAnim;
  final String jobTitle;
  final int total;
  final int pending;

  const _ApplicantsHeader({
    required this.slideAnim,
    required this.jobTitle,
    required this.total,
    required this.pending,
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
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  if (pending > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 7, height: 7,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          Text('$pending pending',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Applicants',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text(
                jobTitle,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                '$total ${total == 1 ? 'person has' : 'people have'} applied',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Filter Row ───────────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final String selected;
  final Map<String, int> counts;
  final ValueChanged<String> onSelect;

  const _FilterRow(
      {required this.selected,
      required this.counts,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: counts.entries.map((e) {
          final sel = e.key == selected;
          return GestureDetector(
            onTap: () => onSelect(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: sel ? _kOrange : _kCreamDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: sel ? _kOrange : _kBrownLight, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.key,
                      style: TextStyle(
                          color: sel ? Colors.white : _kBrownMid,
                          fontSize: 12,
                          fontWeight: sel
                              ? FontWeight.w700
                              : FontWeight.w500)),
                  if (e.value > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: sel
                            ? Colors.white.withValues(alpha: 0.3)
                            : _kOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${e.value}',
                          style: TextStyle(
                              color: sel ? Colors.white : _kOrange,
                              fontSize: 10,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Applicant Card ───────────────────────────────────────────────────────────
class _ApplicantCard extends StatelessWidget {
  final Application application;
  final int index;
  final bool isDark;
  final Future<Map<String, dynamic>> Function(String uid) fetchProfile;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _ApplicantCard({
    required this.application,
    required this.index,
    required this.isDark,
    required this.fetchProfile,
    required this.onAccept,
    required this.onDecline,
  });

  Color get _statusColor {
    switch (application.status) {
      case 'accepted': return _kGreen;
      case 'rejected': return Colors.red.shade400;
      default:         return _kOrange;
    }
  }

  String get _statusLabel {
    switch (application.status) {
      case 'accepted': return 'Accepted';
      case 'rejected': return 'Declined';
      default:         return 'Pending';
    }
  }

  IconData get _statusIcon {
    switch (application.status) {
      case 'accepted': return Icons.check_circle_rounded;
      case 'rejected': return Icons.cancel_rounded;
      default:         return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF2C1F18) : Colors.white;
    final isPending = application.status == 'pending';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 55).clamp(0, 280)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
          opacity: v,
          child:
              Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child)),
      child: FutureBuilder<Map<String, dynamic>>(
        future: fetchProfile(application.applicantId),
        builder: (context, profileSnap) {
          final profile    = profileSnap.data ?? {};
          final firstName  = (profile['firstName'] ?? '').toString();
          final lastName   = (profile['lastName'] ?? '').toString();
          final fullName   = '$firstName $lastName'.trim().isNotEmpty
              ? '$firstName $lastName'.trim()
              : application.applicantName;
          final location   = (profile['location'] ?? '').toString();
          final profession = (profile['profession'] ?? '').toString();
          final skillsRaw  = profile['skills'];
          final skills     = skillsRaw is List
              ? skillsRaw.map((s) => s.toString()).toList()
              : skillsRaw is String && skillsRaw.isNotEmpty
                  ? skillsRaw.split(',').map((s) => s.trim()).toList()
                  : <String>[];

          // Initials avatar
          final initials = [
            if (firstName.isNotEmpty) firstName[0],
            if (lastName.isNotEmpty) lastName[0],
          ].join().toUpperCase();

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isPending
                      ? _kOrange.withValues(alpha: 0.2)
                      : _kBrownLight.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top row: avatar + name + status ──────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Container(
                          width: 52, height: 52,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_kOrangeDark, _kOrangeLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials.isNotEmpty ? initials : '?',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fullName,
                                  style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFF5EDE5)
                                          : _kBrown,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 3),
                              if (profession.isNotEmpty)
                                Text(profession,
                                    style: const TextStyle(
                                        color: _kOrange,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              if (location.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded,
                                        size: 12, color: _kBrownMid),
                                    const SizedBox(width: 3),
                                    Text(location,
                                        style: const TextStyle(
                                            color: _kBrownMid, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon,
                                  size: 12, color: _statusColor),
                              const SizedBox(width: 4),
                              Text(_statusLabel,
                                  style: TextStyle(
                                      color: _statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ── Skills ────────────────────────────────────────────
                    if (skills.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Skills',
                          style: TextStyle(
                              color: _kBrownMid,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: skills
                            .take(6)
                            .map((s) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF3A2A20)
                                        : _kCreamDark,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: _kBrownLight
                                            .withValues(alpha: 0.6)),
                                  ),
                                  child: Text(s,
                                      style: TextStyle(
                                          color: isDark
                                              ? const Color(0xFFBB9070)
                                              : _kBrownMid,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500)),
                                ))
                            .toList(),
                      ),
                    ],

                    // ── Cover letter snippet ──────────────────────────────
                    if (application.coverLetter != null &&
                        application.coverLetter!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3A2A20)
                              : _kCreamDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          application.coverLetter!,
                          style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFBB9070)
                                  : _kBrownMid,
                              fontSize: 12,
                              height: 1.5),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],

                    // ── Action buttons (only for pending) ─────────────────
                    if (isPending) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: onDecline,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.red.shade400, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.close_rounded,
                                        size: 15,
                                        color: Colors.red.shade400),
                                    const SizedBox(width: 6),
                                    Text('Decline',
                                        style: TextStyle(
                                            color: Colors.red.shade400,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: onAccept,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: _kGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_rounded,
                                        size: 15, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text('Accept',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyApplicants extends StatelessWidget {
  final String filter;
  final bool isDark;
  const _EmptyApplicants({required this.filter, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
                color: _kOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child: const Icon(Icons.person_off_rounded,
                size: 40, color: _kOrange),
          ),
          const SizedBox(height: 20),
          Text(
            filter == 'All'
                ? 'No applicants yet'
                : 'No $filter applicants',
            style: TextStyle(
                color: isDark ? const Color(0xFFF5EDE5) : _kBrown,
                fontSize: 18,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            filter == 'All'
                ? 'Applications will appear here'
                : 'No applicants in this category',
            style: const TextStyle(color: _kBrownMid, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
