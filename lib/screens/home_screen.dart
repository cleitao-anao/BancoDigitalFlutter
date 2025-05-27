import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Banco'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Tela inicial
          SingleChildScrollView(
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
                            // TODO: Navegar para o histórico completo
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
          // Outras telas podem ser adicionadas aqui
          const Center(child: Text('Cartões')),
          const Center(child: Text('Pix')),
          const Center(child: Text('Investir')),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, _currentIndex),
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
        'color': const Color(0xFF7B1FA2),
        'gradient': [
          const Color(0xFF9C27B0),
          const Color(0xFF7B1FA2),
        ],
        'onTap': () {
          // TODO: Navegar para tela do Pix
        },
      },
      {
        'icon': Icons.swap_horiz,
        'label': 'Transferir',
        'color': const Color(0xFF2196F3),
        'gradient': [
          const Color(0xFF42A5F5),
          const Color(0xFF1976D2),
        ],
        'onTap': () {
          Navigator.pushNamed(context, AppRoutes.transfer);
        },
      },
      {
        'icon': Icons.attach_money,
        'label': 'Pagar',
        'color': const Color(0xFF4CAF50),
        'gradient': [
          const Color(0xFF66BB6A),
          const Color(0xFF388E3C),
        ],
        'onTap': () {
          // TODO: Navegar para tela de pagamento
        },
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Investir',
        'color': const Color(0xFFFF9800),
        'gradient': [
          const Color(0xFFFFA726),
          const Color(0xFFF57C00),
        ],
        'onTap': () {
          // TODO: Navegar para investimentos
        },
      },
      {
        'icon': Icons.currency_exchange,
        'label': 'Câmbio',
        'color': const Color(0xFF00BCD4),
        'gradient': [
          const Color(0xFF26C6DA),
          const Color(0xFF0097A7),
        ],
        'onTap': () {
          Navigator.pushNamed(context, AppRoutes.quotation);
        },
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: actions.map((action) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: action['gradient'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (action['gradient'] as List<Color>).first.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: action['onTap'] as void Function()?,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              action['icon'] as IconData,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              action['label'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  action['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
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
        if (index == 4) {
          // Navegar para a tela de configurações
          Navigator.pushNamed(context, AppRoutes.settings);
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
    );
  }
}
