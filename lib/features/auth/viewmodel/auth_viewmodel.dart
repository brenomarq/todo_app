// lib/features/auth/viewmodel/auth_viewmodel.dart

import 'package:flutter_riverpod/legacy.dart';
import 'package:todo_app/core/errors/app_exception.dart';
import 'package:todo_app/features/auth/data/auth_providers.dart';
import 'package:todo_app/features/auth/domain/auth_repository.dart';
import 'package:todo_app/features/auth/viewmodel/auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthViewModel(this._repository) : super(const AuthState.initial()) {
    _checkCurrentSession();
  }

  void _checkCurrentSession() {
    final user = _repository.getCurrentUser();
    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AuthState.loading();

    try {
      final user = await _repository.signIn(email: email, password: password);

      state = AuthState.authenticated(user);
    } on AppException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = const AuthState.error('Erro inesperado. Tente novamente.');
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AuthState.loading();

    try {
      final user = await _repository.signUp(email: email, password: password);
      state = AuthState.authenticated(user);
    } on AppException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = const AuthState.error('Erro inesperado ao criar conta.');
    }
  }

  Future<void> signOut() async {
    state = const AuthState.loading();

    try {
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } on AppException catch (e) {
      state = AuthState.error(e.message);
    }
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository);
});
