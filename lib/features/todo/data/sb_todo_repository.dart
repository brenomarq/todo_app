// lib/features/todo/data/todo_repository_impl.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/core/constants/supabase_constants.dart';
import 'package:todo_app/core/errors/app_exception.dart';
import 'package:todo_app/features/todo/domain/todo_model.dart';
import 'package:todo_app/features/todo/domain/todo_repository.dart';

class SbTodoRepository implements TodoRepository {
  final SupabaseClient _client;

  const SbTodoRepository(this._client);

  // Atalho para pegar o ID do usuário logado
  // Lança exceção se não houver usuário — nunca chegamos aqui sem auth
  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const AppException(message: 'Usuário não autenticado.');
    }
    return id;
  }

  @override
  Future<List<Todo>> getTodos() async {
    try {
      final response = await _client
          .from(SupabaseConstants.todosTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => Todo.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw AppException(message: 'Erro ao buscar tarefas.', code: e.code);
    }
  }

  @override
  Future<Todo> getTodoById(String id) async {
    try {
      final response = await _client
          .from(SupabaseConstants.todosTable)
          .select()
          .eq('id', id)
          .single();

      return Todo.fromJson(response);
    } on PostgrestException catch (e) {
      throw AppException(message: 'Tarefa não encontrada.', code: e.code);
    }
  }

  @override
  Future<Todo> createTodo({required String title, String? description}) async {
    try {
      final response = await _client
          .from(SupabaseConstants.todosTable)
          .insert({
            'user_id': _userId,
            'title': title,
            'description': description,
            'is_completed': false,
          })
          .select()
          .single();

      return Todo.fromJson(response);
    } on PostgrestException catch (e) {
      throw AppException(message: 'Erro ao criar tarefa.', code: e.code);
    }
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    try {
      final response = await _client
          .from(SupabaseConstants.todosTable)
          .update({
            'title': todo.title,
            'description': todo.description,
            'is_completed': todo.isCompleted,
          })
          .eq('id', todo.id)
          .select()
          .single();

      return Todo.fromJson(response);
    } on PostgrestException catch (e) {
      throw AppException(message: 'Erro ao atualizar tarefa.', code: e.code);
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await _client.from(SupabaseConstants.todosTable).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw AppException(message: 'Erro ao deletar tarefa.', code: e.code);
    }
  }

  @override
  Future<Todo> toggleTodoCompletion(Todo todo) async {
    return updateTodo(todo.copyWith(isCompleted: !todo.isCompleted));
  }
}
