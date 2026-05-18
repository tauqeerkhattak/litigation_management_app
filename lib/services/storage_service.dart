part of 'locator.dart';

class StorageService {
  StorageService._();
  static const String _userKey = 'user_session';
  static const String _casesKey = 'cases_data';

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

  Future<void> saveCases(List<Case> cases) async {
    final prefs = await SharedPreferences.getInstance();
    final casesJson = cases.map((c) => c.toMap()).toList();
    await prefs.setString(_casesKey, jsonEncode(casesJson));
  }

  Future<List<Case>> loadCases() async {
    final prefs = await SharedPreferences.getInstance();
    final casesStr = prefs.getString(_casesKey);
    if (casesStr == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(casesStr);
      return decoded.map((item) => Case.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }
}
