import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/job.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/jobs_repository.dart';
import '../widgets/app_nav_bar.dart';

const _kOrange = Color(0xFFF77705);
const _kOrangeDark = Color(0xFFE86E00);
const _kOrangeLight = Color(0xFFFF9A3C);
const _kBrown = Color(0xFF1C110C);
const _kBrownMid = Color(0xFF9E7047);
const _kCream = Color(0xFFFCF9F7);
const _kBrownLight = Color(0xFFE8D8CE);

const _kCameroonRegions = [
  'Adamawa',
  'Centre',
  'East',
  'Far North',
  'Littoral',
  'North',
  'North West',
  'South',
  'South West',
  'West',
];

const _kFallbackProfessions = [
  'Plumbing',
  'Electrical',
  'Cleaning',
  'Selling',
  'Hair Dressing',
  'Farming',
  'Carpentry',
  'Building / Masonry',
  'Painting',
  'Welding',
  'Mechanics',
  'Tailoring',
  'Cooking / Catering',
  'Security',
  'Driving',
  'Other',
];

class PostJobPage extends StatefulWidget {
  const PostJobPage({super.key});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage>
    with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _payCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _otherJobTypeCtrl = TextEditingController();

  String? _selectedLocation;
  String? _selectedJobType;
  DateTime? _expiresAt;

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isPosting = false;

