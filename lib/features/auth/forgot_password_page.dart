import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ← Add Firebase Auth

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFFFCF9F7), body: Reset());
  }
}

class Reset extends StatefulWidget {
  @override
  _ResetState createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;

  // Validate email format
  bool _isValidEmail(String value) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
  }

  // Handle password reset
  void _sendResetLink() async {
    final String email = _emailController.text.trim().toLowerCase();

    // Reset error
    if (mounted) {
      setState(() {
        _emailError = null;
      });
    }

    // Validation
    if (email.isEmpty) {
      if (mounted) {
        setState(() {
          _emailError = 'Email is required';
        });
      }
      return;
    }
    if (!_isValidEmail(email)) {
      if (mounted) {
        setState(() {
          _emailError = 'Please enter a valid email';
        });
      }
      return;
    }

    // Show loading
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // ✅ Send password reset email via Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // ✅ Success: Show message and go back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent to your email!'),
          backgroundColor: Color(0xFFED7C26),
        ),
      );

      // Pop back to login page
      context.pop();
    } on FirebaseAuthException catch (e) {
      String message = 'Could not send reset link';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else {
        message = 'Error: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reset email. Check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 844),
                  child: Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(color: Color(0xFFFCF9F7)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Image
                        Container(
                          width: double.infinity,
                          height: 320,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/forget.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Title
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Back Button
                              GestureDetector(
                                onTap: () {
                                  context.pop(); // Go back to login
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2EDE8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFF1C110C),
                                    size: 24,
                                  ),
                                ),
                              ),
                              const Text(
                                'Forgot Password',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF1C110C),
                                  fontSize: 18,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w700,
                                  height: 1.28,
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),

                        // Reset Title
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: 20,
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: const Text(
                            'Reset Your Password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1C110C),
                              fontSize: 24,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ),

                        // Description
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: 4,
                            left: 16,
                            right: 16,
                            bottom: 12,
                          ),
                          child: const Text(
                            "Enter the email address associated with your account, and we'll send you instructions to reset your password.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1C110C),
                              fontSize: 16,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ),

                        // Email Input
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Email Address',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF996D4C),
                                    fontSize: 16,
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF2EDE8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF996D4C),
                                    size: 20,
                                  ),
                                ),
                              ),
                              if (_emailError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 6,
                                    left: 16,
                                  ),
                                  child: Text(
                                    _emailError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontFamily: 'Lexend',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Submit Button
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendResetLink,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFED7C26),
                              foregroundColor: const Color(0xFF1C110C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
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
                                : const Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),

                        // Back to Login Link
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              context.pop(); // Go back to login
                            },
                            child: const Text(
                              'Remember your password? Log in',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF996D4C),
                                fontSize: 14,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                          ),
                        ),

                        // Bottom spacer
                        Container(height: 20, color: const Color(0xFFFCF9F7)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
