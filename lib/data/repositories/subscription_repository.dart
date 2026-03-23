import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a subscription
  Future<void> addSubscription(Subscription subscription) async {
    try {
      final docRef = _firestore.collection('subscriptions').doc();
      final data = subscription.toMap();
      data['id'] = docRef.id;
      await docRef.set(data);
    } catch (e) {
      // Error adding subscription
      rethrow;
    }
  }

  /// Get subscription for a specific user
  Future<Subscription?> getUserSubscription(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('subscriptions')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final first = snapshot.docs.first;
        final data = first.data() as Map<String, dynamic>;
        data['id'] = first.id;
        return Subscription.fromMap(data);
      }
      return null;
    } catch (e) {
      // Error fetching user subscription
      return null;
    }
  }
}
