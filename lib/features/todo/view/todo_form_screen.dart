// lib/features/todo/view/todo_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/features/todo/domain/todo_model.dart';
import 'package:todo_app/features/todo/viewmodel/todo_viewmodel.dart';
import 'package:todo_app/features/todo/viewmodel/todo_state.dart';

class TodoFormScreen extends ConsumerStatefulWidget {
  // Se todo é null → modo criação
  // Se todo não é null → modo edição
  final Todo? todo;

  const TodoFormScreen({super.key, this.todo});

  @override
  ConsumerState<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends ConsumerState<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  // Determina o modo baseado se recebeu um todo ou não
  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    // Se for edição, pré-preenche os campos com os dados existentes
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.todo?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<TodoState>(todoViewModelProvider, (previous, next) {
      next.whenOrNull(
        // Quando a operação for bem sucedida, volta para a lista
        success: (_) {
          final wasLoading =
              previous?.maybeWhen(loading: () => true, orElse: () => false) ??
              false;
          if (wasLoading) context.pop();
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        },
      );
    });

    // Observa o estado para mostrar loading no botão
    final state = ref.watch(todoViewModelProvider);
    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo de título
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ex: Estudar Flutter',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O título é obrigatório';
                  }
                  if (value.trim().length < 3) {
                    return 'Título muito curto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de descrição
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Adicione mais detalhes...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),

              // Botão de salvar com estado de loading
              FilledButton(
                onPressed: isLoading ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Salvar alterações' : 'Criar tarefa',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (_isEditing) {
      // Modo edição: usa copyWith para criar versão atualizada
      final updatedTodo = widget.todo!.copyWith(
        title: title,
        description: description.isEmpty ? null : description,
      );
      ref.read(todoViewModelProvider.notifier).updateTodo(updatedTodo);
    } else {
      // Modo criação: passa apenas os dados necessários
      ref
          .read(todoViewModelProvider.notifier)
          .createTodo(
            title: title,
            description: description.isEmpty ? null : description,
          );
    }
  }
}
