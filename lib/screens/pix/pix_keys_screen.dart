import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/pix_key.dart';
import 'package:flutter_application_1/screens/pix/add_pix_key_screen.dart';
import 'package:flutter_application_1/services/bank_service.dart';

class PixKeysScreen extends StatefulWidget {
  const PixKeysScreen({Key? key}) : super(key: key);

  @override
  _PixKeysScreenState createState() => _PixKeysScreenState();
}

class _PixKeysScreenState extends State<PixKeysScreen> {
  final List<PixKey> _pixKeys = [];
  bool _isLoading = true;
  StreamSubscription? _pixKeysSubscription;

  @override
  void initState() {
    super.initState();
    _setupPixKeysListener();
  }

  @override
  void dispose() {
    _pixKeysSubscription?.cancel();
    super.dispose();
  }

  void _setupPixKeysListener() {
    final bankService = context.read<BankService>();
    
    // Carrega as chaves iniciais
    _loadPixKeys();
    
    // Escuta por atualizações nas chaves
    _pixKeysSubscription = bankService.pixKeysStream.listen((pixKeys) {
      if (mounted) {
        setState(() {
          _pixKeys.clear();
          _pixKeys.addAll(pixKeys);
          _isLoading = false;
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Erro ao carregar chaves: $error');
      }
    });
  }

  Future<void> _loadPixKeys() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final bankService = context.read<BankService>();
      await bankService.getPixKeys(forceRefresh: true);
    } catch (e) {
      if (mounted) {
        _showError('Erro ao carregar chaves: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            'Tem certeza que deseja remover a chave ${key.keyValue}?\n\nEsta ação irá desativar a chave e ela não poderá mais ser usada para receber transferências.'),
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
      try {
        final bankService = context.read<BankService>();
        await bankService.deactivatePixKey(key.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chave PIX removida com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showError('Erro ao remover chave: $e');
        }
      }
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
                color: key.isActive 
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.vpn_key_rounded,
                color: key.isActive 
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
              ),
            ),
            title: Text(
              context.read<BankService>().formatKeyForDisplay(key.keyType, key.keyValue),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: key.isActive ? null : Colors.grey[600],
              ),
            ),
            subtitle: Text(
              'Tipo: ${key.keyType} • ${key.isActive ? 'Ativa' : 'Inativa'}' ,
              style: TextStyle(color: key.isActive ? Colors.grey[600] : Colors.grey[400]),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) {
                if (value == 'delete') {
                  _removePixKey(key);
                } else if (value == 'edit' && key.keyType == 'Chave Aleatória') {
                  _editPixKey(key);
                }
              },
              itemBuilder: (context) => [
                if (key.keyType == 'Chave Aleatória')
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Rotacionar Chave'),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Remover', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            onTap: () {
              // Mostrar detalhes da chave
              _showKeyDetails(key);
            },
          ),
        );
      },
    );
  }
  
  void _showKeyDetails(PixKey key) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalhes da Chave PIX',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Tipo', key.keyType),
            _buildDetailRow('Valor', key.keyValue, keyType: key.keyType),
            _buildDetailRow('Status', key.isActive ? 'Ativa' : 'Inativa'),
            _buildDetailRow('Criada em', 
              '${key.createdAt.day.toString().padLeft(2, '0')}/'
              '${key.createdAt.month.toString().padLeft(2, '0')}/'
              '${key.createdAt.year}'
            ),
            const SizedBox(height: 16),
            if (key.keyType == 'Chave Aleatória' && key.isActive)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _editPixKey(key);
                  },
                  child: const Text('Rotacionar Chave'),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, {String? keyType}) {
    final displayValue = keyType != null
        ? context.read<BankService>().formatKeyForDisplay(keyType, value)
        : value;
        
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _editPixKey(PixKey key) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddPixKeyScreen(),
        settings: RouteSettings(arguments: key),
      ),
    );

    if (result == true && mounted) {
      await _loadPixKeys();
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
