//supabase auth class flutter
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInstance {
  final supabase = Supabase.instance.client;

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    final AuthResponse res =
        await supabase.auth.signUp(email: email, password: password, data: {
      'full_name': fullName,
    });

    final Session? session = res.session;
    final User? user = res.user;

    if (session != null && user != null) {
      print('User successfully registered!');
    } else {
      //log error
      throw Exception('User registration failed!');
    }
  }

 Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    final AuthResponse res = await supabase.auth.signInWithPassword(
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

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
