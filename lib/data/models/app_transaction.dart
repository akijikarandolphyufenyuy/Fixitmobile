class AppTransaction {
  final String? id;
  final String userId;
  final String purpose;
  final String jobTitle;
  final String? jobId;
  final int amount;
  final String paymentMethod;
  final String phoneNumber;
  final DateTime paidAt;
  final String status;
  final String? mesombRef;

  AppTransaction({
    this.id,
    required this.userId,
    required this.purpose,
    required this.jobTitle,
    this.jobId,
    required this.amount,
    required this.paymentMethod,
    required this.phoneNumber,
    required this.paidAt,
    this.status = 'success',
    this.mesombRef,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'purpose': purpose,
        'jobTitle': jobTitle,
        if (jobId != null) 'jobId': jobId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'phoneNumber': phoneNumber,
        'paidAt': paidAt.toIso8601String(),
        'status': status,
        if (mesombRef != null) 'mesombRef': mesombRef,
      };

  factory AppTransaction.fromMap(Map<String, dynamic> map, String id) => AppTransaction(
        id: id,
        userId: map['userId'] ?? '',
        purpose: map['purpose'] ?? '',
        jobTitle: map['jobTitle'] ?? '',
        jobId: map['jobId'],
        amount: (map['amount'] as num?)?.toInt() ?? 0,
        paymentMethod: map['paymentMethod'] ?? '',
        phoneNumber: map['phoneNumber'] ?? '',
        paidAt: DateTime.tryParse(map['paidAt'] ?? '') ?? DateTime.now(),
        status: map['status'] ?? 'success',
        mesombRef: map['mesombRef'],
      );
}
