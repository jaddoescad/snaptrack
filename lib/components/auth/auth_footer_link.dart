import 'package:flutter/material.dart';

class AuthFooterLink extends StatelessWidget {
  final String text1;
  final String text2;
  final VoidCallback onPressed;

  const AuthFooterLink({required this.text1, required this.text2, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: <TextSpan>[
            TextSpan(text: text1),
            TextSpan(text: text2, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}