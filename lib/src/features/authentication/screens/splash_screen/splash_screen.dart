import 'package:flutter/material.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/images/splash_screen/loading.png',
              width: MediaQuery.of(context).size.width * 0.7),
          const SizedBox(height: 10),
          const CircularProgressIndicator(),
        ],
      )),
    );
  }
}
