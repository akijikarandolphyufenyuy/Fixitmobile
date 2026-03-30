import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/notification_item.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/notifications_repository.dart';
import '../widgets/app_nav_bar.dart';

const _kOrange      = Color(0xFFF77705);
const _kOrangeDark  = Color(0xFFE86E00);
const _kOrangeLight = Color(0xFFFF9A3C);
const _kBrown       = Color(0xFF1C110C);
const _kBrownMid    = Color(0xFF9E7047);
const _kCream       = Color(0xFFFCF9F7);
const _kBrownLight  = Color(0xFFE8D8CE);

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  final _repo = NotificationsRepository();
  final _auth = AuthRepository.instance;

  late AnimationController _headerCtrl;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;

  String _filter = 'All';

  double get _headerHeight {
    final topPadding = WidgetsBinding.instance.platformDispatcher.views.first
            .padding.top /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return topPadding + 72;
  }

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  String? get _uid => _auth.currentUser?.id;

  Future<void> _markAllRead() async {
    if (_uid == null) return;
    HapticFeedback.lightImpact();
    await _repo.markAllAsRead(_uid!);
  }

  Future<void> _clearAll() async {
    if (_uid == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Clear all notifications?',
            style: TextStyle(
                color: _kBrown, fontWeight: FontWeight.w700, fontSize: 16)),
        content: const Text(
            'All notifications will be permanently deleted.',
            style: TextStyle(color: _kBrownMid, fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: _kBrownMid))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear all',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok == true) {
      HapticFeedback.mediumImpact();
      await _repo.clearAll(_uid!);
    }
  }

  List<AppNotification> _applyFilter(List<AppNotification> all) {
    switch (_filter) {
      case 'Unread':
        return all.where((n) => !n.isRead).toList();
      case 'Jobs':
        return all.where((n) => n.type == NotificationType.job).toList();
      case 'Apps':
        return all
            .where((n) => n.type == NotificationType.application)
            .toList();
      case 'System':
        return all.where((n) => n.type == NotificationType.system).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid    = _uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF1A1210) : _kCream;

    if (uid == null) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(child: Text('Not logged in')),
        bottomNavigationBar: const AppNavBar(selectedIndex: 0),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<List<AppNotification>>(
        stream: _repo.streamNotifications(uid),
        builder: (context, snap) {
          final all      = snap.data ?? [];
          final unread   = all.where((n) => !n.isRead).length;
          final filtered = _applyFilter(all);
          final loading  =
              snap.connectionState == ConnectionState.waiting && all.isEmpty;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Sticky header matching design system ───────────────────
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
                  child: _NotifHeader(
                    slideAnim: _headerSlide,
                    unreadCount: unread,
                    hasItems: all.isNotEmpty,
                    onMarkAllRead: _markAllRead,
                    onClearAll: _clearAll,
                  ),
                ),
              ),

              // ── Filter tab bar ─────────────────────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterDelegate(
                  selected: _filter,
                  counts: {
                    'All':    all.length,
                    'Unread': all.where((n) => !n.isRead).length,
                    'Jobs':   all.where((n) => n.type == NotificationType.job).length,
                    'Apps':   all.where((n) => n.type == NotificationType.application).length,
                    'System': all.where((n) => n.type == NotificationType.system).length,
                  },
                  isDark: isDark,
                  onSelect: (f) => setState(() => _filter = f),
                ),
              ),

              // ── Content ────────────────────────────────────────────────
              if (loading)
                const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: _kOrange, strokeWidth: 2.5)),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(filter: _filter, isDark: isDark),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _NotifCard(
                        notification: filtered[i],
                        index: i,
                        isDark: isDark,
                        onTap: () async {
                          if (!filtered[i].isRead &&
                              filtered[i].id != null) {
                            await _repo.markAsRead(filtered[i].id!);
                          }
                        },
                        onDelete: () async {
                          if (filtered[i].id != null) {
                            HapticFeedback.lightImpact();
                            await _repo
                                .deleteNotification(filtered[i].id!);
                          }
                        },
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<List<AppNotification>>(
        stream: _repo.streamNotifications(uid),
        builder: (_, snap) {
          final count =
              (snap.data ?? []).where((n) => !n.isRead).length;
          return AppNavBar(selectedIndex: 0, notificationCount: count);
        },
      ),
    );
  }
}

// ─── Header — matches applications_page / home_page pattern exactly ───────────
class _NotifHeader extends StatelessWidget {
  final Animation<Offset> slideAnim;
  final int unreadCount;
  final bool hasItems;
  final VoidCallback onMarkAllRead;
  final VoidCallback onClearAll;

