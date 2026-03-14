import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class ApiService {
  /// Predict the emotion of user's journal or chat input
  Future<Map<String, dynamic>> predictEmotion(String text, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/mood/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text, 'user_id': userId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Send a chat message to the backend NLP chatbot.
  /// Returns a map including:
  ///   - response: bot reply text
  ///   - emotion: detected fine-grained emotion
  ///   - sentiment: 'positive' | 'negative' | 'neutral'
  ///   - is_crisis: bool flag if crisis keywords were detected
  ///   - detected_crisis_keywords: list of matched phrases (if any)
  ///   - intent: simple intent classification label
  Future<Map<String, dynamic>?> sendChatMessage({
    required String message,
    int? userId,
  }) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/chat/message');
      final body = <String, dynamic>{'message': message};
      if (userId != null) {
        body['user_id'] = userId;
      }
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
      debugPrint('sendChatMessage error: statusCode=${resp.statusCode}');
      return null;
    } catch (e) {
      debugPrint('sendChatMessage exception: $e');
      return null;
    }
  }

  /// Get recommendations based on detected emotion
  Future<List<dynamic>> getRecommendations(String emotion) async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/recommend/$emotion'),
    );

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
        uri = Uri.parse('$apiBaseUrl/mood/logs?firebase_uid=$firebaseUid');
      } else if (userId != null) {
        uri = Uri.parse('$apiBaseUrl/mood/logs?user_id=$userId');
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
  Future<int?> lookupOrCreateUserByEmail({
    required String email,
    String? name,
  }) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/auth/user/lookup_or_create');
      final body = jsonEncode({'email': email, if (name != null) 'name': name});
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        if (data.containsKey('user_id')) {
          return int.tryParse(data['user_id'].toString()) ??
              (data['user_id'] is int ? data['user_id'] as int : null);
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

  /// Fetch progress counts for a user (mood_checkins, journal_entries, days_active)
  Future<Map<String, dynamic>> getProgress({required int userId}) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/recommend/progress?user_id=$userId');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return data['progress'] as Map<String, dynamic>;
      }
      return {'mood_checkins': 0, 'journal_entries': 0, 'days_active': 0};
    } catch (e) {
      debugPrint('getProgress error: $e');
      return {'mood_checkins': 0, 'journal_entries': 0, 'days_active': 0};
    }
  }

  /// Generic GET request method for any endpoint
  Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      // use the globally defined apiBaseUrl constant
      final url = Uri.parse('$apiBaseUrl$endpoint');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      debugPrint('API Error: statusCode ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('API Error: $e');
      return null;
    }
  }

  /// --- Analytics helpers ---

  Future<List<dynamic>> getMoodAnalytics(int userId) async {
    final res = await http.get(
      Uri.parse('$apiBaseUrl/analytics/mood?user_id=$userId'),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getStressAnalytics(int userId) async {
    final res = await http.get(
      Uri.parse('$apiBaseUrl/analytics/stress?user_id=$userId'),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> getChatSentiment(int userId) async {
    final res = await http.get(
      Uri.parse('$apiBaseUrl/analytics/chat-sentiment?user_id=$userId'),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {'positive': 0.0, 'neutral': 0.0, 'negative': 0.0};
  }

  Future<List<dynamic>> getActivityAnalytics(int userId) async {
    final res = await http.get(
      Uri.parse('$apiBaseUrl/analytics/activity?user_id=$userId'),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }
}
