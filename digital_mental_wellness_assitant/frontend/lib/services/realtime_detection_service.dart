import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class RealtimeDetectionService {
  static String get _baseUrl => detectionBaseUrl;

  /// Predict emotion from text
  static Future<Map<String, dynamic>> predictEmotion(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict-emotion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to predict emotion');
      }
    } catch (e) {
      throw Exception('Error predicting emotion: $e');
    }
  }

  /// Predict emotion from base64 image
  static Future<Map<String, dynamic>> predictImageEmotion(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict-image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to predict emotion from image');
      }
    } catch (e) {
      throw Exception('Error predicting emotion from image: $e');
    }
  }
}
