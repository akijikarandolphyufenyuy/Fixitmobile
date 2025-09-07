import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Added
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Added

// Define colors used in SubscriptionPage for consistency
const Color cvBgColor = Color(0xFFFCF9F7); // Background color
const Color cvTextColorPrimary = Color(0xFF1C110C); // Primary text color
const Color cvTextColorSecondary = Color(0xFF996D4C); // Secondary text color
const Color cvBorderColor = Color(0xFFE8D8CE); // Border/highlight color
const Color cvAccentColor = Color(0xFFED7C26); // Accent/Orange color

class MyCvPage extends StatefulWidget {
  @override
  _MyCvPageState createState() => _MyCvPageState();
}

class _MyCvPageState extends State<MyCvPage> {
  int _selectedIndex = 3; // Applications tab selected

  // ✅ Controllers — NO hardcoded values
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // ✅ These remain as-is — not touched
  final TextEditingController _summaryController = TextEditingController(
    text:
        'Experienced plumber and electrician with over 5 years of experience in residential and commercial installations. Skilled in problem-solving and providing high-quality service to clients.',
  );
  final TextEditingController _newSkillController = TextEditingController();
  Set<String> _skills = {
    'Plumbing',
    'Electrical Wiring',
    'Pipe Fitting',
    'Circuit Installation',
    'Appliance Repair',
    'Safety Protocols',
  };
  final List<Map<String, TextEditingController>> _certificationControllers = [
    {
      'title': TextEditingController(text: 'Plumbing Certification'),
      'institution': TextEditingController(text: 'Nairobi Technical College'),
    },
  ];
  final List<Map<String, TextEditingController>> _experienceControllers = [
    {
      'position': TextEditingController(text: 'Senior Plumber'),
      'company': TextEditingController(text: 'ABC Plumbing Services'),
      'duration': TextEditingController(text: '2018 - Present'),
    },
    {
      'position': TextEditingController(text: 'Electrician Apprentice'),
      'company': TextEditingController(text: 'XYZ Electrical Ltd'),
      'duration': TextEditingController(text: '2015 - 2018'),
    },
  ];

  late Future<void> _loadPersonalInfoFuture;

  @override
  void initState() {
    super.initState();
    _loadPersonalInfoFuture = _loadPersonalInfo();
  }

  Future<void> _loadPersonalInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;

