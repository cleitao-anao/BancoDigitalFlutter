import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTestWidget extends StatefulWidget {
  const SupabaseTestWidget({Key? key}) : super(key: key);

  @override
  _SupabaseTestWidgetState createState() => _SupabaseTestWidgetState();
}

class _SupabaseTestWidgetState extends State<SupabaseTestWidget> {
  bool _isLoading = false;
  String _result = '';
  final _supabase = Supabase.instance.client;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Testando conexão...';
    });

    try {
      // Testa uma consulta simples à tabela 'accounts'
      final response = await _supabase
          .from('accounts')
          .select()
          .limit(1);
      
      setState(() {
        _result = 'Conexão bem-sucedida!\n\nDados recebidos:\n$response';
      });
    } catch (e) {
      setState(() {
        _result = 'Erro na conexão:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _isLoading ? null : _testConnection,
            child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Testar Conexão com Supabase'),
          ),
          const SizedBox(height: 20),
          Text(
            'Resultado do teste:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(
              minHeight: 100,
              maxHeight: 400,
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _result,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
