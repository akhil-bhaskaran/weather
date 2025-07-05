import 'package:flutter/material.dart';

final ThemeData theme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Montserrat', // Optional, or use 'Roboto'
  scaffoldBackgroundColor: Colors.transparent,

  textTheme: const TextTheme(
    displayLarge: TextStyle(
      // For temperature (e.g., 40°C)
      fontSize: 90,
      fontWeight: FontWeight.w900,

      color: Colors.white,
    ),
    titleLarge: TextStyle(
      // For "Clear"
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    titleMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    titleSmall: TextStyle(
      // For updated time
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.white70,
    ),
    bodyLarge: TextStyle(
      // For values like "24%", "5.66km/h"
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      // For labels like "Humidity", "Wind", etc.
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    bodySmall: TextStyle(
      // For bottom forecast labels (day, temp, wind)
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
  ),
);
