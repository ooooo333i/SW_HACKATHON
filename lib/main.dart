import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ 추가
import 'package:provider/provider.dart';
import 'package:sw_hackathon/route/recommand.dart';

import 'firebase_options.dart';
import 'package:sw_hackathon/providers/exercise_data.dart';
import 'package:sw_hackathon/UI/personalsetting.dart';
import 'package:sw_hackathon/UI/session.dart';
import 'package:sw_hackathon/route/home.dart';
import 'package:sw_hackathon/login/loginscreen.dart';
import 'package:sw_hackathon/login/profile.dart';
import 'package:sw_hackathon/route/preparesession.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ExerciseData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final uid = currentUser.uid;
        print("✅ 로그인된 사용자 UID: $uid");

        final exerciseData = Provider.of<ExerciseData>(context, listen: false);
        exerciseData.fetchRecommendedExercises(uid);
      } else {
        print("⚠️ 현재 로그인된 사용자가 없습니다.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/prepare':(context) =>const Preparesession(),
        '/session':(context)=>const Session(),
        '/personalsetting': (context) => const Personalsetting(),
        '/sign-in': (context) => const Loginscreen(),
        '/profile': (context) => const ProfilePage(),
        '/recommand':(context) => const Recommand(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 161, 198, 92)),
      ),
    );
  }
}
