import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/errors/result.dart';
import '../models/weather_model.dart';

abstract class WeatherService {
  Future<Result<WeatherModel>> getCurrentWeather({double latitude = 19.0760, double longitude = 72.8777});
}

class OpenWeatherService implements WeatherService {
  final http.Client client;
  final String apiKey;

  OpenWeatherService({http.Client? client, this.apiKey = 'DEMO_KEY'})
      : client = client ?? http.Client();

  @override
  Future<Result<WeatherModel>> getCurrentWeather({double latitude = 19.0760, double longitude = 72.8777}) async {
    try {
      if (apiKey == 'DEMO_KEY') {
        // Fallback demo data to keep ₹0 cost and avoid network errors
        return Result.success(WeatherModel.mock());
      }
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey');
      final response = await client.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final main = data['main'] as Map<String, dynamic>? ?? {};
        final wind = data['wind'] as Map<String, dynamic>? ?? {};
        final weatherList = (data['weather'] as List<dynamic>?) ?? [];
        final weatherObj = weatherList.isNotEmpty ? weatherList[0] as Map<String, dynamic> : {};

        final temp = (main['temp'] as num?)?.toDouble() ?? 24.0;
        final condition = weatherObj['main'] as String? ?? 'Clear';
        final windSpeedMs = (wind['speed'] as num?)?.toDouble() ?? 4.0;
        final windSpeedKmh = double.parse((windSpeedMs * 3.6).toStringAsFixed(1));
        final humidity = (main['humidity'] as num?)?.toInt() ?? 60;

        // Calculate Ride Suitability Score
        int score = 100;
        if (temp > 35 || temp < 5) score -= 25;
        if (windSpeedKmh > 35) score -= 30;
        if (humidity > 85) score -= 15;
        if (condition.toLowerCase().contains('rain')) score -= 40;
        score = score.clamp(0, 100);

        final model = WeatherModel(
          temperatureC: temp,
          condition: condition,
          windSpeedKmh: windSpeedKmh,
          windDirection: 'E',
          humidity: humidity,
          suitabilityScore: score,
          hourlyForecast: WeatherModel.mock().hourlyForecast,
        );
        return Result.success(model);
      } else {
        return Result.success(WeatherModel.mock());
      }
    } catch (_) {
      return Result.success(WeatherModel.mock());
    }
  }
}
