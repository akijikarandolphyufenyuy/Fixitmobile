import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingHomePage extends StatelessWidget {
  const OnboardingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final contentPadding = 16.0;
    final textWidth =
        screenWidth - (contentPadding * 2); // 16px padding on each side

    return SingleChildScrollView(
      child: Container(
        width: screenWidth, // Full screen width
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(color: Color(0xFFFCF9F7)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Content
                  Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFCF9F7),
                          ),
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFCF9F7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Container(
                              height:
                                  screenWidth *
                                  1.2, // Responsive height (e.g., 1.2x screen width)
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/images/home.png"),

                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Title
                        Container(
                          padding: const EdgeInsets.only(
                            top: 20,
                            left: 16,
                            right: 16,
                            bottom: 12,
                          ),
                          child: SizedBox(
                            width: textWidth,
                            child: Text(
                              'Fixit',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF1C110C),
                                fontSize: 22,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w700,
                                height: 1.27,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),

                        // Subtitle
                        Container(
                          padding: const EdgeInsets.only(
                            top: 4,
                            left: 16,
                            right: 16,
                            bottom: 12,
                          ),
                          child: SizedBox(
                            width: textWidth,
                            child: Text(
                              'Your Skills, Your Earnings. Find Jobs. Offer Services. Get Paid All In One Place. Joins Us And Turn Your Skills Into Income',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF1C110C),
                                fontSize: 16,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Section: Button + Spacer
                  Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Get Started Button
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: 84,
                                    maxWidth:
                                        screenWidth - 32, // Responsive max
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      context.go('/onboarding/1');
                                    },
                                    child: Container(
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFED7C26),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Get Started',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFF1C110C),
                                            fontSize: 16,
                                            fontFamily: 'Lexend',
                                            fontWeight: FontWeight.w700,
                                            height: 1.50,
                                            decoration:
                                                TextDecoration.none, // 🔴
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bottom Spacer
                        Container(
                          width: double.infinity,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFCF9F7),
                          ),
                        ),
                      ],
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
}
