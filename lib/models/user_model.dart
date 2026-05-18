class UserData {
  final String id;
  final String name;
  final String role;
  final String email;
  const UserData({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'role': role, 'email': email};
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      email: map['email'],
    );
  }
}
