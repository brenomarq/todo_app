import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/core/providers/supabase_provider.dart';
import 'package:todo_app/features/auth/data/sb_auth_repository.dart';
import 'package:todo_app/features/auth/domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SbAuthRepository(client);
});
