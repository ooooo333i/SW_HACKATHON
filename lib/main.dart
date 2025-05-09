import 'package:flutter/material.dart';
import 'package:sw_hackathon/route/home.dart';
import 'package:sw_hackathon/login/loginscreen.dart';
import 'package:sw_hackathon/login/profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 플랫폼별 초기화 정보
  );
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
