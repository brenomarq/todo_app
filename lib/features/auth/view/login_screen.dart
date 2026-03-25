// lib/features/auth/view/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:todo_app/features/auth/viewmodel/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

// ConsumerStatefulWidget quando precisamos de StatefulWidget + Riverpod
// Usamos StatefulWidget aqui por causa dos TextEditingControllers
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Sempre dispose dos controllers para evitar memory leak
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen reage a mudanças de estado SEM reconstruir a tela
    // Ideal para efeitos colaterais: navegação, snackbar, loading
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      next.when(
        initial: () => null,
        loading: () => EasyLoading.show(status: 'Aguarde...'),
        authenticated: (user) => EasyLoading.dismiss(),
        unauthenticated: () => EasyLoading.dismiss(),
        error: (message) {
          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Todo App',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Campo de email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o email';
                      }
                      if (!value.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      // Botão para mostrar/ocultar senha
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a senha';
                      }
                      if (value.length < 6) {
                        return 'Mínimo de 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botão de login
                  FilledButton(
                    onPressed: _signIn,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Entrar', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botão de cadastro
                  OutlinedButton(
                    onPressed: _signUp,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Criar conta',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() {
    // Valida o formulário antes de disparar a ação
    if (!_formKey.currentState!.validate()) return;

    // Dispara a ação no ViewModel — View não sabe o que acontece depois
    ref
        .read(authViewModelProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(authViewModelProvider.notifier)
        .signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }
}
