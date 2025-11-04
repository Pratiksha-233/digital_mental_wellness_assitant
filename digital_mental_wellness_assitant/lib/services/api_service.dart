import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  /// Predict the emotion of user's journal or chat input
  Future<Map<String, dynamic>> predictEmotion(String text, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text, 'user_id': userId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Get recommendations based on detected emotion
  Future<List<dynamic>> getRecommendations(String emotion) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/recommendations/$emotion'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load recommendations');
      }
    } catch (e) {
      print('Error fetching recommendations: $e');
      return [];
    }
  }

  /// Fetch all mood logs of a user (optional)
  Future<List<dynamic>> getMoodLogs(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/mood_logs/$userId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch mood logs');
      }
    } catch (e) {
      print('Error fetching mood logs: $e');
      return [];
    }
  }

  /// Log out endpoint (optional placeholder)
  Future<bool> logout() async {
    // If you’re using token-based auth, clear token locally here
    return true;
  }
}
