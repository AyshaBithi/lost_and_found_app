import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String _apiKey = ''; // API KEY

  // Get weather data for a location
  // Demonstration of API integration
  Future<Map<String, dynamic>> getWeatherForLocation(String location) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?q=$location&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      // For demo purposes, return mock data if API call fails
      return {
        'name': location,
        'main': {'temp': 20.0},
        'weather': [
          {'description': 'clear sky', 'icon': '01d'}
        ],
      };
    }
  }

}
