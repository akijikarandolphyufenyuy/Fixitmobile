class CV {
  final int? id;
  final int userId;
  final String fullName;
  final String email;
  final String phone;
  final String skills; // comma-separated string or JSON array
  final String experience; // work history in text or JSON
  final String education;

  CV({
    this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.skills,
    required this.experience,
    required this.education,
  });

  factory CV.fromMap(Map<String, dynamic> map) {
    return CV(
      id: map['id'],
      userId: map['user_id'],
      fullName: map['full_name'],
      email: map['email'],
      phone: map['phone'],
      skills: map['skills'],
      experience: map['experience'],
      education: map['education'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'skills': skills,
      'experience': experience,
      'education': education,
    };
  }
}
