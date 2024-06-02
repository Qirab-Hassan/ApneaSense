import 'package:apneasense/firebase_options.dart';
import 'package:apneasense/pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //Root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ApneaSense',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff1B9CE4),
          ),
          textTheme: const TextTheme(
              headlineLarge: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1B9CE4)))),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
