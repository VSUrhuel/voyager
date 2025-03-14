import 'package:voyager/src/repository/authentication-repository/supabase_auth_repository.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = AuthenticationRepository();
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/images/splash_screen/loading.png',
              width: MediaQuery.of(context).size.width * 0.7),
          const SizedBox(height: 10),
          const CircularProgressIndicator(),
          ElevatedButton(
            onPressed: () async {
              await auth.logout();
            },
            child: const Text('Go to Login'),
          ),
        ],
      )),
    );
  }
}
