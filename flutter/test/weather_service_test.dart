import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate/features/weather/models/weather_model.dart';
import 'package:ridermate/features/weather/services/weather_service.dart';
import 'package:ridermate/features/weather/controllers/weather_controller.dart';

void main() {
  group('Weather Telemetry & OpenWeather API Integration Unit Tests', () {
    late WeatherService weatherService;
    late WeatherController weatherController;

    setUp(() {
      weatherService = OpenWeatherService(apiKey: 'DEMO_KEY');
      weatherController = WeatherController(weatherService);
    });

    test('OpenWeatherService returns valid WeatherModel mock fallback when offline or demo key', () async {
      final res = await weatherService.getCurrentWeather();
      expect(res.isSuccess, true);
      final weather = res.dataOrNull!;
      expect(weather.temperatureC, 24.5);
      expect(weather.condition, 'Partly Cloudy');
      expect(weather.suitabilityScore, 88);
    });

    test('WeatherController refreshes weather and updates reactive state', () async {
      await weatherController.refreshWeather();
      expect(weatherController.weather.temperatureC, 24.5);
      expect(weatherController.weather.hourlyForecast.length, greaterThan(0));
    });
  });
}
