import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thin client for the users database endpoints.
class UsersDbClient {
  /// Base URL of the backend server, e.g. http://localhost:3000/api/user
  final String baseUrl;

  /// HTTP client used for requests. Can be overridden for testing.
  final http.Client httpClient;

  UsersDbClient({
    String? baseUrl,
    http.Client? httpClient,
  })  : baseUrl = baseUrl ?? _defaultBaseUrl(),
        httpClient = httpClient ?? http.Client();

  /// Registers a user by email and password.
  ///
  /// Mirrors backend/db/usersdb.js POST /register.
  Future<RegisterResponse> registerUser({
    required String email,
    required String password,
  }) async {
    final Uri uri = Uri.parse('$baseUrl/signup');
    http.Response response;
    try {
      response = await httpClient
          .post(
            uri,
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(<String, String>{
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } on Object {
      throw UsersDbException(message: 'Network error. Please try again.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = _decodeJson(response.body);
      return RegisterResponse(
        message: (data['message'] as String?) ?? 'OK',
      );
    }

    // Attempt to parse error message from backend
    String message = 'Registration failed';
    try {
      final Map<String, dynamic> data = _decodeJson(response.body);
      final String? backendError = (data['error'] as String?);
      if (backendError != null && backendError.isNotEmpty) {
        message = backendError;
      }
    } catch (_) {
      // ignore parse errors and fall back to default message
    }

    throw UsersDbException(message: message, statusCode: response.statusCode);
  }

  Map<String, dynamic> _decodeJson(String source) {
    final dynamic decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const FormatException('Unexpected response format');
  }
}

String _defaultBaseUrl() {
  // For web builds we can use relative path, for mobile/desktop use localhost by default
  // Update to point to the Admin Frontend deployment usually on port 3000 or the hosted URL
  return 'http://localhost:3000/api/user';
}

class RegisterResponse {
  final String message;

  RegisterResponse({required this.message});
}

class UsersDbException implements Exception {
  final String message;
  final int? statusCode;

  UsersDbException({required this.message, this.statusCode});

  @override
  String toString() =>
      'UsersDbException(statusCode: ${statusCode?.toString() ?? 'n/a'}, message: $message)';
}