  const _NotifHeader({
    required this.slideAnim,
    required this.unreadCount,
    required this.hasItems,
    required this.onMarkAllRead,
    required this.onClearAll,
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
          // Transparent image overlay — same pattern as other pages
          Positioned(
            right: -10,
            bottom: -4,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/nn.png',
                height: 82,
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
                  // Back button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.go('/dashboard/home'),
                      borderRadius: BorderRadius.circular(22),
                      splashColor: Colors.white.withValues(alpha: 0.25),
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Activity',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.80),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              height: 1.1),
                        ),
                        const Text(
                          'Notifications',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              height: 1.2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Action buttons — mark read + clear
                  if (hasItems) ...[
                    _IconBtn(
                      icon: Icons.done_all_rounded,
                      tooltip: 'Mark all read',
                      onTap: onMarkAllRead,
                      badge: unreadCount,
                    ),
                    const SizedBox(width: 8),
                    _IconBtn(
                      icon: Icons.delete_sweep_rounded,
                      tooltip: 'Clear all',
                      onTap: onClearAll,
                    ),
                  ] else
                    // Bell icon when no items
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1),
                      ),
                      child: const Icon(Icons.notifications_rounded,
                          color: Colors.white, size: 20),
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

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int badge;

  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: Colors.white.withValues(alpha: 0.25),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25), width: 1),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            if (badge > 0)
              Positioned(
                top: -2, right: -2,
                child: Container(
                  width: 17, height: 17,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800),
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

// ─── Pinned filter bar ────────────────────────────────────────────────────────
class _FilterDelegate extends SliverPersistentHeaderDelegate {
  final String selected;
  final Map<String, int> counts;
  final bool isDark;
  final ValueChanged<String> onSelect;

  const _FilterDelegate({
    required this.selected,
    required this.counts,
    required this.isDark,
    required this.onSelect,
  });

  @override double get minExtent => 54;
  @override double get maxExtent => 54;

  @override
  bool shouldRebuild(_FilterDelegate old) =>
      old.selected != selected ||
      old.counts != counts ||
      old.isDark != isDark;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final bg = isDark ? const Color(0xFF1A1210) : _kCream;
    final shadow = overlapsContent
        ? [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ]
        : <BoxShadow>[];

    return Container(
      color: bg,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          boxShadow: shadow,
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: counts.entries.map((e) {
            final isSel = e.key == selected;
            return GestureDetector(
              onTap: () => onSelect(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSel
                      ? _kOrange
                      : (isDark
                          ? const Color(0xFF2C1F18)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSel
                        ? _kOrange
                        : _kBrownLight.withValues(alpha: 0.7),
                  ),
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                              color: _kOrange.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      e.key,
                      style: TextStyle(
                        color: isSel ? Colors.white : _kBrownMid,
                        fontSize: 12,
                        fontWeight: isSel
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    if (e.value > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSel
                              ? Colors.white.withValues(alpha: 0.28)
                              : _kOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${e.value}',
                          style: TextStyle(
                            color: isSel ? Colors.white : _kOrange,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Notification Card ────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final AppNotification notification;
  final int index;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotifCard({
    required this.notification,
    required this.index,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.job:         return Icons.work_rounded;
      case NotificationType.application: return Icons.description_rounded;
      case NotificationType.message:     return Icons.chat_bubble_rounded;
      case NotificationType.system:      return Icons.info_rounded;
    }
  }

  Color get _color {
    switch (notification.type) {
      case NotificationType.job:         return _kOrange;
      case NotificationType.application: return const Color(0xFF0A8F6E);
      case NotificationType.message:     return const Color(0xFF2C7BE5);
      case NotificationType.system:      return _kBrownMid;
    }
  }

  String get _typeLabel {
    final n = notification.type.name;
    return n[0].toUpperCase() + n.substring(1);
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24)   return '${d.inHours}h ago';
    if (d.inDays < 7)     return '${d.inDays}d ago';
    return '${(d.inDays / 7).floor()}w ago';
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final cardBg = isDark
        ? (isUnread
            ? const Color(0xFF2C1F18)
            : const Color(0xFF221710))
        : (isUnread ? const Color(0xFFFFF5EC) : Colors.white);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration:
          Duration(milliseconds: 280 + (index * 45).clamp(0, 220)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
            offset: Offset(0, 16 * (1 - v)), child: child),
      ),
      child: Dismissible(
        key: ValueKey(notification.id ?? '$index'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 22),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_rounded, color: Colors.white, size: 22),
              SizedBox(height: 3),
              Text('Delete',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        confirmDismiss: (_) async {
          onDelete();
          return false;
        },
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isUnread
                    ? _kOrange.withValues(alpha: 0.3)
                    : _kBrownLight.withValues(
                        alpha: isDark ? 0.12 : 0.5),
                width: isUnread ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isUnread
                      ? _kOrange.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon bubble
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: isUnread
                          ? _color
                          : _color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      boxShadow: isUnread
                          ? [
                              BoxShadow(
                                  color:
                                      _color.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3))
                            ]
                          : null,
                    ),
                    child: Icon(_icon,
                        color:
                            isUnread ? Colors.white : _color,
                        size: 20),
                  ),
                  const SizedBox(width: 12),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFF5EDE5)
                                      : _kBrown,
                                  fontSize: 14,
                                  fontWeight: isUnread
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            if (isUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8, height: 8,
                                margin:
                                    const EdgeInsets.only(top: 4),
                                decoration: const BoxDecoration(
                                    color: _kOrange,
                                    shape: BoxShape.circle),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFBB9070)
                                : _kBrownMid,
                            fontSize: 13,
                            height: 1.45,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Footer
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 11,
                                color: isDark
                                    ? const Color(0xFF9E7047)
                                    : _kBrownMid),
                            const SizedBox(width: 3),
                            Text(
                              _timeAgo(notification.createdAt),
                              style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF9E7047)
                                      : _kBrownMid,
                                  fontSize: 11),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    _color.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Text(
                                _typeLabel,
                                style: TextStyle(
                                    color: _color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filter;
  final bool isDark;
  const _EmptyState({required this.filter, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isAll = filter == 'All';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: _kOrange.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_rounded,
                size: 46, color: _kOrange),
          ),
          const SizedBox(height: 24),
          Text(
            isAll ? 'No notifications yet' : 'No $filter notifications',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFFF5EDE5) : _kBrown,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isAll
                ? "You're all caught up!\nNew notifications will appear here."
                : 'Nothing here yet in this category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFF9E7047) : _kBrownMid,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
