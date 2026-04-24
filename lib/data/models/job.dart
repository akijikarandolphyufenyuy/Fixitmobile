class Job {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String? postedBy;
  final DateTime? expiresAt;
  final String? payRange;
  final String? contact;
  final bool isClosed;
  final String? imageUrl;

  Job({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.postedBy,
    this.expiresAt,
    this.payRange,
    this.contact,
    this.isClosed = false,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'posted_by': postedBy,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      if (payRange != null) 'pay_range': payRange,
      if (contact != null) 'contact': contact,
      'is_closed': isClosed,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    final postedByValue = map['posted_by'];
    DateTime? expiresAt;
    if (map['expires_at'] != null) {
      expiresAt = DateTime.tryParse(map['expires_at'].toString());
    }
    return Job(
      id: map['id']?.toString(),
      title: map['title'],
      description: map['description'],
      category: map['category'],
      location: map['location'],
      postedBy: postedByValue?.toString(),
      expiresAt: expiresAt,
      payRange: map['pay_range']?.toString(),
      contact: map['contact']?.toString(),
      isClosed: map['is_closed'] == true || map['is_closed'] == 1,
      imageUrl: map['image_url']?.toString(),
    );
  }
}
