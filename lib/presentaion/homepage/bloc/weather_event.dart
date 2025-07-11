part of 'weather_bloc.dart';

@immutable
sealed class WeatherEvent {}

final class FetchWeather extends WeatherEvent {}

final class WeatherSearchEvent extends WeatherEvent {
  final String searchQuery;

  WeatherSearchEvent({required this.searchQuery});
}

class WeatherLoadedFromSplash extends WeatherEvent {
  final WeatherForecast forecast;
  final WeatherDataModel weatherData;
  WeatherLoadedFromSplash({required this.weatherData, required this.forecast});
}

class RestoreInitialWeatherEvent extends WeatherEvent {}
