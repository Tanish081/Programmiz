abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OfflineException extends AppException {
  const OfflineException([
    super.message = 'No internet connection. Please try again when online.',
  ]);
}

class RateLimitException extends AppException {
  const RateLimitException({
    this.retryAfter = const Duration(seconds: 5),
    String message = 'Too many requests. Please wait a few seconds and try again.',
  }) : super(message);

  final Duration retryAfter;
}

class AuthException extends AppException {
  const AuthException([
    super.message = 'Invalid API key. Please update your Groq API key.',
  ]);
}

class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'The request timed out. Please try again.',
  ]);
}

class ApiException extends AppException {
  const ApiException([
    super.message = 'Something went wrong while contacting the AI service.',
  ]);
}
