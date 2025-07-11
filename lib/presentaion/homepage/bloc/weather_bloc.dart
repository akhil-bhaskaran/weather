import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weather_app/model/forecast_models.dart';
import 'package:weather_app/model/weather_data_model.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  static const cityurl = "https://api.openweathermap.org/data/2.5/weather?q=";
  static const weatherUrl =
      "https://api.openweathermap.org/data/2.5/weather?lat=";
  static const forecastUrl =
      "https://api.openweathermap.org/data/2.5/forecast?lat=";
  static const forecastCityUrl =
      "https://api.openweathermap.org/data/2.5/forecast?q=";
  final api = dotenv.env['API_KEY'];
  WeatherDataModel? _initialWeather;
  WeatherForecast? _initialWeatherForecast;
  final supabase = Supabase.instance.client;
  WeatherBloc() : super(WeatherInitial()) {
    // Handle initial event
    on<WeatherLoadedFromSplash>((event, emit) {
      _initialWeather = event.weatherData;
      _initialWeatherForecast = event.forecast;
      emit(
        WeatherSuccess(
          weatherData: event.weatherData,
          forecast: event.forecast,
        ),
      );
    });
    on<RestoreInitialWeatherEvent>((event, emit) async {
      if (_initialWeather != null && _initialWeatherForecast != null) {
        emit(
          WeatherSuccess(
            weatherData: _initialWeather!,
            forecast: _initialWeatherForecast!,
          ),
        );
      } else {
        emit(WeatherLoading());
        try {
          WeatherDataModel? current_weather = await _getCurrentWeather(
            supabase.auth.currentUser!.id,
          );
          WeatherForecast? forecast = await _getForecast(
            supabase.auth.currentUser!.id,
          );
          if (current_weather != null && forecast != null) {
            emit(
              WeatherSuccess(weatherData: current_weather, forecast: forecast),
            );
          } else {
            emit(WeatherFailure(message: "Failed to fetch weather data"));
          }
        } catch (e) {
          emit(WeatherFailure(message: "Error: $e"));
        }
      }
    });
    // Handle search event
    on<WeatherSearchEvent>((event, emit) async {
      emit(WeatherLoading());
      try {
        final response = await http.get(
          Uri.parse("$cityurl${event.searchQuery}&appid=$api"),
        );
        final forecast_response = await http.get(
          Uri.parse("$forecastCityUrl${event.searchQuery}&appid=$api"),
        );
        if (response.statusCode == 200 && forecast_response.statusCode == 200) {
          final weatherCurrentData = WeatherDataModel.fromJson(
            jsonDecode(response.body),
          );
          final weatherForecastData = WeatherForecast.fromApi(
            jsonDecode(forecast_response.body),
          );
          log(weatherForecastData.toString());
          emit(
            WeatherSearchSuccess(
              weatherData: weatherCurrentData,
              forecast: weatherForecastData,
            ),
          );
        } else {
          emit(WeatherFailure(message: "Failed to fetch weather data"));
        }
      } on SocketException {
        emit(WeatherFailure(message: "No Internet connection."));
      } catch (e) {
        emit(WeatherFailure(message: "Error: $e"));
      }
    });
  }
  @override
  void onTransition(Transition<WeatherEvent, WeatherState> transition) {
    super.onTransition(transition);
    Logger().e(
      "Transition from ${transition.currentState} to ${transition.nextState}",
    );
  }

  // GETING FORECAST IF NOT GIVEN PREMISSION
  Future<WeatherForecast?> _getForecast(String userId) async {
    final now = DateTime.now();

    final existing =
        await supabase
            .from('weather_forecast')
            .select()
            .eq('users_id', userId)
            .maybeSingle();

    if (existing != null && existing['timestamp'] != null) {
      final lastUpdated = DateTime.parse(existing['timestamp']);
      final diff = now.difference(lastUpdated);

      if (diff.inHours < 24) {
        log("Using cached forecast");
        return WeatherForecast.fromJson(existing['data']);
      }
    }

    final position = await _determinePosition();
    final url = Uri.parse(
      "$forecastUrl${position.latitude}&lon=${position.longitude}&appid=$api",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final forecast = WeatherForecast.fromApi(jsonDecode(response.body));

      if (existing != null) {
        await supabase
            .from('weather_forecast')
            .update({
              'data': forecast.toJson(),
              'timestamp': now.toIso8601String(),
            })
            .eq('users_id', userId);
      } else {
        await supabase.from('weather_forecast').insert({
          'users_id': userId,
          'data': forecast.toJson(),
          'timestamp': now.toIso8601String(),
        });
      }

      log(" Forecast updated");
      return forecast;
    } else {
      log("Forecast API failed: ${response.body}");
      return null;
    }
  }

  // GETING CURRENT WEATHER IF NOT GIVEN PREMISSION
  Future<WeatherDataModel?> _getCurrentWeather(String userId) async {
    final now = DateTime.now();

    final existing =
        await supabase
            .from('weather_data')
            .select()
            .eq('users_id', userId)
            .maybeSingle();

    if (existing != null && existing['timestamp'] != null) {
      final lastUpdated = DateTime.parse(existing['timestamp']);
      final diff = now.difference(lastUpdated);

      if (diff.inHours < 3) {
        log("Using cached current weather");
        return WeatherDataModel.fromJsonSupabase(existing['data']);
      }
    }

    final position = await _determinePosition();
    final url = Uri.parse(
      "$weatherUrl${position.latitude}&lon=${position.longitude}&appid=$api",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final weatherData = WeatherDataModel.fromJson(jsonDecode(response.body));

      if (existing != null) {
        await supabase
            .from('weather_data')
            .update({
              'data': weatherData.toJson(),
              'timestamp': now.toIso8601String(),
            })
            .eq('users_id', userId);
      } else {
        await supabase.from('weather_data').insert({
          'users_id': userId,
          'data': weatherData.toJson(),
          'timestamp': now.toIso8601String(),
        });
      }

      log("Current weather updated");
      return weatherData;
    } else {
      log(" Failed to fetch current weather: ${response.body}");
      return null;
    }
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  return await Geolocator.getCurrentPosition();
}
