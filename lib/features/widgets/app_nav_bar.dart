import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

const _kOrange   = Color(0xFFF77705);
const _kBrownMid = Color(0xFF9E7047);

class AppNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;
  final int notificationCount;

  const AppNavBar({
    super.key,
    required this.selectedIndex,
    this.onTap,
    this.notificationCount = 0,
  });

  void _defaultOnTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/dashboard/home'); break;
      case 1: context.go('/dashboard/jobs'); break;
      case 2: context.go('/dashboard/post-job'); break;
      case 3: context.go('/dashboard/applications'); break;
      case 4: context.go('/dashboard/settings'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1210) : Colors.white;
    final handler = onTap ?? (i) => _defaultOnTap(context, i);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                sel: selectedIndex,
                onTap: handler,
                badge: notificationCount,
              ),
              _NavItem(icon: Icons.work_rounded,        label: 'Jobs',    index: 1, sel: selectedIndex, onTap: handler),
              _PostButton(onTap: () {
                HapticFeedback.mediumImpact();
                handler(2);
              }),
              _NavItem(icon: Icons.description_rounded, label: 'Applied', index: 3, sel: selectedIndex, onTap: handler),
              _NavItem(icon: Icons.person_rounded,      label: 'Profile', index: 4, sel: selectedIndex, onTap: handler),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final int sel;
  final ValueChanged<int> onTap;
  final int badge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.sel,
    required this.onTap,
    this.badge = 0,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.sel == widget.index;

    return Expanded(
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                width: isSelected ? 44 : 0,
                height: 3,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: _kOrange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      widget.icon,
                      size: 22,
                      color: isSelected ? _kOrange : _kBrownMid,
                    ),
                  ),
                  if (widget.badge > 0)
                    Positioned(
                      top: -5,
                      right: -8,
                      child: AnimatedScale(
                        scale: widget.badge > 0 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              widget.badge > 9 ? '9+' : '${widget.badge}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? _kOrange : _kBrownMid,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PostButton({required this.onTap});

  @override
  State<_PostButton> createState() => _PostButtonState();
}

class _PostButtonState extends State<_PostButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kOrange, Color(0xFFFF9A3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kOrange.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
