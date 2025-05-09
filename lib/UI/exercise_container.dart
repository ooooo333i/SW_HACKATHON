import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseContainer extends StatefulWidget {
  const ExerciseContainer({super.key});

  @override
  State<ExerciseContainer> createState() => _ExerciseContainerState();
}

class _ExerciseContainerState extends State<ExerciseContainer> {
  late Future<Map<String, String>?> exercise;

  @override
  void initState() {
    super.initState();
    exercise = fetchRandomExercise();
  }

  Future<Map<String, String>?> fetchRandomExercise() async {
    try {
      // Firestore에서 'exercise_list' 컬렉션을 가져오기
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('exercise_list').get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      // 데이터를 필터링하여 'name', 'description', 'youtube_link' 필드를 가진 문서만 처리
      List<Map<String, String>> exercises = snapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['name'] is String &&
                data['description'] is String &&
                data['youtube_link'] is String; // youtube_link도 String 타입이어야 함
          })
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'name': data['name'] as String,
              'description': data['description'] as String,
              'youtube_link': data['youtube_link'] as String,  // youtube_link 추가
            };
          })
          .toList();

      if (exercises.isEmpty) {
        return null;
      }

      // 랜덤으로 운동 선택
      final random = Random();
      final selected = exercises[random.nextInt(exercises.length)];
      return selected;
    } catch (e) {
      print('🔥 Error fetching exercise: $e');
      return null;
    }
  }

  void showYoutubePlayerFromUrl(BuildContext context, String youtubeUrl) {
    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
    if (videoId == null) return;

    YoutubePlayerController controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(autoPlay: true),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: YoutubePlayer(
          controller: controller,
          showVideoProgressIndicator: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>?>( // 타입을 맞추기 위해 Map<String, String>으로 지정
      future: exercise,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Text('운동 정보를 불러올 수 없습니다.');
        } else {
          final exerciseData = snapshot.data!;
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseData['name']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exerciseData['description']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    icon: Icon(Icons.play_circle),
                    onPressed: () {
                      showYoutubePlayerFromUrl(
                        context,
                        exerciseData['youtube_link']!,  // Firestore에서 가져온 youtube_link 사용
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}