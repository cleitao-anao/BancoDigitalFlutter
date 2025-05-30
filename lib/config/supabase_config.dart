class SupabaseConfig {
  // Credenciais do projeto banciDigital no Supabase
  static const String supabaseUrl = 'https://dtdtlpxwbtdlqjsaznaa.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR0ZHRscHh3YnRkbHFqc2F6bmFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg1NjI1ODIsImV4cCI6MjA2NDEzODU4Mn0.Tz9BEfuNJJs9IhLwwtC1JYEQQDp4yx-b2dw_i0j3vU4';
  
  // Nome do bucket para armazenamento de imagens (opcional)
  static const String storageBucket = 'banci-digital-assets';
  
  // Nome da tabela de perfis de usuário
  static const String userProfilesTable = 'user_profiles';
  
  // Nome da tabela de contas bancárias
  static const String accountsTable = 'accounts';
  
  // Nome da tabela de chaves PIX
  static const String pixKeysTable = 'pix_keys';
  
  // Nome da tabela de transações
  static const String transactionsTable = 'transactions';
  
  // Nome da tabela de contatos
  static const String contactsTable = 'contacts';
}
