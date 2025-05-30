import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _selectedDate;
  
  // Formatador de máscara para telefone
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // Seleciona a data de nascimento
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Valida a senha
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }


  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Por favor, selecione sua data de nascimento';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),

        birthDate: _selectedDate!,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      );

      if (!mounted) return;
      
      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
      
      // Navegar para a tela de login
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      String errorMessage = 'Erro ao cadastrar';
      if (e.toString().contains('already registered')) {
        errorMessage = 'Este e-mail já está cadastrado';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'A senha fornecida é muito fraca';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'O endereço de e-mail fornecido é inválido';
      } else {
        errorMessage = e.toString();
      }
      
      setState(() {
        _errorMessage = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira seu nome completo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Data de Nascimento
              TextFormField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                  hintText: 'DD/MM/AAAA',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, selecione sua data de nascimento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo E-mail
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira seu e-mail';
                  }
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                    return 'Por favor, insira um e-mail válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone (opcional)',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: '(00) 00000-0000',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneFormatter],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme sua senha';
                  }
                  if (value != _passwordController.text) {
                    return 'As senhas não conferem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Criar Conta',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                child: const Text('Já tem uma conta? Faça login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
