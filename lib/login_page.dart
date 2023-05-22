import 'package:flutter/material.dart';
import 'package:snaptrack/camera_page.dart';
import 'package:snaptrack/components/auth/auth_footer_link.dart';
import 'components/auth/google_signin_button.dart';
import 'components/auth/auth_text_input.dart';
import 'components/auth/logo.dart';
import 'components/auth/auth_action_button.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    double borderRadius = 10;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const AppLogo(),
            const SizedBox(height: 50),
            GoogleSignInButton(
                borderRadius: borderRadius,
                onPressed: () 
                {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CameraPage()),
                  );
                }
                ),
            const SizedBox(height: 15),
            DividerWithText(borderRadius: borderRadius),
            const SizedBox(height: 15),
            AuthTextInput(
              borderRadius: borderRadius,
              labelText: 'Email',
            ),
            const SizedBox(height: 15),
            AuthTextInput(
              borderRadius: borderRadius,
              labelText: 'Password',
            ),
            const SizedBox(height: 20),
            AuthActionButton(
                borderRadius: borderRadius,
                buttonText: 'Sign in',
                onPressed: () 
                {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CameraPage()),
                  );
                }
                ),
            const SizedBox(height: 20),
            AuthFooterLink(
                text1: "Don't have an account? ",
                text2: "Sign up",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                })
          ],
        ),
      ),
    );
  }
}

class DividerWithText extends StatelessWidget {
  final double borderRadius;
  const DividerWithText({required this.borderRadius, super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(
          child: Divider(),
        ),
        Text(" OR "),
        Expanded(
          child: Divider(),
        ),
      ],
    );
  }
}
