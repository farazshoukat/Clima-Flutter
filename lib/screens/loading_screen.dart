import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:clima/services/weather.dart';
import 'location_screen.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
    getLocationData();
  }

  void getLocationData() async {
    try {
      var weatherData = await WeatherModel().getLocationWeather();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LocationScreen(locationweather: weatherData),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching weather data.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void retry() {
    setState(() => _hasError = false);
    getLocationData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.lightBlueAccent.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_outlined, size: 90, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'Loading Weather...',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 30),
                if (_hasError)
                  Column(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 48, color: Colors.orangeAccent),
                      SizedBox(height: 10),
                      Text(
                        'Unable to load weather.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: retry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                        ),
                        child: Text('Retry'),
                      ),
                    ],
                  )
                else
                  SpinKitFadingCircle(
                    color: Colors.white,
                    size: 60.0,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
