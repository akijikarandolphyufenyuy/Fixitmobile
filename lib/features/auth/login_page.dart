import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ← Added for Firestore

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),
      body: LoginContent(),
    );
  }
}

class LoginContent extends StatefulWidget {
  @override
  _LoginContentState createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // ← Firestore instance

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final contentPadding = screenWidth * 0.041;
    final verticalSpacing = screenHeight * 0.014;
    final smallVerticalSpacing = screenHeight * 0.005;
    final largeVerticalSpacing = screenHeight * 0.024;
    final imageHeight = screenWidth * 0.82;
    final borderRadius = 12.0;
    final buttonBorderRadius = 24.0;
    final socialButtonBorderRadius = 20.0;
    final iconSize = 20.0;
    final textIconSpacing = 8.0;

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFFFCF9F7)),
          child: Column(
            children: [
              // Header Image
              Container(
                height: imageHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/Untitled.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Welcome Text
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: screenHeight * 0.024,
                  left: contentPadding,
                  right: contentPadding,
                  bottom: verticalSpacing,
                ),
                child: Text(
                  'Welcome Back To Fixit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF1C140C),
                    fontSize: screenWidth * 0.065,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),

              // Email Field
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: contentPadding,
                  vertical: verticalSpacing,
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      color: const Color(0xFF9E7047),
                      fontSize: screenWidth * 0.041,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF4EDE5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: const Color(0xFF9E7047),
                      size: iconSize,
                    ),
                  ),
                ),
              ),

              // Password Field
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: contentPadding,
                  vertical: verticalSpacing,
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(
                      color: const Color(0xFF9E7047),
                      fontSize: screenWidth * 0.041,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF4EDE5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: const Color(0xFF9E7047),
                      size: iconSize,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF9E7047),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),

              // Forgot Password
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: smallVerticalSpacing,
                  left: contentPadding,
                  right: contentPadding,
                  bottom: verticalSpacing,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      context.push('/forgot-password');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: const Color(0xFF9E7047),
                        fontSize: screenWidth * 0.036,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),

              // Log In Button
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: contentPadding,
                  vertical: verticalSpacing,
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF77705),
                    foregroundColor: const Color(0xFFFCF9F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(buttonBorderRadius),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: screenWidth * 0.041,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
                          ),
                        ),
                ),
              ),

              SizedBox(height: largeVerticalSpacing),

              // Social Login Buttons
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: contentPadding),
                child: Column(
                  children: [
                    // Facebook
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _simulateSocialLogin('Facebook'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4EDE5),
                          foregroundColor: const Color(0xFF1C140C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              socialButtonBorderRadius,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.facebook,
                              size: iconSize,
                              color: const Color(0xFF1C140C),
                            ),
                            SizedBox(width: textIconSpacing),
                            Text(
                              'Continue with Facebook',
                              style: TextStyle(
                                fontSize: screenWidth * 0.036,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: verticalSpacing),

                    // Google
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _simulateSocialLogin('Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4EDE5),
                          foregroundColor: const Color(0xFF1C140C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              socialButtonBorderRadius,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.g_mobiledata,
                              size: iconSize,
                              color: const Color(0xFF1C140C),
                            ),
                            SizedBox(width: textIconSpacing),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: screenWidth * 0.036,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.048),
              SizedBox(height: largeVerticalSpacing),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ UPDATED: Fetch user name from Firestore after login
  void _handleLogin() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Sign in
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) return;

      // Step 2: Fetch user profile from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        throw Exception(
          "User profile not found. Please complete registration.",
        );
      }

      final data = doc.data()!;
      final firstName = data['firstName'] as String? ?? '';
      final lastName = data['lastName'] as String? ?? '';
      final fullName = '$firstName $lastName'.trim();

      // Fallback: use email prefix if name missing
      final displayName = fullName.isNotEmpty
          ? fullName
          : user.email!.split('@')[0];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful! Welcome, $displayName.'),
          backgroundColor: const Color(0xFFF77705),
        ),
      );

      // ✅ Navigate to dashboard and pass the real name
      context.go('/dashboard/home', extra: displayName);
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _simulateSocialLogin(String provider) async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login successful!'),
        backgroundColor: const Color(0xFFF77705),
      ),
    );

    context.go('/dashboard/home');

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
