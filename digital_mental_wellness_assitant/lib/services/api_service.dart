import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class ApiService {
  /// Predict the emotion of user's journal or chat input
  Future<Map<String, dynamic>> predictEmotion(String text, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mood/predict'),
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
    final response = await http.get(Uri.parse('$baseUrl/recommend/$emotion'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['recommendations']; // ✅ Extract the list only
    } else {
      throw Exception('Failed to load recommendations');
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
      // Use debugPrint instead of print for production-friendly logging
      debugPrint('Error fetching mood logs: $e');
      return [];
    }
  }

  /// Log out endpoint (optional placeholder)
  Future<bool> logout() async {
    // If you’re using token-based auth, clear token locally here
    return true;
  }
}
