import 'package:flutter/material.dart';
import 'package:sw_hackathon/route/home.dart';
import 'package:sw_hackathon/login/loginscreen.dart';
import 'package:sw_hackathon/login/profile.dart';

void main() {
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/sign-in': (context) => const Loginscreen(),
        '/profile': (context) => const ProfilePage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 145, 189, 64)),
      ),
    );
  }
}
