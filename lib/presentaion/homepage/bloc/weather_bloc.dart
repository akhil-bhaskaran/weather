import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weather_app/model/weather_data_model.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  static const url = "https://api.openweathermap.org/data/2.5/weather?q=";
  final api = dotenv.env['API_KEY'];

  WeatherBloc() : super(WeatherInitial()) {
    // Handle fetch weather event
    // on<FetchWeather>((event, emit) async {
    //   emit(WeatherLoading());
    //   try {
    //     final Position currentPosition = await _determinePosition();

    //     List<Placemark> placemarks = await placemarkFromCoordinates(
    //       currentPosition.latitude,
    //       currentPosition.longitude,
    //     );
    //     final cityName = placemarks.first.locality ?? 'kannur';

    //     final response = await http.get(Uri.parse("$url$cityName&appid=$api"));
    //     if (response.statusCode == 200) {
    //       final weatherData = WeatherDataModel.fromJson(
    //         jsonDecode(response.body),
    //       );
    //       emit(WeatherSuccess(weatherData: weatherData));
    //     } else {
    //       emit(WeatherFailure(message: "Failed to fetch weather data"));
    //     }
    //   } catch (e) {
    //     if (e is String &&
    //         (e.contains('permissions are denied') ||
    //             e.contains('permanently denied'))) {
    //       emit(LoadSearchState());
    //     } else {
    //       emit(WeatherFailure(message: "Error: $e"));
    //     }
    //   }
    // });
    on<WeatherLoadedFromSplash>((event, emit) {
      emit(WeatherSuccess(weatherData: event.weatherData));
    });
    // Handle search event
    on<WeatherSearchEvent>((event, emit) {
      emit(WeatherLoading());
      try {
        final response = http.get(
          Uri.parse("$url${event.searchQuery}&appid=$api"),
        );
        response.then((res) {
          if (res.statusCode == 200) {
            final weatherData = WeatherDataModel.fromJson(jsonDecode(res.body));
            emit(WeatherSuccess(weatherData: weatherData));
          } else {
            emit(WeatherFailure(message: "Failed to fetch weather data"));
          }
        });
      } catch (e) {
        emit(WeatherFailure(message: "Error: $e"));
      }
    });
    on<Logout>((event, emit) async {
      emit(WeatherLoading());
      await Supabase.instance.client.auth
          .signOut()
          .then((value) {
            emit(ToAuthState());
          })
          .catchError((error) {
            emit(WeatherFailure(message: "Logout failed: $error"));
          });
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

//Geolocator and Geocoding functions to get current location
// This function determines the current position of the device and returns it.
// It checks if location services are enabled and if the necessary permissions are granted.
// If permissions are denied, it requests them. If the permissions are permanently denied, it returns an error.
// If everything is fine, it returns the current position of the device.
// Future<Position> _determinePosition() async {
//   bool serviceEnabled;
//   LocationPermission permission;

//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     return Future.error('Location services are disabled.');
//   }

//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       return Future.error('Location permissions are denied');
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     return Future.error(
//       'Location permissions are permanently denied, we cannot request permissions.',
//     );
//   }

//   return await Geolocator.getCurrentPosition();
// }
