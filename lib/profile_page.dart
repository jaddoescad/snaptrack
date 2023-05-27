import 'package:flutter/material.dart';
import 'package:snaptrack/login_page.dart';
import 'package:snaptrack/supabase/auth.dart';
import 'package:snaptrack/utilities/snackbar.dart';
import 'package:supabase/supabase.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfile> userProfileFuture;
  final SupabaseInstance supabaseClient = SupabaseInstance();

  @override
  void initState() {
    super.initState();

    try {
      userProfileFuture = _fetchUserProfile();
    } catch (e) {
      context.showErrorSnackBar(message: 'Error fetching user profile');
    }
  }

  Future<UserProfile> _fetchUserProfile() async {
    final user = supabaseClient.supabase.auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final response = await supabaseClient.supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    if (response != null) {
      return UserProfile(
        name: response['full_name'] as String,
        email: user.email!,
      );
    }
    throw Exception('Error fetching user profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<UserProfile>(
        future: userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final profile = snapshot.data!;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      child: Text(
                        profile.name[0].toUpperCase(),
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(profile.email, style: TextStyle(fontSize: 16)),
                    SizedBox(height: 32),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement contact us action
                          },
                          child: Text('Contact us'),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            supabaseClient.supabase.auth.signOut();
                            //pushreplacement to login page
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: Text('Logout'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class UserProfile {
  final String name;
  final String email;

  UserProfile({required this.name, required this.email});
}
