class Subscription {
  final int? id;
  final int userId;
  final String planName; // e.g., Basic, Premium
  final double price;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Subscription({
    this.id,
    required this.userId,
    required this.planName,
    required this.price,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      userId: map['user_id'],
      planName: map['plan_name'],
      price: map['price'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      isActive: map['is_active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'plan_name': planName,
      'price': price,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }
}
