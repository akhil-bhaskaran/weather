class WeatherForecast {
  final String city;
  final List<DailyForecast> forecasts;

  WeatherForecast({required this.city, required this.forecasts});

  /// Parse full API response
  factory WeatherForecast.fromApi(Map<String, dynamic> json) {
    final cityName = json['city']['name'];
    final List<dynamic> list = json['list'];

    // Group by date
    final Map<String, List<HourlyForecast>> grouped = {};

    for (final entry in list) {
      final dateTime = DateTime.parse(entry['dt_txt']);
      final date =
          "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

      final forecast = HourlyForecast.fromApi(entry);
      grouped.putIfAbsent(date, () => []).add(forecast);
    }

    final List<DailyForecast> daily =
        grouped.entries.map((e) {
          final hourlyList = e.value;

          // Midday (12:00) or average fallback
          HourlyForecast? midday = hourlyList.firstWhere(
            (h) => h.time.startsWith('12:'),
            orElse: () => hourlyList[hourlyList.length ~/ 2],
          );

          return DailyForecast(
            date: e.key,
            midday: MiddayWeather(
              temperature: midday.temperature,
              weather: midday.weather,
            ),
            hourly: hourlyList,
          );
        }).toList();

    return WeatherForecast(city: cityName, forecasts: daily);
  }

  factory WeatherForecast.fromSupabase(Map<String, dynamic> data) {
    return WeatherForecast.fromJson(data['weather_data']);
  }

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      city: json['city'],
      forecasts:
          (json['forecasts'] as List)
              .map((e) => DailyForecast.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'city': city,
    'forecasts': forecasts.map((e) => e.toJson()).toList(),
  };
}

class DailyForecast {
  final String date;
  final MiddayWeather midday;
  final List<HourlyForecast> hourly;

  DailyForecast({
    required this.date,
    required this.midday,
    required this.hourly,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'],
      midday: MiddayWeather.fromJson(json['midday']),
      hourly:
          (json['hourly'] as List)
              .map((e) => HourlyForecast.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'midday': midday.toJson(),
    'hourly': hourly.map((e) => e.toJson()).toList(),
  };
}

class MiddayWeather {
  final double temperature;
  final String weather;

  MiddayWeather({required this.temperature, required this.weather});

  factory MiddayWeather.fromJson(Map<String, dynamic> json) {
    return MiddayWeather(
      temperature: (json['temperature'] as num).toDouble(),
      weather: json['weather'],
    );
  }

  Map<String, dynamic> toJson() => {
    'temperature': (temperature * 100).round() / 100,
    'weather': weather,
  };
}

class HourlyForecast {
  final String time; // "06:00"
  final double temperature;
  final String weather;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weather,
  });

  /// Parse from the OpenWeatherMap "list" object
  factory HourlyForecast.fromApi(Map<String, dynamic> json) {
    final dtTxt = json['dt_txt']; // "2025-07-10 06:00:00"
    final time = dtTxt.split(' ')[1].substring(0, 5); // Get "06:00"

    return HourlyForecast(
      time: time,
      temperature:
          ((json['main']['temp']) as num).toDouble() -
          273.15, // Kelvin to Celsius
      weather: json['weather'][0]['main'], // e.g., "Clear"
    );
  }

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'],
      temperature: (json['temperature'] as num).toDouble(),
      weather: json['weather'],
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time,
    'temperature': (temperature * 100).round() / 100,
    'weather': weather,
  };
}
