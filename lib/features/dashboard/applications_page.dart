import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router for navigation

// Define colors used in SubscriptionPage for consistency
// These can also be defined in a central theme/constants file
const Color appBgColor = Color(
  0xFFFFFFFF, // Pure white background
);
const Color appTextColorPrimary = Color(0xFF1C110C); // Primary text color
const Color appTextColorSecondary = Color(0xFF996D4C); // Secondary text color
const Color appBorderColor = Color(0xFFE8D8CE); // Border/highlight color
const Color appAccentColor = Color(0xFFED7C26); // Accent/Orange color

class ApplicationsPage extends StatefulWidget {
  @override
  _ApplicationsPageState createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  int _selectedIndex = 3; // Applications tab selected
  String jobTypeFilter = '';

  // Dummy data for applicants with more details
  final List<Map<String, dynamic>> allApplicants = [
    {
      'id': 1,
      'name': 'Nadia Kameni',
      'email': 'nadia.kameni@email.com',
      'phone': '+237 6 123 456 78',
      'jobType': 'Hair Styling',
      'message':
          'I have 5 years of experience in hair styling and would love to work on this project.',
      'image': 'assets/images/hair.png',
    },
    {
      'id': 2,
      'name': 'Jean-Pierre Njoya',
      'email': 'jp.njoya@email.com',
      'phone': '+237 6 234 567 89',
      'jobType': 'Plumbing',
      'message':
          'Professional plumber with 10 years experience. Available immediately.',
      'image': 'assets/images/tap.png',
    },
    {
      'id': 3,
      'name': 'Marie-Claire Ndi',
      'email': 'marie.claire@email.com',
      'phone': '+237 6 345 678 90',
      'jobType': 'Electrical',
      'message': 'Certified electrician with expertise in residential wiring.',
      'image': 'assets/images/ub1.png',
    },
    {
      'id': 4,
      'name': 'Ahmed Mbarga',
      'email': 'ahmed.mbarga@email.com',
      'phone': '+237 6 456 789 01',
      'jobType': 'Hair Styling',
      'message': 'Specialized in bridal hair styling and makeup artistry.',
      'image': 'assets/images/hair.png',
    },
    {
      'id': 5,
      'name': 'Patrice Talla',
      'email': 'patrice.talla@email.com',
      'phone': '+237 6 567 890 12',
      'jobType': 'Electrical',
      'message':
          'Experienced in both residential and commercial electrical work.',
      'image': 'assets/images/cable.png',
    },
  ];

  List<Map<String, dynamic>> filteredApplicants = [];

