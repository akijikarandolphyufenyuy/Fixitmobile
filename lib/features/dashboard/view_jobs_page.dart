import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ViewJobsPage extends StatefulWidget {
  // Changed from St8 to ViewJobsPage
  @override
  State<ViewJobsPage> createState() => _ViewJobsPageState();
}

class _ViewJobsPageState extends State<ViewJobsPage> {
  int _selectedIndex = 1; // Jobs tab selected
  String jobTypeFilter = '';
  bool sortByPayRange = false;
  String searchQuery = '';
  String _previousRoute = '/home'; // Track previous route

  // Dummy data for jobs with numeric pay values for sorting
  final List<Map<String, dynamic>> allJobs = [
    {
      'isNew': true,
      'title': 'Plumbing Repair',
      'description': 'Fix leaky pipes in residential building',
      'pay': 'KSh 5,000 - 8,000',
      'payValue': 8000,
      'image': 'assets/images/ub1.png',
    },
    {
      'isNew': true,
      'title': 'Electrical Wiring',
      'description': 'Install new electrical systems in office',
      'pay': 'KSh 10,000 - 15,000',
      'payValue': 15000,
      'image': 'assets/images/hair.png',
    },
    {
      'isNew': false,
      'title': 'Appliance Installation',
      'description': 'Install kitchen appliances for new home',
      'pay': 'KSh 3,000 - 5,000',
      'payValue': 5000,
      'image': 'assets/images/cable.png',
    },
    {
      'isNew': true,
      'title': 'Painting Services',
      'description': 'Paint interior walls of 3-bedroom apartment',
      'pay': 'KSh 7,000 - 12,000',
      'payValue': 12000,
      'image': 'assets/images/tap.png',
    },
    {
      'isNew': true,
      'title': 'Electrical Maintenance',
      'description': 'Routine electrical maintenance for commercial building',
      'pay': 'KSh 8,000 - 10,000',
      'payValue': 10000,
      'image': 'assets/images/cable.png',
    },
  ];

  List<Map<String, dynamic>> filteredJobs = [];

