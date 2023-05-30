import 'package:flutter/material.dart';

class AuthTextInput extends StatelessWidget {
  final double borderRadius;
  final String labelText;
  final bool obscureText;
  final TextEditingController controller;

  const AuthTextInput(
      {required this.borderRadius,
      required this.labelText,
      required this.controller,
      this.obscureText = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
