part of 'splash_bloc.dart';

@immutable
sealed class SplashState {}

final class SplashInitial extends SplashState {}

final class SplashLoading extends SplashState {}

class SplashLoaded extends SplashState {
  final WeatherDataModel weatherData;
  final WeatherForecast forecast;
  SplashLoaded({required this.weatherData, required this.forecast});
}

final class DirectToHomePage extends SplashState {}

final class DirectToAuthPage extends SplashState {}

class SplashLocationError extends SplashState {
  final String message;
  SplashLocationError({required this.message});
}
