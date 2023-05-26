//supabase auth class flutter
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthenticator {
  //TODO: store in .env file
  static const String supabaseUrl = 'https://alsjhtogwmbcfwwpfgam.supabase.co';
  static const String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsc2podG9nd21iY2Z3d3BmZ2FtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NDg3NDIzNSwiZXhwIjoyMDAwNDUwMjM1fQ.L4ddvKCITNWrFx59O8P5seTrg9Jyg7V5NtK0R8CA2Ug';

  static final SupabaseClient client = SupabaseClient(supabaseUrl, supabaseKey);

  static Future<void> signUp({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    final AuthResponse res = await client.auth.signUp(
      email: email,
      password: password,
    );

    final Session? session = res.session;
    final User? user = res.user;

    if (session != null && user != null) {
      print('User successfully registered!');
    } else {
      //log error
      throw Exception('User registration failed!');
    }
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    final AuthResponse res = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final Session? session = res.session;
    final User? user = res.user;

    if (session != null && user != null) {
      print('User successfully logged in!');
    } else {
      throw Exception('User login failed!');
    }
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}
