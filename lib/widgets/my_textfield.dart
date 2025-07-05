import 'package:flutter/material.dart';
import 'package:weather_app/theme/theme.dart';

class MyTextfield extends StatefulWidget {
  const MyTextfield({
    super.key,
    required this.hintText,
    required this.controller,
  });
  final TextEditingController controller;
  final String hintText;
  @override
  State<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        focusColor: Colors.black,
        border: UnderlineInputBorder(),

        labelText: widget.hintText,
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          color: Colors.black45,
          fontWeight: FontWeight.w600,
        ),
      ),
      controller: widget.controller,
    );
  }
}
