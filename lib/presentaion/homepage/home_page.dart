import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/model/forecast_models.dart';
import 'package:weather_app/presentaion/auth_pages/sign_in_page.dart';
import 'package:weather_app/presentaion/homepage/bloc/weather_bloc.dart';
import 'package:weather_app/presentaion/homepage/search_page.dart';

import 'package:weather_app/theme/app_colors.dart';
import 'package:weather_app/theme/theme.dart';
import 'package:weather_app/widgets/daily_card.dart';
import 'package:weather_app/widgets/hourly_card.dart';

import 'package:weather_app/widgets/vertical_divider.dart';

class HomePage extends StatefulWidget {
  // final bool locationDenied;
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // This gets called when coming back to HomePage
  @override
  void didPopNext() {
    context.read<WeatherBloc>().add(RestoreInitialWeatherEvent());
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
      case 'snow':
        return 'assets/images/snow.png';
      default:
        return 'assets/images/sunny.png';
    }
  }

  IconData getWeatherIcon(String weather) {
    switch (weather.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'drizzle':
        return Icons.grain;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_sunny;
    }
  }

  String getDayName(int index) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return index < days.length ? days[index] : 'Day ${index + 1}';
  }

  int selectedIndex = 0;
  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    ;

    if (hour == 00) {
      return '12 AM';
    } else if (hour < 12) {
      return '${hour} AM';
    } else if (hour == 12) {
      return '12 PM';
    } else {
      return '${hour - 12} PM';
    }
  }

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    void _showBottomSheet(WeatherForecast forecast, int indexx) {
      showModalBottomSheet(
        context: context,

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 1.5,
            child: ListView.builder(
              itemCount: forecast.forecasts[indexx].hourly.length,
              itemBuilder: (context, index) {
                return HourlyWeatherCard(
                  time: _formatTime(
                    forecast.forecasts[indexx].hourly[index].time,
                  ),
                  temp: forecast.forecasts[indexx].hourly[index].temperature,
                  weather: forecast.forecasts[indexx].hourly[index].weather,
                  imgPath: getWeatherImagePath(
                    forecast.forecasts[indexx].hourly[index].weather,
                  ),
                );
              },
            ),
          );
        },
      );
    }

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
        if (state is WeatherSuccess) {
          return Scaffold(
            body: SafeArea(
              child: Container(
                height: screenHeight * 2,
                width: screenWidth,
                color: AppColors.greybg,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          iconSize: 30,
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const SearchPage(),
                                transitionDuration: Duration.zero,
                              ),
                            );
                          },
                          icon: Icon(Icons.search_sharp),
                        ),
                      ),
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
                      SizedBox(height: 15),
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

                      Text(
                        '${state.weatherData.temperature.toStringAsFixed(0)}\u2103',
                        style: theme.textTheme.displayLarge?.copyWith(
                          height: .6,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        state.weatherData.weather,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          // height: 1.0,
                        ),
                      ),
                      SizedBox(height: 20),
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
                      SizedBox(height: 50),
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
                      SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        width: screenWidth,
                        height: screenWidth / 2,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            53,
                            53,
                            53,
                          ).withOpacity(.3),
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                                _showBottomSheet(state.forecast, index);
                              },
                              child: DailyCard(
                                isSelected: selectedIndex == index,
                                imgPath: getWeatherIcon(
                                  state
                                      .forecast
                                      .forecasts[index]
                                      .midday
                                      .weather,
                                ),
                                day: getDayName(
                                  (DateTime.now().weekday + index - 1) % 7,
                                ),
                                temp:
                                    state
                                        .forecast
                                        .forecasts[index]
                                        .midday
                                        .temperature,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (state is WeatherLoading) {
          return Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        } else {
          return Scaffold(
            body: SafeArea(child: Center(child: Text("No data"))),
          );
        }
      },
    );
  }
}
