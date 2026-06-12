enum UserRole {
  editor,
  commentor,
  documentor,
  viewer;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
          (r) => r.name == role,
      orElse: () => UserRole.viewer,
    );
  }

  bool get canCreateCases => this == UserRole.editor;

  bool get canCreateHearings =>
      this == UserRole.editor || this == UserRole.commentor;

  bool get canAddDocuments =>
      this == UserRole.editor ||
          this == UserRole.commentor ||
          this == UserRole.documentor;
}

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
