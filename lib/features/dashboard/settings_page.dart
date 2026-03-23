import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/app_nav_bar.dart';

typedef ToggleThemeCallback = void Function();
typedef ChangeLanguageCallback = void Function(String languageCode);

class SettingsPage extends StatefulWidget {
  final ToggleThemeCallback? onToggleTheme;
  final ChangeLanguageCallback? onChangeLanguage;
  final String currentLanguageCode;

  const SettingsPage({
    super.key,
    this.onToggleTheme,
    this.onChangeLanguage,
    this.currentLanguageCode = 'en',
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _location;
  late String _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    _location = 'Not set';
    _selectedLanguageCode = widget.currentLanguageCode;
  }

  void _editLocation() {
    final controller = TextEditingController(text: _location == 'Not set' ? '' : _location);
    showDialog(
      context: context,
      builder: (ctx) => _ProfessionalDialog(
        title: 'Update Location',
        icon: Icons.location_on_rounded,
        iconColor: const Color(0xFF6C63FF),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your city or region',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        onConfirm: () {
          setState(() => _location = controller.text.trim().isEmpty ? 'Not set' : controller.text.trim());
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _selectLanguage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Text('Select Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: scheme.onSurface)),
              const SizedBox(height: 16),
              _LanguageOption(
                label: 'English',
                flag: '🇬🇧',
                isSelected: _selectedLanguageCode == 'en',
                onTap: () {
                  setState(() => _selectedLanguageCode = 'en');
                  widget.onChangeLanguage?.call('en');
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
              _LanguageOption(
                label: 'Français',
                flag: '🇫🇷',
                isSelected: _selectedLanguageCode == 'fr',
                onTap: () {
                  setState(() => _selectedLanguageCode = 'fr');
                  widget.onChangeLanguage?.call('fr');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ProfessionalDialog(
        title: 'Sign Out',
        icon: Icons.logout_rounded,
        iconColor: Colors.red,
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant, fontSize: 14),
        ),
        confirmLabel: 'Sign Out',
        confirmColor: Colors.red,
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e'), backgroundColor: Colors.red));
    }
  }

  double get _headerHeight {
    final topPadding = WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return topPadding + 72;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langLabel = _selectedLanguageCode == 'fr' ? 'Français' : 'English';

    return Scaffold(
      backgroundColor: scheme.surface,
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
            flexibleSpace: _SettingsHeader(
              onBack: () => context.go('/dashboard/home'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: 'Account'),
                  _SettingsCard(children: [
                    _SettingsTile(
                      icon: Icons.person_rounded,
                      gradient: [const Color(0xFF6C63FF), const Color(0xFF9B8FFF)],
                      title: 'Personal Information',
                      onTap: () => context.go('/dashboard/my-cv'),
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.workspace_premium_rounded,
                      gradient: [const Color(0xFFFF6B35), const Color(0xFFFF8E53)],
                      title: 'Subscription',
                      onTap: () => context.go('/dashboard/subscription'),
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.lock_rounded,
                      gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                      title: 'Security',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Security settings'))),
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.notifications_rounded,
                      gradient: [const Color(0xFFEB3349), const Color(0xFFF45C43)],
                      title: 'Notifications',
                      onTap: () => context.go('/dashboard/notifications'),
                    ),
                  ]),
                  _SectionLabel(label: 'Preferences'),
                  _SettingsCard(children: [
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      gradient: [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
                      title: 'Language',
                      trailing: Text(langLabel, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
                      onTap: _selectLanguage,
                    ),
                    _SettingsDivider(),
                    _DarkModeTile(
                      isDark: isDark,
                      onToggle: () => widget.onToggleTheme?.call(),
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.location_on_rounded,
                      gradient: [const Color(0xFF6C63FF), const Color(0xFF9B8FFF)],
                      title: 'Location',
                      trailing: Text(_location, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
                      onTap: _editLocation,
                    ),
                  ]),
                  _SectionLabel(label: 'Support'),
                  _SettingsCard(children: [
                    _SettingsTile(
                      icon: Icons.help_rounded,
                      gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                      title: 'Help Center',
                      onTap: () => context.go('/dashboard/fixit-assistance'),
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.feedback_rounded,
                      gradient: [const Color(0xFFFF6B35), const Color(0xFFFF8E53)],
                      title: 'Send Feedback',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback'))),
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.info_rounded,
                      gradient: [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
                      title: 'About Fixit',
                      onTap: () => context.go('/dashboard/about'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _SettingsCard(children: [
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      gradient: [const Color(0xFFEB3349), const Color(0xFFF45C43)],
                      title: 'Sign Out',
                      titleColor: Colors.red,
                      onTap: _onLogout,
                      showArrow: false,
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppNavBar(selectedIndex: 4),
    );
  }

}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool showArrow;

  const _SettingsTile({
    required this.icon,
    required this.gradient,
    required this.title,
    this.titleColor,
    this.trailing,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? scheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
            if (showArrow) Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DarkModeTile extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _DarkModeTile({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gradient = isDark
        ? const LinearGradient(colors: [Color(0xFF1a1a2e), Color(0xFF16213e)], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : const LinearGradient(colors: [Color(0xFFFFB347), Color(0xFFFFCC02)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('Dark Mode', style: TextStyle(color: scheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          Switch.adaptive(
            value: isDark,
            onChanged: (_) => onToggle(),
            activeThumbColor: scheme.primary,
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({required this.label, required this.flag, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? Border.all(color: scheme.primary, width: 1.5) : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: scheme.onSurface)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle_rounded, color: scheme.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget content;
  final String confirmLabel;
  final Color? confirmColor;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const _ProfessionalDialog({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.content,
    this.confirmLabel = 'Confirm',
    this.confirmColor,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 24),
            Row(
              children: [
                if (onCancel != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor ?? scheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Settings Header Widget ────────────────────────────────────────────────────
class _SettingsHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _SettingsHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE86E00), Color(0xFFF77705), Color(0xFFFF9A3C)],
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
                  Text('Account', style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 12, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 2),
                  const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3, height: 1.1)),
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
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
