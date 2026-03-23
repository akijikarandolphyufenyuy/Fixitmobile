import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(scheme, size),
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to continue to FixIt',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildInputField(
                        controller: _emailController,
                        hint: 'Email address',
                        icon: Icons.email_outlined,
                        scheme: scheme,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _buildPasswordField(scheme),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => context.push('/forgot-password'),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildLoginButton(scheme),
                      const SizedBox(height: 24),
                      _buildDivider(scheme),
                      const SizedBox(height: 24),
                      _buildSocialButton(
                        label: 'Continue with Google',
                        logo: const _GoogleLogo(),
                        scheme: scheme,
                        onTap: _handleGoogleLogin,
                      ),
                      const SizedBox(height: 12),
                      _buildSocialButton(
                        label: 'Continue with Facebook',
                        logo: const _FacebookLogo(),
                        scheme: scheme,
                        onTap: _handleFacebookLogin,
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push('/signup'),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
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
      ),
    );
  }

  Widget _buildHero(ColorScheme scheme, Size size) {
    return SizedBox(
      height: size.height * 0.34,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero background — local asset
          Image.asset(
            'assets/images/home.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Dark gradient overlay for text legibility
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x99000000), Color(0xCC000000)],
              ),
            ),
          ),
          // Logo + tagline centered over image
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Wordmark logo
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(Icons.build_rounded,
                              color: Colors.white, size: 15),
                        ),
                        const SizedBox(width: 9),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Fix',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              TextSpan(
                                text: 'It',
                                style: TextStyle(
                                  color: Color(0xFFF77705),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Your trusted service marketplace',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ColorScheme scheme,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
          prefixIcon: Icon(icon, color: scheme.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField(ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
          prefixIcon: Icon(Icons.lock_outline_rounded, color: scheme.primary, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: scheme.onSurfaceVariant,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLoginButton(ColorScheme scheme) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _isLoading
              ? LinearGradient(colors: [scheme.onSurfaceVariant, scheme.onSurfaceVariant])
              : LinearGradient(colors: [scheme.primary, scheme.tertiary], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isLoading ? [] : [
            BoxShadow(color: scheme.primary.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 5)),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _buildDivider(ColorScheme scheme) {
    return Row(
      children: [
        Expanded(child: Divider(color: scheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or continue with', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
        ),
        Expanded(child: Divider(color: scheme.outlineVariant)),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget logo,
    required ColorScheme scheme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: scheme.onSurface)),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) throw Exception('User profile not found.');

      final data = doc.data()!;
      final firstName = data['firstName'] as String? ?? '';
      final lastName = data['lastName'] as String? ?? '';
      final fullName = '$firstName $lastName'.trim();
      final displayName = fullName.isNotEmpty ? fullName : user.email!.split('@')[0];

      if (mounted) { context.go('/dashboard/home', extra: displayName); }
    } on FirebaseAuthException catch (e) {
      String msg = 'Login failed';
      if (e.code == 'user-not-found') { msg = 'No account found with this email'; }
      else if (e.code == 'wrong-password') { msg = 'Incorrect password'; }
      _showError(msg);
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn(
        clientId: '469693488242-h865u4nol6a64un275k7jm4sm5cabdel.apps.googleusercontent.com',
      );
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) { setState(() => _isLoading = false); return; }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) throw Exception('Google sign-in failed');

      if (userCred.additionalUserInfo?.isNewUser == true) {
        final parts = (user.displayName ?? '').split(' ');
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email ?? '',
          'firstName': parts.isNotEmpty ? parts.first : '',
          'lastName': parts.length > 1 ? parts.last : '',
          'profession': '', 'skills': '', 'location': '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      final name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
      if (mounted) context.go('/dashboard/home', extra: name.isNotEmpty ? name : user.email);
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Google sign-in failed');
    } catch (e) {
      _showError('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookLogin() async {
    setState(() => _isLoading = true);
    try {
      await FacebookAuth.instance.logOut();
      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );
      if (result.status != LoginStatus.success) { setState(() => _isLoading = false); return; }

      final token = result.accessToken?.tokenString;
      if (token == null) throw Exception('Facebook token missing');

      final credential = FacebookAuthProvider.credential(token);
      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) throw Exception('Facebook sign-in failed');

      if (userCred.additionalUserInfo?.isNewUser == true) {
        final parts = (user.displayName ?? '').split(' ');
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email ?? '',
          'firstName': parts.isNotEmpty ? parts.first : '',
          'lastName': parts.length > 1 ? parts.last : '',
          'profession': '', 'skills': '', 'location': '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      final name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
      if (mounted) context.go('/dashboard/home', extra: name.isNotEmpty ? name : user.email);
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Facebook sign-in failed');
    } catch (e) {
      _showError('Facebook sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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

    // Draw the four colored arcs of the Google G
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Red (top-right)
    canvas.drawArc(rect, -0.52, 1.57, false,
        Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.stroke..strokeWidth = size.width * 0.22..strokeCap = StrokeCap.butt);
    // Yellow (bottom-right)
    canvas.drawArc(rect, 1.05, 1.57, false,
        Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.stroke..strokeWidth = size.width * 0.22..strokeCap = StrokeCap.butt);
    // Green (bottom-left)
    canvas.drawArc(rect, 2.62, 1.05, false,
        Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.stroke..strokeWidth = size.width * 0.22..strokeCap = StrokeCap.butt);
    // Blue (top-left + horizontal bar)
    canvas.drawArc(rect, 3.67, 1.72, false,
        Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.stroke..strokeWidth = size.width * 0.22..strokeCap = StrokeCap.butt);

    // Horizontal bar of the G (blue)
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.85, cy),
      barPaint,
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
