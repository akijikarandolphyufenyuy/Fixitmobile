class Application {
  final String? id;
  final String jobId;
  final String applicantId;
  final String applicantName;
  final String? applicantEmail;
  final String? applicantPhone;
  final String? coverLetter;
  final String status; // e.g., pending, accepted, rejected
  final DateTime dateApplied;

  Application({
    this.id,
    required this.jobId,
    required this.applicantId,
    required this.applicantName,
    this.applicantEmail,
    this.applicantPhone,
    this.coverLetter,
    required this.status,
    required this.dateApplied,
  });

  factory Application.fromMap(Map<String, dynamic> map) {
    final jobIdValue = map['job_id'];
    final applicantIdValue = map['applicant_id'];
    return Application(
      id: map['id']?.toString(),
      jobId: jobIdValue.toString(),
      applicantId: applicantIdValue.toString(),
      applicantName: (map['applicant_name'] ?? '').toString(),
      applicantEmail: map['applicant_email']?.toString(),
      applicantPhone: map['applicant_phone']?.toString(),
      coverLetter: map['cover_letter']?.toString(),
      status: map['status'],
      dateApplied: DateTime.parse(map['date_applied'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'job_id': jobId,
      'applicant_id': applicantId,
      'applicant_name': applicantName,
      'applicant_email': applicantEmail,
      'applicant_phone': applicantPhone,
      'cover_letter': coverLetter,
      'status': status,
      'date_applied': dateApplied.toIso8601String(),
    };
  }
}
