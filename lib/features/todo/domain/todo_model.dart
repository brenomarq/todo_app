import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_model.freezed.dart';
part 'todo_model.g.dart';

// Adicione dentro da classe Todo, antes do factory fromJson:
@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    String? description,
    @JsonKey(name: 'is_completed') required bool isCompleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Todo;

  // Factory para criar um Todo "em branco" ao abrir o formulário
  factory Todo.empty() => Todo(
    id: '', // será gerado pelo Supabase
    userId: '', // será preenchido pelo Repository
    title: '',
    description: null,
    isCompleted: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
