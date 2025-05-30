import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/pix_key.dart';
import 'package:flutter_application_1/screens/pix/add_pix_key_screen.dart';

class PixKeysScreen extends StatefulWidget {
  const PixKeysScreen({Key? key}) : super(key: key);

  @override
  _PixKeysScreenState createState() => _PixKeysScreenState();
}

class _PixKeysScreenState extends State<PixKeysScreen> {
  // TODO: Substituir por chamada ao serviço
  List<PixKey> _pixKeys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPixKeys();
  }

  Future<void> _loadPixKeys() async {
    setState(() => _isLoading = true);
    // TODO: Implementar carregamento das chaves do backend
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _pixKeys = [];
      _isLoading = false;
    });
  }

  Future<void> _addPixKey() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddPixKeyScreen()),
    );

    if (result == true) {
      await _loadPixKeys();
    }
  }

  Future<void> _removePixKey(PixKey key) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover chave PIX'),
        content: Text(
            'Tem certeza que deseja remover a chave ${key.keyValue}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implementar remoção da chave no backend
      await _loadPixKeys();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Chaves PIX'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pixKeys.isEmpty
              ? _buildEmptyState()
              : _buildPixKeysList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPixKey,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar Chave'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.vpn_key_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma chave PIX cadastrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione uma chave para começar a usar o PIX',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPixKeysList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pixKeys.length,
      itemBuilder: (context, index) {
        final key = _pixKeys[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.vpn_key_rounded,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              key.keyValue,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Tipo: ${key.keyType} • ${key.isActive ? 'Ativa' : 'Inativa'}' ,
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              onPressed: () => _removePixKey(key),
            ),
            onTap: () {
              // TODO: Mostrar detalhes da chave
            },
          ),
        );
      },
    );
  }
}
