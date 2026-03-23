import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../widgets/app_nav_bar.dart';

const _kOrange      = Color(0xFFF77705);
const _kOrangeDark  = Color(0xFFE86E00);
const _kOrangeLight = Color(0xFFFF9A3C);
const _kBrown       = Color(0xFF1C110C);
const _kBrownMid    = Color(0xFF9E7047);
const _kCream       = Color(0xFFFCF9F7);
const _kCreamDark   = Color(0xFFF4EDE5);
const _kBrownLight  = Color(0xFFE8D8CE);

class MyCvPage extends StatefulWidget {
  const MyCvPage({super.key});

  @override
  State<MyCvPage> createState() => _MyCvPageState();
}

class _MyCvPageState extends State<MyCvPage> with SingleTickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  bool _loading = true;
  bool _uploadingPhoto = false;
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _location = '';
  String _profession = '';
  String _language = 'English';
  String? _photoUrl;

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
    _headerCtrl.forward();
    _loadProfile();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) { if (mounted) setState(() => _loading = false); return; }

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!mounted) return;

      if (doc.exists) {
        final d = doc.data()!;
        final firstName = d['firstName'] as String? ?? '';
        final lastName  = d['lastName']  as String? ?? '';
        setState(() {
          _fullName   = '$firstName $lastName'.trim();
          _email      = d['email']      as String? ?? user.email ?? '';
          _phone      = d['phone']      as String? ?? '';
          _location   = d['location']   as String? ?? '';
          _profession = d['profession'] as String? ?? '';
          _language   = (d['language']  as String? ?? 'en') == 'fr' ? 'Français' : 'English';
          _photoUrl   = d['photoUrl']   as String?;
          _loading    = false;
        });
      } else {
        setState(() {
          _email    = user.email ?? '';
          _fullName = user.displayName ?? '';
          _loading  = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos/${user.uid}.jpg');
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'photoUrl': url});

      if (!mounted) return;
      setState(() => _photoUrl = url);
      _showSnack('Profile photo updated', isError: false);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to upload photo', isError: true);
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: 'Reset Password',
        icon: Icons.lock_reset_rounded,
        iconColor: _kOrange,
        message: 'We\'ll send a password reset link to\n${user.email}',
        confirmLabel: 'Send Link',
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      if (!mounted) return;
      _showSnack('Reset link sent to ${user.email}', isError: false);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to send reset email', isError: true);
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
              child: _ProfileHeader(
                onBack: () => context.go('/dashboard/settings'),
                slideAnim: _headerSlide,
              ),
            ),
          ),
          _loading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: _kOrange)))
              : SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvatarSection(),
                        const SizedBox(height: 28),
                        _buildSectionLabel('Personal Information'),
                        const SizedBox(height: 12),
                        _buildInfoCard(),
                        const SizedBox(height: 28),
                        _buildSectionLabel('Account'),
                        const SizedBox(height: 12),
                        _buildAccountCard(),
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

  // ── Avatar ───────────────────────────────────────────────────────────────────
  Widget _buildAvatarSection() {
    final initials = _fullName.isNotEmpty
        ? _fullName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child)),
      child: Center(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_kOrangeDark, _kOrange, _kOrangeLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [BoxShadow(color: _kOrange.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 6))],
                    image: _photoUrl != null
                        ? DecorationImage(image: NetworkImage(_photoUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _photoUrl == null
                      ? Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)))
                      : null,
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: GestureDetector(
                    onTap: _uploadingPhoto ? null : _uploadPhoto,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: _kBrown,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _uploadingPhoto
                          ? const Padding(
                              padding: EdgeInsets.all(6),
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _fullName.isNotEmpty ? _fullName : 'Your Name',
              style: const TextStyle(color: _kBrown, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
            if (_profession.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: _kOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_profession, style: const TextStyle(color: _kOrange, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Info Card ────────────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            _infoRow(Icons.person_rounded, 'Full Name', _fullName.isNotEmpty ? _fullName : '—'),
            _divider(),
            _infoRow(Icons.email_rounded, 'Email', _email.isNotEmpty ? _email : '—'),
            _divider(),
            _infoRow(Icons.phone_rounded, 'Phone', _phone.isNotEmpty ? _phone : '—'),
            _divider(),
            _infoRow(Icons.location_on_rounded, 'Location', _location.isNotEmpty ? _location : '—'),
            _divider(),
            _infoRow(Icons.language_rounded, 'Language', _language),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: _kBrownMid, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: _kBrown, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.only(left: 68),
    child: Divider(height: 1, color: _kBrownLight.withValues(alpha: 0.6)),
  );

  // ── Account Card ─────────────────────────────────────────────────────────────
  Widget _buildAccountCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            _actionRow(
              icon: Icons.lock_reset_rounded,
              gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
              label: 'Change Password',
              subtitle: 'Send a reset link to your email',
              onTap: _changePassword,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionRow({
    required IconData icon,
    required List<Color> gradient,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: _kBrown, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: _kBrownMid, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _kBrownMid, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(color: _kBrownMid, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final VoidCallback onBack;
  final Animation<Offset> slideAnim;

  const _ProfileHeader({required this.onBack, required this.slideAnim});

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
          Positioned(
            right: -8, bottom: -6,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/profile.png', height: 85, fit: BoxFit.contain),
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
                        Text('My Account', style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 12, fontWeight: FontWeight.w400)),
                        const SizedBox(height: 2),
                        const Text('Personal Information',
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
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
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

// ─── Confirm Dialog ───────────────────────────────────────────────────────────
class _ConfirmDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmDialog({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kBrown)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _kBrownMid, fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: _kBrownLight),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: _kBrownMid)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_kOrangeDark, _kOrangeLight]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
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
