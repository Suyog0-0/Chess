// Add this new file: chess_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChessApiService {
  static const String baseUrl = 'https://chess-api.com/v1';

  static Future<Map<String, dynamic>> getBestMove(
      String fen, int skillLevel) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/move?fen=$fen&skill=$skillLevel'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get move from API');
      }
    } catch (e) {
      throw Exception('API error: $e');
    }
  }

  static Future<Map<String, dynamic>> getAnalysis(String fen) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analyze?fen=$fen'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get analysis from API');
      }
    } catch (e) {
      throw Exception('API error: $e');
    }
  }
}
