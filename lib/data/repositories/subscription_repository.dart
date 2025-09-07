import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a subscription
  Future<void> addSubscription(Subscription subscription) async {
    try {
      await _firestore
          .collection('subscriptions')
          .add(subscription.toMap());
    } catch (e) {
      print('Error adding subscription: $e');
      rethrow;
    }
  }

  /// Get subscription for a specific user
  Future<Subscription?> getUserSubscription(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Subscription.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching user subscription: $e');
      return null;
    }
  }
}
