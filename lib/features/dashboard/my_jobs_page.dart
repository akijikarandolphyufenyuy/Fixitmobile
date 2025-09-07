import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Define colors used in SubscriptionPage for consistency
const Color myJobsBgColor = Color(0xFFFCF9F7); // Background color
const Color myJobsTextColorPrimary = Color(0xFF1C110C); // Primary text color
const Color myJobsTextColorSecondary = Color(
  0xFF996D4C,
); // Secondary text color
const Color myJobsBorderColor = Color(0xFFE8D8CE); // Border/highlight color
const Color myJobsAccentColor = Color(0xFFED7C26); // Accent/Orange color

class MyJobsPage extends StatefulWidget {
  @override
  _MyJobsPageState createState() => _MyJobsPageState();
}

class _MyJobsPageState extends State<MyJobsPage> {
  int _selectedIndex = 1; // Jobs tab selected

  // Dummy data for jobs
  final List<Map<String, dynamic>> jobs = [
    {
      'status': 'Pending',
      'title': 'Plumbing Repair',
      'applicants': '12 Applicants',
      'image': 'assets/images/ub1.png',
      'action': 'Edit',
    },
    {
      'status': 'Closed',
      'title': 'Electrical Wiring',
      'applicants': '5 Applicants',
      'image': 'assets/images/ub2.png',
      'action': 'View',
    },
    {
      'status': 'Pending',
      'title': 'Appliance Installation',
      'applicants': '8 Applicants',
      'image': 'assets/images/cable.png',
      'action': 'Edit',
    },
    {
      'status': 'Closed',
      'title': 'Painting Services',
      'applicants': '3 Applicants',
      'image': 'assets/images/tap.png',
      'action': 'View',
    },
  ];

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
              myJobsBgColor, // Use SubscriptionPage background color
          body: SafeArea(
            child: Column(
              children: [
                // App Bar Section
                _buildAppBar(context),

                // Jobs List
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        return _buildJobCard(jobs[index]);
                      },
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
      decoration: const BoxDecoration(color: myJobsBgColor), // Match background
      child: Row(
        children: [
          // Back Button
          IconButton(
            // --- Changed Back Icon Color ---
            icon: Icon(
              Icons.arrow_back,
              color: myJobsTextColorPrimary,
            ), // Use primary text color
            onPressed: () => _onBackPressed(context),
          ),

          const SizedBox(width: 8),

          // Title
          const Expanded(
            child: Text(
              'My Jobs',
              textAlign: TextAlign.center,
              style: TextStyle(
                // --- Changed App Title Color ---
                color: myJobsTextColorPrimary, // Use primary text color
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

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['status'],
                    style: const TextStyle(
                      // --- Changed Status Text Color ---
                      color:
                          myJobsTextColorSecondary, // Use secondary text color
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job['title'],
                    style: const TextStyle(
                      // --- Changed Title Text Color ---
                      color: myJobsTextColorPrimary, // Use primary text color
                      fontSize: 16,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job['applicants'],
                    style: const TextStyle(
                      // --- Changed Applicants Text Color ---
                      color:
                          myJobsTextColorSecondary, // Use secondary text color
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      // Handle action button tap
                      if (job['action'] == 'Edit') {
                        // Navigate to edit job page
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Edit ${job['title']}'),
                            // --- Changed SnackBar Background Color ---
                            backgroundColor:
                                myJobsAccentColor, // Use accent color
                          ),
                        );
                      } else {
                        // Navigate to view applicants page
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('View ${job['title']} applicants'),
                            // --- Changed SnackBar Background Color ---
                            backgroundColor:
                                myJobsAccentColor, // Use accent color
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 84,
                      height: 32,
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      decoration: ShapeDecoration(
                        // --- Changed Action Button Background Color ---
                        color:
                            myJobsBorderColor, // Use border color for button background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            job['action'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              // --- Changed Action Button Text Color ---
                              color:
                                  myJobsTextColorPrimary, // Use primary text color
                              fontSize: 14,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(
                            // --- Changed Action Icon Color ---
                            Icons.arrow_forward_ios,
                            size: 18,
                            color:
                                myJobsTextColorPrimary, // Use primary text color
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                job['image'],
                width: 130,
                height: 118,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        // --- Changed Bottom Nav Bar Background Color ---
        color: myJobsBgColor, // Use main background color
        // --- Changed Top Border Color ---
        border: Border(
          top: BorderSide(
            width: 1,
            color: myJobsBorderColor, // Use border color
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        // --- Changed Selected Item Color ---
        selectedItemColor: myJobsTextColorPrimary, // Use primary text color
        // --- Changed Unselected Item Color ---
        unselectedItemColor:
            myJobsTextColorSecondary, // Use secondary text color
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
                  ? myJobsTextColorPrimary
                  : myJobsTextColorSecondary,
            ),
            // --- Changed Active Icon Color ---
            activeIcon: Icon(Icons.home, color: myJobsTextColorPrimary),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.work,
              color: _selectedIndex == 1
                  ? myJobsTextColorPrimary
                  : myJobsTextColorSecondary,
            ),
            activeIcon: Icon(Icons.work, color: myJobsTextColorPrimary),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: _selectedIndex == 2
                  ? myJobsTextColorPrimary
                  : myJobsTextColorSecondary,
            ),
            activeIcon: Icon(Icons.add, color: myJobsTextColorPrimary),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.description,
              color: _selectedIndex == 3
                  ? myJobsTextColorPrimary
                  : myJobsTextColorSecondary,
            ),
            activeIcon: Icon(Icons.description, color: myJobsTextColorPrimary),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: _selectedIndex == 4
                  ? myJobsTextColorPrimary
                  : myJobsTextColorSecondary,
            ),
            activeIcon: Icon(Icons.settings, color: myJobsTextColorPrimary),
            label: 'Settings',
          ),
        ],
        onTap: _onItemTapped, // Added navigation logic
      ),
    );
  }
}
