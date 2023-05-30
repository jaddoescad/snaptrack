import 'package:flutter/material.dart';

class AuthActionButton extends StatelessWidget {
  final double borderRadius;
  final String buttonText;
  final VoidCallback onPressed;

  const AuthActionButton(
      {required this.borderRadius,
      required this.buttonText,
      required this.onPressed,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
      ),
      child: ElevatedButton(
        onPressed: () {
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.all(15),
          elevation: 0,
        ),
        child: Text(buttonText),
      ),
    );
  }
}
