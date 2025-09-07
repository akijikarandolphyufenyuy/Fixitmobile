import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Onboarding2Page extends StatelessWidget {
  const Onboarding2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Changed: Remove dark background completely
      backgroundColor: const Color(0xFFFCF9F7), // ← Now CREAM, not dark blue
      body: SafeArea(
        bottom: false,
        // ✅ Wrap in full cream container to ensure no dark shows
        child: Container(
          color: const Color(0xFFFCF9F7), // Double protection
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: St2(), // Your original widget — unchanged
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class St2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    final contentPadding = screenWidth * 0.041; // ~16px
    final textWidth = screenWidth - (2 * contentPadding);
    final imageHeight = screenWidth * 0.85; // Responsive image
    final dotSize = screenWidth * 0.0205; // ~8px
    final buttonWidth = screenWidth * 0.215; // ~84px
    final buttonHeight = screenHeight * 0.055; // ~48px
    final verticalSpacing = screenHeight * 0.014; // ~12px
    final dotToButtonSpacing =
        screenHeight * 0.024; // Space between dots and buttons

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFCF9F7), // Cream background to cover fully
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === White Top Container with Image, Title, Subtitle ===
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  height: imageHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/ub2.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Title
                Container(
                  padding: EdgeInsets.fromLTRB(
                    contentPadding,
                    screenHeight * 0.024,
                    contentPadding,
                    verticalSpacing,
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: textWidth,
                    child: Text(
                      'Post a Job in Minutes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1C140C),
                        fontSize: screenWidth * 0.065,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),

                // Subtitle
                Container(
                  padding: EdgeInsets.fromLTRB(
                    contentPadding,
                    screenHeight * 0.005,
                    contentPadding,
                    verticalSpacing,
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: textWidth,
                    child: Text(
                      'Turn Your Skills Into Steady Income. Get Discovered, Apply For Jobs, And Grow Your Reputation. Your Talent Deserves The Spotlight.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1C140C),
                        fontSize: screenWidth * 0.041,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // === DOTS (Centered) ===
          Container(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.024),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: dotSize,
                  height: dotSize,
                  margin: EdgeInsets.symmetric(horizontal: dotSize * 0.75),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D8CE),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: dotSize,
                  height: dotSize,
                  margin: EdgeInsets.symmetric(horizontal: dotSize * 0.75),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF77705),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: dotSize,
                  height: dotSize,
                  margin: EdgeInsets.symmetric(horizontal: dotSize * 0.75),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D8CE),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // ✅ NEW: Small space between dots and buttons
          SizedBox(height: dotToButtonSpacing),

          // === BUTTONS: Skip & Next ===
          Padding(
            padding: EdgeInsets.symmetric(horizontal: contentPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button
                GestureDetector(
                  onTap: () {
                    print('Skip button pressed on page 2!');
                    context.go('/login');
                  },
                  child: Container(
                    width: buttonWidth,
                    height: buttonHeight,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: contentPadding),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.051),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1C140C),
                        fontSize: screenWidth * 0.036,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),

                // Next Button
                GestureDetector(
                  onTap: () {
                    print('Next button pressed on page 2!');
                    context.go('/onboarding/3');
                  },
                  child: Container(
                    width: buttonWidth,
                    height: buttonHeight,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: contentPadding),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF77705),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.051),
                      ),
                    ),
                    child: Text(
                      'Next',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFFCF9F7),
                        fontSize: screenWidth * 0.036,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Bottom spacer (same cream color to fill)
          Container(
            height: screenHeight * 0.024,
            color: const Color(0xFFFCF9F7),
          ),
        ],
      ),
    );
  }
}
