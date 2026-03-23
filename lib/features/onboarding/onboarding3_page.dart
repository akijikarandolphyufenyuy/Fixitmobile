import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/auth_repository.dart'; // Adjust path if needed

class Onboarding3Page extends StatelessWidget {
  const Onboarding3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),
      body: SafeArea(
        bottom: false,
        child: Container(
          color: const Color(0xFFFCF9F7),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(child: St3()),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class St3 extends StatelessWidget {
  const St3({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final contentPadding = screenWidth * 0.041;
    final textWidth = screenWidth - (2 * contentPadding);
    final imageHeight = screenWidth * 0.82;
    final dotSize = screenWidth * 0.0205;
    final verticalSpacing = screenHeight * 0.014;
    final smallVerticalSpacing = screenHeight * 0.005;
    final buttonHeight = screenHeight * 0.057;
    final borderRadius = screenWidth * 0.061;

    return Column(
      children: [
        Container(
          width: screenWidth,
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(color: Color(0xFFFCF9F7)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: imageHeight,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/ub3.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.024,
                          left: contentPadding,
                          right: contentPadding,
                          bottom: verticalSpacing,
                        ),
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
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: smallVerticalSpacing,
                          left: contentPadding,
                          right: contentPadding,
                          bottom: verticalSpacing,
                        ),
                        child: SizedBox(
                          width: textWidth,
                          child: Text(
                            'Work. Get Paid. Securely. Earn Safely Through MoMo Or Orange Money No Delays. Trusted By The Local Community.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF1C140C),
                              fontSize: screenWidth * 0.041,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.024,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildIndicator(
                                isActive: false,
                                dotSize: dotSize,
                              ),
                              _buildIndicator(
                                isActive: false,
                                dotSize: dotSize,
                              ),
                              _buildIndicator(isActive: true, dotSize: dotSize),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: contentPadding,
                          vertical: verticalSpacing,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            // Get Started button pressed
                            // ✅ Fixed singleton call
                            await AuthRepository.instance.completeOnboarding();
                            context.push('/signup');
                          },
                          child: Container(
                            height: buttonHeight,
                            padding: EdgeInsets.symmetric(
                              horizontal: contentPadding * 1.2,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF77705),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  borderRadius,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Get Started',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFFFCF9F7),
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
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: smallVerticalSpacing,
                          left: contentPadding,
                          right: contentPadding,
                          bottom: verticalSpacing,
                        ),
                        child: SizedBox(
                          width: textWidth,
                          child: Text(
                            'Skip',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF9E7047),
                              fontSize: screenWidth * 0.036,
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
              ),
              Container(
                height: screenHeight * 0.024,
                color: const Color(0xFFFCF9F7),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator({required bool isActive, required double dotSize}) {
    return Container(
      width: dotSize,
      height: dotSize,
      margin: EdgeInsets.symmetric(horizontal: dotSize * 0.75),
      decoration: ShapeDecoration(
        color: isActive ? const Color(0xFFF77705) : const Color(0xFFE8D8CE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dotSize * 0.5),
        ),
      ),
    );
  }
}


