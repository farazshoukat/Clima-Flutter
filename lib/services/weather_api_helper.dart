// lib/services/weather_api_helper.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherAPIHelper {
  final String apiKey = '9f1d44c5e0114efc96d105155241506'; // WeatherMateo

  Future<double?> getCityTemperature(String cityName) async {
    final url =
        'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=${Uri.encodeComponent(cityName)}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ WeatherAPI: ${data['current']['temp_c']}°C'); // confirm
        return data['current']['temp_c']?.toDouble();
      } else {
        print('❌ WeatherAPI error: ${response.statusCode}');
      }
    } catch (e) {
      print('❗ WeatherAPI exception: $e');
    }

    return null;
  }
}
