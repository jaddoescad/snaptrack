// import 'package:camera_app/camera_page.dart';
import 'package:flutter/material.dart';
import 'package:snaptrack/signup_page.dart';
import 'login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Login Signup App',
        home: const SignupPage(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ));
  }
}