      // ✅ Populate ONLY personal info fields
      final firstName = data['firstName'] as String? ?? '';
      final lastName = data['lastName'] as String? ?? '';
      _fullNameController.text = '$firstName $lastName'.trim();
      _emailController.text = data['email'] as String? ?? user.email ?? '';
      _phoneController.text = data['phone'] as String? ?? '';
      _locationController.text = data['location'] as String? ?? '';
    } catch (e) {
      // Silently fail — don’t break the UI
      print('Error loading personal info: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

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
    context.go('/dashboard/settings');
  }

  void _onDownloadPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CV download started!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addSkill() {
    if (_newSkillController.text.trim().isNotEmpty) {
      setState(() {
        _skills.add(_newSkillController.text.trim());
        _newSkillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _addCertificationField() {
    setState(() {
      _certificationControllers.add({
        'title': TextEditingController(),
        'institution': TextEditingController(),
      });
    });
  }

  void _removeCertificationField(int index) {
    if (_certificationControllers.length > 1) {
      setState(() {
        _certificationControllers.removeAt(index);
      });
    }
  }

  void _addExperienceField() {
    setState(() {
      _experienceControllers.add({
        'position': TextEditingController(),
        'company': TextEditingController(),
        'duration': TextEditingController(),
      });
    });
  }

  void _removeExperienceField(int index) {
    if (_experienceControllers.length > 1) {
      setState(() {
        _experienceControllers.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    _newSkillController.dispose();

    for (var cert in _certificationControllers) {
      cert['title']!.dispose();
      cert['institution']!.dispose();
    }

    for (var exp in _experienceControllers) {
      exp['position']!.dispose();
      exp['company']!.dispose();
      exp['duration']!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

        return Scaffold(
          backgroundColor: cvBgColor,
          body: SafeArea(
            child: FutureBuilder<void>(
              future: _loadPersonalInfoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Personal Information'),
                              _buildEditableInfoRow(
                                'Full Name',
                                _fullNameController,
                              ),
                              _buildEditableInfoRow('Email', _emailController),
                              _buildEditableInfoRow('Phone', _phoneController),
                              _buildEditableInfoRow(
                                'Location',
                                _locationController,
                              ),
                              const SizedBox(height: 24),

                              _buildSectionTitle('Professional Summary'),
                              _buildEditableSummaryBox(),
                              const SizedBox(height: 24),

                              _buildSectionTitle('Skills'),
                              _buildEditableSkills(),
                              const SizedBox(height: 24),

                              _buildSectionTitle('Certifications'),
                              ..._buildEditableCertificationItems(),
                              const SizedBox(height: 24),

                              _buildSectionTitle('Work Experience'),
                              ..._buildEditableExperienceItems(),
                              const SizedBox(height: 32),

                              _buildDownloadButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  // ✅ All UI methods below are UNCHANGED — no modifications

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      decoration: const BoxDecoration(color: cvBgColor),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: cvTextColorPrimary),
            onPressed: () => _onBackPressed(context),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'My CV',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cvTextColorPrimary,
                fontSize: 18,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.download, color: cvTextColorPrimary),
            onPressed: _onDownloadPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: cvTextColorPrimary,
          fontSize: 22,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEditableInfoRow(String label, TextEditingController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: cvTextColorSecondary,
                fontSize: 16,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: cvTextColorPrimary,
                fontSize: 16,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableSummaryBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: cvBorderColor),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: TextField(
        controller: _summaryController,
        maxLines: 5,
        style: const TextStyle(
          color: cvTextColorPrimary,
          fontSize: 14,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w400,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter your professional summary...',
          hintStyle: TextStyle(color: cvTextColorSecondary),
        ),
      ),
    );
  }

  Widget _buildEditableSkills() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _skills.map((skill) {
              return Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: ShapeDecoration(
                  color: cvBorderColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      skill,
                      style: const TextStyle(
                        color: cvTextColorPrimary,
                        fontSize: 14,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _removeSkill(skill),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: cvTextColorPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: cvBorderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: TextField(
                    controller: _newSkillController,
                    style: const TextStyle(
                      color: cvTextColorPrimary,
                      fontSize: 14,
                      fontFamily: 'Lexend',
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Add a new skill',
                      hintStyle: TextStyle(color: cvTextColorSecondary),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _addSkill,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: ShapeDecoration(
                    color: cvAccentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEditableCertificationItems() {
    List<Widget> items = [];
    for (int i = 0; i < _certificationControllers.length; i++) {
      items.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _certificationControllers[i]['title'],
                style: const TextStyle(
                  color: cvTextColorPrimary,
                  fontSize: 16,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Certification Title',
                  hintStyle: TextStyle(color: cvTextColorSecondary),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _certificationControllers[i]['institution'],
                style: const TextStyle(
                  color: cvTextColorSecondary,
                  fontSize: 14,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Institution',
                  hintStyle: TextStyle(color: cvTextColorSecondary),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (_certificationControllers.length > 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _removeCertificationField(i),
                    child: const Text(
                      'Remove',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    items.add(
      TextButton(
        onPressed: _addCertificationField,
        child: Text(
          'Add Certification',
          style: TextStyle(color: cvAccentColor),
        ),
      ),
    );
    return items;
  }

  List<Widget> _buildEditableExperienceItems() {
    List<Widget> items = [];
    for (int i = 0; i < _experienceControllers.length; i++) {
      items.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _experienceControllers[i]['position'],
                style: const TextStyle(
                  color: cvTextColorPrimary,
                  fontSize: 16,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Position',
                  hintStyle: TextStyle(color: cvTextColorSecondary),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _experienceControllers[i]['company'],
                style: const TextStyle(
                  color: cvTextColorSecondary,
                  fontSize: 14,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Company',
                  hintStyle: TextStyle(color: cvTextColorSecondary),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _experienceControllers[i]['duration'],
                style: const TextStyle(
                  color: cvTextColorSecondary,
                  fontSize: 14,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Duration (e.g., 2018 - Present)',
                  hintStyle: TextStyle(color: cvTextColorSecondary),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (_experienceControllers.length > 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _removeExperienceField(i),
                    child: const Text(
                      'Remove',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    items.add(
      TextButton(
        onPressed: _addExperienceField,
        child: Text(
          'Add Work Experience',
          style: TextStyle(color: cvAccentColor),
        ),
      ),
    );
    return items;
  }

  Widget _buildDownloadButton() {
    return GestureDetector(
      onTap: _onDownloadPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: ShapeDecoration(
          color: cvTextColorPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Center(
          child: Text(
            'Download CV',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
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
        color: cvBgColor,
        border: Border(top: BorderSide(width: 1, color: cvBorderColor)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: cvTextColorPrimary,
        unselectedItemColor: cvTextColorSecondary,
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
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0
                  ? cvTextColorPrimary
                  : cvTextColorSecondary,
            ),
            activeIcon: Icon(Icons.home, color: cvTextColorPrimary),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.work,
              color: _selectedIndex == 1
                  ? cvTextColorPrimary
                  : cvTextColorSecondary,
            ),
            activeIcon: Icon(Icons.work, color: cvTextColorPrimary),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: _selectedIndex == 2
                  ? cvTextColorPrimary
                  : cvTextColorSecondary,
            ),
            activeIcon: Icon(Icons.add, color: cvTextColorPrimary),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.description,
              color: _selectedIndex == 3
                  ? cvTextColorPrimary
                  : cvTextColorSecondary,
            ),
            activeIcon: Icon(Icons.description, color: cvTextColorPrimary),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: _selectedIndex == 4
                  ? cvTextColorPrimary
                  : cvTextColorSecondary,
            ),
            activeIcon: Icon(Icons.settings, color: cvTextColorPrimary),
            label: 'Settings',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
