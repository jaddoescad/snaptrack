import 'package:flutter/material.dart';
import 'package:snaptrack/camera_page.dart';
import 'package:snaptrack/components/auth/auth_footer_link.dart';
import 'package:snaptrack/supabase/auth.dart';
import 'package:snaptrack/utilities/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  void dispose() {
    // Dispose the text editing controllers when the state is disposed
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double borderRadius = 10;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 0),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                FocusScope.of(context).unfocus();
              }
              return true;
            },
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const AppLogo(),
                    const SizedBox(height: 50),
                    AuthTextInput(
                      controller: emailController,
                      borderRadius: borderRadius,
                      labelText: 'Email',
                    ),
                    const SizedBox(height: 15),
                    AuthTextInput(
                      controller: passwordController,
                      borderRadius: borderRadius,
                      labelText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    AuthActionButton(
                        borderRadius: borderRadius,
                        buttonText: 'Sign in',
                        onPressed: () async {
                          try {
                            await SupabaseAuthenticator.signIn(
                              email: emailController.text,
                              password: passwordController.text,
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CameraPage()),
                            );
                          } on AuthException catch (error) {
                            context.showErrorSnackBar(message: error.message);
                          } catch (e) {
                            context.showErrorSnackBar(message: e.toString());
                          }
                        }),
                    const SizedBox(height: 20),
                    AuthFooterLink(
                        text1: "Don't have an account? ",
                        text2: "Sign up",
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupPage()),
                          );
                        })
                  ],
                ),
              ),
            ),
          ),
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
