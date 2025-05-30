import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/models/bank_account.dart';
import 'package:flutter_application_1/config/supabase_config.dart' as config;

class AuthService {
  final _supabase = Supabase.instance.client;
  
  // Obtém o usuário atual
  User? get currentUser => _supabase.auth.currentUser;
  
  // Stream de autenticação
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;
  
  // Verifica se o usuário está logado
  bool get isLoggedIn => currentUser != null;
  
  // Faz login do usuário com email e senha
  Future<UserProfile> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Falha no login: usuário não encontrado');
      }
      
      // Busca o perfil do usuário
      return await _getUserProfile(response.user!.id);
      
    } catch (e) {
      throw Exception('Erro ao fazer login: ${e.toString()}');
    }
  }
  
  // Gera um número de conta aleatório
  String _generateAccountNumber() {
    final random = Random();
    final accountNumber = StringBuffer();
    
    // Gera um número de 8 dígitos
    for (var i = 0; i < 8; i++) {
      accountNumber.write(random.nextInt(10));
    }
    
    return accountNumber.toString();
  }
  
  // Registra um novo usuário
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String fullName,
    required DateTime birthDate,
    String? phone,
  }) async {
    try {
      // 1. Cria o usuário no Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
        },
      );
      
      if (authResponse.user == null) {
        throw Exception('Falha ao criar usuário: resposta de autenticação inválida');
      }
      
      final userId = authResponse.user!.id;
      final now = DateTime.now().toUtc();
      
      // 2. Cria o perfil do usuário
      await _supabase.from(config.SupabaseConfig.userProfilesTable).upsert({
        'id': userId,
        'email': email.trim(),
        'full_name': fullName,
        'phone': phone,
        'birth_date': birthDate.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
      
      // 3. Cria a conta corrente do usuário
      final accountNumber = _generateAccountNumber();
      await _supabase.from(config.SupabaseConfig.accountsTable).insert({
        'user_id': userId,
        'account_number': accountNumber,
        'branch': '0001',
        'account_type': 'CHECKING',
        'balance': 0.0,
        'status': 'ACTIVE',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
      
      // 4. Cria uma chave PIX usando o email
      await _supabase.from(config.SupabaseConfig.pixKeysTable).insert({
        'user_id': userId,
        'key_type': 'EMAIL',
        'key_value': email.trim(),
        'is_active': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
      
      // 5. Retorna o perfil do usuário criado
      return await _getUserProfile(userId);
      
    } catch (e) {
      // Em caso de erro, tenta remover o usuário criado
      if (e.toString().contains('already registered')) {
        await _supabase.auth.signOut();
        await _supabase.auth.admin.deleteUser(_supabase.auth.currentUser?.id ?? '');
      }
      throw Exception('Erro ao cadastrar usuário: ${e.toString()}');
    }
  }
  
  // Faz logout do usuário
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
  
  // Envia email de redefinição de senha
  Future<dynamic> resetPassword(String email) async {
    return await _supabase.auth.resetPasswordForEmail(email);
  }
  
  // Atualiza o perfil do usuário
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    
    await _supabase
        .from('user_profiles')
        .update(updates)
        .eq('id', userId);
  }
  
  // Obtém o perfil do usuário por ID
  Future<UserProfile> _getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from(config.SupabaseConfig.userProfilesTable)
          .select()
          .eq('id', userId)
          .single();
      
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar perfil do usuário: ${e.toString()}');
    }
  }
  
  // Obtém o perfil do usuário atual
  Future<UserProfile> getUserProfile() async {
    if (currentUser == null) {
      throw Exception('Nenhum usuário autenticado');
    }
    return await _getUserProfile(currentUser!.id);
  }
  
  // Obtém a conta bancária principal do usuário
  Future<BankAccount> getUserBankAccount() async {
    if (currentUser == null) {
      throw Exception('Nenhum usuário autenticado');
    }
    
    try {
      final response = await _supabase
          .from(config.SupabaseConfig.accountsTable)
          .select()
          .eq('user_id', currentUser!.id)
          .eq('account_type', 'CHECKING')
          .single();
      
      return BankAccount.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar conta bancária: ${e.toString()}');
    }
  }
}
