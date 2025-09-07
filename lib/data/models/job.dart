class Job {
  final int? id;
  final String title;
  final String description;
  final String category;
  final String location;
  final int postedBy;

  Job({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.postedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'posted_by': postedBy,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      location: map['location'],
      postedBy: map['posted_by'],
    );
  }
}
