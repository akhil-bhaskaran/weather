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
import 'package:weather_app/model/weather_data_model.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SupabaseClient supabase = Supabase.instance.client;
  final String apiKey = dotenv.env['API_KEY']!;
  static const weatherUrl =
      "https://api.openweathermap.org/data/2.5/weather?lat=";
  // "https://api.openweathermap.org/data/2.5/weather?q=";

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
        final now = DateTime.now();

        final existing =
            await supabase
                .from('weather_data')
                .select()
                .eq('users_id', user.id)
                .maybeSingle();

        if (existing != null && existing['timestamp'] != null) {
          log("Existing weather data found for user: ${user.id}");
          final lastUpdated = DateTime.parse(existing['timestamp']);
          final diff = now.difference(lastUpdated);

          if (diff.inHours < 3) {
            log("from supabase");
            log("Existing weather data: ${existing}");
            final weather = WeatherDataModel.fromJsonSupabase(existing["data"]);
            print(weather.maxTemperature.toStringAsFixed(0));
            emit(SplashLoaded(weatherData: weather));
            return;
          }
        }
        final position = await _determinePosition();

        // Fetch new data (either no existing data or data is stale)
        log("Fetching new weather data");
        final response = await http.get(
          Uri.parse(
            "$weatherUrl${position.latitude}&lon=${position.longitude}&appid=$apiKey",
          ),
        );

        if (response.statusCode == 200) {
          log(response.body);
          final weatherData = WeatherDataModel.fromJson(
            jsonDecode(response.body),
          );

          // Update or insert data
          if (existing != null) {
            await supabase
                .from('weather_data')
                .update({
                  'data': weatherData.toJson(),
                  'timestamp': now.toIso8601String(),
                })
                .eq("users_id", user.id);
            log("Weather data updated successfully");
          } else {
            await supabase.from('weather_data').insert({
              'users_id': user.id,
              'data': weatherData.toJson(),
              'timestamp': now.toIso8601String(),
            });
            log("Weather data inserted successfully");
          }

          emit(SplashLoaded(weatherData: weatherData));
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
        emit(SplashLocationError(message: "Some Error Occured"));
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
}
