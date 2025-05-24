import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _pixKeyController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _usePix = false;
  String _selectedAccount = 'Conta Corrente';
  final List<String> _accounts = ['Conta Corrente', 'Poupança'];
  
  // Mask formatters
  final _accountNumberFormatter = MaskTextInputFormatter(
    mask: '#####-#',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  final _amountFormatter = MaskTextInputFormatter(
    mask: '###0.00',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _pixKeyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitTransfer() {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Text('Transferência Realizada'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sua transferência foi realizada com sucesso!'),
                const SizedBox(height: 16),
                _buildInfoRow('Valor:', 'R\$ ${_amountController.text}'),
                _buildInfoRow('Favorecido:', _usePix 
                    ? _pixKeyController.text 
                    : 'Ag. 1234-5 / C/C ${_accountNumberController.text}'),
                _buildInfoRow('Descrição:', _descriptionController.text.isNotEmpty 
                    ? _descriptionController.text 
                    : 'Sem descrição'),
                _buildInfoRow('Data:', _formatDate(DateTime.now())),
                _buildInfoRow('Status:', 'Concluído', isSuccess: true),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  Widget _buildInfoRow(String label, String value, {bool isSuccess = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isSuccess ? Colors.green : null,
                fontWeight: isSuccess ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferência'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Account selection
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Conta de origem',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedAccount,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: _accounts.map((String account) {
                                return DropdownMenuItem<String>(
                                  value: account,
                                  child: Text(account),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedAccount = newValue;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecione uma conta';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Saldo disponível: R\$ 5.432,10',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Transfer type toggle
                    ToggleButtons(
                      isSelected: [_usePix, !_usePix],
                      onPressed: (index) {
                        setState(() {
                          _usePix = index == 0;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: Colors.white,
                      fillColor: Theme.of(context).primaryColor,
                      color: Theme.of(context).primaryColor,
                      constraints: BoxConstraints.expand(
                        width: (MediaQuery.of(context).size.width - 48) / 2,
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pix, size: 20),
                              SizedBox(width: 8),
                              Text('PIX'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.swap_horiz, size: 20),
                              SizedBox(width: 8),
                              Text('TED/DOC'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Transfer form
                    if (_usePix) ..._buildPixForm() else ..._buildTEDDOCForm(),
                    
                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      maxLength: 50,
                      maxLines: 2,
                      minLines: 1,
                    ),
                    const SizedBox(height: 32),
                    
                    // Transfer button
                    ElevatedButton(
                      onPressed: _submitTransfer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Transferir',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Schedule transfer option
                    TextButton(
                      onPressed: () {
                        // TODO: Implement schedule transfer
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Agendar transferência não implementado'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text('Agendar transferência'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  List<Widget> _buildPixForm() {
    return [
      TextFormField(
        controller: _pixKeyController,
        decoration: const InputDecoration(
          labelText: 'Chave PIX',
          hintText: 'Digite a chave PIX (CPF, email, telefone ou chave aleatória)',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.vpn_key_outlined),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, insira uma chave PIX';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        inputFormatters: [_amountFormatter],
        decoration: const InputDecoration(
          labelText: 'Valor',
          hintText: '0,00',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.attach_money),
          prefixText: 'R\$ ',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, insira um valor';
          }
          final amount = double.tryParse(value.replaceAll('.', '').replaceAll(',', '.'));
          if (amount == null || amount <= 0) {
            return 'Valor inválido';
          }
          // Check if balance is sufficient (mock check)
          if (amount > 5432.10) {
            return 'Saldo insuficiente';
          }
          return null;
        },
      ),
    ];
  }
  
  List<Widget> _buildTEDDOCForm() {
    return [
      // Bank selection would go here in a real app
      TextFormField(
        controller: _accountNumberController,
        inputFormatters: [_accountNumberFormatter],
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Conta',
          hintText: '00000-0',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.account_balance_outlined),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, insira o número da conta';
          }
          if (value.replaceAll(RegExp(r'[^0-9]'), '').length != 6) {
            return 'Conta inválida';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        inputFormatters: [_amountFormatter],
        decoration: const InputDecoration(
          labelText: 'Valor',
          hintText: '0,00',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.attach_money),
          prefixText: 'R\$ ',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, insira um valor';
          }
          final amount = double.tryParse(value.replaceAll('.', '').replaceAll(',', '.'));
          if (amount == null || amount <= 0) {
            return 'Valor inválido';
          }
          // Check if balance is sufficient (mock check)
          if (amount > 5432.10) {
            return 'Saldo insuficiente';
          }
          // Check TED/DOC limit (R$ 4,999.99)
          if (amount > 4999.99) {
            return 'Para valores acima de R\$ 4.999,99 utilize outro tipo de transferência';
          }
          return null;
        },
      ),
      const SizedBox(height: 8),
      const Text(
        'Transferências acima de R\$ 1.000,00 podem demorar até 1 dia útil para serem processadas.',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    ];
  }
}
