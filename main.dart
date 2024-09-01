import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  String _weather = '';
  String _imagePath = '';
  bool _loading = false;

  void _getWeather() async {
    final city = _controller.text;
    if (city.isNotEmpty) {
      setState(() {
        _loading = true;
        _weather = '';
        _imagePath = '';
      });

      try {
        final data = await fetchWeather(city);
        final weather = data['data'][0];
        final description = weather['weather']['description'].toLowerCase();


        if (description.contains('sunny') || description.contains('clear')) {
          _imagePath = 'sunny.png';
        } else if (description.contains('rain') || description.contains('drizzle')) {
          _imagePath = 'rainy.png';
        } else if (description.contains('cloud')) {
          _imagePath = 'cloudy.png';
        } else {
          _imagePath = '';
        }

        // Debugging output
        print('Weather Description: $description');
        print('Image Path: $_imagePath');

        setState(() {
          _weather = 'Temperature: ${weather['temp']}°C\n'
              'Weather: ${weather['weather']['description']}';
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _weather = 'Error fetching weather data. Check the console for details.';
        });
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }


  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final String apiKey = '016723200df3429d80a8b4d9946538a8';
    final url = 'https://api.weatherbit.io/v2.0/current?city=$city&key=$apiKey&units=M';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load weather data');
      }
    } catch (e) {

      print('Exception occurred: $e');
      throw Exception('Failed to fetch weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.lightBlue[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Weather Finder',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Enter city',
                    prefixIcon: Icon(Icons.location_city),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _getWeather,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Get Weather'),
              ),
              SizedBox(height: 16),
              if (_loading) CircularProgressIndicator(),
              if (!_loading) Column(
                children: [
                  if (_imagePath.isNotEmpty)
                    Image.asset(
                      _imagePath,
                      width: 100,
                      height: 100,
                    ),
                  SizedBox(height: 16),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _weather,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
