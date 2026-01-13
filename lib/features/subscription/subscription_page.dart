import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for FilteringTextInputFormatter
// Import go_router if you are using it for navigation
import 'package:go_router/go_router.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  // State variables to track selections
  String _selectedPlan = 'Free'; // Default selection
  String _selectedPaymentMethod = 'MTN'; // Default selection
  final TextEditingController _phoneNumberController = TextEditingController();

  // Plan data
  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Free',
      'description':
          'Basic features 500frs', // Note: Original text had '500frs' here
      'price': 0, // Free plan typically has no price
    },
    {
      'name': 'Pro',
      'description':
          'High and fast notifications 1000frs', // Note: Original text had '1000frs' here
      'price': 1000,
    },
  ];

  // Payment method data
  final List<String> _paymentMethods = ['MTN', 'Orange'];

  // Function to handle plan selection
  void _selectPlan(String planName) {
    setState(() {
      _selectedPlan = planName;
    });
  }

  // Function to handle payment method selection
  void _selectPaymentMethod(String methodName) {
    setState(() {
      _selectedPaymentMethod = methodName;
    });
  }

  // Function to handle subscription action
  void _onSubscribe() {
    // Validate phone number
    if (!_isValidCameroonPhoneNumber(_phoneNumberController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid Cameroon phone number (9 digits)',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedPlanData = _plans.firstWhere(
      (plan) => plan['name'] == _selectedPlan,
    );
    final String methodName = _selectedPaymentMethod;

    // In a real app, you would initiate the payment process here.
    // For now, just show a snackbar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subscribing to ${_selectedPlan} via $methodName...'),
        backgroundColor: const Color(0xFFED7C26),
      ),
    );
    // Example: Navigate to a payment confirmation or processing screen
    // context.go('/payment-processing?plan=$_selectedPlan&method=$methodName');
  }

  // Function to validate Cameroon phone number (9 digits)
  bool _isValidCameroonPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    // Check if it's exactly 9 digits
    return digitsOnly.length == 9;
  }

  // Function to handle back navigation
  void _onBackPressed() {
    context.go('/dashboard/settings');
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Pure white background
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double horizontalPadding = constraints.maxWidth * 0.05;
            if (horizontalPadding < 16) horizontalPadding = 16;
            if (horizontalPadding > 32) horizontalPadding = 32;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Bar Section with Back Button
                _buildAppBar(horizontalPadding),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildSectionTitle('Choose your plan'),
                        const SizedBox(height: 16),
                        // Plan Options
                        ..._plans
                            .map((plan) => _buildPlanOption(plan))
                            .toList(),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Payment Method'),
                        const SizedBox(height: 16),
                        // Payment Method Options
                        ..._paymentMethods
                            .map((method) => _buildPaymentOption(method))
                            .toList(),
                        const SizedBox(height: 16),
                        // Phone Number Input Field
                        _buildPhoneNumberInput(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Subscribe Button
                _buildSubscribeButton(horizontalPadding),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(double horizontalPadding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 16,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 8,
      ),
      decoration: const BoxDecoration(color: Color(0xFFFFFFFF)), // Pure white
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Back Button
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFED7C26),
            ), // Orange color
            onPressed: _onBackPressed, // Call the back function
          ),
          const SizedBox(width: 8), // Space between icon and title
          Expanded(
            child: Text(
              'Subscription',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1C110C),
                fontSize: 18,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Placeholder for symmetry (width of IconButton)
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF1C110C),
        fontSize: 22,
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildPlanOption(Map<String, dynamic> plan) {
    final bool isSelected = _selectedPlan == plan['name'];
    return GestureDetector(
      onTap: () => _selectPlan(plan['name']),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1.5,
              color: isSelected
                  ? const Color(0xFFED7C26) // Orange color
                  : const Color(0xFFE8D8CE),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan['name'],
                    style: const TextStyle(
                      color: Color(0xFF1C110C),
                      fontSize: 16,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan['description'], // Shows description like 'Basic features 500frs'
                    style: const TextStyle(
                      color: Color(0xFF996D4C),
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Radio-like indicator
            Container(
              width: 20,
              height: 20,
              decoration: ShapeDecoration(
                shape: CircleBorder(
                  side: BorderSide(
                    width: 2,
                    color: isSelected
                        ? const Color(0xFFED7C26) // Orange color
                        : const Color(0xFFE8D8CE),
                  ),
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFED7C26), // Orange color
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String methodName) {
    final bool isSelected = _selectedPaymentMethod == methodName;
    return GestureDetector(
      onTap: () => _selectPaymentMethod(methodName),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1.5,
              color: isSelected
                  ? const Color(0xFFED7C26) // Orange color
                  : const Color(0xFFE8D8CE),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                methodName,
                style: const TextStyle(
                  color: Color(0xFF1C110C),
                  fontSize: 16,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Radio-like indicator
            Container(
              width: 20,
              height: 20,
              decoration: ShapeDecoration(
                shape: CircleBorder(
                  side: BorderSide(
                    width: 2,
                    color: isSelected
                        ? const Color(0xFFED7C26) // Orange color
                        : const Color(0xFFE8D8CE),
                  ),
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFED7C26), // Orange color
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberInput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12), // Reduced padding for smaller height
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.5, color: Color(0xFFE8D8CE)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Phone Number',
            style: TextStyle(
              color: Color(0xFF1C110C),
              fontSize: 16,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4), // Reduced spacing
          TextField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            maxLength: 9, // Limit to 9 characters
            decoration: const InputDecoration(
              hintText: 'Enter 9-digit phone number',
              hintStyle: TextStyle(
                color: Color(0xFF996D4C),
                fontSize: 14,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              counterText: '', // Hide character counter
            ),
            style: const TextStyle(
              color: Color(0xFF1C110C),
              fontSize: 14,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
            ),
            // Input formatter to allow only digits
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: ElevatedButton(
        onPressed: _onSubscribe,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFED7C26), // Orange color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 2,
          // Ensure text color is contrasting
          foregroundColor: const Color(0xFF1C110C), // Text/icon color
        ),
        child: const Center(
          child: Text(
            'Subscribe',
            style: TextStyle(
              color: Color(0xFF1C110C), // Explicit text color
              fontSize: 16,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
