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
    await Future.delayed(const Duration(seconds: 2));
    final user = locator<AuthService>().currentUser;
    state = state.copyWith(user: user, isLoading: false);
  }

  Future<void> login(String email, String password) async {
    return await runSafely(() async {
      state = state.copyWith(isLoading: true);
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

  @override
  void handleError(String message) {
    super.handleError(message);
    state = state.copyWith(isLoading: false);
  }
}

final authProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});
