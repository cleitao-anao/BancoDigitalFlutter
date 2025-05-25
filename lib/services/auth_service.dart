import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/models/user_profile.dart';

class AuthService {
  final _supabase = Supabase.instance.client;
  
  // Obtém o usuário atual
  User? get currentUser => _supabase.auth.currentUser;
  
  // Stream de autenticação
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;
  
  // Verifica se o usuário está logado
  bool get isLoggedIn => currentUser != null;
  
  // Faz login do usuário com email e senha
  Future<void> login(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  // Registra um novo usuário
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
        },
      );
      
      if (response.user != null) {
        // Cria o perfil do usuário na tabela user_profiles
        await _supabase.from('user_profiles').upsert({
          'id': response.user!.id,
          'email': email.trim(),
          'full_name': fullName,
          'phone': phone,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception(e.toString());
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
  
  // Obtém o perfil do usuário atual
  Future<UserProfile?> getUserProfile() async {
    if (currentUser == null) return null;
    
    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', currentUser!.id)
        .single();
    
    return UserProfile.fromJson(response);
  }
}
