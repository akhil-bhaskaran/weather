import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart' show Logger;
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weather_app/model/forecast_models.dart';
import 'package:weather_app/model/weather_data_model.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SupabaseClient supabase = Supabase.instance.client;
  final String apiKey = dotenv.env['API_KEY']!;
  static const weatherUrl =
      "https://api.openweathermap.org/data/2.5/weather?lat=";

  SplashBloc() : super(SplashInitial()) {
    on<AppStarted>((event, emit) async {
      log("AppStarted event triggered");

      final user = supabase.auth.currentUser;

      if (user == null) {
        log("No user found, redirecting to auth page");
        emit(DirectToAuthPage());
        return;
      }
      log(" Supabase susu: $user");

      try {
        log("Enterd try");

        WeatherDataModel? current_weather = await _getCurrentWeather(
          supabase.auth.currentUser!.id,
        );
        WeatherForecast? forecast = await _getForecast(
          supabase,
          supabase.auth.currentUser!.id,
        );
        if (forecast != null && current_weather != null) {
          emit(SplashLoaded(weatherData: current_weather, forecast: forecast));
        } else {
          emit(SplashLocationError(message: "API failed"));
        }
      } on SocketException {
        emit(SplashLocationError(message: "No Internet connection."));
      } on Exception catch (e) {
        log("Error determining position: ${e}");
        emit(SplashLocationError(message: e.toString()));
      } catch (c) {
        log("Error determining position: ${c}");
        emit(SplashLocationError(message: "Some Error Occured "));
      }
    });
  }

  Future<Position> _determinePosition() async {
    log("Determining position");
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission permanently denied');
    }
    log("Location permission granted");
    return await Geolocator.getCurrentPosition();
  }

  @override
  void onTransition(Transition<SplashEvent, SplashState> transition) {
    super.onTransition(transition);
    Logger().e(
      "Transition from ${transition.currentState} to ${transition.nextState}",
    );
  }

  Future<WeatherForecast?> _getForecast(
    SupabaseClient supabase,
    String userId,
  ) async {
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
        log(" Using cached forecast from Supabase");
        return WeatherForecast.fromJson(existing['data']);
      }
    }

    // If no data or stale
    final position = await _determinePosition();
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final forecast = WeatherForecast.fromApi(jsonData);

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

      log("Forecast updated");
      return forecast;
    } else {
      log("Forecast API failed: ${response.body}");
      return null;
    }
  }

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

    // Fetch new data
    final position = await _determinePosition();
    final url = Uri.parse(
      "$weatherUrl${position.latitude}&lon=${position.longitude}&appid=$apiKey",
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
            .eq("users_id", userId);
      } else {
        await supabase.from('weather_data').insert({
          'users_id': userId,
          'data': weatherData.toJson(),
          'timestamp': now.toIso8601String(),
        });
      }

      log("✅ Current weather updated");
      return weatherData;
    } else {
      log("❌ Failed to fetch current weather: ${response.body}");
      return null;
    }
  }
}
