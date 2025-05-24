import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final List<String> _currencies = ApiConfig.supportedCurrencies.keys.toList();
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
    debugPrint('initState() chamado');
    
    // Inicializa o controlador de texto com valor padrão
    _amountController.text = '1.00';
    
    // Inicia o processo de carregamento
    _startInitialLoad();
  }
  
  // Inicializa o carregamento dos dados
  Future<void> _startInitialLoad() async {
    debugPrint('_startInitialLoad() chamado');
    
    if (!mounted) return;
    
    try {
      // Primeiro tenta carregar do cache
      await _loadCachedData();
      
      // Depois tenta buscar dados da API
      if (mounted) {
        _startAutoUpdate();
      }
    } catch (e) {
      debugPrint('Erro no carregamento inicial: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar dados. Tente novamente mais tarde.';
          _isLoading = false;
        });
      }
    }
  }

  void _startAutoUpdate() {
    debugPrint('_startAutoUpdate() chamado');
    
    // Cancelar timer existente se houver
    _updateTimer?.cancel();
    
    // Buscar imediatamente
    if (mounted) {
      _fetchQuotation().then((_) {
        debugPrint('Primeira busca concluída');
      }).catchError((e) {
        debugPrint('Erro na primeira busca: $e');
      });
    }
    
    // Configurar timer para atualizações periódicas (a cada 30 segundos)
    _updateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (mounted) {
          _fetchQuotation().then((_) {
            debugPrint('Atualização periódica concluída');
          }).catchError((e) {
            debugPrint('Erro na atualização periódica: $e');
          });
        } else {
          timer.cancel();
        }
      },
    );
    
    debugPrint('Timer de atualização configurado');
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  // Carrega dados salvos localmente
  Future<void> _loadCachedData() async {
    debugPrint('_loadCachedData() chamado');
    
    // Se já temos dados, não precisamos carregar do cache
    if (_quotationData != null) {
      debugPrint('Já temos dados, pulando carregamento do cache');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    
    try {
      debugPrint('Carregando dados do SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('last_quotation');
      final lastUpdate = prefs.getInt('last_update');
      
      if (savedData != null && lastUpdate != null) {
        debugPrint('Dados encontrados no cache');
        if (mounted) {
          setState(() {
            try {
              _quotationData = json.decode(savedData);
              _lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
              _errorMessage = 'Dados carregados localmente';
              _isLoading = false;
              debugPrint('Dados do cache carregados com sucesso');
            } catch (e) {
              debugPrint('Erro ao decodificar dados do cache: $e');
              _errorMessage = 'Erro ao carregar dados locais';
              _isLoading = false;
            }
          });
          _updateConversion();
          return;
        }
      } else {
        debugPrint('Nenhum dado encontrado no cache');
      }
      
      // Se chegou aqui, não há dados em cache
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      
      // Tenta carregar dados mockados
      debugPrint('Tentando carregar dados mockados...');
      await _loadMockData();
      
    } catch (e) {
      debugPrint('Erro ao carregar dados em cache: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar dados locais';
          _isLoading = false;
        });
      }
      
      // Tenta carregar dados mockados em caso de erro
      await _loadMockData();
    }
  }

  // Salva os dados localmente
  Future<void> _saveDataToCache() async {
    if (_quotationData == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_quotation', json.encode(_quotationData));
      await prefs.setInt('last_update', _lastUpdateTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Erro ao salvar dados em cache: $e');
    }
  }

  Future<void> _fetchQuotation() async {
    debugPrint('_fetchQuotation() chamado');
    
    if (_isLoading) {
      debugPrint('Já está carregando, ignorando chamada duplicada');
      return;
    }
    
    if (!mounted) {
      debugPrint('Widget não está montado, abortando');
      return;
    }
    
    debugPrint('Iniciando carregamento...');
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Verifica a conectividade antes de tentar a requisição
    try {
      debugPrint('Verificando conectividade...');
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        debugPrint('Sem conexão com a internet');
        if (mounted) {
          setState(() {
            _errorMessage = 'Sem conexão com a internet. Usando dados locais.';
            _isLoading = false;
          });
          await _loadCachedData();
        }
        return;
      }

      final url = ApiConfig.getQuotationUrl();
      debugPrint('Conectado. Buscando dados de: $url');
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 15));
      
      debugPrint('Resposta recebida. Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Status 200 OK. Processando resposta...');
        final data = json.decode(response.body);
        
        // Valida a estrutura dos dados recebidos
        if (data is! Map<String, dynamic> || 
            data['results'] is! Map<String, dynamic> || 
            data['results']['currencies'] is! Map<String, dynamic>) {
          debugPrint('Formato de dados inválido da API');
          throw FormatException('Formato de dados inválido da API');
        }
        
        if (mounted) {
          debugPrint('Dados válidos, atualizando estado...');
          setState(() {
            _quotationData = data;
            _lastUpdateTime = DateTime.now();
            _errorMessage = '';
            _isLoading = false;
          });
          _updateConversion();
          await _saveDataToCache();
          debugPrint('Dados salvos em cache');
        }
      } else {
        // Tratamento de erros HTTP
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = 'Requisição inválida';
            break;
          case 401:
            errorMessage = 'Não autorizado - verifique sua chave de API';
            break;
          case 403:
            errorMessage = 'Acesso negado';
            break;
          case 404:
            errorMessage = 'Recurso não encontrado';
            break;
          case 429:
            errorMessage = 'Muitas requisições - limite de taxa excedido';
            break;
          case 500:
            errorMessage = 'Erro interno do servidor';
            break;
          case 503:
            errorMessage = 'Serviço indisponível';
            break;
          default:
            errorMessage = 'Erro ao carregar cotações (${response.statusCode})';
        }
        
        debugPrint('Erro HTTP ${response.statusCode}: $errorMessage');
        if (mounted) {
          setState(() {
            _errorMessage = '$errorMessage. Usando dados locais.';
            _isLoading = false;
          });
          await _loadCachedData();
        }
      }
    } on TimeoutException {
      debugPrint('Timeout ao buscar dados da API');
      if (mounted) {
        setState(() {
          _errorMessage = 'Tempo de conexão esgotado. Usando dados locais.';
          _isLoading = false;
        });
        await _loadCachedData();
      }
    } on FormatException catch (e) {
      debugPrint('Erro de formatação nos dados: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro no formato dos dados recebidos. Usando dados locais.';
          _isLoading = false;
        });
        await _loadCachedData();
      }
    } catch (e) {
      debugPrint('Erro inesperado ao buscar cotações: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro inesperado. Usando dados locais.';
          _isLoading = false;
        });
        await _loadCachedData();
      }
    } finally {
      debugPrint('_fetchQuotation() finalizado. _isLoading: $_isLoading');
    }
    // Não é mais necessário o bloco finally, pois o _isLoading é atualizado em cada caso
  }

  Future<void> _loadMockData() async {
    debugPrint('_loadMockData() chamado');
    
    // Se o widget não está montado, não faz nada
    if (!mounted) {
      debugPrint('Widget não está montado, abortando _loadMockData');
      return;
    }
    
    // Se já temos dados, não carrega os mockados
    if (_quotationData != null) {
      debugPrint('Já temos dados, pulando carregamento de dados mockados');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    
    debugPrint('Carregando dados mockados...');
    
    try {
      // Adiciona um pequeno atraso para garantir que a UI possa ser atualizada
      await Future.delayed(const Duration(milliseconds: 50));
      
      if (!mounted) return;
      
      final mockData = {
        'by': 'default',
        'valid_key': true,
        'results': {
          'currencies': {
            'USD': {'buy': 5.10, 'sell': 5.20, 'variation': 0.21},
            'EUR': {'buy': 5.60, 'sell': 5.70, 'variation': 0.15},
            'GBP': {'buy': 6.50, 'sell': 6.60, 'variation': 0.12},
            'ARS': {'buy': 0.020, 'sell': 0.021, 'variation': 0.05},
            'BTC': {'buy': 350000.00, 'sell': 360000.00, 'variation': -2.5},
            'JPY': {'buy': 0.036, 'sell': 0.037, 'variation': 0.08},
            'ETH': {'buy': 18000.00, 'sell': 18500.00, 'variation': -1.2},
            'CAD': {'buy': 3.80, 'sell': 3.90, 'variation': 0.10},
            'AUD': {'buy': 3.50, 'sell': 3.60, 'variation': 0.15},
            'CNY': {'buy': 0.70, 'sell': 0.72, 'variation': 0.05},
          },
          'stocks': {},
          'available_sources': [],
          'taxes': []
        },
        'execution_time': 0.01,
        'from_cache': true
      };
      
      if (mounted) {
        setState(() {
          _quotationData = mockData;
          _lastUpdateTime = DateTime.now();
          _isLoading = false;
          _errorMessage = _errorMessage.isNotEmpty 
              ? _errorMessage 
              : 'Usando dados locais';
          debugPrint('Dados mockados carregados com sucesso');
        });
        _updateConversion();
        
        // Salva os dados mockados no cache para uso futuro
        _saveDataToCache().then((_) {
          debugPrint('Dados mockados salvos no cache');
        }).catchError((e) {
          debugPrint('Erro ao salvar dados mockados no cache: $e');
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados mockados: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar dados. Tente novamente mais tarde.';
          _isLoading = false;
        });
      }
    }
  }

  void _updateConversion() {
    if (_quotationData == null || 
        _quotationData!['results']?['currencies'] == null) return;

    final currencies = _quotationData!['results']['currencies'];
    final currency = currencies[_selectedCurrency];
    
    if (currency == null) return;
    
    final rate = currency['buy']?.toDouble() ?? 0.0;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    setState(() {
      _convertedAmount = amount * rate;
    });
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 5) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 1) {
      return 'Há ${difference.inSeconds} segundos';
    } else if (difference.inHours < 1) {
      return 'Há ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else if (difference.inDays < 1) {
      return 'Há ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
    } else {
      return 'Em ${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildCurrencyCard(String currency) {
    final currencies = _quotationData?['results']?['currencies'];
    final currencyData = currencies?[currency];
    
    if (currencyData == null) return const SizedBox.shrink();
    
    final buy = currencyData['buy']?.toDouble() ?? 0.0;
    final sell = currencyData['sell']?.toDouble() ?? 0.0;
    final variation = currencyData['variation']?.toDouble() ?? 0.0;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${ApiConfig.supportedCurrencies[currency] ?? currency}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'R\$${buy.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Venda: R\$${sell.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${variation >= 0 ? '↑' : '↓'} ${variation.abs().toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: variation >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExchangeRatesList() {
    if (_quotationData == null || _quotationData!['results']?['currencies'] == null) {
      return [];
    }

    final rates = _quotationData!['results']['currencies'] as Map<String, dynamic>;
    final List<Widget> rateWidgets = [];

    // Adiciona todas as moedas à lista
    for (var currency in _currencies) {
      if (rates.containsKey(currency)) {
        rateWidgets.add(_buildCurrencyCard(currency));
      }
    }

    return rateWidgets;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build() - _isLoading: $_isLoading, _errorMessage: $_errorMessage');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotações'),
        actions: [
          if (_lastUpdateTime != null && !_isLoading && _quotationData != null)
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
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchQuotation,
            tooltip: 'Atualizar cotações',
          ),
        ],
      ),
      body: _isLoading && _quotationData == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchQuotation,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _errorMessage.isNotEmpty && _quotationData == null
                    ? Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange.shade700,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tentar novamente'),
                              onPressed: _isLoading ? null : _fetchQuotation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                  children: [
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
                            if (_quotationData?['results']?['currencies']?[_selectedCurrency] != null)
                              Text(
                                '1 $_selectedCurrency = ${_quotationData!['results']['currencies'][_selectedCurrency]['buy'].toStringAsFixed(4)} BRL',
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
                      'Base: 1 BRL - Atualizado em ${_lastUpdateTime != null ? _formatTimeAgo(_lastUpdateTime) : 'N/A'}',
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
      ),
    );
  }
}
