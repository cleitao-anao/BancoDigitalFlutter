class ApiConfig {
  // ExchangeRate-API (https://www.exchangerate-api.com/)
  static const String exchangeRateApiKey = '5c8bbed2498b541f8975075f';
  
  // API base URLs
  static const String exchangeRateBaseUrl = 'https://v6.exchangerate-api.com/v6';
  
  // Moedas suportadas
  static const List<String> supportedCurrencies = [
    'USD', // Dólar Americano
    'EUR', // Euro
    'GBP', // Libra Esterlina
    'JPY', // Iene Japonês
    'ARS', // Peso Argentino
    'BTC', // Bitcoin
    'ETH', // Ethereum
    'CAD', // Dólar Canadense
    'AUD', // Dólar Australiano
    'CNY', // Yuan Chinês
  ];
  
  // Tempo de cache em segundos (5 minutos)
  static const int cacheDuration = 300;
}