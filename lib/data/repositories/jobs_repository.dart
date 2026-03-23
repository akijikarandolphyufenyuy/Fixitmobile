import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';

class JobsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Post a new job
  Future<void> postJob(Job job) async {
    try {
      // Use a deterministic doc id and persist it into `id`
      // so other repositories (applications) can reference the job.
      final docRef = _firestore.collection('jobs').doc();
      final data = job.toMap();
      data['id'] = docRef.id;
      await docRef.set(data);
    } catch (e) {
      // Error posting job
      rethrow;
    }
  }

  /// Get all jobs (used by dashboard home + jobs browsing).
  Future<List<Job>> getAllJobs() async {
    try {
      final snapshot = await _firestore.collection('jobs').get();
      return snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Job.fromMap(data);
      })
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Get jobs filtered by category and location
  Future<List<Job>> getJobsByCategoryAndLocation(
    String category,
    String location,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .where('category', isEqualTo: category)
          .where('location', isEqualTo: location)
          .get();

      return snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Job.fromMap(data);
      })
          .toList();
    } catch (e) {
      // Error fetching jobs
      return [];
    }
  }

  /// Get jobs posted by the current user.
  Future<List<Job>> getJobsByPostedBy(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .where('posted_by', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Job.fromMap(data);
      })
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Toggle job open/closed status.
  Future<void> toggleJobStatus(String jobId, bool isClosed) async {
    await _firestore.collection('jobs').doc(jobId).update({'is_closed': isClosed});
  }

  /// Delete a single job.
  Future<void> deleteJob(String jobId) async {
    await _firestore.collection('jobs').doc(jobId).delete();
  }

  /// Delete all jobs posted by a user.
  Future<void> clearAllJobs(String userId) async {
    final snap = await _firestore
        .collection('jobs')
        .where('posted_by', isEqualTo: userId)
        .get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Real-time stream of jobs posted by a user.
  Stream<List<Job>> streamJobsByPostedBy(String userId) {
    return _firestore
        .collection('jobs')
        .where('posted_by', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Job.fromMap(data);
            }).toList());
  }

  /// Get distinct professions from users collection.
  Future<List<String>> getDistinctProfessions() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final professions = snapshot.docs
          .map((doc) => (doc.data()['profession'] as String? ?? '').trim())
          .where((p) => p.isNotEmpty)
          .toSet()
          .toList();
      professions.sort();
      return professions;
    } catch (_) {
      return [];
    }
  }
}
