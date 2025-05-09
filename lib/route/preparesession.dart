import 'package:flutter/material.dart';
import 'package:sw_hackathon/UI/exercise_recommand.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Preparesession extends StatefulWidget {
  const Preparesession({super.key});

  @override
  State<Preparesession> createState() => _PreparesessionState();
}

class _PreparesessionState extends State<Preparesession> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
      ),
      body: Column(
        children: [
          ExerciseRecommand(uid: user!.uid)
        ],
      ),
    );
  }
}