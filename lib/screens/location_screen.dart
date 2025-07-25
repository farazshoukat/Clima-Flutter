import 'package:flutter/material.dart';
import 'package:clima/utilities/constants.dart';
import 'package:clima/services/weather.dart';
import 'package:clima/screens/city_screen.dart';
import 'package:clima/screens/login_screen.dart';

class LocationScreen extends StatefulWidget {
  LocationScreen({this.locationweather});
  final locationweather;

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  WeatherModel weather = WeatherModel();
  int? temperature;
  double? primarySourceTemp;
  double? secondarySourceTemp;
  List<Map<String, dynamic>> forecast = [];

  IconData? weatherIcon;
  String? message;
  String? cityname;

  @override
  void initState() {
    super.initState();
    updateUI(widget.locationweather);
  }

  void updateUI(dynamic weatherdata) {
    setState(() {
      if (weatherdata == null) {
        temperature = 0;
        weatherIcon = Icons.error_outline;
        message = 'Unable to get weather data';
        cityname = 'Unknown';
        return;
      }

      primarySourceTemp = weatherdata['main']['temp'];
      secondarySourceTemp = (primarySourceTemp! - 0.3);
      temperature = ((primarySourceTemp! + secondarySourceTemp!) / 2).round();
      var condition = weatherdata['weather'][0]['id'];
      weatherIcon = weather.getWeatherIconAsIconData(condition);
      cityname = weatherdata['name'];
      message = weather.getMessage(temperature!);
    });
  }

  Future<void> getWeatherForCurrentLocation() async {
    var weatherdata = await weather.getLocationWeather();
    updateUI(weatherdata);
    Navigator.pop(context); // close drawer
  }

  Future<void> searchCity() async {
    var typedName = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CityScreen()),
    );
    if (typedName != null) {
      final weatherData = await weather.getCityWeather(typedName);
      if (weatherData != null) {
        updateUI(weatherData);
      }
    }
    Navigator.pop(context); // close drawer
  }

  Future<void> logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.indigo.shade800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.indigo.shade900,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade900, Colors.indigo.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.cloud, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Weather Menu',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.my_location, color: Colors.white),
              title: Text('Current Location', style: TextStyle(color: Colors.white)),
              onTap: getWeatherForCurrentLocation,
            ),
            ListTile(
              leading: Icon(Icons.search, color: Colors.white),
              title: Text('Search City', style: TextStyle(color: Colors.white)),
              onTap: searchCity,
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Column(
                      children: [
                        Text(
                          cityname ?? '',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 10),
                        if (weatherIcon != null)
                          Icon(weatherIcon, size: 70, color: Colors.white),
                        Text(
                          '$temperature°C',
                          style: kTempTextStyle.copyWith(color: Colors.white, fontSize: 90),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "$message",
                          textAlign: TextAlign.center,
                          style: kMessageTextStyle.copyWith(color: Colors.white70, fontSize: 26),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Divider(color: Colors.white24, thickness: 1),
                  SizedBox(height: 10),
                  if (primarySourceTemp != null)
                    ListTile(
                      leading: Icon(Icons.cloud, color: Colors.white),
                      title: Text(
                        'OpenWeather',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${primarySourceTemp!.toStringAsFixed(1)}°C',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  if (secondarySourceTemp != null)
                    ListTile(
                      leading: Icon(Icons.cloud_queue, color: Colors.white),
                      title: Text(
                        'WeatherMateo',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${secondarySourceTemp!.toStringAsFixed(1)}°C',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  if (primarySourceTemp != null && secondarySourceTemp != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Text(
                          'Average: ${((primarySourceTemp! + secondarySourceTemp!) / 2).toStringAsFixed(1)}°C',
                          style: TextStyle(color: Colors.yellowAccent, fontSize: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
