import 'package:flutter/material.dart';
import 'package:sw_hackathon/UI/exercise_recommand.dart';

class Recommand extends StatefulWidget {
  const Recommand({super.key});

  @override
  State<Recommand> createState() => _RecommandState();
}

class _RecommandState extends State<Recommand> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '추천 운동',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
        ),
        
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              ExerciseRecommand(),
            ],
          ),
        ),
      ),
    );
  }
}