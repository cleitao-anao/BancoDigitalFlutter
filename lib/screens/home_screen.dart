import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Banco'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account balance card
            _buildBalanceCard(context),
            const SizedBox(height: 24),
            
            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Ações rápidas',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            
            // Recent transactions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Últimas transações',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to full transaction history
                    },
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
            ),
            _buildRecentTransactions(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, 0),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColorDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo disponível',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'R\$ 12.456,78',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(Icons.credit_card, 'Cartão final 7890'),
              _buildInfoItem(Icons.account_balance, 'Ag. 1234-5 / C/C 12.345-6'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.pix,
        'label': 'Pix',
        'onTap': () {
          // TODO: Navigate to Pix screen
        },
      },
      {
        'icon': Icons.swap_horiz,
        'label': 'Transferir',
        'onTap': () {
          Navigator.pushNamed(context, AppRoutes.transfer);
        },
      },
      {
        'icon': Icons.attach_money,
        'label': 'Pagar',
        'onTap': () {
          // TODO: Navigate to payment screen
        },
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Investir',
        'onTap': () {
          // TODO: Navigate to investments
        },
      },
      {
        'icon': Icons.currency_exchange,
        'label': 'Câmbio',
        'onTap': () {
          Navigator.pushNamed(context, AppRoutes.quotation);
        },
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: actions.map((action) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                InkWell(
                  onTap: action['onTap'] as void Function()?,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      action['icon'] as IconData?,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = [
      {
        'icon': Icons.shopping_bag,
        'title': 'Supermercado',
        'date': 'Hoje',
        'amount': '-R\$ 128,90',
        'isPositive': false,
      },
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Salário',
        'date': 'Ontem',
        'amount': '+R\$ 5.200,00',
        'isPositive': true,
      },
      {
        'icon': Icons.phone_android,
        'title': 'Recarga de celular',
        'date': '24/05',
        'amount': '-R\$ 30,00',
        'isPositive': false,
      },
      {
        'icon': Icons.restaurant,
        'title': 'Restaurante',
        'date': '23/05',
        'amount': '-R\$ 78,50',
        'isPositive': false,
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(
              transaction['icon'] as IconData?,
              color: Theme.of(context).primaryColor,
            ),
          ),
          title: Text(transaction['title'] as String),
          subtitle: Text(
            transaction['date'] as String,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Text(
            transaction['amount'] as String,
            style: TextStyle(
              color: transaction['isPositive'] as bool
                  ? AppTheme.successColor
                  : AppTheme.errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            // TODO: Navigate to transaction details
          },
        );
      },
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.credit_card_outlined),
          activeIcon: Icon(Icons.credit_card),
          label: 'Cartões',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pix_outlined),
          activeIcon: Icon(Icons.pix),
          label: 'Pix',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.query_stats_outlined),
          activeIcon: Icon(Icons.query_stats),
          label: 'Investir',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_outlined),
          activeIcon: Icon(Icons.menu),
          label: 'Mais',
        ),
      ],
      onTap: (index) {
        // Handle bottom navigation tap
        if (index == 1) {
          // Navigate to Cards
        } else if (index == 2) {
          // Navigate to Pix
        } else if (index == 3) {
          // Navigate to Investments
        } else if (index == 4) {
          // Open menu
        }
      },
    );
  }
}
