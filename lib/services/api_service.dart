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

  /// Fetch all mood logs of a user by firebase UID or local user id
  Future<List<dynamic>> getMoodLogs({String? firebaseUid, int? userId}) async {
    try {
      Uri uri;
      if (firebaseUid != null) {
        uri = Uri.parse('$baseUrl/mood/logs?firebase_uid=$firebaseUid');
      } else if (userId != null) {
        uri = Uri.parse('$baseUrl/mood/logs?user_id=$userId');
      } else {
        throw Exception('firebaseUid or userId required');
      }

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to fetch mood logs: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching mood logs: $e');
      return [];
    }
  }

  /// Lookup (or create) a local numeric `user_id` by providing an email and optional name.
  /// Returns the numeric user_id on success, or null on failure.
  Future<int?> lookupOrCreateUserByEmail({required String email, String? name}) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/user/lookup_or_create');
      final body = jsonEncode({'email': email, if (name != null) 'name': name});
      final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        if (data.containsKey('user_id')) {
          return int.tryParse(data['user_id'].toString()) ?? (data['user_id'] is int ? data['user_id'] as int : null);
        }
      }
      return null;
    } catch (e) {
      debugPrint('lookupOrCreateUserByEmail error: $e');
      return null;
    }
  }

  /// Log out endpoint (optional placeholder)
  Future<bool> logout() async {
    // If you’re using token-based auth, clear token locally here
    return true;
  }
}
