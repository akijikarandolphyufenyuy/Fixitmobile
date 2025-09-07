class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? location;
  final String? category;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.location,
    this.category,
    required String role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'location': location,
      'category': category,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'],
      location: map['location'],
      category: map['category'],
      role: '',
    );
  }

  User? copyWith({required int id}) {
    return null;
  }
}
