import 'dart:async';
import 'dart:collection';
import 'dart:math' show Random;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/config/supabase_config.dart' as config;
import 'package:flutter_application_1/models/transaction.dart';
import 'package:flutter_application_1/exceptions/timeout_exception.dart';
import 'package:flutter_application_1/models/pix_key.dart';

class BankService extends ChangeNotifier {
  // Controladores para streams
  final _balanceController = StreamController<double>.broadcast();
  final _transactionsController = StreamController<UnmodifiableListView<Transaction>>.broadcast();
  
  // Cache local
  double? _cachedBalance;
  List<Transaction> _cachedTransactions = [];
  
  // Streams expostos
  Stream<double> get balanceStream => _balanceController.stream;
  Stream<UnmodifiableListView<Transaction>> get transactionsStream => _transactionsController.stream;
  
  // Limite de transações por página
  static const int _transactionsPerPage = 20;
  
  // Controlador para stream de chaves PIX
  final _pixKeysController = StreamController<UnmodifiableListView<PixKey>>.broadcast();
  
  // Flag para controlar se o serviço foi descartado
  bool _isDisposed = false;
  
  // Cache local de chaves PIX
  List<PixKey> _cachedPixKeys = [];
  
  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription? _balanceSubscription;

  // Stream de chaves PIX
  Stream<UnmodifiableListView<PixKey>> get pixKeysStream => _pixKeysController.stream;
  
  // Obtém as chaves PIX do usuário
  Future<List<PixKey>> getPixKeys({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _cachedPixKeys.isNotEmpty) {
        return _cachedPixKeys;
      }
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }
      
      debugPrint('Buscando chaves PIX para o usuário: $userId');
      
