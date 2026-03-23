import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'package:go_router/go_router.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String _selectedPlan = 'Free';
  String _selectedPaymentMethod = 'MTN';
  final TextEditingController _phoneNumberController = TextEditingController();

  // Plan data
  final List<Map<String, dynamic>> _plans = [
    {'name': 'Free', 'description': 'Basic features', 'price': '500frs'},
    {
      'name': 'Pro',
      'description': 'High and fast notifications',
      'price': '1000frs',
    },
  ];

  // Payment method data
  final List<String> _paymentMethods = ['MTN', 'Orange'];

  void _selectPlan(String planName) {
    setState(() {
      _selectedPlan = planName;
    });
  }

  void _selectPaymentMethod(String methodName) {
    setState(() {
      _selectedPaymentMethod = methodName;
    });
  }

  void _onSubscribe() {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Subscribing to $_selectedPlan via $_selectedPaymentMethod...',
        ),
        backgroundColor: const Color(0xFFED7C26),
      ),
    );
  }

  bool _isValidCameroonPhoneNumber(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.length == 9;
  }

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
      // Ensure the Scaffold background is white, which is crucial for text visibility
      backgroundColor: Colors.white,
      // FIX 1: Use a proper AppBar instead of a custom Container.
      // This is more robust and handles theming correctly.
      appBar: AppBar(
        // Set the AppBar background to white and remove the shadow
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // FIX 2: Use the 'leading' property for the back button.
        // This ensures it is placed correctly and is visible.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFED7C26)),
          onPressed: _onBackPressed,
        ),
        // By default, a leading widget is implied. We disable it because we provide our own.
        automaticallyImplyLeading: false,
        title: const Text(
          'Subscription',
          style: TextStyle(
            color: Color(0xFF1C110C), // Dark text color for the title
            fontSize: 18,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double horizontalPadding = constraints.maxWidth * 0.05;
            if (horizontalPadding < 16) horizontalPadding = 16;
            if (horizontalPadding > 32) horizontalPadding = 32;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildSectionTitle('Choose your plan'),
                        const SizedBox(height: 16),
                        ..._plans
                            .map((plan) => _buildPlanOption(plan))
                            ,
                        const SizedBox(height: 24),
                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Payment Method'),
                        const SizedBox(height: 16),
                        ..._paymentMethods
                            .map((method) => _buildPaymentOption(method))
                            ,
                        const SizedBox(height: 16),
                        // FIX 3: This was already correct, but it was invisible due
                        // to the background color issue. It now works as intended.
                        _buildPhoneNumberInput(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                _buildSubscribeButton(horizontalPadding),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  // The custom _buildAppBar method is no longer needed and can be deleted.

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
                  ? const Color(0xFFED7C26)
                  : const Color(0xFFE0E0E0),
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
                    plan['description'],
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan['price'],
                  style: const TextStyle(
                    color: Color(0xFF1C110C),
                    fontSize: 16,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: ShapeDecoration(
                    shape: CircleBorder(
                      side: BorderSide(
                        width: 2,
                        color: isSelected
                            ? const Color(0xFFED7C26)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFFED7C26),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
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
                  ? const Color(0xFFED7C26)
                  : const Color(0xFFE0E0E0),
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
            Container(
              width: 20,
              height: 20,
              decoration: ShapeDecoration(
                shape: CircleBorder(
                  side: BorderSide(
                    width: 2,
                    color: isSelected
                        ? const Color(0xFFED7C26)
                        : const Color(0xFFE0E0E0),
                  ),
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFED7C26),
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
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.5, color: Color(0xFFE0E0E0)),
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
          const SizedBox(height: 8),
          TextField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            maxLength: 9,
            decoration: const InputDecoration(
              hintText: 'Enter 9-digit phone number',
              hintStyle: TextStyle(
                color: Color(0xFF996D4C),
                fontSize: 14,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              counterText: '',
            ),
            style: const TextStyle(
              color: Color(0xFF1C110C),
              fontSize: 14,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w400,
            ),
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
          backgroundColor: const Color(0xFFED7C26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 2,
          foregroundColor: const Color(0xFF1C110C),
        ),
        child: const Center(
          child: Text(
            'Subscribe',
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
}


