import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/presentaion/auth_pages/sign_in_page.dart';
import 'package:weather_app/presentaion/homepage/bloc/weather_bloc.dart';
import 'package:weather_app/presentaion/homepage/home_page.dart';
import 'package:weather_app/presentaion/homepage/search_page.dart';

import 'package:weather_app/presentaion/splash_screen/bloc/splash_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SplashBloc>().add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is DirectToAuthPage) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const SignInPage(),
                transitionDuration: Duration.zero,
              ),
            );
          } else if (state is SplashLoaded) {
            context.read<WeatherBloc>().add(
              WeatherLoadedFromSplash(
                weatherData: state.weatherData,
                forecast: state.forecast,
              ),
            );
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HomePage(),
                transitionDuration: Duration.zero,
              ),
            );
          } else if (state is SplashLocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
            log("Location error: ${state.message} navigating to search page");
          }
        },
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  child: Lottie.asset("assets/lottie/Animation - 3.json"),
                ),
                SizedBox(height: 10),
                Text(
                  'NowCast',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
