import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mausham/screen_2.dart';

class Screen1 extends StatefulWidget {
  final dynamic weatherData;
  const Screen1({super.key, this.weatherData});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> with TickerProviderStateMixin {
  final String apiKey = "d58514f088d9d9657abfdcc003fd43f8";

  String? cityName;
  String? currentWeather;
  String? tempInCelsius;
  String? feelsLike;
  String? humidity;
  String? windSpeed;
  String? visibility;
  String? pressure;
  String emoji = "❓";
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    updateUI(widget.weatherData);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 28, 98, 227),
              const Color(0xFF2A5298),
              const Color.fromARGB(255, 87, 122, 182),
            ],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        // Header with buttons
                        _buildHeader(),
                        const SizedBox(height: 40),

                        // Main weather display
                        _buildMainWeatherCard(),
                        const SizedBox(height: 30),

                        // Weather details grid
                        _buildWeatherDetailsGrid(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: () async {
              if (cityName != null && cityName!.isNotEmpty) {
                await getWeatherDataFromCityName(cityName!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("City name is not set"),
                    backgroundColor: Color(0xFF2A5298),
                  ),
                );
              }
            },
          ),
        ),
        Text(
          'Weather App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => const Screen2()),
              );

              if (result != null && result.isNotEmpty) {
                await getWeatherDataFromCityName(result);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            cityName ?? 'Unknown City',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tempInCelsius != null ? tempInCelsius! : '--',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Text(
                '°C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 15),
              Text(
                currentWeather ?? 'Unknown',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          if (feelsLike != null) ...[
            const SizedBox(height: 15),
            Text(
              'Feels like $feelsLike°C',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeatherDetailsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weather Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 10,
          childAspectRatio: 1.3,
          children: [
            _buildDetailCard(
              icon: Icons.water_drop,
              title: 'Humidity',
              value: humidity != null ? '$humidity%' : '--',
              color: const Color(0xFF64B5F6),
            ),
            _buildDetailCard(
              icon: Icons.air,
              title: 'Wind Speed',
              value: windSpeed != null ? '$windSpeed m/s' : '--',
              color: const Color(0xFF81C784),
            ),
            _buildDetailCard(
              icon: Icons.visibility,
              title: 'Visibility',
              value: visibility != null ? '$visibility km' : '--',
              color: const Color(0xFFFFB74D),
            ),
            _buildDetailCard(
              icon: Icons.speed,
              title: 'Pressure',
              value: pressure != null ? '$pressure hPa' : '--',
              color: const Color(0xFFF06292),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String kelvinToCelsius(double temp) {
    return (temp - 273.15).floor().toString();
  }

  Future<void> getWeatherDataFromCityName(String city) async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'q': city,
      'appid': apiKey,
    });

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var weatherData = jsonDecode(response.body);
        updateUI(weatherData);
        _animationController.reset();
        _animationController.forward();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to fetch weather: ${response.statusCode}"),
            backgroundColor: const Color(0xFF2A5298),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching weather: $e"),
          backgroundColor: const Color(0xFF2A5298),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateUI(dynamic weatherData) {
    if (weatherData == null) {
      debugPrint("Weather data is null");
      return;
    }

    try {
      final weatherList = weatherData['weather'];
      final weatherId = weatherList != null && weatherList.isNotEmpty
          ? weatherList[0]['id']
          : null;
      final temp = weatherData['main']?['temp'];
      final feelsLikeTemp = weatherData['main']?['feels_like'];
      final humidityValue = weatherData['main']?['humidity'];
      final pressureValue = weatherData['main']?['pressure'];
      final windData = weatherData['wind'];
      final visibilityValue = weatherData['visibility'];
      final name = weatherData['name'];
      final mainWeather = weatherData['weather']?[0]?['main'];

      // Set weather emoji based on weather ID
      if (weatherId != null) {
        if (weatherId >= 200 && weatherId < 300) {
          emoji = '🌩️';
        } else if (weatherId >= 300 && weatherId < 400) {
          emoji = '🌦️';
        } else if (weatherId >= 500 && weatherId < 600) {
          emoji = '🌧️';
        } else if (weatherId >= 600 && weatherId < 700) {
          emoji = '❄️';
        } else if (weatherId >= 700 && weatherId < 800) {
          emoji = '🌫️';
        } else if (weatherId == 800) {
          emoji = '☀️';
        } else if (weatherId > 800 && weatherId < 900) {
          emoji = '☁️';
        } else {
          emoji = '❓';
        }
      }

      setState(() {
        cityName = name ?? 'Unknown';
        currentWeather = mainWeather ?? 'N/A';
        tempInCelsius = temp != null ? kelvinToCelsius(temp) : null;
        feelsLike = feelsLikeTemp != null
            ? kelvinToCelsius(feelsLikeTemp)
            : null;
        humidity = humidityValue?.toString();
        pressure = pressureValue?.toString();
        windSpeed = windData?['speed']?.toStringAsFixed(1);
        visibility = visibilityValue != null
            ? (visibilityValue / 1000).toStringAsFixed(1)
            : null;
      });
    } catch (e) {
      debugPrint("Error parsing weather data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error parsing weather data."),
          backgroundColor: Color(0xFF2A5298),
        ),
      );
    }
  }
}
