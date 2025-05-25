import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  
  // Construtor factory para retornar a mesma instância
  factory SupabaseService() {
    return _instance;
  }
  
  // Construtor privado
  SupabaseService._internal();
  
  // Getter para acessar o cliente do Supabase
  SupabaseClient get client => Supabase.instance.client;
  
  // Inicializa o Supabase
  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }
  
  // Verifica se o usuário está autenticado
  bool get isAuthenticated => client.auth.currentUser != null;
  
  // Retorna o ID do usuário atual
  String? get currentUserId => client.auth.currentUser?.id;
  
  // Retorna o e-mail do usuário atual
  String? get currentUserEmail => client.auth.currentUser?.email;
  
  // Faz logout do usuário
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
