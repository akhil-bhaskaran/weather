import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/presentaion/auth_pages/sign_in_page.dart';
import 'package:weather_app/presentaion/homepage/bloc/weather_bloc.dart';
import 'package:weather_app/presentaion/homepage/search_page.dart';

import 'package:weather_app/theme/app_colors.dart';
import 'package:weather_app/theme/theme.dart';
import 'package:weather_app/widgets/vertical_divider.dart';

class HomePage extends StatefulWidget {
  // final bool locationDenied;
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

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
        if (state is WeatherFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: theme.textTheme.bodyLarge),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is ToAuthState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInPage()),
          );
        }
      },
      builder: (context, state) {
        if (state is WeatherSuccess) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.greybg,
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {
                    BlocProvider.of<WeatherBloc>(context).add(Logout());
                  },
                  icon: Icon(Icons.logout, color: Colors.white),
                ),
              ],
            ),
            body: SafeArea(
              child: Container(
                height: screenHeight,
                width: screenWidth,
                color: AppColors.greybg,
                child: Column(
                  children: [
                    Text(
                      state.weatherData.location,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Day and date'.toUpperCase(),
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
                          image: AssetImage('assets/images/raint.png'),
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    Text(
                      '${state.weatherData.temperature.toStringAsFixed(0)}\u2103',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.0),
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
                            text: "H:${state.weatherData.maxTemperature}°  ",
                            style: theme.textTheme.bodyLarge?.copyWith(),
                          ),

                          TextSpan(
                            text: "L:${state.weatherData.minTemperature}°",
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
        }
        // else if (state is WeatherLoading) {
        //   return Scaffold(
        //     body: SafeArea(child: Center(child: CircularProgressIndicator())),
        //   );
        // }
        else {
          return SearchPage();
        }
      },
    );
  }
}
