import '../utils/constants.dart';

class UserData {
  final String id;
  final String name;
  final UserRole role;
  final String email;
  final String countryCode;
  final String phoneNumber;
  const UserData({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.countryCode,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'role': role.name, 'email': email};
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'],
      name: map['name'],
      role: UserRole.values.byName(map['role']),
      email: map['email'],
      countryCode: map['country_code'],
      phoneNumber: map['phone_number'],
    );
  }
}
