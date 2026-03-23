import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_item.dart';

class NotificationsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('notifications');

  /// Real-time stream of notifications for a user, newest first.
  Stream<List<AppNotification>> streamNotifications(String userId) {
    return _col
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AppNotification.fromDoc).toList());
  }

  /// One-time fetch (kept for backward compat).
  Future<List<AppNotification>> getNotificationsForUser(String userId) async {
    try {
      final snap = await _col
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();
      return snap.docs.map(AppNotification.fromDoc).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addNotification(AppNotification n) async {
    final ref = _col.doc();
    await ref.set({...n.toMap(), 'id': ref.id});
  }

  Future<void> markAsRead(String id) =>
      _col.doc(id).update({'is_read': true});

  Future<void> markAllAsRead(String userId) async {
    final snap = await _col
        .where('user_id', isEqualTo: userId)
        .where('is_read', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'is_read': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String id) => _col.doc(id).delete();

  Future<void> clearAll(String userId) async {
    final snap = await _col.where('user_id', isEqualTo: userId).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
