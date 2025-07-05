import 'package:flutter/material.dart';

class MyVerticalDivider extends StatelessWidget {
  const MyVerticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 3,
        height: MediaQuery.of(context).size.width / 9,
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
