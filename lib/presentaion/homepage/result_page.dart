import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/presentaion/auth_pages/sign_in_page.dart';
import 'package:weather_app/presentaion/homepage/bloc/weather_bloc.dart';
import 'package:weather_app/presentaion/homepage/search_page.dart';

import 'package:weather_app/theme/app_colors.dart';
import 'package:weather_app/theme/theme.dart';

import 'package:weather_app/widgets/vertical_divider.dart';

class ResultPage extends StatefulWidget {
  // final bool locationDenied;
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();
  }

  String getWeatherImagePath(String weather) {
    switch (weather.toLowerCase()) {
      case 'clear':
        return 'assets/images/sunny.png';
      case 'clouds':
        return 'assets/images/cloudy.png';
      case 'rain':
        return 'assets/images/rainy.png';
      case 'thunderstorm':
        return 'assets/images/raint.png';
      case 'drizzle':
        return 'assets/images/drizzle.png';
      default:
        return 'assets/images/default.png'; // Fallback image
    }
  }

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocConsumer<WeatherBloc, WeatherState>(
      listener: (context, state) {
        if (state is WeatherFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is WeatherSearchSuccess) {
          return Scaffold(
            appBar: AppBar(backgroundColor: AppColors.greybg, elevation: 0),
            body: SafeArea(
              child: Container(
                height: screenHeight,
                width: screenWidth,
                color: AppColors.greybg,
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    Text(
                      state.weatherData.location,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      height: screenHeight / 4,
                      width: screenWidth,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            getWeatherImagePath(state.weatherData.weather),
                          ),
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    Text(
                      '${state.weatherData.temperature.toStringAsFixed(0)}\u2103',
                      style: theme.textTheme.displayLarge?.copyWith(height: .3),
                    ),
                    SizedBox(height: 30),
                    Text(
                      state.weatherData.weather,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        // height: 1.0,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                "H:${state.weatherData.maxTemperature.toStringAsFixed(0)}°  ",
                            style: theme.textTheme.bodyLarge?.copyWith(),
                          ),

                          TextSpan(
                            text:
                                "L:${state.weatherData.minTemperature.toStringAsFixed(0)}°",
                            style: theme.textTheme.bodyLarge?.copyWith(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 90),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 10,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Humidity',
                                style: theme.textTheme.bodyMedium,
                              ),
                              SizedBox(height: 5),
                              Text(
                                state.weatherData.humidity.toString(),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        MyVerticalDivider(),
                        Expanded(
                          child: Column(
                            children: [
                              Text('Wind', style: theme.textTheme.bodyMedium),

                              SizedBox(height: 5),
                              Text(
                                '${state.weatherData.wind.toStringAsFixed(1)}km/h',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        MyVerticalDivider(),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Pressure',
                                style: theme.textTheme.bodyMedium,
                              ),

                              SizedBox(height: 5),
                              Text(
                                '${state.weatherData.pressure}hPa',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is WeatherLoading) {
          return Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        } else {
          return SearchPage();
        }
      },
    );
  }
}