  @override
  void initState() {
    super.initState();
    filteredJobs = List.from(allJobs);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Track the previous route when this page is accessed
    final routeInformation = GoRouter.of(
      context,
    ).routeInformationProvider.value;
    final referringRoute =
        routeInformation.uri.queryParameters['from'] ?? '/dasboard/home';
    _previousRoute = referringRoute;
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
          context.go('/dashboard/applications');
          break;
        case 4:
          context.go('/dashboard/settings');
          break;
      }
    });
  }

  void _onBackPressed(BuildContext context) {
    // Navigate back to the previous page
    if (_previousRoute == '/dashboards/fixit-assistance') {
      context.go('/dashboard/fixit-assistance');
    } else {
      context.go('/dashboard/home');
    }
  }

  void _onApplyPressed(String jobTitle) {
    // Navigate to apply page
    context.go('/dashboard/apply-jobs');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applying for $jobTitle'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      List<Map<String, dynamic>> tempJobs = List.from(allJobs);

      // Apply job type filter (from both input field and search icon)
      String filterText = jobTypeFilter.isNotEmpty
          ? jobTypeFilter
          : searchQuery;
      if (filterText.isNotEmpty) {
        tempJobs = tempJobs.where((job) {
          return job['title'].toString().toLowerCase().contains(
            filterText.toLowerCase(),
          );
        }).toList();
      }

      // Apply pay range sorting
      if (sortByPayRange) {
        tempJobs.sort((a, b) => b['payValue'].compareTo(a['payValue']));
      }

      filteredJobs = tempJobs;
    });
  }

  void _onSearchPressed() {
    // Apply search filter
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

        return Scaffold(
          backgroundColor: const Color(0xFFFFFFFF), // Pure white background
          body: SafeArea(
            child: Column(
              children: [
                // App Bar Section
                _buildAppBar(context),

                // Welcome Message
                _buildWelcomeMessage(),

                // Filter Section (Job Type and Pay Range side by side)
                _buildFilterSection(),

                // Jobs List
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: filteredJobs.length,
                      itemBuilder: (context, index) {
                        return _buildJobCard(filteredJobs[index], index);
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
      decoration: const BoxDecoration(color: Color(0xFFFFFFFF)), // Pure white
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFED7C26),
            ), // Orange color
            onPressed: () => _onBackPressed(context),
          ),

          const SizedBox(width: 8),

          // Title
          const Expanded(
            child: Text(
              'Available Jobs',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1C140C),
                fontSize: 18,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Search Icon
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1C140C)),
            onPressed: _onSearchPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: const Text(
        'Find Jobs That Match Your Skills',
        style: TextStyle(
          color: Color(0xFF1C140C),
          fontSize: 24,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Job Type Filter Input
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Job type',
                hintStyle: TextStyle(
                  color: Color(0xFF99704C),
                  fontSize: 14,
                  fontFamily: 'Lexend',
                ),
                filled: true,
                fillColor: Color(0xFFF2EDE8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF1C140C),
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
          ),
          const SizedBox(width: 12),

          // Pay Range Filter Button
          GestureDetector(
            onTap: () {
              setState(() {
                sortByPayRange = !sortByPayRange;
              });
              _applyFilters();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: sortByPayRange
                    ? const Color(0xFFED7C26) // Light orange when active
                    : const Color(0xFFF2EDE8),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Text(
                    'Pay Range',
                    style: TextStyle(
                      color: sortByPayRange
                          ? Colors.black
                          : const Color(0xFF1C140C),
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    sortByPayRange ? Icons.arrow_downward : Icons.arrow_upward,
                    color: sortByPayRange
                        ? Colors.black
                        : const Color(0xFF99704C),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (job['isNew'])
                        const Text(
                          'New',
                          style: TextStyle(
                            color: Color(0xFF99704C),
                            fontSize: 14,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        job['title'],
                        style: const TextStyle(
                          color: Color(0xFF1C140C),
                          fontSize: 16,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['description'],
                        style: const TextStyle(
                          color: Color(0xFF99704C),
                          fontSize: 14,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['pay'],
                        style: const TextStyle(
                          color: Color(0xFF1C140C),
                          fontSize: 14,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w700,
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
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _onApplyPressed(job['title']),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: const ShapeDecoration(
                  color: Color(0xFFED7C26), // Light orange background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Apply Now',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black, // Black text
                      fontSize: 16,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
        color: Color(0xFFFFFFFF), // Pure white background
        border: Border(top: BorderSide(width: 1, color: Color(0xFFF2EDE8))),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black, // Black for selected items
        unselectedItemColor: const Color(0xFF99704C),
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
        items: [
          BottomNavigationBarItem(
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _selectedIndex == 0
                    ? const Color(0xFFED7C26) // Light orange background
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home,
                color: _selectedIndex == 0
                    ? Colors.black
                    : const Color(0xFF99704C),
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
                    ? const Color(0xFFED7C26) // Light orange background
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work,
                color: _selectedIndex == 1
                    ? Colors.black
                    : const Color(0xFF99704C),
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
                    ? const Color(0xFFED7C26) // Light orange background
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: _selectedIndex == 2
                    ? Colors.black
                    : const Color(0xFF99704C),
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
                    ? const Color(0xFFED7C26) // Light orange background
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description,
                color: _selectedIndex == 3
                    ? Colors.black
                    : const Color(0xFF99704C),
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
                    ? const Color(0xFFED7C26) // Light orange background
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings,
                color: _selectedIndex == 4
                    ? Colors.black
                    : const Color(0xFF99704C),
                size: 18,
              ),
            ),
            label: 'Settings',
          ),
        ],
        onTap: _onItemTapped, // Added navigation logic
      ),
    );
  }
}
