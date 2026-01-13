import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:async';

// Define colors used in SubscriptionPage for consistency
const Color homeBgColor = Color(0xFFFFFFFF);
const Color homeTextColorPrimary = Color(0xFF1C110C);
const Color homeTextColorSecondary = Color(0xFF996D4C);
const Color homeBorderColor = Color(0xFFE8D8CE);
const Color homeAccentColor = Color(0xFFED7C26);

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImageFile;
  Timer? _timer;
  DateTime _cameroonTime = DateTime.now().toUtc().add(const Duration(hours: 1));

  final List<Map<String, dynamic>> allJobs = [
    {
      'isNew': true,
      'title': 'Plumbing repair',
      'description': 'Fix a leaky faucet in a residential building',
      'image': 'assets/images/tap.png',
      'payRange': 15000,
    },
    {
      'isNew': true,
      'title': 'Electrical wiring',
      'description': 'Install new lighting fixtures in an office space',
      'image': 'assets/images/cable.png',
      'payRange': 25000,
    },
    {
      'isNew': true,
      'title': 'Hair styling',
      'description': 'Provide hair styling services for a wedding event',
      'image': 'assets/images/hair.png',
      'payRange': 12000,
    },
    {
      'isNew': false,
      'title': 'Electrical maintenance',
      'description': 'Routine electrical maintenance for commercial building',
      'image': 'assets/images/cable.png',
      'payRange': 18000,
    },
    {
      'isNew': true,
      'title': 'Hair cutting',
      'description': 'Professional hair cutting services',
      'image': 'assets/images/hair.png',
      'payRange': 8000,
    },
  ];

  List<Map<String, dynamic>> filteredJobs = [];
  String jobTypeFilter = '';
  bool sortByPayRange = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _cameroonTime = DateTime.now().toUtc().add(const Duration(hours: 1));
      });
    });
    _cameroonTime = DateTime.now().toUtc().add(const Duration(hours: 1));
    filteredJobs = List.from(allJobs);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          context.go('/dashboard/home');
          break;
        case 1:
          context.go('/dashboard/jobs');
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

  void _onNotificationPressed() {
    context.go('/dashboard/notifications');
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      List<Map<String, dynamic>> tempJobs = List.from(allJobs);
      if (jobTypeFilter.isNotEmpty) {
        tempJobs = tempJobs.where((job) {
          return job['title'].toString().toLowerCase().contains(
            jobTypeFilter.toLowerCase(),
          );
        }).toList();
      }
      if (sortByPayRange) {
        tempJobs.sort((a, b) => b['payRange'].compareTo(a['payRange']));
      }
      filteredJobs = tempJobs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;
        return Scaffold(
          backgroundColor: homeBgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                _buildWelcomeMessageWithCameroonTime(),
                _buildJobsHeader(),
                _buildFilterSection(),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: filteredJobs.length,
                      itemBuilder: (context, index) {
                        return _buildJobCard(filteredJobs[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(color: homeBgColor),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: homeTextColorPrimary, width: 2),
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _profileImageFile != null
                        ? FileImage(_profileImageFile!)
                        : const AssetImage('assets/images/profile.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Fixit',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: homeTextColorPrimary,
                fontSize: 20,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: homeTextColorPrimary),
            onPressed: _onNotificationPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessageWithCameroonTime() {
    final String? passedName = GoRouterState.of(context).extra as String?;

    // ✅ If no name is passed, show empty string — NO fallback like "User"
    final displayName = passedName ?? '';

    final String formattedDate = DateFormat(
      'EEEE, MMMM d, yyyy',
      'en_US',
    ).format(_cameroonTime);
    final String formattedTime = DateFormat(
      'h:mm a',
      'en_US',
    ).format(_cameroonTime);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayName.isNotEmpty)
            Text(
              'Welcome back, $displayName! We Missed You.',
              style: const TextStyle(
                color: homeTextColorPrimary,
                fontSize: 24,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
              ),
            )
          else
            const SizedBox(), // Show nothing if no name
          const SizedBox(height: 8),
          Text(
            '$formattedDate • $formattedTime (WAT)',
            style: const TextStyle(
              color: homeTextColorSecondary,
              fontSize: 14,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        'Jobs matching your skills',
        style: const TextStyle(
          color: homeTextColorPrimary,
          fontSize: 18,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Job type',
                    hintStyle: TextStyle(
                      color: homeTextColorSecondary,
                      fontSize: 14,
                      fontFamily: 'Lexend',
                    ),
                    filled: true,
                    fillColor: homeBorderColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(
                    color: homeTextColorPrimary,
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
              GestureDetector(
                onTap: () {
                  setState(() {
                    sortByPayRange = !sortByPayRange;
                  });
                  _applyFilters();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: sortByPayRange ? homeAccentColor : homeBorderColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pay Range',
                        style: TextStyle(
                          color: sortByPayRange
                              ? Colors.black
                              : homeTextColorPrimary,
                          fontSize: 14,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        sortByPayRange
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: sortByPayRange
                            ? Colors.black
                            : homeTextColorSecondary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Upload profile',
            style: TextStyle(
              color: homeTextColorSecondary,
              fontSize: 12,
              fontFamily: 'Lexend',
            ),
          ),
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
                  if (job['isNew'])
                    Text(
                      'New',
                      style: const TextStyle(
                        color: homeTextColorSecondary,
                        fontSize: 14,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    job['title'],
                    style: const TextStyle(
                      color: homeTextColorPrimary,
                      fontSize: 16,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job['description'],
                    style: const TextStyle(
                      color: homeTextColorSecondary,
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₦${job['payRange'].toString()}',
                    style: const TextStyle(
                      color: homeAccentColor,
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(width: 1, color: homeBorderColor)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: homeTextColorSecondary,
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
                    ? homeAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home,
                color: _selectedIndex == 0
                    ? Colors.black
                    : homeTextColorSecondary,
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
                    ? homeAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work,
                color: _selectedIndex == 1
                    ? Colors.black
                    : homeTextColorSecondary,
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
                    ? homeAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: _selectedIndex == 2
                    ? Colors.black
                    : homeTextColorSecondary,
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
                    ? homeAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description,
                color: _selectedIndex == 3
                    ? Colors.black
                    : homeTextColorSecondary,
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
                    ? homeAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings,
                color: _selectedIndex == 4
                    ? Colors.black
                    : homeTextColorSecondary,
                size: 18,
              ),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
