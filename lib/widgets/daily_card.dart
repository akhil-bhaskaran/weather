import 'package:flutter/material.dart';

class DailyCard extends StatelessWidget {
  final String day;
  final IconData imgPath;
  final double temp;
  final bool isSelected;

  const DailyCard({
    super.key,
    required this.day,
    required this.imgPath,
    required this.temp,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    Color background = Colors.white;
    Color onBackground = Colors.black;
    if (!isSelected) {
      background = Colors.black;
      onBackground = Colors.white;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 12),
        height: MediaQuery.sizeOf(context).width / 3,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(imgPath, color: onBackground, size: 30),
            Text(day, style: TextStyle(color: onBackground)),
            Text(
              "${temp.toStringAsFixed(0)}\u2103",
              style: TextStyle(color: onBackground),
            ),
          ],
        ),
        width: MediaQuery.sizeOf(context).width / 5,
      ),
    );
  }
}
