import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/core/errors/app_exception.dart';
import 'package:todo_app/features/auth/domain/auth_repository.dart';
import 'package:todo_app/features/auth/domain/user_model.dart';

class SbAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  const SbAuthRepository(this._client);

  @override
  UserModel? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    });
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AppException(message: 'Usuário não encontrado.');
      }

      return UserModel.fromSupabaseUser(user);
    } on AuthException catch (e) {
      throw AppException(message: _translateAuthError(e.message));
    } catch (e) {
      throw const AppException(message: "Erro inesperado a fazer login");
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AppException(message: 'Erro ao criar conta.');
      }

      return UserModel.fromSupabaseUser(user);
    } on AuthException catch (e) {
      throw AppException(message: _translateAuthError(e.message));
    } catch (e) {
      throw const AppException(message: "Erro inesperado a fazer cadastro");
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AppException(message: _translateAuthError(e.message));
    }
  }

  String _translateAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email ou senha incorretos.';
    }
    if (message.contains('Email already registered')) {
      return 'Este email já está cadastrado.';
    }
    if (message.contains('Password should be at least')) {
      return 'A senha deve ter no mínimo 6 caracteres.';
    }
    return 'Erro de autenticação. Tente novamente.';
  }
}
