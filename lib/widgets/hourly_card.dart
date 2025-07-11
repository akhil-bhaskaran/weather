import 'package:flutter/material.dart';
import 'package:weather_app/theme/theme.dart';

class HourlyWeatherCard extends StatelessWidget {
  final String time;
  final double temp;
  final String weather;
  final String imgPath;

  const HourlyWeatherCard({
    Key? key,

    required this.time,
    required this.temp,
    required this.weather,
    required this.imgPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 0, 0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              offset: Offset(-3, 0),
              color: Colors.black,
              spreadRadius: 4,
              // blurStyle: BlurStyle.outer,
              blurRadius: 10,
            ),
            BoxShadow(
              offset: Offset(3, 3),
              color: const Color.fromARGB(255, 114, 114, 114).withOpacity(.6),
              spreadRadius: 4,
              // blurStyle: BlurStyle.outer,
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Time
              SizedBox(
                width: 80,
                child: Text(
                  time,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                ),
              ),

              // Weather Icon
              Container(width: 50, height: 50, child: Image.asset(imgPath)),
              SizedBox(width: 16),

              // Weather Description
              Expanded(
                child: Text(
                  weather,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),

              // Temperature
              Text(
                '${temp.round()}°C',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
