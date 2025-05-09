import 'package:flutter/material.dart';
import 'package:sw_hackathon/route/preparesession.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sw_hackathon/save_session.dart';

class Session extends StatefulWidget {
  const Session({super.key});

  @override
  State<Session> createState() => _SessionState();
}

class _SessionState extends State<Session> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  int currentSet = 1;
  late ValueNotifier<double> progressNotifier;
  late List<ExerciseSet> exercises;
  late AnimationController _controller;

  void _updateProgressWithAnimation(double targetValue) {
    double startValue = progressNotifier.value;
    double currentValue = startValue;
    const totalSteps = 20; // 60 FPS에 맞춰서
    const duration = Duration(milliseconds: 1500);
    final stepDuration = duration.inMilliseconds ~/ totalSteps;
    int currentStep = 0;

    void animate() {
      if (currentStep < totalSteps && mounted) {
        currentStep++;
        currentValue = startValue + (targetValue - startValue) * (currentStep / totalSteps);
        progressNotifier.value = currentValue;
        Future.delayed(Duration(milliseconds: stepDuration), animate);
      }
    }

    animate();
  }

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

    if (args == null || args is! List || args.isEmpty) {
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

    // args를 ExerciseSet 리스트로 변환
    exercises = args.map<ExerciseSet>((e) {
      if (e is ExerciseSet) return e;
      return ExerciseSet(name: e['name'], sets: e['sets'] ?? 1);
    }).toList();

    final totalExercises = exercises.length;
    final currentExercise = exercises[currentIndex];
    final totalSets = currentExercise.sets;

    return Scaffold(
      appBar: AppBar(
        title: const Text("운동 세션"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(FontAwesomeIcons.heartPulse),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 진척도
            Center(
              child: DashedCircularProgressBar.square(
                dimensions: 150,
                progress: progressNotifier.value,
                maxProgress: 1.0,
                corners: StrokeCap.round,
                foregroundColor: Colors.green,
                backgroundColor: Colors.grey.shade300,
                backgroundStrokeWidth: 2,
                foregroundStrokeWidth: 12,
                backgroundGapSize: 4,
                backgroundDashSize: 4,
                foregroundGapSize: 4,
                foregroundDashSize: 4,
                seekSize: 8,
                seekColor: Colors.green,
                startAngle: 270,
                sweepAngle: 360,
                child: Center(
                  child: ValueListenableBuilder<double>(
                    valueListenable: progressNotifier,
                    builder: (context, value, _) => Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 현재 운동 카드
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

            // 버튼
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
              onPressed: () async {
                if (currentSet < currentExercise.sets) {
                  setState(() {
                    currentSet++;
                  });
                  final totalSets = currentExercise.sets;
                  final totalExercises = exercises.length;
                  final newProgress = ((currentIndex * totalSets) + currentSet) / (totalExercises * totalSets);
                  _updateProgressWithAnimation(newProgress);
                } else if (currentIndex < totalExercises - 1) {
                  setState(() {
                    currentIndex++;
                    currentSet = 1;
                  });
                  final totalSets = exercises[currentIndex].sets;
                  final totalExercises = exercises.length;
                  final newProgress = ((currentIndex * totalSets) + currentSet) / (totalExercises * totalSets);
                  _updateProgressWithAnimation(newProgress);
                } else {
                  // 세션 종료
                  await saveSessionData(exercises);
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("운동 완료"),
                      content: const Text("모든 운동 세트를 완료했습니다!"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/'),
                          child: const Text("확인"),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}