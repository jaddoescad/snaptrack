import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snaptrack/models/bin_list_notifier.dart';
import 'package:snaptrack/models/image_list_notifier.dart';
import 'package:snaptrack/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  //TODO: add supabase url and anon key to .env file
  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey:
          dotenv.env['SUPABASE_KEY']!); // Initialize Supabase with the API key

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
