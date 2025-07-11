import 'package:flutter/material.dart';
import 'package:weather_app/theme/theme.dart';

class MyTextfield extends StatefulWidget {
  const MyTextfield({
    super.key,
    required this.hintText,
    required this.controller,
    required this.isIconNeeded,
  });

  final TextEditingController controller;
  final String hintText;
  final bool isIconNeeded;

  @override
  State<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText:
          widget.isIconNeeded
              ? _obscureText
              : false, // only obscure if it's password
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: widget.hintText,
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          color: Colors.black45,
          fontWeight: FontWeight.w600,
        ),
        border: const UnderlineInputBorder(),
        suffixIcon:
            widget.isIconNeeded
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : null,
      ),
    );
  }
}
