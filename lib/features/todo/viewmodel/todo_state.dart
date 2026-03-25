// lib/features/todo/viewmodel/todo_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo_app/features/todo/domain/todo_model.dart';

part 'todo_state.freezed.dart';

@freezed
class TodoState with _$TodoState {
  // Estado inicial — app acabou de abrir
  const factory TodoState.initial() = _Initial;

  // Carregando — aguardando resposta do Supabase
  const factory TodoState.loading() = _Loading;

  // Sucesso — dados prontos para exibir
  const factory TodoState.success(List<Todo> todos) = _Success;

  // Erro — algo deu errado, exibe mensagem
  const factory TodoState.error(String message) = _Error;
}
