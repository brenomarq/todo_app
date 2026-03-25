import 'package:todo_app/features/auth/domain/user_model.dart';

abstract class AuthRepository {
  UserModel? getCurrentUser();

  Stream<UserModel?> get authStateChanges;

  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel> signUp({required String email, required String password});

  Future<void> signOut();
}
