import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { job, application, system, message }

class AppNotification {
  final String? id;
  final String userId;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;

  AppNotification({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.type = NotificationType.system,
  });

  factory AppNotification.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: (data['user_id'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      message: (data['message'] ?? '').toString(),
      createdAt: data['created_at'] is Timestamp
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
      isRead: data['is_read'] == true || data['is_read'] == 1,
      type: _typeFromString(data['type']?.toString()),
    );
  }

  factory AppNotification.fromMap(Map<String, dynamic> data) {
    return AppNotification(
      id: data['id']?.toString(),
      userId: (data['user_id'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      message: (data['message'] ?? '').toString(),
      createdAt: data['created_at'] is Timestamp
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
      isRead: data['is_read'] == true || data['is_read'] == 1,
      type: _typeFromString(data['type']?.toString()),
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'title': title,
        'message': message,
        'created_at': FieldValue.serverTimestamp(),
        'is_read': isRead,
        'type': type.name,
      };

  static NotificationType _typeFromString(String? s) {
    switch (s) {
      case 'job':         return NotificationType.job;
      case 'application': return NotificationType.application;
      case 'message':     return NotificationType.message;
      default:            return NotificationType.system;
    }
  }
}
