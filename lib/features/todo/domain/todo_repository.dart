import 'package:todo_app/features/todo/domain/todo_model.dart';

abstract class TodoRepository {
  Future<List<Todo>> getTodos();

  Future<Todo> getTodoById(String id);

  Future<Todo> createTodo({required String title, String? description});

  Future<Todo> updateTodo(Todo todo);

  Future<void> deleteTodo(String id);

  Future<Todo> toggleTodoCompletion(Todo todo);
}
