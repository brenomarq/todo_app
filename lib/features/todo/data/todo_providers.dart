import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/core/providers/supabase_provider.dart';
import 'package:todo_app/features/todo/data/sb_todo_repository.dart';
import 'package:todo_app/features/todo/domain/todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SbTodoRepository(client);
});
