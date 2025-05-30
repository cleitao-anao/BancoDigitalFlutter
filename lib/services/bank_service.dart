import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/config/supabase_config.dart' as config;
import 'package:flutter_application_1/models/transaction.dart';
import 'package:flutter_application_1/exceptions/timeout_exception.dart';

class BankService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtém o saldo da conta do usuário atual
  Future<double> getBalance() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final response = await _supabase
          .from(config.SupabaseConfig.accountsTable)
          .select('balance')
          .eq('user_id', userId)
          .single();

      return (response['balance'] as num).toDouble();
    } catch (e) {
      throw Exception('Erro ao buscar saldo: ${e.toString()}');
    }
  }

  // Realiza uma transferência PIX
  Future<Map<String, dynamic>> makePixTransfer({
    required String pixKey,
    required double amount,
    String? description,
  }) async {
    try {
      // Validações iniciais
      if (pixKey.isEmpty) {
        throw ArgumentError('A chave PIX não pode estar vazia');
      }
      
      if (amount <= 0) {
        throw ArgumentError('O valor da transferência deve ser maior que zero');
      }

      // Obtém o ID do usuário autenticado
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado. Faça login novamente.');
      }

      print('Iniciando transferência PIX:');
      print('- Remetente: $userId');
      print('- Chave PIX: $pixKey');
      print('- Valor: $amount');
      print('- Descrição: ${description ?? 'Transferência PIX'}');

      // Chama a função RPC no Supabase
      final response = await _supabase.rpc('make_pix_transfer', params: {
        'p_sender_id': userId,
        'p_pix_key': pixKey.trim(),
        'p_amount': amount,
        'p_description': description?.trim() ?? 'Transferência PIX',
      });

      // Adiciona um timeout manual
      final responseWithTimeout = await response.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
            'A transferência está demorando mais que o esperado. Tente novamente mais tarde.',
            timeout: const Duration(seconds: 30),
          );
        },
      );

      // Verifica a resposta
      if (responseWithTimeout == null) {
        throw Exception('Resposta inválida do servidor');
      }

      final responseMap = Map<String, dynamic>.from(responseWithTimeout as Map);
      
      if (responseMap['success'] == true) {
        print('Transferência realizada com sucesso: ${responseMap['transaction_id']}');
      } else {
        print('Erro na transferência: ${responseMap['message']}');
      }

      return responseMap;
    } on TimeoutException catch (e) {
      print('Erro de timeout na transferência: $e');
      rethrow;
    } on PostgrestException catch (e) {
      print('Erro no banco de dados: ${e.message}');
      throw Exception('Erro ao processar a transferência: ${e.details ?? e.message}');
    } on ArgumentError catch (e) {
      print('Erro de validação: $e');
      rethrow;
    } on Exception catch (e) {
      print('Erro inesperado: $e');
      throw Exception('Ocorreu um erro inesperado ao processar a transferência');
    }
  }

  // Obtém o extrato de transações do usuário
  Future<List<Transaction>> getStatement({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      var query = _supabase
          .from(config.SupabaseConfig.transactionsTable)
          .select('*')
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      
      return (response as List)
          .map((json) => Transaction.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar extrato: ${e.toString()}');
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

  // Obtém as chaves PIX do usuário
  Future<List<Map<String, dynamic>>> getPixKeys() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final response = await _supabase
          .from(config.SupabaseConfig.pixKeysTable)
          .select('*')
          .eq('user_id', userId)
          .eq('is_active', true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Erro ao buscar chaves PIX: ${e.toString()}');
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
}