  List<String> _jobTypeOptions = [];
  bool _loadingProfessions = true;

  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  double get _headerHeight {
    final topPadding =
        WidgetsBinding.instance.platformDispatcher.views.first.padding.top /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return topPadding + 72;
  }

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerCtrl.forward();
    _loadProfessions();
  }

  Future<void> _loadProfessions() async {
    final fromDb = await JobsRepository().getDistinctProfessions();
    final merged = <String>{};
    // Add fallback list first (minus 'Other'), then DB ones, then 'Other' last
    for (final p in _kFallbackProfessions) {
      if (p != 'Other') merged.add(p);
    }
    for (final p in fromDb) {
      merged.add(_capitalize(p));
    }
    if (mounted) {
      setState(() {
        _jobTypeOptions = [...merged, 'Other'];
        _loadingProfessions = false;
      });
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  void dispose() {
    _headerCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _payCtrl.dispose();
    _contactCtrl.dispose();
    _otherJobTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    XFile? f;
    try {
      f = await _picker.pickImage(source: ImageSource.gallery);
    } catch (_) {
      return;
    }
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    if (f != null) setState(() => _selectedImage = f);
  }

  Future<void> _pickExpiration() async {
    // Step 1: pick date
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kOrange,
            onPrimary: Colors.white,
            onSurface: _kBrown,
          ),
        ),
        child: child!,
      ),
    );
    await Future.delayed(Duration.zero);
    if (date == null || !mounted) return;

    // Step 2: pick time
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kOrange,
            onPrimary: Colors.white,
            onSurface: _kBrown,
          ),
        ),
        child: child!,
      ),
    );
    await Future.delayed(Duration.zero);
    if (time == null || !mounted) return;

    setState(() {
      _expiresAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatExpiration(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  •  $hour:$minute $period';
  }

  Future<void> _onPostJob() async {
    final effectiveJobType = _selectedJobType == 'Other'
        ? _otherJobTypeCtrl.text.trim()
        : _selectedJobType ?? '';

    if (_titleCtrl.text.trim().isEmpty ||
        _descCtrl.text.trim().isEmpty ||
        effectiveJobType.isEmpty ||
        _selectedLocation == null) {
      _showSnack('Please fill in all required fields', isError: true);
      return;
    }

    final postedBy = AuthRepository.instance.currentUser?.id;
    if (postedBy == null || postedBy.isEmpty) {
      _showSnack('Please log in to post a job', isError: true);
      return;
    }

    // Show payment prompt before posting
    _showPaymentPrompt(effectiveJobType, postedBy);
  }

  void _showPaymentPrompt(String jobType, String postedBy) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PostJobPaymentSheet(
        jobTitle: _titleCtrl.text.trim(),
        onPay: () {
          context.pop();
          context.push(
            '/payment',
            extra: <String, dynamic>{
              'purpose': 'post_job',
              'amount': 50,
              'jobTitle': _titleCtrl.text.trim(),
              'onSuccess': () => _doPostJob(jobType, postedBy),
            },
          );
        },
      ),
    );
  }

  Future<void> _doPostJob(String jobType, String postedBy) async {
    setState(() => _isPosting = true);
    try {
      await JobsRepository().postJob(
        Job(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: jobType,
          location: _selectedLocation!,
          postedBy: postedBy,
          expiresAt: _expiresAt,
          payRange: _payCtrl.text.trim().isEmpty ? null : _payCtrl.text.trim(),
          contact: _contactCtrl.text.trim().isEmpty
              ? null
              : _contactCtrl.text.trim(),
        ),
      );
      if (!mounted) return;
      _titleCtrl.clear();
      _descCtrl.clear();
      _payCtrl.clear();
      _contactCtrl.clear();
      _otherJobTypeCtrl.clear();
      setState(() {
        _selectedLocation = null;
        _selectedJobType = null;
        _expiresAt = null;
        _selectedImage = null;
      });
      context.go('/dashboard/my-jobs');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to post job: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
              child: _PostJobHeader(
                onBack: () => context.go('/dashboard/home'),
                slideAnim: _headerSlide,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Field(
                    label: 'Job Title *',
                    hint: 'e.g. Plumber needed urgently',
                    controller: _titleCtrl,
                  ),
                  _buildJobTypeDropdown(),
                  if (_selectedJobType == 'Other') ...[
                    const SizedBox(height: 16),
                    _Field(
                      label: 'Specify Job Type *',
                      hint: 'Describe the job type',
                      controller: _otherJobTypeCtrl,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildLocationDropdown(),
                  const SizedBox(height: 16),
                  _Field(
                    label: 'Job Description *',
                    hint: 'Describe the job in detail...',
                    controller: _descCtrl,
                    maxLines: 4,
                  ),
                  _Field(
                    label: 'Pay Range',
                    hint: 'e.g. 5,000 – 15,000 FCFA',
                    controller: _payCtrl,
                    icon: Icons.payments_rounded,
                  ),
                  _Field(
                    label: 'Contact Info',
                    hint: 'Phone or WhatsApp number',
                    controller: _contactCtrl,
                    icon: Icons.phone_rounded,
                  ),
                  const SizedBox(height: 4),
                  _buildExpirationPicker(),
                  const SizedBox(height: 16),
                  _buildImagePicker(),
                  const SizedBox(height: 28),
                  _buildPostButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppNavBar(selectedIndex: 2),
    );
  }

  // ── Job Type Dropdown ────────────────────────────────────────────────────────
  Widget _buildJobTypeDropdown() {
    return _DropdownField(
      label: 'Job Type / Category *',
      hint: _loadingProfessions ? 'Loading...' : 'Select a job type',
      icon: Icons.work_outline_rounded,
      value: _selectedJobType,
      items: _jobTypeOptions,
      onChanged: _loadingProfessions
          ? null
          : (val) => setState(() => _selectedJobType = val),
    );
  }

  // ── Location Dropdown ────────────────────────────────────────────────────────
  Widget _buildLocationDropdown() {
    return _DropdownField(
      label: 'Location *',
      hint: 'Select a region',
      icon: Icons.location_on_rounded,
      value: _selectedLocation,
      items: _kCameroonRegions,
      onChanged: (val) => setState(() => _selectedLocation = val),
    );
  }

  // ── Expiration Picker ────────────────────────────────────────────────────────
  Widget _buildExpirationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Expiration Date',
          style: TextStyle(
            color: _kBrownMid,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickExpiration,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _expiresAt != null ? _kOrange : _kBrownLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: _expiresAt != null ? _kOrange : _kBrownMid,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _expiresAt != null
                        ? _formatExpiration(_expiresAt!)
                        : 'Tap to set expiration date & time',
                    style: TextStyle(
                      color: _expiresAt != null ? _kBrown : _kBrownMid,
                      fontSize: 14,
                      fontWeight: _expiresAt != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (_expiresAt != null)
                  GestureDetector(
                    onTap: () => setState(() => _expiresAt = null),
                    child: const Icon(
                      Icons.close_rounded,
                      color: _kBrownMid,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Image Picker ─────────────────────────────────────────────────────────────
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Image (Optional)',
          style: TextStyle(
            color: _kBrownMid,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBrownLight),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.upload_rounded,
                  color: _selectedImage != null ? _kOrange : _kBrownMid,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedImage != null
                        ? 'Image selected ✓'
                        : 'Tap to select an image',
                    style: TextStyle(
                      color: _selectedImage != null ? _kOrange : _kBrownMid,

                      fontSize: 14,
                      fontWeight: _selectedImage != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (_selectedImage != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedImage = null),
                    child: const Icon(
                      Icons.close_rounded,
                      color: _kBrownMid,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Post Button ──────────────────────────────────────────────────────────────
  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _isPosting
              ? const LinearGradient(colors: [_kBrownLight, _kBrownLight])
              : const LinearGradient(
                  colors: [_kOrangeDark, _kOrange, _kOrangeLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPosting
              ? []
              : [
                  BoxShadow(
                    color: _kOrange.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _isPosting ? null : _onPostJob,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isPosting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Post Job · 50 FCFA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Dropdown Field ───────────────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _kBrownMid,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: value != null ? _kOrange : _kBrownLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Row(
                children: [
                  Icon(icon, color: _kBrownMid, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    hint,
                    style: const TextStyle(color: _kBrownMid, fontSize: 14),
                  ),
                ],
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _kBrownMid,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(14),
              dropdownColor: Colors.white,
              style: const TextStyle(
                color: _kBrown,
                fontSize: 14,
                fontFamily: 'default',
              ),
              onChanged: onChanged,
              selectedItemBuilder: (context) => items
                  .map(
                    (item) => Row(
                      children: [
                        Icon(icon, color: _kOrange, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          item,
                          style: const TextStyle(
                            color: _kBrown,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              items: items.map((item) {
                final isOther = item == 'Other';
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(
                        isOther ? Icons.edit_rounded : icon,
                        color: isOther ? _kOrange : _kBrownMid,
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item,
                        style: TextStyle(
                          color: isOther ? _kOrange : _kBrown,
                          fontSize: 14,
                          fontWeight: isOther
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Reusable Text Field ──────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final IconData? icon;

  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _kBrownMid,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBrownLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(color: _kBrown, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: _kBrownMid, fontSize: 14),
                prefixIcon: icon != null
                    ? Icon(icon, color: _kOrange, size: 18)
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Post Job Header ──────────────────────────────────────────────────────────
class _PostJobHeader extends StatelessWidget {
  final VoidCallback onBack;
  final Animation<Offset> slideAnim;

  const _PostJobHeader({required this.onBack, required this.slideAnim});

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
            right: -6,
            bottom: -8,
            child: Opacity(
              opacity: 0.16,
              child: Image.asset(
                'assets/images/home.png',
                height: 88,
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
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.80),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Post a Job',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
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
                      Icons.add_circle_outline_rounded,
                      color: Colors.white,
                      size: 20,
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

// ─── Post Job Payment Sheet ───────────────────────────────────────────────────
class _PostJobPaymentSheet extends StatelessWidget {
  final String jobTitle;
  final VoidCallback onPay;

  const _PostJobPaymentSheet({required this.jobTitle, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _kBrownLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kOrangeDark, _kOrangeLight],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _kOrange.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.payment_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ready to Post?',
            style: TextStyle(
              color: _kBrown,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$jobTitle"',
            style: const TextStyle(
              color: _kOrange,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCF9F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBrownLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kOrange.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.monetization_on_rounded,
                    color: _kOrange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Posting Fee',
                        style: TextStyle(
                          color: _kBrownMid,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '50 FCFA',
                        style: TextStyle(
                          color: _kBrown,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
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
                    color: Colors.green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'One-time',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your job will be visible to technicians matching your job category immediately after payment.',
            style: TextStyle(color: _kBrownMid, fontSize: 12, height: 1.5),
            textAlign: TextAlign.center,
          ),
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
                boxShadow: [
                  BoxShadow(
                    color: _kOrange.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Proceed to Payment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: _kBrownMid,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
