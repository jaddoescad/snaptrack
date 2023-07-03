import 'package:flutter/material.dart';
import 'package:snaptrack/components/auth/auth_footer_link.dart';
import 'package:snaptrack/home_page.dart';
import 'package:snaptrack/utilities/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'components/auth/google_signin_button.dart';
import 'components/auth/auth_text_input.dart';
import 'components/auth/logo.dart';
import 'components/auth/auth_action_button.dart';
import 'login_page.dart';
import 'camera_page.dart';
import './supabase/auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final SupabaseInstance authenticator = SupabaseInstance();
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
          onTapDown: (details) => FocusScope.of(context).unfocus(),
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
                    const SizedBox(height: 15),
                    AuthTextInput(
                      controller: fullNameController,
                      borderRadius: borderRadius,
                      labelText: 'Full Name',
                    ),
                                        const SizedBox(height: 15),

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
                        buttonText: 'Sign up',
                        onPressed: () async {
                          try {
                            await authenticator.signUp(
                              fullName: fullNameController.text,
                              email: emailController.text,
                              password: passwordController.text,
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
                            );
                          } on AuthException catch (error) {
                            context.showErrorSnackBar(message: error.message);
                          } catch (e) {
                            context.showErrorSnackBar(message: e.toString());
                          }
                        }),
                    const SizedBox(height: 20),
                    AuthFooterLink(
                        text1: "Already have an account? ",
                        text2: "Sign in",
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
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
