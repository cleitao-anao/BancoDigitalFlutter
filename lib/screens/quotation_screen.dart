import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/api_config.dart';

class QuotationScreen extends StatefulWidget {
  const QuotationScreen({Key? key}) : super(key: key);

  @override
  _QuotationScreenState createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _quotationData;
  final List<String> _currencies = ApiConfig.supportedCurrencies;
  String _selectedCurrency = 'USD';
  final TextEditingController _amountController = TextEditingController(
    text: '1.00',
  );
  double _convertedAmount = 0.0;
  Timer? _updateTimer;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _startAutoUpdate();
  }

  void _startAutoUpdate() {
    // Cancelar timer existente se houver
    _updateTimer?.cancel();
    
    // Buscar imediatamente
    _fetchQuotation();
    
    // Configurar timer para atualizações periódicas (a cada 30 segundos)
    _updateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (mounted) {
          _fetchQuotation();
        } else {
          timer.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuotation() async {
    if (_isLoading) return;
    
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final url = 'https://v6.exchangerate-api.com/v6/5c8bbed2498b541f8975075f/latest/USD';
      debugPrint('Fetching data from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${ApiConfig.exchangeRateApiKey}'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rates'] != null && mounted) {
          setState(() {
            _quotationData = data;
            _lastUpdateTime = DateTime.now();
          });
          _updateConversion();
          return;
        }
      }
      
      // Se chegou aqui, houve algum erro
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar cotações. Usando dados locais.';
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro de conexão. Usando dados locais.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      // Carrega dados mockados em caso de erro
      if (mounted) _loadMockData();
    }
  }

  void _loadMockData() {
    if (!mounted || _quotationData != null) return;
    
    // Mock data in case the API fails
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final mockData = {
        'base': 'BRL',
        'date': DateTime.now().toIso8601String().split('T')[0],
        'rates': {
          'USD': 0.20,
          'EUR': 0.18,
          'GBP': 0.16,
          'ARS': 51.23,
          'BTC': 0.0000078,
          'JPY': 28.50,
          'ETH': 0.00012,
          'CAD': 0.27,
          'AUD': 0.30,
          'CNY': 1.45,
        },
      };
      
      if (mounted) {
        setState(() {
          _quotationData = mockData;
          _lastUpdateTime = DateTime.now();
          _isLoading = false;
          _errorMessage = _errorMessage.isNotEmpty 
              ? _errorMessage 
              : 'Usando dados locais';
        });
        _updateConversion();
      }
    });
  }

  void _updateConversion() {
    if (_quotationData == null || _quotationData!['rates'] == null) return;

    final rates = _quotationData!['rates'] as Map<String, dynamic>;
    final rate = rates[_selectedCurrency] ?? 0.0;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    setState(() {
      _convertedAmount = amount * (rate is int ? rate.toDouble() : rate);
    });
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Atualizado há $minutes${minutes == 1 ? ' minuto' : ' minutos'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Atualizado há $hours hora${hours == 1 ? '' : 's'}';
    } else {
      return 'Atualizado em ${dateTime.toString().substring(0, 16)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotações'),
        actions: [
          if (_lastUpdateTime != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
              child: Text(
                _formatTimeAgo(_lastUpdateTime!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchQuotation,
            tooltip: 'Atualizar cotações',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchQuotation,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Currency converter card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Conversor de Moedas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // From currency (BRL)
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _amountController,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: 'Valor em BRL',
                                      border: OutlineInputBorder(),
                                      prefixText: 'R\$ ',
                                    ),
                                    onChanged: (_) => _updateConversion(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'BRL',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // To currency (selected)
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                      text: _convertedAmount.toStringAsFixed(4),
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Valor em $_selectedCurrency',
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                DropdownButton<String>(
                                  value: _selectedCurrency,
                                  items:
                                      _currencies.map((String currency) {
                                        return DropdownMenuItem<String>(
                                          value: currency,
                                          child: Text(currency),
                                        );
                                      }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedCurrency = newValue;
                                        _updateConversion();
                                      });
                                    }
                                  },
                                  underline: Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '1 $_selectedCurrency = ${(1 / (_quotationData!['rates']?[_selectedCurrency] ?? 1)).toStringAsFixed(4)} BRL',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Exchange rates list
                    const Text(
                      'Taxas de Câmbio',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Base: 1 BRL - Atualizado em ${_quotationData?['date'] ?? 'N/A'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    ..._buildExchangeRatesList(),
                    const SizedBox(height: 24),
                    const Text(
                      'As cotações são fornecidas por terceiros e podem estar desatualizadas. Valores meramente informativos.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
    );
  }

  List<Widget> _buildExchangeRatesList() {
    if (_quotationData == null || _quotationData!['rates'] == null) {
      return [];
    }

    final rates = _quotationData!['rates'] as Map<String, dynamic>;
    final List<Widget> rateWidgets = [];

    // Add all currencies to the list
    for (var currency in _currencies) {
      if (rates.containsKey(currency)) {
        final rate = rates[currency];
        final isSelected = _selectedCurrency == currency;

        rateWidgets.add(
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 8),
            color:
                isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                child: Text(
                  currency,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                '1 $currency = ${(1 / (rate is int ? rate.toDouble() : rate)).toStringAsFixed(4)} BRL',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '1 BRL = ${(rate is int ? rate.toDouble() : rate).toStringAsFixed(4)} $currency',
              ),
              trailing:
                  isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
              onTap: () {
                setState(() {
                  _selectedCurrency = currency;
                  _updateConversion();
                });
              },
            ),
          ),
        );
      }
    }

    return rateWidgets;
  }
}
