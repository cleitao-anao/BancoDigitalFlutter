import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/pix/pix_transfer_screen.dart';
import 'package:flutter_application_1/screens/pix/pix_keys_screen.dart';
import 'package:flutter_application_1/screens/pix/pix_history_screen.dart';

class PixHomeScreen extends StatelessWidget {
  const PixHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PIX'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionCard(
              context,
              title: 'Fazer Transferência',
              icon: Icons.payment_rounded,
              onTap: () => _navigateTo(context, const PixTransferScreen()),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: 'Minhas Chaves PIX',
              icon: Icons.vpn_key_rounded,
              onTap: () => _navigateTo(context, const PixKeysScreen()),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: 'Histórico de Transações',
              icon: Icons.history_rounded,
              onTap: () => _navigateTo(context, const PixHistoryScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