      final response = await _supabase
          .from(config.SupabaseConfig.pixKeysTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      debugPrint('Resposta do Supabase: $response');
      
      try {
        _cachedPixKeys = (response as List)
            .map((json) {
              debugPrint('Convertendo JSON para PixKey: $json');
              return PixKey.fromJson(json);
            })
            .toList();
        
        debugPrint('Chaves PIX convertidas com sucesso: ${_cachedPixKeys.length} itens');
        _pixKeysController.add(UnmodifiableListView(_cachedPixKeys));
        
        return _cachedPixKeys;
      } catch (e, stackTrace) {
        debugPrint('Erro ao converter chaves PIX: $e');
        debugPrint('Stack trace: $stackTrace');
        rethrow;
      }
    } catch (e) {
      debugPrint('Erro ao buscar chaves PIX: $e');
      debugPrint('Tipo do erro: ${e.runtimeType}');
      rethrow;
    }
  }
  
  // Formata o valor da chave de acordo com o tipo
  String _formatKeyValue(String keyType, String keyValue) {
    if (keyType == 'Telefone') {
      // Remove todos os caracteres não numéricos
      final digitsOnly = keyValue.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Verifica se é um número de telefone válido (DDD + 9 dígitos)
      if (digitsOnly.length == 11) {
        return '+55$digitsOnly';
      } else if (digitsOnly.length == 13 && digitsOnly.startsWith('55')) {
        // Já está no formato internacional
        return '+$digitsOnly';
      } else {
        throw Exception('Número de telefone inválido. Use o formato (DD) 9XXXX-XXXX');
      }
    } else if (keyType == 'CPF') {
      // Remove todos os caracteres não numéricos
      return keyValue.replaceAll(RegExp(r'[^0-9]'), '');
    } else if (keyType == 'E-mail') {
      // Remove espaços em branco extras
      return keyValue.trim().toLowerCase();
    }
    
    // Para outros tipos, retorna o valor sem formatação
    return keyValue;
  }
  
  // Adiciona uma nova chave PIX
  Future<PixKey> addPixKey(String keyType, String keyValue) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }
      
      // Validação básica da chave
      if (keyValue.isEmpty) {
        throw Exception('O valor da chave não pode estar vazio');
      }
      
      // Formata o valor da chave de acordo com o tipo
      final formattedKeyValue = _formatKeyValue(keyType, keyValue);
      
      // Verifica se a chave já existe
      final existingKey = await _supabase
          .from(config.SupabaseConfig.pixKeysTable)
          .select()
          .eq('key_value', formattedKeyValue)
          .maybeSingle();
      
      if (existingKey != null) {
        throw Exception('Esta chave PIX já está em uso');
      }
      
      final newKey = {
        'user_id': userId,
        'key_type': keyType,
        'key_value': formattedKeyValue,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final response = await _supabase
          .from(config.SupabaseConfig.pixKeysTable)
          .insert(newKey)
          .select()
          .single();
      
      // Atualiza o cache
      final pixKey = PixKey.fromJson(response);
      _cachedPixKeys.insert(0, pixKey);
      _pixKeysController.add(UnmodifiableListView(_cachedPixKeys));
      
      return pixKey;
    } catch (e) {
      debugPrint('Erro ao adicionar chave PIX: $e');
      rethrow;
    }
  }
  
  // Rotaciona uma chave PIX (desativa a atual e gera uma nova aleatória)
  Future<PixKey> rotatePixKey(String currentKeyId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }
      
      // Verifica se a chave atual existe e pertence ao usuário
      final currentKeyResponse = await _supabase
          .from(config.SupabaseConfig.pixKeysTable)
          .select()
          .eq('id', currentKeyId)
          .eq('user_id', userId)
          .maybeSingle();
      
      if (currentKeyResponse == null) {
        throw Exception('Chave PIX não encontrada');
      }
      
      // Gera uma nova chave aleatória e formata corretamente
      final newKeyValue = _generateRandomKey();
      
      // Inicia uma transação para garantir a atomicidade
      await _supabase.rpc('begin');
      
      try {
        // Desativa a chave atual
        await _supabase
            .from(config.SupabaseConfig.pixKeysTable)
            .update({
              'is_active': false,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', currentKeyId);
        
        // Adiciona a nova chave
        final newKey = {
          'user_id': userId,
          'key_type': 'Chave Aleatória',
          'key_value': newKeyValue, // Já está no formato correto
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        final response = await _supabase
            .from(config.SupabaseConfig.pixKeysTable)
            .insert(newKey)
            .select()
            .single();
        
        // Confirma a transação
        await _supabase.rpc('commit');
        
        // Atualiza o cache
        await getPixKeys(forceRefresh: true);
        
        return PixKey.fromJson(response);
      } catch (e) {
        // Em caso de erro, faz rollback
        await _supabase.rpc('rollback');
        rethrow;
      }
    } catch (e) {
      debugPrint('Erro ao rotacionar chave PIX: $e');
      rethrow;
    }
  }
  
  // Formata a exibição de uma chave PIX de acordo com o tipo
  String formatKeyForDisplay(String keyType, String keyValue) {
    if (keyType == 'Telefone' && keyValue.startsWith('+55')) {
      final digits = keyValue.substring(3); // Remove o +55
      if (digits.length == 11) {
        // Formato: (XX) 9XXXX-XXXX
        return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
      }
    } else if (keyType == 'CPF' && keyValue.length == 11) {
      // Formato: XXX.XXX.XXX-XX
      return '${keyValue.substring(0, 3)}.${keyValue.substring(3, 6)}.${keyValue.substring(6, 9)}-${keyValue.substring(9)}';
    }
    
    // Para outros tipos, retorna o valor sem formatação
    return keyValue;
  }
  
  // Gera uma chave aleatória para PIX
  String _generateRandomKey() {
    const chars = '0123456789abcdefghijklmnopqrstuvwxyz';
    final random = Random();
    return List.generate(32, (index) => chars[random.nextInt(chars.length)]).join('');
  }
  
  // Configura a assinatura em tempo real do saldo
  void _setupRealtimeBalance() {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null || _isDisposed) return;
      
      // Cancela a assinatura anterior se existir
      _balanceSubscription?.cancel();
      
      // Cria uma nova assinatura para atualizações em tempo real
      _balanceSubscription = _supabase
          .from(config.SupabaseConfig.accountsTable)
          .stream(primaryKey: ['user_id'])
          .eq('user_id', userId)
          .listen(
            (data) {
              if (_isDisposed) return;
              if (data.isNotEmpty) {
                final newBalance = (data[0]['balance'] as num).toDouble();
                if (_cachedBalance != newBalance) {
                  _cachedBalance = newBalance;
                  if (!_balanceController.isClosed) {
                    _balanceController.add(newBalance);
                  }
                }
              }
            },
            onError: (error) {
              if (_isDisposed) return;
              debugPrint('Erro no stream de saldo em tempo real: $error');
              if (!_balanceController.isClosed) {
                _balanceController.addError(error);
              }
              // Tenta reconectar após um curto período
              if (!_isDisposed) {
                Future.delayed(const Duration(seconds: 2), _setupRealtimeBalance);
              }
            },
            cancelOnError: true,
          );
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('Erro ao configurar stream de saldo: $e');
      // Tenta novamente após um curto período em caso de erro
      if (!_isDisposed) {
        Future.delayed(const Duration(seconds: 2), _setupRealtimeBalance);
      }
    }
  }
  
  // Obtém o saldo da conta do usuário atual
  Future<double> getBalance({bool forceRefresh = false}) async {
    try {
      // Retorna o valor em cache se disponível e não for forçado o refresh
      if (_cachedBalance != null && !forceRefresh) {
        return _cachedBalance!;
      }
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final response = await _supabase
          .from(config.SupabaseConfig.accountsTable)
          .select('balance')
          .eq('user_id', userId)
          .single();

      final newBalance = (response['balance'] as num).toDouble();
      
      // Atualiza o cache e notifica os ouvintes
      _cachedBalance = newBalance;
      if (!_balanceController.isClosed) {
        _balanceController.add(newBalance);
      }
      
      // Configura a assinatura em tempo real
      _setupRealtimeBalance();
      
      return newBalance;
    } catch (e) {
      debugPrint('Erro ao buscar saldo: $e');
      rethrow;
    }
  }
  
  // Atualiza o saldo local após uma transação
  void _updateBalanceAfterTransaction(double amount) {
    if (_cachedBalance != null) {
      _cachedBalance = _cachedBalance! - amount;
      if (!_balanceController.isClosed) {
        _balanceController.add(_cachedBalance!);
      }
    }
  }

  /// Realiza uma transferência PIX entre contas
  Future<Map<String, dynamic>> makePixTransfer({
    required String pixKey,
    required double amount,
    String? description,
  }) async {
    try {
      debugPrint('Iniciando transferência PIX - Validações iniciais');
      
      // Validações iniciais
      if (pixKey.trim().isEmpty) {
        debugPrint('Erro: Chave PIX vazia');
        throw ArgumentError('A chave PIX não pode estar vazia');
      }
      
      if (amount <= 0) {
        debugPrint('Erro: Valor da transferência inválido: $amount');
        throw ArgumentError('O valor da transferência deve ser maior que zero');
      }
      
      if (amount > 5000) { // Exemplo de limite máximo
        debugPrint('Erro: Valor excede o limite máximo: $amount');
        throw ArgumentError('O valor máximo por transferência é de R\$ 5.000,00');
      }

      // Obtém o ID do usuário autenticado
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('Erro: Usuário não autenticado');
        throw Exception('Usuário não autenticado. Faça login novamente.');
      }

      // Verifica se o usuário tem saldo suficiente (força atualização do saldo)
      final balance = await getBalance(forceRefresh: true);
      if (balance < amount) {
        debugPrint('Erro: Saldo insuficiente. Saldo atual: $balance, Valor solicitado: $amount');
        throw Exception('Saldo insuficiente para realizar a transferência');
      }

      // Verifica se a chave PIX é válida
      if (!_isValidPixKey(pixKey)) {
        throw ArgumentError('Formato de chave PIX inválido');
      }

      // Prepara os dados da transferência
      final transferData = {
        'p_sender_id': userId,
        'p_pix_key': pixKey.trim(),
        'p_amount': amount,
        'p_description': description?.trim() ?? 'Transferência PIX',
      };

      print('Iniciando transferência PIX:');
      print('- Remetente: $userId');
      print('- Chave PIX: ${_obfuscatePixKey(pixKey)}');
      print('- Valor: R\$ ${amount.toStringAsFixed(2)}');
      print('- Descrição: ${transferData['p_description']}');

      // Chama a função RPC no Supabase com timeout
      final response;
      try {
        response = await _supabase.rpc(
          'make_pix_transfer',
          params: transferData,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException(
              'A transferência está demorando mais que o esperado. Tente novamente mais tarde.',
              timeout: const Duration(seconds: 30),
            );
          },
        );
      } on TimeoutException catch (e) {
        debugPrint('Erro de timeout ao realizar transferência PIX: $e');
        throw TimeoutException('Tempo de conexão excedido. Verifique sua internet e tente novamente.');
      } on PostgrestException catch (e) {
        debugPrint('Erro de banco de dados ao realizar transferência PIX: $e');
        throw Exception(_parseDatabaseError(e));
      } catch (e, stackTrace) {
        debugPrint('Erro inesperado ao realizar transferência PIX: $e');
        debugPrint('Stack trace: $stackTrace');
        rethrow;
      }

      // Processa a resposta
      if (response == null) {
        throw Exception('Resposta inválida do servidor');
      }

      final responseMap = Map<String, dynamic>.from(response as Map);
      
      if (responseMap['success'] == true) {
        final transactionId = responseMap['transaction_id'];
        print('✅ Transferência realizada com sucesso: $transactionId');
        
        // Atualiza o cache local
        _updateBalanceAfterTransaction(amount);
        
        // Atualiza o histórico de transações
        if (responseMap['transaction'] != null) {
          final transaction = Transaction.fromJson(responseMap['transaction']);
          _addTransactionToCache(transaction);
        }
        
        // Força atualização do cache de transações
        await refreshTransactions();
        
        return responseMap;
      } else {
        final errorMsg = responseMap['message'] ?? 'Erro desconhecido';
        print('❌ Erro na transferência: $errorMsg');
        throw Exception(errorMsg);
      }
    } on TimeoutException catch (e, stackTrace) {
      debugPrint('⏱️ Erro: Tempo excedido ao processar a transferência: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    } on PostgrestException catch (e, stackTrace) {
      debugPrint('💾 Erro no banco de dados:');
      debugPrint('- Mensagem: ${e.message}');
      debugPrint('- Detalhes: ${e.details}');
      debugPrint('- Dica: ${e.hint}');
      debugPrint('- Código: ${e.code}');
      debugPrint('Stack trace: $stackTrace');
      throw Exception(_parseDatabaseError(e));
    } on ArgumentError catch (e, stackTrace) {
      debugPrint('⚠️ Erro de validação dos dados: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    } on Exception catch (e, stackTrace) {
      debugPrint('❌ Erro inesperado ao processar transferência:');
      debugPrint('- Tipo: ${e.runtimeType}');
      debugPrint('- Mensagem: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Tenta obter mais detalhes do erro
      if (e is PostgrestException) {
        debugPrint('Detalhes do erro Postgrest:');
        debugPrint('- Mensagem: ${e.message}');
        debugPrint('- Detalhes: ${e.details}');
        debugPrint('- Dica: ${e.hint}');
        debugPrint('- Código: ${e.code}');
      }
      
      throw Exception('Ocorreu um erro inesperado ao processar a transferência. Por favor, tente novamente.');
    }
  }

  // Método para forçar a atualização do cache de transações
  Future<void> refreshTransactions() async {
    await getStatement(forceRefresh: true);
  }
  
  // Método auxiliar para filtrar transações por data
  List<Transaction> _filterTransactionsByDateRange(
    List<Transaction> transactions, 
    DateTime? startDate, 
    DateTime? endDate
  ) {
    if (startDate == null && endDate == null) {
      return transactions;
    }
    
    return transactions.where((transaction) {
      final transactionDate = transaction.createdAt;
      if (startDate != null && transactionDate.isBefore(startDate)) {
        return false;
      }
      if (endDate != null) {
        final endOfDay = endDate.add(const Duration(days: 1));
        if (transactionDate.isAfter(endOfDay)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // Obtém o extrato de transações do usuário
  Future<List<Transaction>> getStatement({
    int limit = 10,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      // Se não há filtros de data e não está forçando refresh, tenta retornar do cache
      final hasNoFilters = startDate == null && endDate == null;
      if (hasNoFilters && _cachedTransactions.isNotEmpty && !forceRefresh) {
        // Se está pedindo uma página que já está em cache, retorna do cache
        if (offset + limit <= _cachedTransactions.length) {
          return _cachedTransactions.sublist(
            offset,
            (offset + limit).clamp(0, _cachedTransactions.length),
          );
        }
      }

      // Constrói a string de filtro para o usuário (remetente OU destinatário)
      final userFilter = 'sender_id.eq.$userId,receiver_id.eq.$userId';
      
      // Constrói a string de filtro para as datas
      final dateFilters = <String>[];
      
      if (startDate != null) {
        dateFilters.add('created_at.gte.${startDate.toIso8601String()}');
      }
      
      if (endDate != null) {
        // Adiciona 1 dia para incluir o dia final
        final endOfDay = endDate.add(const Duration(days: 1)).toIso8601String();
        dateFilters.add('created_at.lt.$endOfDay');
      }
      
      // Combina todos os filtros em uma única string
      String filterString = userFilter;
      if (dateFilters.isNotEmpty) {
        filterString = 'and($userFilter,and(${dateFilters.join(',')}))';
      }
      
      // Constrói e executa a query
      final response = await _supabase
          .from(config.SupabaseConfig.transactionsTable)
          .select('*')
          .or(filterString)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      // Converte os resultados em objetos Transaction
      final transactions = (response as List)
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Atualiza o cache apenas se não houver filtros de data
      if (hasNoFilters) {
        if (offset == 0) {
          // Primeira página, substitui o cache
          _cachedTransactions = transactions;
        } else if (offset == _cachedTransactions.length) {
          // Páginas subsequentes, adiciona ao final
          _cachedTransactions.addAll(transactions);
        } else if (offset < _cachedTransactions.length) {
          // Se estiver buscando uma página no meio, substitui apenas os itens necessários
          _cachedTransactions.replaceRange(
            offset,
            (offset + transactions.length).clamp(0, _cachedTransactions.length),
            transactions,
          );
        }
        
        // Notifica os ouvintes sobre a atualização
        if (!_transactionsController.isClosed) {
          _transactionsController.add(UnmodifiableListView(_cachedTransactions));
        }
      }
      
      return transactions;
    } on TimeoutException {
      debugPrint('Timeout ao buscar extrato');
      rethrow;
    } on PostgrestException catch (e) {
      debugPrint('Erro no banco de dados: ${e.message}');
      throw Exception(_parseDatabaseError(e));
    } catch (e, stackTrace) {
      debugPrint('Erro inesperado: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  // Adiciona uma nova transação ao cache local
  void _addTransactionToCache(Transaction transaction) {
    _cachedTransactions.insert(0, transaction);
    _notifyTransactionsUpdated();
  }
  
  // Notifica os ouvintes sobre atualizações nas transações
  void _notifyTransactionsUpdated() {
    if (!_transactionsController.isClosed) {
      _transactionsController.add(UnmodifiableListView(_cachedTransactions));
    }
    
    // Atualiza o cache de saldo quando as transações mudam
    if (!_balanceController.isClosed) {
      getBalance(forceRefresh: true).catchError((error) {
        // Log do erro, mas não propaga
        debugPrint('Erro ao atualizar saldo: $error');
        return _cachedBalance ?? 0.0; // Retorna o valor em cache ou zero
      });
    }
  }

  // Desativa uma chave PIX existente
  Future<void> deactivatePixKey(String keyId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      await _supabase
          .from(config.SupabaseConfig.pixKeysTable)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', keyId)
          .eq('user_id', userId);

      // Atualiza o cache
      await getPixKeys(forceRefresh: true);
    } catch (e) {
      throw Exception('Erro ao desativar chave PIX: ${e.toString()}');
    }
  }

  // Cria uma nova chave PIX
  Future<void> createPixKey({
    required String keyType,
    required String keyValue,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      await _supabase.from(config.SupabaseConfig.pixKeysTable).upsert({
        'user_id': userId,
        'key_type': keyType,
        'key_value': keyValue,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao criar chave PIX: ${e.toString()}');
    }
  }



  // Verifica se uma chave PIX é válida
  Future<Map<String, dynamic>> validatePixKey(String pixKey) async {
    try {
      final response = await _supabase
          .from(config.SupabaseConfig.pixKeysTable)
          .select('*, user_profiles:user_id(full_name)')
          .eq('key_value', pixKey)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        throw Exception('Chave PIX não encontrada');
      }

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Erro ao validar chave PIX: ${e.toString()}');
    }
  }

  // Verifica se a chave PIX tem um formato válido
  bool _isValidPixKey(String pixKey) {
    // Remove espaços e caracteres especiais
    final cleanKey = pixKey.replaceAll(RegExp(r'[^a-zA-Z0-9@.]'), '');
    
    // Verifica se é um CPF (apenas dígitos, 11 caracteres)
    if (RegExp(r'^\d{11}$').hasMatch(cleanKey)) {
      return true;
    }
    
    // Verifica se é um email válido
    if (RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(cleanKey)) {
      return true;
    }
    
    // Verifica se é um telefone (com DDD, incluindo 9º dígito)
    if (RegExp(r'^[1-9]{2}9?[0-9]{8}$').hasMatch(cleanKey)) {
      return true;
    }
    
    // Verifica se é uma chave aleatória (UUID)
    if (RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
        .hasMatch(cleanKey)) {
      return true;
    }
    
    return false;
  }
  
  // Ofusca parte da chave PIX para exibição em logs
  String _obfuscatePixKey(String pixKey) {
    if (pixKey.length <= 8) {
      return '*' * pixKey.length;
    }
    final visibleStart = pixKey.substring(0, 4);
    final visibleEnd = pixKey.substring(pixKey.length - 4);
    return '$visibleStart***$visibleEnd';
  }
  
  
  // Traduz erros do banco de dados para mensagens amigáveis
  String _parseDatabaseError(PostgrestException e) {
    try {
      final message = e.message ?? 'Erro desconhecido';
      final details = e.details?.toString() ?? '';
      final hint = e.hint?.toString() ?? '';
      
      // Erros comuns do Supabase
      if (message.toString().contains('insufficient_funds')) {
        return 'Saldo insuficiente para realizar a transferência';
      } else if (message.toString().contains('pix_key_not_found') || 
                details.contains('destinatário não encontrado')) {
        return 'Chave PIX não encontrada';
      } else if (message.toString().contains('daily_limit_exceeded') || 
                hint.contains('exceeded daily transfer limit')) {
        return 'Limite diário de transferências excedido';
      } else if (message.toString().contains('transaction_limit_exceeded') || 
                hint.contains('exceeds maximum allowed amount')) {
        return 'Valor máximo por transferência excedido';
      } else if (message.toString().contains('duplicate key value') || 
                message.toString().contains('já existe')) {
        return 'Esta transação já foi processada anteriormente';
      } else if (details.isNotEmpty) {
        return 'Erro ao processar a transferência: $details';
      } else if (hint.isNotEmpty) {
        return 'Erro: $hint';
      }
      
      return 'Erro ao processar a transferência: $message';
    } catch (e) {
      return 'Ocorreu um erro inesperado ao processar a transferência';
    }
  }
  
  // Limpa o cache ao fazer logout
  void clearCache() {
    _cachedBalance = null;
    _cachedTransactions.clear();
  }
  
  // Atualiza o saldo de todos os usuários para R$ 1.000,00
  // ATENÇÃO: Use com cuidado em produção, pois isso afetará TODOS os usuários
  Future<void> updateAllUsersBalanceTo1000() async {
    try {
      // Atualiza todas as contas para terem saldo de R$ 1.000,00
      await _supabase
          .from(config.SupabaseConfig.accountsTable)
          .update({
            'balance': 1000.0,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
      
      // Limpa o cache local para forçar atualização
      _cachedBalance = 1000.0;
      if (!_balanceController.isClosed) {
        _balanceController.add(1000.0);
      }
      
      debugPrint('Saldo de todos os usuários atualizado para R\$ 1.000,00');
    } catch (e) {
      debugPrint('Erro ao atualizar saldos: $e');
      rethrow;
    }
  }
  
  // Fecha os controladores de stream
  @override
  void dispose() {
    if (_isDisposed) return;
    
    _isDisposed = true;
    
    // Cancela a assinatura do saldo
    _balanceSubscription?.cancel();
    _balanceSubscription = null;
    
    // Fecha todos os controladores de stream
    if (!_balanceController.isClosed) _balanceController.close();
    if (!_transactionsController.isClosed) _transactionsController.close();
    if (!_pixKeysController.isClosed) _pixKeysController.close();
    
    super.dispose();
  }
}
