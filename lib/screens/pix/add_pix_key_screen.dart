import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/services/bank_service.dart';
import 'package:flutter_application_1/models/pix_key.dart';
import 'package:flutter_application_1/widgets/custom_text_field.dart';

class AddPixKeyScreen extends StatefulWidget {
  const AddPixKeyScreen({Key? key}) : super(key: key);

  @override
  _AddPixKeyScreenState createState() => _AddPixKeyScreenState();
}

class _AddPixKeyScreenState extends State<AddPixKeyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keyValueController = TextEditingController();
  String _selectedKeyType = 'CPF';
  bool _isLoading = false;
  String? _currentKeyId; // Armazena o ID da chave atual para rotação

  final List<String> _keyTypes = [
    'CPF',
    'E-mail',
    'Telefone',
    'Chave Aleatória',
  ];

  @override
  void dispose() {
    _keyValueController.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final bankService = Provider.of<BankService>(context, listen: false);
      
      if (_currentKeyId != null) {
        // Se já existe um ID de chave, estamos atualizando uma chave existente
        await bankService.rotatePixKey(_currentKeyId!);
      } else {
        // Caso contrário, estamos criando uma nova chave
        await bankService.addPixKey(_selectedKeyType, _keyValueController.text);
      }
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chave PIX atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar chave: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Construtor para permitir a edição de uma chave existente
  _AddPixKeyScreenState({PixKey? existingKey}) : _existingKey = existingKey;
  final PixKey? _existingKey;

  @override
  void initState() {
    super.initState();
    // Se estiver editando uma chave existente, preenche os campos
    if (_existingKey != null) {
      _currentKeyId = _existingKey.id;
      _selectedKeyType = _existingKey.keyType;
      _keyValueController.text = _existingKey.keyValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingKey != null ? 'Editar Chave PIX' : 'Adicionar Chave PIX'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selecione o tipo de chave',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedKeyType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _keyTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedKeyType = value);
                    _updateInputType(value);
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildKeyInput(),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_existingKey != null && _existingKey.keyType == 'Chave Aleatória')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : () => _showRotateKeyDialog(context),
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Rotacionar Chave'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveKey,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _existingKey != null ? 'Atualizar Chave' : 'Salvar Chave',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyInput() {
    switch (_selectedKeyType) {
      case 'CPF':
        return CustomTextField(
          controller: _keyValueController,
          label: 'CPF',
          hint: '000.000.000-00',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
            _CpfInputFormatter(),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, informe o CPF';
            }
            // TODO: Adicionar validação de CPF
            return null;
          },
        );
      case 'E-mail':
        return CustomTextField(
          controller: _keyValueController,
          label: 'E-mail',
          hint: 'seu@email.com',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, informe o e-mail';
            }
            if (!value.contains('@') || !value.contains('.')) {
              return 'Por favor, informe um e-mail válido';
            }
            return null;
          },
        );
      case 'Telefone':
        return CustomTextField(
          controller: _keyValueController,
          label: 'Telefone',
          hint: '(00) 00000-0000',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
            _PhoneInputFormatter(),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, informe o telefone';
            }
            // Remove caracteres não numéricos
            final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
            if (digits.length < 10 || digits.length > 11) {
              return 'Número de telefone inválido';
            }
            return null;
          },
        );
      case 'Chave Aleatória':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _keyValueController,
              label: 'Chave Aleatória',
              hint: 'Digite ou gere uma chave aleatória',
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, gere uma chave aleatória';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _generateRandomKey,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Gerar Chave Aleatória'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _updateInputType(String type) {
    _keyValueController.clear();
    if (type == 'Chave Aleatória') {
      _generateRandomKey();
    }
  }

  void _generateRandomKey() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = String.fromCharCodes(
      List.generate(
        32,
        (index) => chars.codeUnitAt(
          DateTime.now().millisecondsSinceEpoch % chars.length,
        ),
      ),
    );
    setState(() {
      _keyValueController.text = random;
    });
  }
  
  Future<void> _showRotateKeyDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rotacionar Chave PIX'),
        content: const Text(
          'Deseja realmente gerar uma nova chave aleatória? A chave atual será desativada e não poderá mais ser usada para receber transferências.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _generateRandomKey();
    }
  }
}

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('.');
      } else if (i == 9) {
        buffer.write('');
      }
      if (i < 11) {
        buffer.write(text[i]);
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    if (text.length >= 2) {
      buffer.write('(${text.substring(0, 2)})');
      if (text.length > 2) {
        buffer.write(' ');
      }
    } else {
      buffer.write(text);
      return TextEditingValue(
        text: buffer.toString(),
        selection: TextSelection.collapsed(offset: buffer.length),
      );
    }

    if (text.length <= 2) {
      return TextEditingValue(
        text: buffer.toString(),
        selection: TextSelection.collapsed(offset: buffer.length),
      );
    }

    if (text.length <= 7) {
      buffer.write(text.substring(2, text.length));
    } else {
      buffer.write('${text.substring(2, 7)}-${text.substring(7, text.length)}');
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
