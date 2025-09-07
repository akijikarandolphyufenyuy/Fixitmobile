// core/util.dart
import 'package:flutter/material.dart';

class AppUtil {
  // Email Validation
  static bool isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  // Phone Number Validation (Cameroon format example)
  static bool isValidPhone(String phone) {
    return RegExp(r"^(?:\+237|237)?[6-9]\d{8}$").hasMatch(phone);
  }

  // Show SnackBar
  static void showSnackBar(BuildContext context, String message,
      {Color color = Colors.orange}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // Compare location (simple text match for now, can integrate GPS later)
  static bool isSameLocation(String jobLocation, String userLocation) {
    return jobLocation.trim().toLowerCase() ==
        userLocation.trim().toLowerCase();
  }
}
