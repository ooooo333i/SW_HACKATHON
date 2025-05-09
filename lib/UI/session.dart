import 'package:flutter/material.dart';
import 'package:sw_hackathon/route/preparesession.dart'; // ExerciseSet import

class Session extends StatefulWidget {
  const Session({super.key});

  @override
  State<Session> createState() => _SessionState();
}

class _SessionState extends State<Session> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // arguments 받기
    final List<ExerciseSet> exercises =
        ModalRoute.of(context)!.settings.arguments as List<ExerciseSet>;

    final currentExercise = exercises[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("운동 세션"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '현재 운동: ${currentExercise.name}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              '총 세트 수: ${currentExercise.sets}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),

            // 진척도 표시
            LinearProgressIndicator(
              value: (currentIndex + 1) / exercises.length,
              minHeight: 10,
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (currentIndex < exercises.length - 1) {
                    setState(() {
                      currentIndex++;
                    });
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("완료"),
                        content: const Text("모든 운동을 완료했습니다!"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("확인"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text(
                  currentIndex < exercises.length - 1
                      ? "다음 운동으로"
                      : "운동 종료",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}