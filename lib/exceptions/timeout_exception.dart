/// Exceção lançada quando uma operação excede o tempo limite
class TimeoutException implements Exception {
  final String message;
  final Duration? timeout;

  TimeoutException(this.message, {this.timeout});

  @override
  String toString() => 'TimeoutException: $message (timeout: $timeout)';
}
