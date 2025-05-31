import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/config/app_routes.dart' show loginRoute;
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _logout() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.logout();
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          loginRoute, 
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao sair. Tente novamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          _buildListTile(
            context,
            icon: Icons.person_outline,
            title: 'Conta',
            onTap: () {
              // Navegar para tela de conta
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abrir tela de conta')),
              );
            },
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppTheme.themeNotifier,
            builder: (_, themeMode, __) {
              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Modo Escuro'),
                value: themeMode == ThemeMode.dark,
                onChanged: (value) async {
                  await AppTheme.toggleTheme();
                },
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.lock_outline,
            title: 'Privacidade e segurança',
            onTap: () {
              // Navegar para tela de privacidade
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abrir privacidade e segurança')),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.help_outline,
            title: 'Ajuda',
            onTap: () {
              // Navegar para tela de ajuda
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abrir ajuda')),
              );
            },
          ),
          const Divider(),
          _buildListTile(
            context,
            icon: Icons.logout,
            title: 'Sair',
            textColor: Colors.red,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Tem certeza que deseja sair da sua conta?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o diálogo
                await _logout();
              },
            ),
          ],
        );
      },
    );
  }
}
