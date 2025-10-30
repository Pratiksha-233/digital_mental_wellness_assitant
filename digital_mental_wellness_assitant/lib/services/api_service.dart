import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Default base URL for local backend. Update when deploying.
  // Note: backend context-path is /api (configured in application.properties)
  static String baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080/api');

  /// Fetch wellness tips from backend
  /// Returns the parsed JSON list on success or throws an exception.
  static Future<List<dynamic>> fetchWellnessTips() async {
    final uri = Uri.parse('\$baseUrl/wellness-tips');
    final resp = await http.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data is List) return data;
      // If backend wraps the list in an object, try to extract
      if (data is Map && data['data'] is List) return data['data'];
      return [data];
    }

    throw Exception('Failed to fetch wellness tips: \\${resp.statusCode}');
  }
}
