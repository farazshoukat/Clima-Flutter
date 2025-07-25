import 'package:clima/services/networking.dart';
import 'package:clima/services/location.dart';
import 'package:flutter/material.dart';

const apiKey = '1707ffd3221c68ec5d60543658c886a6';
const OpenWeatherMapURL = 'https://api.openweathermap.org/data/2.5/weather';

class WeatherModel {
  Future<dynamic> getCityWeather(String cityName) async {
    var url = '$OpenWeatherMapURL?q=$cityName&appid=$apiKey&units=metric';
    NetworkHelper networkHelper = NetworkHelper(url);
    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  Future<dynamic> getLocationWeather() async {
    Location local = Location();
    await local.getCurrentLocation();

    NetworkHelper networkHelper = NetworkHelper(
      '$OpenWeatherMapURL?lat=${local.latitude}&lon=${local.longitude}&appid=$apiKey&units=metric',
    );
    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  // Replaces emojis with Flutter IconData
  IconData getWeatherIconAsIconData(int condition) {
    if (condition < 300) {
      return Icons.thunderstorm;
    } else if (condition < 400) {
      return Icons.grain; // drizzle
    } else if (condition < 600) {
      return Icons.beach_access; // rain
    } else if (condition < 700) {
      return Icons.ac_unit; // snow
    } else if (condition < 800) {
      return Icons.foggy; // mist/haze
    } else if (condition == 800) {
      return Icons.wb_sunny;
    } else if (condition <= 804) {
      return Icons.cloud;
    } else {
      return Icons.help_outline;
    }
  }

  String getMessage(int temp) {
    if (temp > 25) {
      return 'It\'s 🍦 time';
    } else if (temp > 20) {
      return 'Time for shorts and 👕';
    } else if (temp < 10) {
      return 'You\'ll need 🧣 and 🧤';
    } else {
      return 'Bring a 🧥 just in case';
    }
  }
}
