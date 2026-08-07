class HourlyForecast {
  final String time;
  final double tempC;
  final String icon;

  const HourlyForecast({
    required this.time,
    required this.tempC,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'time': time,
        'tempC': tempC,
        'icon': icon,
      };

  factory HourlyForecast.fromJson(Map<String, dynamic> json) => HourlyForecast(
        time: json['time'] as String? ?? '12:00',
        tempC: (json['tempC'] as num?)?.toDouble() ?? 24.0,
        icon: json['icon'] as String? ?? 'light_mode',
      );
}

class WeatherModel {
  final double temperatureC;
  final String condition;
  final double windSpeedKmh;
  final String windDirection;
  final int humidity;
  final int suitabilityScore;
  final List<HourlyForecast> hourlyForecast;

  const WeatherModel({
    required this.temperatureC,
    required this.condition,
    required this.windSpeedKmh,
    required this.windDirection,
    required this.humidity,
    required this.suitabilityScore,
    required this.hourlyForecast,
  });

  Map<String, dynamic> toJson() => {
        'temperatureC': temperatureC,
        'condition': condition,
        'windSpeedKmh': windSpeedKmh,
        'windDirection': windDirection,
        'humidity': humidity,
        'suitabilityScore': suitabilityScore,
        'hourlyForecast': hourlyForecast.map((h) => h.toJson()).toList(),
      };

  factory WeatherModel.fromJson(Map<String, dynamic> json) => WeatherModel(
        temperatureC: (json['temperatureC'] as num?)?.toDouble() ?? 24.0,
        condition: json['condition'] as String? ?? 'Partly Cloudy',
        windSpeedKmh: (json['windSpeedKmh'] as num?)?.toDouble() ?? 15.0,
        windDirection: json['windDirection'] as String? ?? 'E',
        humidity: (json['humidity'] as num?)?.toInt() ?? 55,
        suitabilityScore: (json['suitabilityScore'] as num?)?.toInt() ?? 88,
        hourlyForecast: (json['hourlyForecast'] as List<dynamic>?)
                ?.map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  static WeatherModel mock() => const WeatherModel(
        temperatureC: 24.5,
        condition: 'Partly Cloudy',
        windSpeedKmh: 15.0,
        windDirection: 'E',
        humidity: 58,
        suitabilityScore: 88,
        hourlyForecast: [
          HourlyForecast(time: 'Now', tempC: 24.5, icon: 'light_mode'),
          HourlyForecast(time: '12 PM', tempC: 26.0, icon: 'wb_sunny'),
          HourlyForecast(time: '1 PM', tempC: 27.2, icon: 'wb_sunny'),
          HourlyForecast(time: '2 PM', tempC: 27.5, icon: 'wb_sunny'),
          HourlyForecast(time: '3 PM', tempC: 26.8, icon: 'cloud'),
          HourlyForecast(time: '4 PM', tempC: 25.4, icon: 'cloud'),
        ],
      );
}
