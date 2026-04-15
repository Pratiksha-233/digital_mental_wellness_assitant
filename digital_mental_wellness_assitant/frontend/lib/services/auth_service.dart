import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AuthService {
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return {
            ...data,
            if (!data.containsKey('status')) 'status': 'success',
          };
        }
        return {'status': 'success'};
      } else {
        String? message;
        try {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            final m = data['message'];
            if (m != null) message = m.toString();
          }
        } catch (_) {
          // Ignore non-JSON bodies.
        }

        message ??= 'Server error: ${response.statusCode}';
        return {
          'status': 'error',
          'message': message,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) return data;
        return {'status': 'success'};
      } else {
        try {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            return {
              'status': data['status'] ?? 'error',
              'message': data['message'] ?? 'Login failed',
            };
          }
        } catch (_) {}

        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }
}
