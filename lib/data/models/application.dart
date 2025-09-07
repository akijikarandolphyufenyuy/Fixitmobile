class Application {
  final int? id;
  final int jobId;
  final int applicantId;
  final String applicantName;
  final String status; // e.g., pending, accepted, rejected
  final DateTime dateApplied;

  Application({
    this.id,
    required this.jobId,
    required this.applicantId,
    required this.applicantName,
    required this.status,
    required this.dateApplied,
  });

  factory Application.fromMap(Map<String, dynamic> map) {
    return Application(
      id: map['id'],
      jobId: map['job_id'],
      applicantId: map['applicant_id'],
      applicantName: map['applicant_name'],
      status: map['status'],
      dateApplied: DateTime.parse(map['date_applied']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'job_id': jobId,
      'applicant_id': applicantId,
      'applicant_name': applicantName,
      'status': status,
      'date_applied': dateApplied.toIso8601String(),
    };
  }
}
