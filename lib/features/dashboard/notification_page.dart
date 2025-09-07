import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Define colors used in SubscriptionPage for consistency
const Color notifBgColor = Color(0xFFFFFFFF); // Pure white background
const Color notifTextColorPrimary = Color(0xFF1C110C); // Primary text color
const Color notifTextColorSecondary = Color(0xFF996D4C); // Secondary text color
const Color notifBorderColor = Color(0xFFE8D8CE); // Border/highlight color
const Color notifAccentColor = Color(0xFFED7C26); // Accent/Orange color

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 3; // Applications tab selected

  // Dummy data for notifications
  final List<Map<String, dynamic>> notifications = [
    {
      'isNew': true,
      'title': 'You have a new job match',
      'time': '1h',
      'image': 'assets/images/cable.png',
    },
    {
      'isNew': true,
      'title': 'Your application was accepted',
      'time': '2h',
      'image': 'assets/images/tap.png',
    },
    {
      'isNew': false,
      'title': 'You have a new message',
      'time': '3h',
      'image': 'assets/images/hair.png',
    },
    {
      'isNew': false,
      'title': 'Your application was rejected',
      'time': '1d',
      'image': 'assets/images/cable.png',
    },
    {
      'isNew': false,
      'title': 'You have a new job match',
      'time': '2d',
      'image': 'assets/images/ub1.png',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // ✅ FIXED: Use correct /dashboard/... paths
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

  void _onBackPressed(BuildContext context) {
    final state = GoRouterState.of(context);
    if (state.uri.toString() == '/dashboard/notifications' &&
        state.uri.queryParameters['from'] == 'settings') {
      context.go('/dashboard/settings');
    } else {
      context.go('/dashboard/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

        return Scaffold(
          backgroundColor: notifBgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(notifications[index]);
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
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      decoration: const BoxDecoration(color: notifBgColor),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: notifAccentColor),
            onPressed: () => _onBackPressed(context),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Notifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: notifTextColorPrimary,
                fontSize: 18,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(width: 48),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notification['title']),
            backgroundColor: notifAccentColor,
          ),
        );
      },
      child: Container(
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
                    if (notification['isNew'])
                      Text(
                        'New',
                        style: const TextStyle(
                          color: notifTextColorSecondary,
                          fontSize: 14,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      notification['title'],
                      style: const TextStyle(
                        color: notifTextColorPrimary,
                        fontSize: 16,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['time'],
                      style: const TextStyle(
                        color: notifTextColorSecondary,
                        fontSize: 14,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  notification['image'],
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(width: 1, color: notifBorderColor)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: notifTextColorSecondary,
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
                    ? notifAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home,
                color: _selectedIndex == 0
                    ? Colors.black
                    : notifTextColorSecondary,
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
                    ? notifAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work,
                color: _selectedIndex == 1
                    ? Colors.black
                    : notifTextColorSecondary,
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
                    ? notifAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: _selectedIndex == 2
                    ? Colors.black
                    : notifTextColorSecondary,
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
                    ? notifAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description,
                color: _selectedIndex == 3
                    ? Colors.black
                    : notifTextColorSecondary,
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
                    ? notifAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings,
                color: _selectedIndex == 4
                    ? Colors.black
                    : notifTextColorSecondary,
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
