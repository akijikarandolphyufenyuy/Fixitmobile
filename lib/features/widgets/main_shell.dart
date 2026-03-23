import 'package:flutter/material.dart';

import '../dashboard/home_page.dart';
import '../dashboard/view_jobs_page.dart';
import '../dashboard/post_job_page.dart';
import '../dashboard/applications_page.dart';
import '../dashboard/settings_page.dart';
import '../widgets/app_nav_bar.dart';
import '../../theme_provider.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomePage(),
          const ViewJobsPage(),
          const PostJobPage(),
          const ApplicationsPage(),
          SettingsPage(onToggleTheme: themeProvider.toggleTheme),
        ],
      ),
      bottomNavigationBar: AppNavBar(
        selectedIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}
