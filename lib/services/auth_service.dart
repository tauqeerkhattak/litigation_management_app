part of 'locator.dart';

class AuthService {
  AuthService._();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserData> signIn(String email, String password) async {
    final UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User? user = result.user;
    if (user != null) {
      return UserData(
        id: user.uid,
        name: user.displayName ?? email.split('@')[0],
        role: "User", // Role could be fetched from Firestore in a later step
        email: user.email ?? "",
      );
    }
    throw Exception('Authentication failed.');
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  UserData? get currentUser {
    final user = _auth.currentUser;
    if (user != null) {
      return UserData(
        id: user.uid,
        name: user.displayName ?? user.email?.split('@')[0] ?? "User",
        role: "User",
        email: user.email ?? "",
      );
    }
    return null;
  }
}
