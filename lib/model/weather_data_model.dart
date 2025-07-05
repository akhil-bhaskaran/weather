class WeatherDataModel {
  final String location;
  final String weather;
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final double humidity;
  final double wind;
  final double pressure;

  WeatherDataModel({
    required this.wind,
    required this.location,
    required this.weather,
    required this.temperature,
    required this.humidity,
    required this.minTemperature,
    required this.maxTemperature,
    required this.pressure,
  });

  factory WeatherDataModel.fromJson(Map<String, dynamic> json) {
    return WeatherDataModel(
      location: json['name'] ?? 'Unknown',
      weather: json['weather'][0]['main'],
      temperature: json['main']['temp'].toDouble() - 273.15,
      pressure: json['main']['pressure'].toDouble(),
      humidity: json['main']['humidity'].toDouble(),
      maxTemperature: json['main']['temp_max'].toDouble() - 273.15,
      minTemperature: json['main']['temp_min'].toDouble() - 273.15,
      wind: json['wind']['speed'].toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'weather': weather,
      'temperature': (temperature * 100).round() / 100,
      'minTemperature': (minTemperature * 100).round() / 100,
      'maxTemperature': (maxTemperature * 100).round() / 100,
      'humidity': humidity,
      'wind': wind,
      'pressure': pressure,
    };
  }

  factory WeatherDataModel.fromJsonSupabase(Map<String, dynamic> json) {
    return WeatherDataModel(
      location: json['location'] ?? 'Unknown',
      weather: json['weather'],
      temperature: json['temperature'],
      minTemperature: json['minTemperature'],
      maxTemperature: json['maxTemperature'],
      humidity: json['humidity'],
      wind: json['wind'],
      pressure: json['pressure'],
    );
  }
}
