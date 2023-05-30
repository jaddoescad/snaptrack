import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final double borderRadius;
  final VoidCallback onPressed;

  const GoogleSignInButton(
      {required this.borderRadius, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
      ),
      child: ElevatedButton.icon(
        icon: Image.asset('assets/images/google_logo.png', width: 24),
        label: const Text('Sign in with Google'),
        onPressed: () {
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: const BorderSide(color: Color.fromARGB(255, 152, 152, 152)),
          ),
          padding: const EdgeInsets.all(12),
          elevation: 0,
        ),
      ),
    );
  }
}
