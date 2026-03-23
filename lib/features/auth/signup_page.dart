import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

const _orange = Color(0xFFF77705);
const _orangeDark = Color(0xFFE86E00);
const _orangeLight = Color(0xFFFF9A3C);
const _brown = Color(0xFF1C110C);
const _brownMid = Color(0xFF9E7047);
const _cream = Color(0xFFFCF9F7);
const _creamDark = Color(0xFFF4EDE5);

const _regions = [
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
  'Others',
];

const _professions = [
  'Plumber',
  'Electrician',
  'Carpenter',
  'Mechanic',
  'Painter',
  'Cleaner',
  'Gardener',
  'Mason',
  'Welder',
  'Tailor',
  'Others',
];

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _cream,
      body: _SignupContent(),
    );
  }
}

class _SignupContent extends StatefulWidget {
  const _SignupContent();

  @override
  State<_SignupContent> createState() => _SignupContentState();
}

class _SignupContentState extends State<_SignupContent>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _customProfessionCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _selectedProfession;
  String? _selectedLocation;
  _Carrier? _detectedCarrier;

  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _customProfessionCtrl.dispose();
    _skillsCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHero(size),
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Create Your Account',
                        style: TextStyle(
                          color: _brown,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Join Fixit and earn from your skills',
                        style: TextStyle(
                          color: _brownMid,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Name row
                    Row(
                      children: [
                        Expanded(
                          child: _buildInput(
                            controller: _firstNameCtrl,
                            hint: 'First Name',
                            icon: Icons.person_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInput(
                            controller: _lastNameCtrl,
                            hint: 'Last Name',
                            icon: Icons.person_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Email
                    _buildInput(
                      controller: _emailCtrl,
                      hint: 'Email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                      onChanged: _validateEmail,
                    ),
                    const SizedBox(height: 14),

                    // Password
                    _buildInput(
                      controller: _passwordCtrl,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      errorText: _passwordError,
                      onChanged: _validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: _brownMid,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Confirm Password
                    _buildInput(
                      controller: _confirmPasswordCtrl,
                      hint: 'Confirm Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirm,
                      errorText: _confirmError,
                      onChanged: _validateConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: _brownMid,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Profession Dropdown
                    _buildDropdown(
                      value: _selectedProfession,
                      hint: 'Select Profession',
                      icon: Icons.work_outline_rounded,
                      items: _professions,
                      onChanged: (v) =>
                          setState(() => _selectedProfession = v),
                    ),

                    // Custom profession input when "Others" selected
                    if (_selectedProfession == 'Others') ...[
                      const SizedBox(height: 14),
                      _buildInput(
                        controller: _customProfessionCtrl,
                        hint: 'Enter your profession',
                        icon: Icons.edit_outlined,
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Skills
                    _buildInput(
                      controller: _skillsCtrl,
                      hint: 'Enter your skill (optional)',
                      icon: Icons.star_outline_rounded,
                    ),
                    const SizedBox(height: 14),

                    // Phone
                    _buildPhoneInput(),
                    const SizedBox(height: 14),

                    // Location Dropdown
                    _buildDropdown(
                      value: _selectedLocation,
                      hint: 'Select Region / Location',
                      icon: Icons.location_on_outlined,
                      items: _regions,
                      onChanged: (v) =>
                          setState(() => _selectedLocation = v),
                    ),
                    const SizedBox(height: 32),

                    // Register Button
                    _buildRegisterButton(),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                            child: Divider(color: _brownMid.withValues(alpha: 0.3))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or continue with',
                            style: TextStyle(
                                color: _brownMid,
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        Expanded(
                            child: Divider(color: _brownMid.withValues(alpha: 0.3))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Google
                    _buildSocialButton(
                      label: 'Continue with Google',
                      logo: const _GoogleLogo(),
                      onTap: _handleGoogleSignup,
                    ),
                    const SizedBox(height: 12),

                    // Facebook
                    _buildSocialButton(
                      label: 'Continue with Facebook',
                      logo: const _FacebookLogo(),
                      onTap: _handleFacebookSignup,
                    ),
                    const SizedBox(height: 32),

                    // Login link
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/login'),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: _brownMid, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  color: _orange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHero(Size size) {
    return Container(
      height: size.height * 0.28,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_orangeDark, _orange, _orangeLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Transparent hero image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(36)),
              child: Opacity(
                opacity: 0.13,
                child: Image.asset(
                  'assets/images/home.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: -20,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Back button
            Positioned(
              top: 12,
              left: 16,
              child: Material(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.pop(),
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4), width: 2),
                    ),
                    child: const Icon(Icons.handyman_rounded,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Fix',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        TextSpan(
                          text: 'It',
                          style: TextStyle(
                            color: Color(0xFFFFD580),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your trusted service marketplace',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Carrier detection ─────────────────────────────────────────────────────

  void _onPhoneChanged(String v) {
    // Cameroon MTN prefixes: 650-659, 670-679, 680-689
    // Cameroon Orange prefixes: 690-699, 655-659 (shared), 620-629
    // We detect on 9 digits (local format without country code)
    _Carrier? carrier;
    if (v.length == 9) {
      final prefix = int.tryParse(v.substring(0, 3)) ?? 0;
      if ((prefix >= 650 && prefix <= 654) ||
          (prefix >= 670 && prefix <= 679) ||
          (prefix >= 680 && prefix <= 689)) {
        carrier = _Carrier.mtn;
      } else if ((prefix >= 655 && prefix <= 659) ||
          (prefix >= 690 && prefix <= 699) ||
          (prefix >= 620 && prefix <= 629)) {
        carrier = _Carrier.orange;
      }
    }
    setState(() => _detectedCarrier = carrier);
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: _creamDark,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        maxLength: 9,
        onChanged: _onPhoneChanged,
        decoration: InputDecoration(
          hintText: 'Phone number (9 digits)',
          hintStyle: TextStyle(color: _brownMid, fontSize: 14),
          prefixIcon:
              const Icon(Icons.phone_outlined, color: _orange, size: 20),
          suffixIcon: _detectedCarrier != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: _CarrierBadge(carrier: _detectedCarrier!),
                )
              : null,
          border: InputBorder.none,
          counterText: '',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? errorText,
    void Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _creamDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: errorText != null
                  ? Colors.red.shade400
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: obscureText ? 1 : maxLines,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: _brownMid, fontSize: 14),
              prefixIcon: Icon(icon, color: _orange, size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 4),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _creamDark,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(icon, color: _orange, size: 20),
                const SizedBox(width: 12),
                Text(hint, style: const TextStyle(color: _brownMid, fontSize: 14)),
              ],
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: _brownMid),
          ),
          borderRadius: BorderRadius.circular(14),
          dropdownColor: _cream,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Icon(icon, color: _orange, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            e,
                            style: const TextStyle(
                              color: _brown,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _isLoading
              ? const LinearGradient(
                  colors: [Color(0xFFCCBBAA), Color(0xFFCCBBAA)])
              : const LinearGradient(
                  colors: [_orangeDark, _orange, _orangeLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: _orange.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget logo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _creamDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _brownMid.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logo,
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _brown),
            ),
          ],
        ),
      ),
    );
  }

  // ── Validation ────────────────────────────────────────────────────────────

  void _validateEmail(String v) {
    setState(() {
      if (v.isEmpty) {
        _emailError = 'Email is required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String v) {
    setState(() {
      _passwordError = v.isEmpty
          ? 'Password is required'
          : v.length < 6
              ? 'Minimum 6 characters'
              : null;
      if (_confirmPasswordCtrl.text.isNotEmpty) {
        _validateConfirm(_confirmPasswordCtrl.text);
      }
    });
  }

  void _validateConfirm(String v) {
    setState(() {
      _confirmError = v.isEmpty
          ? 'Please confirm your password'
          : v != _passwordCtrl.text
              ? 'Passwords do not match'
              : null;
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade600 : _orange,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Auth handlers ─────────────────────────────────────────────────────────

  Future<void> _handleRegister() async {
    final profession = _selectedProfession == 'Others'
        ? _customProfessionCtrl.text.trim()
        : _selectedProfession ?? '';

    if (_firstNameCtrl.text.isEmpty ||
        _lastNameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty ||
        _confirmPasswordCtrl.text.isEmpty ||
        profession.isEmpty ||
        _selectedLocation == null) {
      _showSnack('Please fill in all required fields', isError: true);
      return;
    }

    if (_emailError != null || _passwordError != null || _confirmError != null) {
      _showSnack('Please fix the errors before submitting', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final email = _emailCtrl.text.trim().toLowerCase();
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: _passwordCtrl.text);
      final user = cred.user;
      if (user == null) throw Exception('User creation failed');

      await _firestore.collection('users').doc(user.uid).set({
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'email': email,
        'profession': profession,
        'skills': _skillsCtrl.text.trim(),
        'location': _selectedLocation,
        'phone': _phoneCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _auth.signOut();
      _showSnack('Registration successful! Please sign in.');
      if (mounted) context.go('/login');
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Signup failed', isError: true);
    } catch (e) {
      _showSnack('Registration failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignup() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn(
        clientId:
            '469693488242-h865u4nol6a64un275k7jm4sm5cabdel.apps.googleusercontent.com',
      );

      // Sign out first to force account picker
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) throw Exception('Google sign-in failed');

      final nameParts = (user.displayName ?? '').split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.last : '';

      // Only set data if new user
      if (userCred.additionalUserInfo?.isNewUser == true) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email ?? '',
          'firstName': firstName,
          'lastName': lastName,
          'profession': '',
          'skills': '',
          'location': '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (mounted) context.go('/dashboard/home');
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Google sign-in failed', isError: true);
    } catch (e) {
      _showSnack('Google sign-in failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookSignup() async {
    setState(() => _isLoading = true);
    try {
      // Log out first to force account picker
      await FacebookAuth.instance.logOut();
      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        setState(() => _isLoading = false);
        return;
      }

      final token = result.accessToken?.tokenString;
      if (token == null) throw Exception('Facebook access token missing');

      final credential = FacebookAuthProvider.credential(token);
      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) throw Exception('Facebook sign-in failed');

      if (userCred.additionalUserInfo?.isNewUser == true) {
        final nameParts = (user.displayName ?? '').split(' ');
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email ?? '',
          'firstName': nameParts.isNotEmpty ? nameParts.first : '',
          'lastName': nameParts.length > 1 ? nameParts.last : '',
          'profession': '',
          'skills': '',
          'location': '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (mounted) context.go('/dashboard/home');
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Facebook sign-in failed', isError: true);
    } catch (e) {
      _showSnack('Facebook sign-in failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

enum _Carrier { mtn, orange }

class _CarrierBadge extends StatelessWidget {
  const _CarrierBadge({required this.carrier});
  final _Carrier carrier;

  @override
  Widget build(BuildContext context) {
    final isMtn = carrier == _Carrier.mtn;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(carrier),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isMtn ? const Color(0xFFFFCC00) : const Color(0xFFFF6600),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isMtn ? const Color(0xFFFFCC00) : const Color(0xFFFF6600))
                  .withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            isMtn ? 'MTN' : 'ORG',
            style: TextStyle(
              color: isMtn ? Colors.black : Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Branded social logo widgets ───────────────────────────────────────────

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Red
    canvas.drawArc(rect, -0.52, 1.57, false,
        Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.stroke..strokeWidth = size.width * 0.22..strokeCap = StrokeCap.butt);
    // Yellow
    canvas.drawArc(rect, 1.05, 1.57, false,
        Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.stroke..strokeWidth = size.width * 0.22..strokeCap = StrokeCap.butt);
    // Green
    canvas.drawArc(rect, 2.62, 1.05, false,
        Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.stroke..strokeWidth = size.width * 0.22..strokeCap = StrokeCap.butt);
    // Blue arc
    canvas.drawArc(rect, 3.67, 1.72, false,
        Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.stroke..strokeWidth = size.width * 0.22..strokeCap = StrokeCap.butt);

    // Horizontal bar of the G
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.85, cy),
      Paint()..color = const Color(0xFF4285F4)..strokeWidth = size.width * 0.22..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FacebookLogo extends StatelessWidget {
  const _FacebookLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
