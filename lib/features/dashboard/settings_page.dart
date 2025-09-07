import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Define colors used in SubscriptionPage for consistency
const Color settingsBgColor = Color(0xFFFFFFFF); // Pure white background
const Color settingsTextColorPrimary = Color(0xFF1C110C); // Primary text color
const Color settingsTextColorSecondary = Color(
  0xFF996D4C,
); // Secondary text color
const Color settingsBorderColor = Color(0xFFE8D8CE); // Border/highlight color
const Color settingsAccentColor = Color(0xFFED7C26); // Accent/Orange color

typedef ToggleThemeCallback = void Function();
typedef ChangeLanguageCallback = void Function(String languageCode);

class SettingsPage extends StatefulWidget {
  final ToggleThemeCallback? onToggleTheme;
  final ChangeLanguageCallback? onChangeLanguage;
  final String currentLanguageCode;

  const SettingsPage({
    Key? key,
    this.onToggleTheme,
    this.onChangeLanguage,
    this.currentLanguageCode = 'en',
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 4; // Settings tab selected
  late String _location;
  late String _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    _location = "Not set";
    _selectedLanguageCode = widget.currentLanguageCode;
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
          // Already on settings — do nothing
          break;
      }
    });
  }

  void _editLocation() {
    TextEditingController locationController = TextEditingController(
      text: _location == "Not set" ? "" : _location,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Location"),
          content: TextField(
            controller: locationController,
            decoration: const InputDecoration(hintText: "Enter your location"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _location = locationController.text.trim().isEmpty
                      ? "Not set"
                      : locationController.text.trim();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Location updated: $_location")),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _selectLanguage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("English"),
                onTap: () {
                  setState(() => _selectedLanguageCode = 'en');
                  widget.onChangeLanguage?.call('en');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Language set to English")),
                  );
                },
                selected: _selectedLanguageCode == 'en',
                selectedTileColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
              ),
              ListTile(
                title: const Text("Français"),
                onTap: () {
                  setState(() => _selectedLanguageCode = 'fr');
                  widget.onChangeLanguage?.call('fr');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Langue définie sur Français"),
                    ),
                  );
                },
                selected: _selectedLanguageCode == 'fr',
                selectedTileColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleDarkMode() {
    widget.onToggleTheme?.call();
  }

  // ✅ FIXED: Now correctly logs out and redirects to /login
  Future<void> _onLogout() async {
    try {
      await FirebaseAuth.instance.signOut();

      // ✅ Guard against unmounted context after async operation
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have been logged out.'),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ Use absolute path — '/login' is defined in your GoRouter
      context.go('/login');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final languageDisplayText = _selectedLanguageCode == 'fr'
        ? 'Français'
        : 'English';

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: settingsBgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        _buildSectionTitle('Account'),
                        _buildSettingsItem(
                          icon: Icons.person,
                          title: 'Personal Information',
                          onTap: () => context.go('/dashboard/my-cv'),
                        ),
                        _buildSettingsItem(
                          icon: Icons.workspace_premium,
                          title: 'Subscription',
                          onTap: () => context.go('/dashboard/subscription'),
                        ),
                        _buildSettingsItem(
                          icon: Icons.lock,
                          title: 'Security',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Security settings tapped'),
                              ),
                            );
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          onTap: () => context.go('/dashboard/notifications'),
                        ),
                        _buildSectionTitle('Preferences'),
                        _buildSettingsItem(
                          icon: Icons.language,
                          title: 'Language',
                          trailing: Text(languageDisplayText),
                          onTap: _selectLanguage,
                        ),
                        _buildDarkModeSettingsItem(
                          icon: Icons.dark_mode,
                          title: 'Dark Mode',
                          value: isDarkMode,
                          onChanged: _toggleDarkMode,
                        ),
                        _buildSettingsItem(
                          icon: Icons.location_on,
                          title: 'Location',
                          trailing: Text(_location),
                          onTap: _editLocation,
                        ),
                        _buildSettingsItem(
                          icon: Icons.logout,
                          title: 'Logout',
                          onTap:
                              _onLogout, // ✅ Now triggers real logout + redirect
                        ),
                        _buildSectionTitle('Support'),
                        _buildSettingsItem(
                          icon: Icons.help,
                          title: 'Help Center',
                          onTap: () =>
                              context.go('/dashboard/fixit-assistance'),
                        ),
                        _buildSettingsItem(
                          icon: Icons.feedback,
                          title: 'Send Feedback',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Feedback tapped')),
                            );
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.info,
                          title: 'About',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('About tapped')),
                            );
                          },
                        ),
                      ],
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
      decoration: const BoxDecoration(color: settingsBgColor),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: settingsAccentColor),
            onPressed: () => context.go('/dashboard/home'),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: settingsTextColorPrimary,
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

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: settingsTextColorSecondary,
          fontSize: 14,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(color: settingsBgColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: settingsAccentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Icon(icon, color: Colors.black),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: settingsTextColorPrimary,
                      fontSize: 16,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            Icon(Icons.arrow_forward_ios, size: 18, color: settingsAccentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeSettingsItem({
    required IconData icon,
    required String title,
    required bool value,
    required VoidCallback onChanged,
  }) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(color: settingsBgColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: ShapeDecoration(
              color: settingsAccentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: settingsTextColorPrimary,
                    fontSize: 16,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (bool newValue) => onChanged(),
            activeColor: settingsAccentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(width: 1, color: settingsBorderColor)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: settingsTextColorSecondary,
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
                    ? settingsAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home,
                color: _selectedIndex == 0
                    ? Colors.black
                    : settingsTextColorSecondary,
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
                    ? settingsAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work,
                color: _selectedIndex == 1
                    ? Colors.black
                    : settingsTextColorSecondary,
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
                    ? settingsAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: _selectedIndex == 2
                    ? Colors.black
                    : settingsTextColorSecondary,
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
                    ? settingsAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description,
                color: _selectedIndex == 3
                    ? Colors.black
                    : settingsTextColorSecondary,
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
                    ? settingsAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings,
                color: _selectedIndex == 4
                    ? Colors.black
                    : settingsTextColorSecondary,
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
