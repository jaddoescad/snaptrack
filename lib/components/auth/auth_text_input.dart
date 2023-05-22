import 'package:flutter/material.dart';

class AuthTextInput extends StatelessWidget {
  final double borderRadius;
  final String labelText;
  final bool obscureText;

  const AuthTextInput(
      {required this.borderRadius,
      required this.labelText,
      this.obscureText = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        labelText: labelText,
      ),
    );
  }
}
