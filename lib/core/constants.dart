// core/constants.dart

class AppConstants {
  static const String appName = "Fixit";
  static const String dbName = "fixit.db";
  static const int dbVersion = 1;

  // Table names
  static const String userTable = "users";
  static const String jobTable = "jobs";
  static const String applicationTable = "applications";

  // Subscription Plans
  static const List<String> subscriptionPlans = [
    "Free",
    "Basic",
    "Premium",
  ];

  // API Keys (if needed later for payment gateways or AI bot)
  static const String apiKey = "YOUR_API_KEY";

  // Supported Languages
  static const List<String> languages = ["English", "French"];
}
