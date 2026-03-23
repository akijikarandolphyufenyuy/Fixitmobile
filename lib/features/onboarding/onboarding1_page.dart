import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Onboarding1Page extends StatelessWidget {
  const Onboarding1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔁 Removed dark background — let our cream cover everything
      backgroundColor: const Color(0xFFFCF9F7), // ← Now CREAM, not dark blue
      body: SafeArea(
        bottom: false,
        // ✅ Status bar text/icons will be dark (on light status bar)
        child: Container(
          color: const Color(0xFFFCF9F7), // Extra safety
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // 🔽 This ensures content is AT LEAST screen height
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: St1(), // Your original widget — unchanged
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

class St1 extends StatelessWidget {
  const St1({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    final contentPadding = screenWidth * 0.041; // ~16px
    final textWidth = screenWidth - (2 * contentPadding);
    final imageHeight = screenWidth * 0.85; // ~320px
    final dotSize = screenWidth * 0.0205; // ~8px
    final buttonWidth = screenWidth * 0.215; // ~84px
    final buttonHeight = screenHeight * 0.057; // ~48px
    final verticalSpacing = screenHeight * 0.014; // ~12px
    final smallVerticalSpacing = screenHeight * 0.005; // ~4px

    return Container(
      decoration: const BoxDecoration(color: Color(0xFFFCF9F7)), // Cream BG
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === Image Section ===
          Container(
            width: double.infinity,
            height: imageHeight,
            decoration: const BoxDecoration(color: Colors.white),
            child: Image.asset(
              "assets/images/ub1.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: imageHeight,
            ),
          ),

          // === Title ===
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: screenHeight * 0.024,
              left: contentPadding,
              right: contentPadding,
              bottom: verticalSpacing,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: textWidth,
                  child: Text(
                    'Post a Job in Minutes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF1C110C),
                      fontSize: screenWidth * 0.056,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      height: 1.27,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // === Subtitle ===
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: smallVerticalSpacing,
              left: contentPadding,
              right: contentPadding,
              bottom: verticalSpacing,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: textWidth,
                  child: Text(
                    'Need Help? Post A Job In Minutes. From Plumbing To Hairstyling. Connect Instantly With Skilled Workers Near You. Fast.Simple.Local.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF1C110C),
                      fontSize: screenWidth * 0.041,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // === Dots Indicator ===
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.024),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: dotSize,
                  height: dotSize,
                  margin: EdgeInsets.symmetric(horizontal: dotSize * 0.75),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFED7C26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(dotSize * 0.5),
                    ),
                  ),
                ),
                Container(
                  width: dotSize,
                  height: dotSize,
                  margin: EdgeInsets.symmetric(horizontal: dotSize * 0.75),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE8D8CE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(dotSize * 0.5),
                    ),
                  ),
                ),
                Container(
                  width: dotSize,
                  height: dotSize,
                  margin: EdgeInsets.symmetric(horizontal: dotSize * 0.75),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE8D8CE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(dotSize * 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // === Bottom Buttons ===
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: contentPadding,
              vertical: verticalSpacing,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button
                GestureDetector(
                  onTap: () {
                    context.go('/login');
                  },
                  child: Container(
                    width: buttonWidth,
                    height: buttonHeight,
                    padding:
                        EdgeInsets.symmetric(horizontal: contentPadding * 1.2),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.061),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Skip',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF1C110C),
                          fontSize: screenWidth * 0.041,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // Next Button
                GestureDetector(
                  onTap: () {
                    context.go('/onboarding/2');
                  },
                  child: Container(
                    width: buttonWidth,
                    height: buttonHeight,
                    padding:
                        EdgeInsets.symmetric(horizontal: contentPadding * 1.2),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFED7C26),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.061),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Next',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF1C110C),
                          fontSize: screenWidth * 0.041,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom spacer (same cream color to fill)
          Container(
            width: double.infinity,
            height: screenHeight * 0.024,
            color: const Color(0xFFFCF9F7),
          ),
        ],
      ),
    );
  }
}

