import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/services/bank_service.dart';
import 'package:intl/intl.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  double _investmentAmount = 1000.0;
  String _selectedInvestment = 'CDB';
  final List<String> _investmentTypes = [
    'CDB',
    'LCI',
    'LCA',
    'Tesouro Direto',
    'Fundos de Renda Fixa',
    'Fundos de Ações'
  ];

  final Map<String, double> _interestRates = {
    'CDB': 0.12,
    'LCI': 0.1,
    'LCA': 0.095,
    'Tesouro Direto': 0.115,
    'Fundos de Renda Fixa': 0.11,
    'Fundos de Ações': 0.15,
  };

  final Map<String, String> _riskLevels = {
    'CDB': 'Baixo',
    'LCI': 'Baixo',
    'LCA': 'Baixo',
    'Tesouro Direto': 'Médio',
    'Fundos de Renda Fixa': 'Médio',
    'Fundos de Ações': 'Alto',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final double rate = _interestRates[_selectedInvestment] ?? 0.0;
    final double yearlyReturn = _investmentAmount * rate;
    final double monthlyReturn = yearlyReturn / 12;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investimentos'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de Investimento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedInvestment,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: _investmentTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedInvestment = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rentabilidade ao ano:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${(rate * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nível de risco:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _riskLevels[_selectedInvestment] == 'Baixo'
                                ? Colors.green.withOpacity(0.2)
                                : _riskLevels[_selectedInvestment] == 'Médio'
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _riskLevels[_selectedInvestment] ?? '',
                            style: TextStyle(
                              color: _riskLevels[_selectedInvestment] == 'Baixo'
                                  ? Colors.green
                                  : _riskLevels[_selectedInvestment] == 'Médio'
                                      ? Colors.orange
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Valor do Investimento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currencyFormat.format(_investmentAmount),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: _investmentAmount,
                      min: 100,
                      max: 10000,
                      divisions: 99,
                      label: currencyFormat.format(_investmentAmount),
                      onChanged: (double value) {
                        setState(() {
                          _investmentAmount = value.roundToDouble();
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(currencyFormat.format(100)),
                        Text(currencyFormat.format(10000)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Projeção de Retorno',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildReturnRow('Mensal:', currencyFormat.format(monthlyReturn)),
                    const Divider(),
                    _buildReturnRow('Anual:', currencyFormat.format(yearlyReturn)),
                    const Divider(),
                    _buildReturnRow('Em 5 anos:', currencyFormat.format(yearlyReturn * 5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implementar lógica de investimento
                  _showInvestmentConfirmation(context, currencyFormat);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: theme.primaryColor,
                ),
                child: const Text(
                  'Investir Agora',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lembre-se: Todo investimento tem risco de perda. Consulte um especialista financeiro antes de investir.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showInvestmentConfirmation(
      BuildContext context, NumberFormat currencyFormat) async {
    final bankService = Provider.of<BankService>(context, listen: false);
    final balance = await bankService.getBalance();

    if (_investmentAmount > balance) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Saldo Insuficiente'),
          content: Text(
              'Você não possui saldo suficiente para este investimento.\n\nSaldo disponível: ${currencyFormat.format(balance)}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Investimento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: $_selectedInvestment'),
            const SizedBox(height: 8),
            Text('Valor: ${currencyFormat.format(_investmentAmount)}'),
            const SizedBox(height: 16),
            const Text('Deseja confirmar este investimento?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Simular processamento
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Simular tempo de processamento
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.pop(context); // Fechar loading

      // TODO: Implementar lógica real de investimento
      await bankService.makeInvestment(_investmentAmount);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Investimento Realizado!'),
          content: const Text('Seu investimento foi realizado com sucesso.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Voltar para a tela anterior
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
