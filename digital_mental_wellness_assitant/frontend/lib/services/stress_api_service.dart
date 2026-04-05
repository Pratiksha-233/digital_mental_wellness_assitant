

library;

import '../models/stress_model.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StressApiService {





  String get _baseUrl => apiBaseUrl;


  Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {

      return null;
    }
  }


  Future<StressData> getStressLevel({required int userId}) async {
    try {
      final response = await get('/stress/calculate?user_id=$userId');
      if (response == null) throw Exception('No response from server');
      return StressData.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to fetch stress level: $e');
    }
  }


  Future<List<StressHistoryRecord>> getStressHistory({
    required int userId,
    int days = 30,
    int limit = 100,
  }) async {
    try {
      final response = await get(
        '/stress/history?user_id=$userId&days=$days&limit=$limit',
      );
      if (response == null) return [];
      final data = response['data'] as List;
      return data.map((h) => StressHistoryRecord.fromJson(h)).toList();
    } catch (e) {
      throw Exception('Failed to fetch stress history: $e');
    }
  }


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


  Future<StressData> getStressRecommendations({required int userId}) async {
    try {
      final response = await get('/stress/recommendation?user_id=$userId');
      if (response == null) throw Exception('No response from server');
      return StressData.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch recommendations: $e');
    }
  }



}




























