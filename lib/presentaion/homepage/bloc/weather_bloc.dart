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
import 'package:weather_app/model/weather_data_model.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  static const cityurl = "https://api.openweathermap.org/data/2.5/weather?q=";
  static const weatherUrl =
      "https://api.openweathermap.org/data/2.5/weather?lat=";
  final api = dotenv.env['API_KEY'];
  WeatherDataModel? _initialWeather;
  final supabase = Supabase.instance.client;
  WeatherBloc() : super(WeatherInitial()) {
    // Handle initial event
    on<WeatherLoadedFromSplash>((event, emit) {
      _initialWeather = event.weatherData;
      emit(WeatherSuccess(weatherData: event.weatherData));
    });
    on<RestoreInitialWeatherEvent>((event, emit) async {
      if (_initialWeather != null) {
        emit(WeatherSuccess(weatherData: _initialWeather!));
      } else {
        emit(WeatherLoading());
        try {
          final existing =
              await supabase
                  .from('weather_data')
                  .select()
                  .eq('users_id', supabase.auth.currentUser!.id)
                  .maybeSingle();
          final position = await _determinePosition();

          // Fetch new data (either no existing data or data is stale)
          log("Fetching new weather data");
          final response = await http.get(
            Uri.parse(
              "$weatherUrl${position.latitude}&lon=${position.longitude}&appid=$api",
            ),
          );

          if (response.statusCode == 200) {
            log(response.body);
            final weatherData = WeatherDataModel.fromJson(
              jsonDecode(response.body),
            );
            final now = DateTime.now();

            // Update or insert data
            if (existing != null) {
              await supabase
                  .from('weather_data')
                  .update({
                    'data': weatherData.toJson(),
                    'timestamp': now.toIso8601String(),
                  })
                  .eq("users_id", supabase.auth.currentUser!.id);
              log("Weather data updated successfully");
            } else {
              await supabase.from('weather_data').insert({
                'users_id': supabase.auth.currentUser!.id,
                'data': weatherData.toJson(),
                'timestamp': now.toIso8601String(),
              });
              log("Weather data inserted successfully");
            }
            emit(WeatherSuccess(weatherData: weatherData));
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
        if (response.statusCode == 200) {
          final weatherData = WeatherDataModel.fromJson(
            jsonDecode(response.body),
          );
          emit(WeatherSearchSuccess(weatherData: weatherData));
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
