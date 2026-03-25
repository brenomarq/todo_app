// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Garante que os bindings do Flutter estão prontos antes
  // de qualquer operação assíncrona
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente do arquivo .env
  await dotenv.load(fileName: '.env');

  // Inicializa o Supabase com as credenciais do .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // ProviderScope é obrigatório para o Riverpod funcionar —
  // ele envolve todo o app e gerencia o ciclo de vida dos providers
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Todo App')),
        body: const Center(child: Text('Welcome to the Todo App')),
      ),
    );
  }
}
