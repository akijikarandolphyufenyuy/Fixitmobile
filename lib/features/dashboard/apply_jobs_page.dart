import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Define colors used in SubscriptionPage for consistency
const Color applyBgColor = Color(0xFFFCF9F7); // Background color
const Color applyTextColorPrimary = Color(0xFF1C110C); // Primary text color
const Color applyTextColorSecondary = Color(0xFF996D4C); // Secondary text color
const Color applyBorderColor = Color(0xFFE8D8CE); // Border/highlight color
const Color applyAccentColor = Color(0xFFED7C26); // Accent/Orange color

class ApplyJobsPage extends StatefulWidget {
  @override
  _ApplyJobsPageState createState() => _ApplyJobsPageState();
}

class _ApplyJobsPageState extends State<ApplyJobsPage> {
  int _selectedIndex = 3; // Applications tab selected

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Navigate using GoRouter
      switch (index) {
        case 0:
          context.go('/dashboard/home');
          break;
        case 1:
          context.go('/dashboard/view-jobs');
          break;
        case 2:
          context.go('/dashboard/post-job');
          break;
        case 3:
          context.go('/dashboard/applications');
          break;
        case 4:
          context.go('/dashboard/settings');
          break;
      }
    });
  }

  void _onBackPressed(BuildContext context) {
    // Navigate back to home
    context.go('/dashboard/home');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

        return Scaffold(
          // --- Changed Background Color ---
          backgroundColor:
              applyBgColor, // Use SubscriptionPage background color
          body: SafeArea(
            child: Column(
              children: [
                // App Bar Section
                _buildAppBar(context),

                // Apply Job Form
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Personal Information'),
                          _buildTextField('Full Name'),
                          const SizedBox(height: 16),
                          _buildTextField('Email Address'),
                          const SizedBox(height: 16),
                          _buildTextField('Phone Number'),
                          const SizedBox(height: 24),

                          _buildSectionTitle('Proof of Skills Or CV'),
                          _buildUploadBox(),
                          const SizedBox(height: 24),

                          _buildSectionTitle('Cover Letter'),
                          _buildCoverLetterField(),
                          const SizedBox(height: 32),

                          _buildApplyButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation Bar
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      // --- Changed AppBar Background Color ---
      decoration: const BoxDecoration(color: applyBgColor),
      child: Row(
        children: [
          // Back Button
          IconButton(
            // --- Changed Back Icon Color ---
            icon: Icon(
              Icons.arrow_back,
              color: applyTextColorPrimary,
            ), // Use primary text color
            onPressed: () => _onBackPressed(context),
          ),

          const SizedBox(width: 8),

          // Title
          const Expanded(
            child: Text(
              'Apply for Job',
              textAlign: TextAlign.center,
              style: TextStyle(
                // --- Changed App Title Color ---
                color: applyTextColorPrimary, // Use primary text color
                fontSize: 18,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Placeholder for symmetry
          Container(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          // --- Changed Section Title Color ---
          color: applyTextColorPrimary, // Use primary text color
          fontSize: 18,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        // --- Potentially Changed Text Field Background Color (Optional) ---
        // Keeping white background for input fields is common, but if you want consistency:
        // color: applyBgColor,
        color: Colors.white, // Keep white for input fields if preferred
        shape: RoundedRectangleBorder(
          // --- Changed Text Field Border Color ---
          side: BorderSide(
            width: 1,
            color: applyBorderColor,
          ), // Use border color
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            // --- Changed Hint Text Color ---
            color: applyTextColorSecondary, // Use secondary text color
            fontSize: 14,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildUploadBox() {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // --- Changed Upload Box Background Color ---
      decoration: const BoxDecoration(
        color: applyBgColor,
      ), // Match page background
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              height: 56,
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 8,
                bottom: 16,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                // --- Changed Upload Box Inner Background Color ---
                color:
                    applyBorderColor, // Use border color for the button background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload File',
                    style: const TextStyle(
                      // --- Changed Upload Text Color ---
                      color: applyTextColorPrimary, // Use primary text color
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      // --- Changed Upload Icon Color ---
                      Icons.upload,
                      size: 20,
                      color: applyTextColorPrimary, // Use primary text color
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

  Widget _buildCoverLetterField() {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        // --- Potentially Changed Cover Letter Background Color (Optional) ---
        // Keeping white background for input fields is common, but if you want consistency:
        // color: applyBgColor,
        color: Colors.white, // Keep white for input fields if preferred
        shape: RoundedRectangleBorder(
          // --- Changed Cover Letter Border Color ---
          side: BorderSide(
            width: 1,
            color: applyBorderColor,
          ), // Use border color
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: TextField(
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: 'Write your cover letter here...',
          hintStyle: TextStyle(
            // --- Changed Cover Letter Hint Color ---
            color: applyTextColorSecondary, // Use secondary text color
            fontSize: 14,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return GestureDetector(
      onTap: () {
        // Handle apply button tap
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Application submitted successfully!'),
            // --- Changed SnackBar Background Color ---
            backgroundColor: applyAccentColor, // Use accent color
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: ShapeDecoration(
          // --- Changed Apply Button Background Color ---
          color:
              applyTextColorPrimary, // Use primary text color (was #1C140C, now #1C110C)
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Center(
          child: Text(
            'Apply',
            textAlign: TextAlign.center,
            style: TextStyle(
              // --- Changed Apply Button Text Color ---
              color: Colors.white, // Keep white text for contrast
              fontSize: 16,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        // --- Changed Bottom Nav Bar Background Color ---
        color: applyBgColor, // Use main background color
        // --- Changed Top Border Color ---
        border: Border(
          top: BorderSide(width: 1, color: applyBorderColor),
        ), // Use border color
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        // --- Changed Selected Item Color ---
        selectedItemColor: applyTextColorPrimary, // Use primary text color
        // --- Changed Unselected Item Color ---
        unselectedItemColor:
            applyTextColorSecondary, // Use secondary text color
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w500,
        ),
        // --- Changed Icons to Match Colors ---
        items: [
          BottomNavigationBarItem(
            // --- Changed Icon Color ---
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0
                  ? applyTextColorPrimary
                  : applyTextColorSecondary,
            ),
            // --- Changed Active Icon Color ---
            activeIcon: Icon(Icons.home, color: applyTextColorPrimary),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.work,
              color: _selectedIndex == 1
                  ? applyTextColorPrimary
                  : applyTextColorSecondary,
            ),
            activeIcon: Icon(Icons.work, color: applyTextColorPrimary),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: _selectedIndex == 2
                  ? applyTextColorPrimary
                  : applyTextColorSecondary,
            ),
            activeIcon: Icon(Icons.add, color: applyTextColorPrimary),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.description,
              color: _selectedIndex == 3
                  ? applyTextColorPrimary
                  : applyTextColorSecondary,
            ),
            activeIcon: Icon(Icons.description, color: applyTextColorPrimary),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: _selectedIndex == 4
                  ? applyTextColorPrimary
                  : applyTextColorSecondary,
            ),
            activeIcon: Icon(Icons.settings, color: applyTextColorPrimary),
            label: 'Settings',
          ),
        ],
        onTap: _onItemTapped, // Added navigation logic
      ),
    );
  }
}
