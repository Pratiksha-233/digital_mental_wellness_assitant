/// API Service methods for stress endpoints
/// Add these methods to your existing ApiService class in lib/services/api_service.dart

import '../models/stress_model.dart';

class StressApiService {
  final String baseUrl = 'http://localhost:5000'; // Update with your backend URL

  /// Calculate current stress level
  Future<StressData> getStressLevel({required int userId}) async {
    try {
      final response = await get('/stress/calculate?user_id=$userId');
      if (response == null) throw Exception('No response from server');
      return StressData.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to fetch stress level: $e');
    }
  }

  /// Get stress history
  Future<List<StressHistoryRecord>> getStressHistory({
    required int userId,
    int days = 30,
    int limit = 100,
  }) async {
    try {
      final response = await get('/stress/history?user_id=$userId&days=$days&limit=$limit');
      if (response == null) return [];
      final data = response['data'] as List;
      return data.map((h) => StressHistoryRecord.fromJson(h)).toList();
    } catch (e) {
      throw Exception('Failed to fetch stress history: $e');
    }
  }

  /// Get stress statistics
  Future<StressStats> getStressStats({
    required int userId,
    int days = 30,
  }) async {
    try {
      final response = await get('/stress/stats?user_id=$userId&days=$days');
      if (response == null) throw Exception('No response from server');
      return StressStats.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch stress stats: $e');
    }
  }

  /// Get stress recommendations
  Future<StressData> getStressRecommendations({required int userId}) async {
    try {
      final response = await get('/stress/recommendation?user_id=$userId');
      if (response == null) throw Exception('No response from server');
      return StressData.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch recommendations: $e');
    }
  }

  // Add this method to your ApiService if it doesn't exist
  // Use ApiService.get from lib/services/api_service.dart instead of duplicating it here.
}

// Usage example in your existing ApiService:
//
// class ApiService {
//   static const String baseUrl = 'http://localhost:5000';
//
//   Future<Map<String, dynamic>?> get(String endpoint) async {
//     try {
//       final url = Uri.parse('$baseUrl$endpoint');
//       final response = await http.get(url).timeout(const Duration(seconds: 10));
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       }
//       return null;
//     } catch (e) {
//       print('API Error: $e');
//       return null;
//     }
//   }
//
//   Future<StressData> getStressLevel({required int userId}) async {
//     final response = await get('/api/stress/calculate?user_id=$userId');
//     if (response == null) throw Exception('Failed to fetch stress');
//     return StressData.fromJson(response['data']);
//   }
//
//   // ... other stress methods
// }
