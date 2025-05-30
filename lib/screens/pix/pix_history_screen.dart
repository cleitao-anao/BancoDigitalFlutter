import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/transaction.dart';
import 'package:flutter_application_1/widgets/transaction_item.dart';

class PixHistoryScreen extends StatefulWidget {
  const PixHistoryScreen({Key? key}) : super(key: key);

  @override
  _PixHistoryScreenState createState() => _PixHistoryScreenState();
}

class _PixHistoryScreenState extends State<PixHistoryScreen> {
  // TODO: Substituir por chamada ao serviço
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    
    // TODO: Implementar carregamento das transações do backend
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _transactions = []; // Lista vazia para exemplo
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Transações'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _loadTransactions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? _buildEmptyState()
              : _buildTransactionList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma transação encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suas transações PIX aparecerão aqui',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return TransactionItem(transaction: transaction);
        },
      ),
    );
  }
}
