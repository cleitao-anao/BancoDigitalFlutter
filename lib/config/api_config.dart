class ApiConfig {
  // HG Brasil API (https://hgbrasil.com/)
  static const String hgBrasilApiKey = '1f7e553a';
  static const String hgBrasilBaseUrl = 'https://api.hgbrasil.com/finance';
  
  // Moedas suportadas
  static const Map<String, String> supportedCurrencies = {
    'USD': 'Dólar Americano',
    'EUR': 'Euro',
    'GBP': 'Libra Esterlina',
    'JPY': 'Iene Japonês',
    'ARS': 'Peso Argentino',
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'CAD': 'Dólar Canadense',
    'AUD': 'Dólar Australiano',
    'CNY': 'Yuan Chinês',
  };
  
  // Obter URL da API de cotações
  static String getQuotationUrl() {
    return '$hgBrasilBaseUrl?key=$hgBrasilApiKey';
  }
  
  // Tempo de cache em segundos (5 minutos)
  static const int cacheDuration = 300;
}