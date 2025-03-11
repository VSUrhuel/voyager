import 'package:voyager/src/utils/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import the SupabaseAuthRepository
import 'package:supabase_flutter/supabase_flutter.dart';

int initScreen = 0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://zyqxnzxudwofrlvdzbvf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5cXhuenh1ZHdvZnJsdmR6YnZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE3MDQ1NjEsImV4cCI6MjA1NzI4MDU2MX0.Sbj42rsklbYOk0ug5rjswXefwlksX8MwkjFq5T6DH0E',
  );

  //Get.put(SupabaseAuthRepository()); // Replace FirebaseAuth with SupabaseAuth

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = prefs.getInt("initScreen") ?? 0;
  await prefs.setInt("initScreen", 1);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Voyager',
      theme: CS3AppTheme.lightTheme,
      darkTheme: CS3AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      //initialRoute: initScreen == 0 ? MRoutes.onBoarding : MRoutes.welcome,
      // getPages: MAppRoutes.pages,
    );
  }
}
