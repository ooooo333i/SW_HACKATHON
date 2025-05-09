import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sw_hackathon/UI/exercise_recommand.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sw_hackathon/providers/exercise_data.dart';
import 'package:sw_hackathon/UI/session_container.dart';

class Preparesession extends StatefulWidget {
  const Preparesession({super.key});

  @override
  State<Preparesession> createState() => _PreparesessionState();
}

class ExerciseSet {
  final String name;
  int sets;

  ExerciseSet({required this.name, this.sets = 1});
}

class _PreparesessionState extends State<Preparesession> {
  List<ExerciseSet> sessionExercises = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Future.microtask(() async {
        if (!mounted) return; // ✅ context 사용 전 확인
        await Provider.of<ExerciseData>(
          context,
          listen: false,
        ).fetchRecommendedExercises(user.uid);
      });
    }
  }

  void updateExercise(String name, int sets) {
    final index = sessionExercises.indexWhere((e) => e.name == name);
    if (index != -1) {
      sessionExercises[index].sets = sets;
    } else {
      sessionExercises.add(ExerciseSet(name: name, sets: sets));
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendedList =
        context.watch<ExerciseData>().recommendedExerciseNames;

    return Scaffold(
      appBar: AppBar(title: const Text("운동 준비")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/session',
                  arguments: sessionExercises,
                );
              },
              child: const Text('Start Session'),
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 10),

            // 운동 추천 리스트 출력
            if (recommendedList.isEmpty)
              const Text("추천 운동이 없습니다.")
            else
              Column(
                children:
                    recommendedList
                        .map(
                          (name) => SessionContainer(
                            exerciseName: name,
                            onSetChanged: updateExercise,
                          ),
                        )
                        .toList(),
              ),
            // 기존 추천 위젯이 있다면 유지
            //ExerciseRecommand(),
          ],
        ),
      ),
    );
  }
}
