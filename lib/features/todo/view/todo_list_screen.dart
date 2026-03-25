import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/router/app_router.dart';
import 'package:todo_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:todo_app/features/todo/domain/todo_model.dart';
import 'package:todo_app/features/todo/view/widgets/todo_item_widget.dart';
import 'package:todo_app/features/todo/viewmodel/todo_viewmodel.dart';
import 'package:todo_app/features/todo/viewmodel/todo_state.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega as tarefas assim que a tela é criada
    // addPostFrameCallback garante que o build terminou antes de disparar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todoViewModelProvider.notifier).fetchTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    // watch reconstrói a tela quando o estado muda
    final state = ref.watch(todoViewModelProvider);

    ref.listen<TodoState>(todoViewModelProvider, (previous, next) {
      next.whenOrNull(
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              ref.read(authViewModelProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.todoForm),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(TodoState state) {
    // 'when' força tratar todos os estados — nenhum é esquecido
    return state.when(
      initial: () => const SizedBox.shrink(),

      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      ),

      success: (todos) =>
          todos.isEmpty ? _buildEmptyState() : _buildTodoList(todos),

      error: (message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  ref.read(todoViewModelProvider.notifier).fetchTodos(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhuma tarefa ainda',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Toque no + para criar sua primeira tarefa',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    return RefreshIndicator(
      // Pull to refresh — padrão mobile que os usuários esperam
      onRefresh: () => ref.read(todoViewModelProvider.notifier).fetchTodos(),
      color: Colors.deepPurple,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return TodoItemWidget(
            todo: todo,
            onToggle: () =>
                ref.read(todoViewModelProvider.notifier).toggleTodo(todo),
            onEdit: () => context.push(AppRoutes.todoForm, extra: todo),
            onDelete: () => _confirmDelete(todo),
          );
        },
      ),
    );
  }

  // Diálogo de confirmação antes de deletar
  void _confirmDelete(Todo todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Deseja excluir "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ref.read(todoViewModelProvider.notifier).deleteTodo(todo.id);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
