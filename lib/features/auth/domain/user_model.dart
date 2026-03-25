import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String email;

  const UserModel({required this.id, required this.email});

  // Converte o User do Supabase para o nosso modelo de domínio
  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(id: user.id, email: user.email ?? '');
  }
}
