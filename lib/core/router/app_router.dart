import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:todo_app/features/auth/viewmodel/auth_state.dart';
import 'package:todo_app/features/auth/view/login_screen.dart';
import 'package:todo_app/features/todo/view/todo_list_screen.dart';
import 'package:todo_app/features/todo/view/todo_form_screen.dart';
import 'package:todo_app/features/todo/domain/todo_model.dart';

// Nomes das rotas centralizados — nunca use strings mágicas espalhadas
class AppRoutes {
  static const login = '/login';
  static const todos = '/todos';
  static const todoForm = '/todos/form';
}

final routerProvider = Provider<GoRouter>((ref) {
  // Ouve o estado de autenticação para redirecionar automaticamente
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    // redirect é chamado antes de cada navegação
    redirect: (context, routerState) {
      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      final isOnLogin = routerState.matchedLocation == AppRoutes.login;

      // Se autenticado e tentando ir para login → manda para todos
      if (isAuthenticated && isOnLogin) return AppRoutes.todos;

      // Se não autenticado e tentando ir para qualquer outra rota → manda para login
      if (!isAuthenticated && !isOnLogin) return AppRoutes.login;

      // Caso contrário, segue a navegação normalmente
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.todos,
        builder: (context, state) => const TodoListScreen(),
      ),
      GoRoute(
        path: AppRoutes.todoForm,
        builder: (context, state) {
          // Recebe um Todo opcional via 'extra' para edição
          // Se for null, o formulário abre em modo criação
          final todo = state.extra as Todo?;
          return TodoFormScreen(todo: todo);
        },
      ),
    ],
  );
});
