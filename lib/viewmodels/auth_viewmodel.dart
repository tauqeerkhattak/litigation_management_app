import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../providers/storage_provider.dart';
import 'base_view_model.dart';

class AuthState {
  final User? user;
  final String? error;
  final bool isLoading;

  AuthState({this.user, this.error, this.isLoading = false});

  AuthState copyWith({User? user, String? error, bool? isLoading}) {
    return AuthState(
      user: user ?? this.user,
      error: error,
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
    final user = await ref.read(storageProvider).loadUser();
    state = state.copyWith(user: user, isLoading: false);
  }

  void login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final name = username.toLowerCase();
    User? user;
    
    if (password == "dc2025") {
      if (name.contains("tanveer")) {
        user = User(
          id: "u1",
          name: "Muhammad Tanveer",
          role: "Senior Clerk",
          email: "tanveer@dc-sukkur.gov.pk",
        );
      } else if (name.contains("admin")) {
        user = User(
          id: "u2",
          name: "Admin",
          role: "Administrator",
          email: "admin@dc-sukkur.gov.pk",
        );
      } else if (name.contains("legal")) {
        user = User(
          id: "u3",
          name: "Legal Officer",
          role: "Legal Officer",
          email: "legal@dc-sukkur.gov.pk",
        );
      }

      if (user != null) {
        await ref.read(storageProvider).saveUser(user);
        state = state.copyWith(isLoading: false, user: user);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Invalid username. Use: Tanveer, Admin, or Legal Officer",
        );
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        error: "Invalid password. Try: dc2025",
      );
    }
  }

  void logout() async {
    await ref.read(storageProvider).saveUser(null);
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});
