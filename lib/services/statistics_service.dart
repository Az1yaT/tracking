import 'dart:convert';
import 'package:http/http.dart' as http;

class StatisticsService {
  final String baseUrl;

  StatisticsService(this.baseUrl);

  final List<Map<String, dynamic>> mockStatistics = [
    {'day': 'Пн', 'count': 10},
    {'day': 'Вт', 'count': 15},
    {'day': 'Ср', 'count': 8},
  ];

  Future<List<Map<String, dynamic>>> fetchStatistics() async {
    final response = await http.get(Uri.parse('$baseUrl/statistics'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load statistics');
    }
  }
}