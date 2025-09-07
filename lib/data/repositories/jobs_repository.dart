import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';

class JobsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Post a new job
  Future<void> postJob(Job job) async {
    try {
      await _firestore
          .collection('jobs') // Collection name in Firestore
          .add(job.toMap());
    } catch (e) {
      print('Error posting job: $e');
      rethrow;
    }
  }

  /// Get jobs filtered by category and location
  Future<List<Job>> getJobsByCategoryAndLocation(String category, String location) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('jobs')
          .where('category', isEqualTo: category)
          .where('location', isEqualTo: location)
          .get();

      return snapshot.docs
          .map((doc) => Job.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching jobs: $e');
      return [];
    }
  }
}
