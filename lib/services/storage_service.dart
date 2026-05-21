part of 'locator.dart';

class StorageService {
  StorageService._();
  static const String _userKey = 'user_session';

  Future<void> saveUser(UserData? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_userKey);
    } else {
      await prefs.setString(_userKey, jsonEncode(user.toMap()));
    }
  }

  Future<UserData?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    try {
      return UserData.fromMap(jsonDecode(userStr));
    } catch (e) {
      return null;
    }
  }
}
