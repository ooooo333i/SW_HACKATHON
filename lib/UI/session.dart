import 'package:flutter/material.dart';
import 'package:sw_hackathon/route/preparesession.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';

class Session extends StatefulWidget {
  const Session({super.key});

  @override
  State<Session> createState() => _SessionState();
}

class _SessionState extends State<Session> {
  int currentIndex = 0;
  int currentSet = 1;
  late ValueNotifier<double> progressNotifier;

  @override
  void initState() {
    super.initState();
    progressNotifier = ValueNotifier(0.0);
  }

  @override
  void dispose() {
    progressNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! List<ExerciseSet> || args.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("운동 세션")),
        body: const Center(
          child: Text(
            "운동 항목이 없습니다.\n운동을 먼저 추가해주세요!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final List<ExerciseSet> exercises = args;
    final totalExercises = exercises.length;
    final currentExercise = exercises[currentIndex];
    final totalSets = currentExercise.sets;

    // 전체 세션 진척도: 전체 운동 개수 기준
    final overallProgress =
        ((currentIndex * totalSets) + currentSet) / (totalExercises * totalSets);
    progressNotifier.value = overallProgress;

    return Scaffold(
      appBar: AppBar(title: const Text("운동 세션")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 원형 진척도 표시
            Center(
              child: DashedCircularProgressBar.square(
                dimensions: 150,
                valueNotifier: progressNotifier,
                maxProgress: 1.0,
                foregroundColor: Colors.green,
                backgroundColor: Colors.grey.shade300,
                animation: true,
                startAngle: 270,
                sweepAngle: 360,
                backgroundStrokeWidth: 2,
                foregroundStrokeWidth: 12,
                backgroundGapSize: 2,
                backgroundDashSize: 2,
                seekSize: 8,
                child: Center(
                  child: Text(
                    '${(overallProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 운동 카드
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentExercise.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '세트 $currentSet / ${currentExercise.sets}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              icon: Icon(
                currentIndex < totalExercises - 1 ||
                        currentSet < currentExercise.sets
                    ? Icons.fitness_center
                    : Icons.check,
              ),
              label: Text(currentIndex < totalExercises - 1 ||
                      currentSet < currentExercise.sets
                  ? '다음 세트'
                  : '운동 종료'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  if (currentSet < currentExercise.sets) {
                    currentSet++; // 다음 세트
                  } else if (currentIndex < totalExercises - 1) {
                    currentIndex++; // 다음 운동
                    currentSet = 1;
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("운동 완료"),
                        content: const Text("모든 운동 세트를 완료했습니다!"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("확인"),
                          ),
                        ],
                      ),
                    );
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}