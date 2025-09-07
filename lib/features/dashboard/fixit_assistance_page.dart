import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router for navigation

// Define colors used in SubscriptionPage for consistency
const Color assistBgColor = Color(0xFFFFFFFF); // Pure white background
const Color assistTextColorPrimary = Color(0xFF1C110C); // Primary text color
const Color assistTextColorSecondary = Color(
  0xFF996D4C,
); // Secondary text color
const Color assistBorderColor = Color(0xFFE8D8CE); // Border/highlight color
const Color assistAccentColor = Color(0xFFED7C26); // Accent/Orange color

class FixitAssistancePage extends StatefulWidget {
  @override
  _FixitAssistancePageState createState() => _FixitAssistancePageState();
}

class _FixitAssistancePageState extends State<FixitAssistancePage> {
  final TextEditingController _textController = TextEditingController();
  int _selectedIndex =
      0; // Assuming home, adjust based on how you navigate here

  // Dummy data for chat messages
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'assistant',
      'text':
          "Hello there! I'm here to help you navigate Fixit. What can I assist you with today?",
      'time': '10:00 AM',
    },
    {
      'sender': 'assistant',
      'text':
          "You can ask me to:\n- Post a job\n- Apply for a job\n- Navigate the app\n- Show helpful tips",
      'time': '10:01 AM',
    },
    {
      'sender': 'assistant',
      'text': "Or, you can use the quick actions below:",
      'time': '10:01 AM',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Navigate using GoRouter
      switch (index) {
        case 0:
          context.go('/dashboard/home'); // Adjusted back to home for index 0
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
    context.go('/dashboard/settings');
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'sender': 'user',
          'text': _textController.text,
          'time':
              '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        });
        // Simulate a response after a short delay
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _messages.add({
              'sender': 'assistant',
              'text':
                  "Thanks for your message! I'm a demo assistant. In a real app, I'd provide helpful responses.",
              'time':
                  '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
            });
          });
        });
      });
      _textController.clear();
    }
  }

  void _handleQuickAction(String action) {
    String response = "";
    switch (action) {
      case 'Start Job Post':
        context.go('/dashboard/post-job');
        return;
      case 'Find a Job':
        // ✅ Tapping "Find a Job" navigates to View Jobs page — as requested
        context.go('/dashboard/view-jobs');
        return;
      case 'Show Me Around':
        response =
            "Here's a quick tour:\n1. Home: See job matches\n2. Jobs: Browse available jobs\n3. Post: Create a job listing\n4. Applications: Track your applications\n5. Settings: Manage your account";
        break;
      default:
        response = "Action '$action' triggered.";
    }

    setState(() {
      _messages.add({
        'sender': 'assistant',
        'text': response,
        'time':
            '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if the screen is wide (e.g., tablet or desktop)
        final bool isWideScreen = constraints.maxWidth > 700;

        // --- Changed Scaffold Background Color ---
        return Scaffold(
          backgroundColor: assistBgColor, // Use pure white background
          body: SafeArea(
            child: Column(
              children: [
                // App Bar Section
                _buildAppBar(context),

                // Chat Messages - Takes up available space
                Expanded(
                  child: Container(
                    // Removed fixed padding values that could cause issues on different screens
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: LayoutBuilder(
                      builder: (context, innerConstraints) {
                        return ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(
                              _messages[index],
                              innerConstraints.maxWidth,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Quick Actions
                _buildQuickActions(isWideScreen),

                // Input Area
                _buildInputArea(),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ), // Reduced vertical padding
      // --- Changed AppBar Background Color ---
      decoration: const BoxDecoration(color: assistBgColor), // Match background
      child: Row(
        children: [
          // Back Button
          IconButton(
            // --- Changed Back Icon Color ---
            icon: Icon(
              Icons.arrow_back,
              color: assistAccentColor, // Use accent color
            ), // Use primary text color
            onPressed: () => _onBackPressed(context),
            // Ensure the IconButton has a reasonable size
            iconSize: 24.0,
          ),
          const SizedBox(width: 8),
          // Title
          const Expanded(
            child: Text(
              'Fixit Assistant',
              textAlign: TextAlign.center,
              style: TextStyle(
                // --- Changed App Title Color ---
                color: assistTextColorPrimary, // Use primary text color
                fontSize: 18,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Placeholder for symmetry (approximate width of IconButton + spacing)
          const SizedBox(width: 32), // Reduced width for better balance
        ],
      ),
    );
  }

  // Make message bubble width highly responsive and prevent overflow
  Widget _buildMessageBubble(Map<String, dynamic> message, double maxWidth) {
    bool isUser = message['sender'] == 'user';
    // Dynamically calculate a safe max width for the message content
    // Leave a margin for avatars and spacing
    final double safeAreaWidth =
        maxWidth -
        40 -
        12 -
        40 -
        12; // avatar1(40) + space1(12) + space2(12) + avatar2(40)
    // Ensure a minimum width and a reasonable maximum
    final double messageMaxWidth = safeAreaWidth.clamp(100.0, 500.0);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
      ), // Reduced vertical padding between messages
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end, // Align to bottom
        children: [
          if (!isUser) // Assistant avatar
            CircleAvatar(
              radius: 20, // Use CircleAvatar for better built-in responsiveness
              backgroundImage: const AssetImage('assets/images/cable.png'),
              // If the image fails, provide a fallback
              onBackgroundImageError: (exception, stackTrace) {
                // Handle error silently or provide a default icon
              },
              // --- Changed Assistant Avatar Background Color (Optional) ---
              // If you want a background color for the avatar, you can add it here
              // backgroundColor: assistBorderColor.withOpacity(0.3),
            ),
          if (!isUser) const SizedBox(width: 12),
          // Use Flexible to allow the ConstrainedBox to shrink if needed
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: messageMaxWidth),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: ShapeDecoration(
                  // --- Changed Message Bubble Colors ---
                  color: isUser
                      ? assistTextColorPrimary // Use primary color for user messages
                      : assistBorderColor, // Use border color for assistant messages
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  message['text'],
                  style: const TextStyle(
                    // --- Changed Message Text Color ---
                    color:
                        assistTextColorPrimary, // Use primary text color for text
                    fontSize: 16,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 12),
          if (isUser) // User avatar
            CircleAvatar(
              radius: 20,
              backgroundImage: const AssetImage('assets/images/profile.jpg'),
              onBackgroundImageError: (exception, stackTrace) {
                // Handle error
              },
              // --- Changed User Avatar Background Color (Optional) ---
              // backgroundColor: assistAccentColor.withOpacity(0.3),
            ),
        ],
      ),
    );
  }

  // Make quick actions responsive (e.g., row for wide screens)
  Widget _buildQuickActions(bool isWideScreen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (isWideScreen) {
            // For wide screens, arrange buttons in a Row
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Start Job Post',
                    assistAccentColor, // Use accent color
                  ),
                ),
                const SizedBox(width: 12), // Spacing between buttons
                Expanded(
                  child: _buildActionButton(
                    'Find a Job',
                    assistBorderColor, // Use border color
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Show Me Around',
                    assistBorderColor, // Use border color
                  ),
                ),
              ],
            );
          } else {
            // For narrow screens, keep the Column layout
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                _buildActionButton(
                  'Start Job Post',
                  assistAccentColor,
                ), // Use accent color
                _buildActionButton(
                  'Find a Job',
                  assistBorderColor,
                ), // Use border color
                _buildActionButton(
                  'Show Me Around',
                  assistBorderColor,
                ), // Use border color
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildActionButton(String text, Color color) {
    return GestureDetector(
      onTap: () => _handleQuickAction(text),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          // --- Changed Action Button Background Color ---
          color: color, // Use the passed color (accent or border)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              // --- Changed Action Button Text Color ---
              color: assistTextColorPrimary, // Use primary text color
              fontSize: 14,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w700,
              height: 1.50,
            ),
            // Prevent text overflow
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 48,
              ), // Ensure minimum height
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 48,
                      ), // Match parent height
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      clipBehavior: Clip.antiAlias,
                      decoration: const ShapeDecoration(
                        // --- Changed Input Field Background Color ---
                        color:
                            assistBorderColor, // Use border color for input background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          // --- Changed Hint Text Color ---
                          hintText: 'Ask me anything...',
                          hintStyle: TextStyle(
                            color:
                                assistTextColorSecondary, // Use secondary text color
                            fontSize: 16,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          // Remove content padding to prevent internal overflow
                          contentPadding: EdgeInsets.zero,
                          isDense: true, // Helps control height
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        // Allow text to wrap if needed
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 48,
                      ), // Match parent height
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: const ShapeDecoration(
                        // --- Changed Send Button Background Color ---
                        color:
                            assistBorderColor, // Use border color for send button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: Icon(
                        // --- Changed Send Icon Color ---
                        Icons.send,
                        color: assistTextColorPrimary, // Use primary text color
                      ),
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

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        // --- Changed Bottom Nav Bar Background Color ---
        color: Colors.white, // Use pure white background
        // --- Changed Top Border Color ---
        border: Border(
          top: BorderSide(width: 1, color: assistBorderColor),
        ), // Use border color
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        // --- Changed Selected Item Color ---
        selectedItemColor: Colors.black, // Black for selected items
        // --- Changed Unselected Item Color ---
        unselectedItemColor:
            assistTextColorSecondary, // Use secondary text color
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
                    ? assistAccentColor // Orange background
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home,
                color: _selectedIndex == 0
                    ? Colors
                          .black // Black icon
                    : assistTextColorSecondary,
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
                    ? assistAccentColor // Orange background
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work,
                color: _selectedIndex == 1
                    ? Colors
                          .black // Black icon
                    : assistTextColorSecondary,
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
                    ? assistAccentColor // Orange background
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: _selectedIndex == 2
                    ? Colors
                          .black // Black icon
                    : assistTextColorSecondary,
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
                    ? assistAccentColor // Orange background
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description,
                color: _selectedIndex == 3
                    ? Colors
                          .black // Black icon
                    : assistTextColorSecondary,
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
                    ? assistAccentColor // Orange background
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings,
                color: _selectedIndex == 4
                    ? Colors
                          .black // Black icon
                    : assistTextColorSecondary,
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
