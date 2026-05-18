import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/locator.dart';
import 'base_view_model.dart';

class AuthState {
  final UserData? user;
  final bool isLoading;

  AuthState({this.user, this.isLoading = false});

  AuthState copyWith({UserData? user, bool? isLoading}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthViewModel extends BaseViewModel<AuthState> {
  AuthViewModel() : super(AuthState());

  @override
  void init() {
    super.init();
    _loadUser();
  }

  Future<void> _loadUser() async {
    state = state.copyWith(isLoading: true);
    // First check local storage for session
    var user = await locator<StorageService>().loadUser();

    // If not in local storage, check Firebase current user
    if (user == null) {
      user = locator<AuthService>().currentUser;
      if (user != null) {
        await locator<StorageService>().saveUser(user);
      }
    }

    state = state.copyWith(user: user, isLoading: false);
  }

  Future<void> login(String email, String password) async {
    return await runSafely(() async {
      final user = await locator<AuthService>().signIn(email, password);
      await locator<StorageService>().saveUser(user);
      state = state.copyWith(isLoading: false, user: user);
    });
  }

  Future<void> logout() async {
    return await runSafely(() async {
      state = state.copyWith(isLoading: true);
      await locator<AuthService>().signOut();
      await locator<StorageService>().saveUser(null);
      state = AuthState();
    });
  }
}

final authProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});
