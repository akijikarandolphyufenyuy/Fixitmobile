import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Define colors used in SubscriptionPage for consistency
const Color postJobBgColor = Color(0xFFFFFFFF); // Pure white background
const Color postJobTextColorPrimary = Color(0xFF1C110C); // Primary text color
const Color postJobTextColorSecondary = Color(
  0xFF996D4C,
); // Secondary text color
const Color postJobBorderColor = Color(0xFFE8D8CE); // Border/highlight color
const Color postJobAccentColor = Color(0xFFED7C26); // Accent/Orange color

class PostJobPage extends StatefulWidget {
  @override
  _PostJobPageState createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  int _selectedIndex = 2; // Post tab selected
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _payRangeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _jobTypeController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // ✅ NEW: Store referrer from query parameter
  String? _referrer;

  // ✅ NEW: Read 'from' parameter on route change
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GoRouterState.of(context);
    _referrer = state.uri.queryParameters['from'];
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

  // ✅ UPDATED: Navigate back to referrer if exists, else fallback to home
  void _onBackPressed(BuildContext context) {
    // If user came from Assistance (or any page via ?from=...), go back there
    if (_referrer != null && _referrer!.isNotEmpty) {
      context.go(_referrer!);
    } else {
      // Otherwise, fallback to home
      context.go('/dashboard/home');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onPostJob() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('Selected Image Path: ${_selectedImage?.path}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job posted successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    _titleController.clear();
    _descriptionController.clear();
    _payRangeController.clear();
    _locationController.clear();
    _contactInfoController.clear();
    _jobTypeController.clear();
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _payRangeController.dispose();
    _locationController.dispose();
    _contactInfoController.dispose();
    _jobTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ✅ Handle system back button too
      onWillPop: () async {
        if (_referrer != null && _referrer!.isNotEmpty) {
          context.go(_referrer!);
          return false; // Prevent default pop
        }
        return true; // Allow default behavior (e.g., go to previous route or exit)
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return Scaffold(
            backgroundColor: postJobBgColor,
            body: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Job Title'),
                            _buildTextField(
                              'Enter job title',
                              _titleController,
                            ),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Job Description'),
                            _buildDescriptionField(
                              'Enter job description',
                              _descriptionController,
                            ),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Job Type'),
                            _buildTextField(
                              'Enter job type (e.g., Plumbing, Electrical)',
                              _jobTypeController,
                            ),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Pay Range'),
                            _buildTextField(
                              'Enter pay range',
                              _payRangeController,
                            ),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Contact Info'),
                            _buildTextField(
                              'Enter contact information',
                              _contactInfoController,
                            ),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Location'),
                            _buildTextField(
                              'Enter location',
                              _locationController,
                            ),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Upload Image (Optional)'),
                            _buildImagePickerField(),
                            const SizedBox(height: 32),

                            _buildPostButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      decoration: const BoxDecoration(color: postJobBgColor),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: postJobTextColorPrimary),
            onPressed: () => _onBackPressed(context),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Post a Job',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: postJobTextColorPrimary,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: postJobTextColorPrimary,
          fontSize: 16,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: postJobBorderColor),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: postJobTextColorSecondary,
            fontSize: 14,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDescriptionField(
    String hintText,
    TextEditingController controller,
  ) {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: postJobBorderColor),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: postJobTextColorSecondary,
            fontSize: 14,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildImagePickerField() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: postJobBorderColor),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.upload, color: postJobTextColorSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedImage != null
                    ? 'Image Selected'
                    : 'Tap to select an image',
                style: const TextStyle(
                  color: postJobTextColorSecondary,
                  fontSize: 14,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_selectedImage != null)
              Icon(Icons.check_circle, color: postJobAccentColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPostButton() {
    return GestureDetector(
      onTap: _onPostJob,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: ShapeDecoration(
          color: postJobAccentColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Center(
          child: Text(
            'Post Job',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
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
        color: postJobBgColor,
        border: Border(top: BorderSide(width: 1, color: postJobBorderColor)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: postJobTextColorSecondary,
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
                    ? postJobAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home,
                color: _selectedIndex == 0
                    ? Colors.black
                    : postJobTextColorSecondary,
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
                    ? postJobAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work,
                color: _selectedIndex == 1
                    ? Colors.black
                    : postJobTextColorSecondary,
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
                    ? postJobAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: _selectedIndex == 2
                    ? Colors.black
                    : postJobTextColorSecondary,
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
                    ? postJobAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description,
                color: _selectedIndex == 3
                    ? Colors.black
                    : postJobTextColorSecondary,
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
                    ? postJobAccentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings,
                color: _selectedIndex == 4
                    ? Colors.black
                    : postJobTextColorSecondary,
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
