import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application.dart';

class ApplicationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Apply for a job: saves application to Firestore
  Future<void> applyForJob(Application application) async {
    try {
      await _firestore
          .collection('applications') // Collection name in Firestore
          .add(application.toMap());
    } catch (e) {
      print('Error adding application: $e');
      rethrow;
    }
  }

  /// Get all applications for a specific job
  Future<List<Application>> getApplicationsByJob(String jobId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .get();

      return snapshot.docs
          .map((doc) => Application.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching applications: $e');
      return [];
    }
  }
}
