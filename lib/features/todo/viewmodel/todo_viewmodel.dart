import 'package:flutter_riverpod/legacy.dart';
import 'package:todo_app/core/errors/app_exception.dart';
import 'package:todo_app/features/todo/data/todo_providers.dart';
import 'package:todo_app/features/todo/domain/todo_model.dart';
import 'package:todo_app/features/todo/domain/todo_repository.dart';
import 'package:todo_app/features/todo/viewmodel/todo_state.dart';

class TodoViewModel extends StateNotifier<TodoState> {
  final TodoRepository _repository;

  TodoViewModel(this._repository) : super(const TodoState.initial());

  Future<void> fetchTodos() async {
    state = const TodoState.loading();

    try {
      final todos = await _repository.getTodos();
      state = TodoState.success(todos);
    } on AppException catch (e) {
      state = TodoState.error(e.message);
    } catch (e) {
      state = const TodoState.error('Erro ao buscar tarefas.');
    }
  }

  Future<void> createTodo({required String title, String? description}) async {
    final previousState = state;

    try {
      final newTodo = await _repository.createTodo(
        title: title,
        description: description,
      );

      state.whenOrNull(
        success: (todos) {
          state = TodoState.success([newTodo, ...todos]);
        },
      );
    } on AppException catch (e) {
      state = previousState;
      state = TodoState.error(e.message);
    } catch (e) {
      state = previousState;
      state = const TodoState.error('Erro ao criar tarefa.');
    }
  }

  Future<void> updateTodo(Todo todo) async {
    final previousState = state;

    try {
      final updatedTodo = await _repository.updateTodo(todo);

      state.whenOrNull(
        success: (todos) {
          final updatedList = todos.map((t) {
            return t.id == updatedTodo.id ? updatedTodo : t;
          }).toList();
          state = TodoState.success(updatedList);
        },
      );
    } on AppException catch (e) {
      state = previousState;
      state = TodoState.error(e.message);
    } catch (e) {
      state = previousState;
      state = const TodoState.error('Erro ao atualizar tarefa.');
    }
  }

  Future<void> deleteTodo(String id) async {
    final previousState = state;

    try {
      await _repository.deleteTodo(id);

      state.whenOrNull(
        success: (todos) {
          final updatedList = todos.where((t) => t.id != id).toList();
          state = TodoState.success(updatedList);
        },
      );
    } on AppException catch (e) {
      state = previousState;
      state = TodoState.error(e.message);
    } catch (e) {
      state = previousState;
      state = const TodoState.error('Erro ao deletar tarefa.');
    }
  }

  Future<void> toggleTodo(Todo todo) async {
    final previousState = state;

    try {
      final updatedTodo = await _repository.toggleTodoCompletion(todo);

      state.whenOrNull(
        success: (todos) {
          final updatedList = todos.map((t) {
            return t.id == updatedTodo.id ? updatedTodo : t;
          }).toList();
          state = TodoState.success(updatedList);
        },
      );
    } on AppException catch (e) {
      state = previousState;
      state = TodoState.error(e.message);
    } catch (e) {
      state = previousState;
      state = const TodoState.error('Erro ao atualizar tarefa.');
    }
  }
}

final todoViewModelProvider = StateNotifierProvider<TodoViewModel, TodoState>((
  ref,
) {
  final repository = ref.watch(todoRepositoryProvider);
  return TodoViewModel(repository);
});
