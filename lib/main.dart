import 'package:firebase_core/firebase_core.dart';
import 'package:voyager/firebase_options.dart';
import 'package:voyager/src/repository/authentication_repository_firebase/authentication_repository.dart';
import 'package:voyager/src/utils/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/routing/app_routes.dart';
import 'package:voyager/src/routing/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

int initScreen = 0;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );


  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Initialize SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = prefs.getInt("initScreen") ?? 0;
  await prefs.setInt("initScreen", 1);

  // Initialize deep links
  // Ensure navigation happens after the first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.put(FirebaseAuthenticationRepository());
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure initialization happens only after GetMaterialApp is built
    Get.put(FirebaseAuthenticationRepository());

    return GetMaterialApp(
      title: 'Voyager',
      theme: VoyagerTheme.lightTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      // initialRoute: MRoutes.onBoarding,
      initialRoute: initScreen == 0 ? MRoutes.onBoarding : MRoutes.welcome,
      getPages: MAppRoutes.pages,
    );
  }
}
