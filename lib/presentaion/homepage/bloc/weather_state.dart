part of 'weather_bloc.dart';

@immutable
sealed class WeatherState {}

final class WeatherInitial extends WeatherState {}

final class WeatherLoading extends WeatherState {}

final class WeatherSuccess extends WeatherState {
  final WeatherDataModel weatherData;
  final WeatherForecast forecast;

  WeatherSuccess({required this.weatherData, required this.forecast});
}

final class WeatherFailure extends WeatherState {
  final String message;

  WeatherFailure({required this.message});
}

final class LoadSearchState extends WeatherState {}

final class WeatherSearchSuccess extends WeatherState {
  final WeatherDataModel weatherData;
  final WeatherForecast forecast;

  WeatherSearchSuccess({required this.weatherData, required this.forecast});
}
