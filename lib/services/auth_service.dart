import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';
  
  // Verifica se o usuário está logado
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
  
  // Faz login do usuário
  Future<bool> login(String email, String password) async {
    // Simula uma chamada de API
    await Future.delayed(const Duration(seconds: 1));
    
    // Em um aplicativo real, isso seria uma chamada para sua API de autenticação
    if (email == 'user@example.com' && password == 'password') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, 'dummy_token_12345');
      await prefs.setBool(_isLoggedInKey, true);
      return true;
    }
    return false;
  }
  
  // Faz logout do usuário
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
  
  // Obtém o token de autenticação
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Verifica se o usuário está autenticado (com token válido)
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
