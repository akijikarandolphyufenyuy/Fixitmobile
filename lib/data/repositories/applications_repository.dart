import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application.dart';

class ApplicationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Apply for a job: saves application to Firestore
  Future<void> applyForJob(Application application) async {
    try {
      final docRef = _firestore.collection('applications').doc();
      final data = application.toMap();
      data['id'] = docRef.id;
      await docRef.set(data);
    } catch (e) {
      // Error adding application
      rethrow;
    }
  }

  /// Get all applications for a specific job
  Future<List<Application>> getApplicationsByJob(String jobId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('applications')
          .where('job_id', isEqualTo: jobId)
          .get();

      return snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Application.fromMap(data);
      })
          .toList();
    } catch (e) {
      // Error fetching applications
      return [];
    }
  }

  /// Get all applications submitted by a specific applicant.
  Future<List<Application>> getApplicationsByApplicant(String applicantId) async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('applicant_id', isEqualTo: applicantId)
          .get();

      return snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Application.fromMap(data);
      })
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Real-time stream of applications for a specific job.
  Stream<List<Application>> streamApplicationsByJob(String jobId) {
    return _firestore
        .collection('applications')
        .where('job_id', isEqualTo: jobId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Application.fromMap(data);
            }).toList());
  }

  /// Update an application's status (e.g. pending -> accepted/rejected).
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': status,
      });
    } catch (e) {
      rethrow;
    }
  }
}
