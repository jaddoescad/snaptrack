import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaptrack/models/bin.dart';
import 'package:snaptrack/models/bin_list_notifier.dart';
import 'package:snaptrack/models/image_list_notifier.dart';
import 'package:snaptrack/signup_page.dart';
import 'package:snaptrack/splash_screen.dart';
import 'login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:overlay_support/overlay_support.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //TODO: add supabase url and anon key to .env file
  await Supabase.initialize(
      url: 'https://alsjhtogwmbcfwwpfgam.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsc2podG9nd21iY2Z3d3BmZ2FtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NDg3NDIzNSwiZXhwIjoyMDAwNDUwMjM1fQ.L4ddvKCITNWrFx59O8P5seTrg9Jyg7V5NtK0R8CA2Ug');

  runApp(
    OverlaySupport(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) =>
                BinListNotifier(), // Initialize your BinListNotifier here
          ),
          ChangeNotifierProvider(create: (context) => ImageListNotifier()),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Login Signup App',
        home: const SplashPage(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ));
  }
}