  @override
  void initState() {
    super.initState();
    filteredApplicants = List.from(allApplicants);
  }

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
          // Already on applications page
          break;
        case 4:
          context.go('/dashboard/settings');
          break;
      }
    });
  }

  void _onBackPressed(BuildContext context) {
    context.go('/dashboard/home');
  }

  void _applyFilters() {
    setState(() {
      if (jobTypeFilter.isEmpty) {
        filteredApplicants = List.from(allApplicants);
      } else {
        filteredApplicants = allApplicants
            .where(
              (applicant) => applicant['jobType']
                  .toString()
                  .toLowerCase()
                  .contains(jobTypeFilter.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _acceptApplication(Map<String, dynamic> applicant) {
    // Remove applicant from the list
    setState(() {
      allApplicants.removeWhere((app) => app['id'] == applicant['id']);
      filteredApplicants.removeWhere((app) => app['id'] == applicant['id']);
    });

    // Show notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Application accepted for ${applicant['name']}'),
        backgroundColor: Colors.green,
      ),
    );

    // In a real app, you would send a notification to the applicant here
    print('Notification sent: Application accepted for ${applicant['name']}');
  }

  void _declineApplication(Map<String, dynamic> applicant) {
    // Remove applicant from the list
    setState(() {
      allApplicants.removeWhere((app) => app['id'] == applicant['id']);
      filteredApplicants.removeWhere((app) => app['id'] == applicant['id']);
    });

    // Show notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Application declined for ${applicant['name']}'),
        backgroundColor: Colors.red,
      ),
    );

    // In a real app, you would send a notification to the applicant here
    print('Notification sent: Application declined for ${applicant['name']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Changed Background Color ---
      backgroundColor: appBgColor, // Use pure white background
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildFilterSection(),
            Expanded(
              // Use Expanded to take the remaining space
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: filteredApplicants.length,
                  itemBuilder: (context, index) {
                    return Container(
                      // Optional: Add padding between cards for visual separation
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildApplicantCard(filteredApplicants[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      // --- Changed AppBar Background Color ---
      decoration: const BoxDecoration(color: appBgColor), // Match background
      child: Row(
        children: [
          IconButton(
            // --- Changed Back Icon Color ---
            icon: Icon(
              Icons.arrow_back,
              color: appTextColorPrimary,
            ), // Use primary text color
            onPressed: () => _onBackPressed(context),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Applicants',
              textAlign: TextAlign.center,
              style: TextStyle(
                // --- Changed App Title Color ---
                color: appTextColorPrimary, // Use primary text color
                fontSize: 18,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(width: 48), // Placeholder for symmetry
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Job type',
          hintStyle: TextStyle(
            color: appTextColorSecondary,
            fontSize: 14,
            fontFamily: 'Lexend',
          ),
          filled: true,
          fillColor: appBorderColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        style: TextStyle(
          color: appTextColorPrimary,
          fontSize: 14,
          fontFamily: 'Lexend',
        ),
        onChanged: (value) {
          setState(() {
            jobTypeFilter = value;
          });
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildApplicantCard(Map<String, dynamic> applicant) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate a responsive image width, e.g., 30% of the card's width, capped at a max
          final double maxImageWidth =
              100.0; // Absolute max width for the image
          final double calculatedImageWidth =
              constraints.maxWidth * 0.30; // 30% of available width
          final double imageWidth = calculatedImageWidth > maxImageWidth
              ? maxImageWidth
              : calculatedImageWidth;

          // Ensure a minimum image width for very small screens
          final double finalImageWidth = imageWidth < 60.0 ? 60.0 : imageWidth;

          // Calculate image height proportional to width or set a fixed responsive height
          final double imageHeight =
              finalImageWidth * 0.9; // e.g., keep a 10:9 aspect ratio

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align items to the top
                children: [
                  // 1. Applicant Info (Expanded to take remaining space)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize:
                          MainAxisSize.min, // Shrink to fit content height
                      children: [
                        Text(
                          applicant['name'],
                          style: const TextStyle(
                            // --- Changed Applicant Name Color ---
                            color:
                                appTextColorPrimary, // Use primary text color
                            fontSize: 16,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          applicant['email'],
                          style: const TextStyle(
                            color: appTextColorSecondary,
                            fontSize: 14,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          applicant['phone'],
                          style: const TextStyle(
                            color: appTextColorSecondary,
                            fontSize: 14,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Job Type: ${applicant['jobType']}',
                          style: const TextStyle(
                            color: appTextColorPrimary,
                            fontSize: 14,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16), // Space between text and image
                  // 2. Applicant Image (Constrained in size)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: finalImageWidth,
                        maxHeight: imageHeight,
                      ),
                      child: Image.asset(
                        applicant['image'],
                        width: finalImageWidth, // Use the calculated width
                        height: imageHeight, // Use the calculated height
                        fit: BoxFit.cover, // Cover the allocated space
                        errorBuilder: (context, error, stackTrace) {
                          // Handle image loading errors gracefully
                          return Container(
                            width: finalImageWidth,
                            height: imageHeight,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error, color: Colors.red),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                applicant['message'],
                style: const TextStyle(
                  color: appTextColorPrimary,
                  fontSize: 14,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _acceptApplication(applicant),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const ShapeDecoration(
                          color: appAccentColor, // Orange color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Accept',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _declineApplication(applicant),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const ShapeDecoration(
                          color: appAccentColor, // Orange color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Decline',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        // --- Changed Bottom Nav Bar Background Color ---
        color: Colors.white, // Use pure white background
        // --- Changed Top Border Color ---
        border: Border(
          top: BorderSide(width: 1, color: appBorderColor),
        ), // Use border color
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        // --- Changed Selected Item Color ---
        selectedItemColor: Colors.black, // Black for selected items
        // --- Changed Unselected Item Color ---
        unselectedItemColor:
            appTextColorSecondary, // Use secondary text color for unselected
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
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _selectedIndex == 0
                    ? appAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home,
                color: _selectedIndex == 0
                    ? Colors.black
                    : appTextColorSecondary,
                size: 18,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _selectedIndex == 1
                    ? appAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work,
                color: _selectedIndex == 1
                    ? Colors.black
                    : appTextColorSecondary,
                size: 18,
              ),
            ),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _selectedIndex == 2
                    ? appAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: _selectedIndex == 2
                    ? Colors.black
                    : appTextColorSecondary,
                size: 18,
              ),
            ),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _selectedIndex == 3
                    ? appAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description,
                color: _selectedIndex == 3
                    ? Colors.black
                    : appTextColorSecondary,
                size: 18,
              ),
            ),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _selectedIndex == 4
                    ? appAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings,
                color: _selectedIndex == 4
                    ? Colors.black
                    : appTextColorSecondary,
                size: 18,
              ),
            ),
            label: 'Settings',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
