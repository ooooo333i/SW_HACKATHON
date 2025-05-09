import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:sw_hackathon/providers/exercise_data.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseRecommand extends StatelessWidget {
  const ExerciseRecommand({super.key});

  Future<List<Map<String, String>>> fetchExerciseDetails(List<String> recommendedNames) async {
    try {
      if (recommendedNames.isEmpty) {
        print("❌ 추천 운동 이름 없음");
        return [];
      }

      final exerciseListSnap = await FirebaseFirestore.instance.collection('exercise_list').get();

      final exerciseMap = {
        for (var doc in exerciseListSnap.docs)
          doc['name']: {
            'name': doc['name'],
            'description': doc['description'],
            'youtube_link': doc['youtube_link'],
          }
      };

      final exercises = recommendedNames
          .where((name) => exerciseMap.containsKey(name))
          .map((name) {
            final e = exerciseMap[name]!;
            return {
              'name': e['name'].toString(),
              'description': e['description'].toString(),
              'youtube_link': e['youtube_link'].toString(),
            };
          })
          .toList();

      return exercises;
    } catch (e) {
      print("🔥 운동 상세 정보 로딩 중 오류 발생: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseData>(
      builder: (context, exerciseData, _) {
        return FutureBuilder<List<Map<String, String>>>(
          future: fetchExerciseDetails(exerciseData.recommendedExerciseNames),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(child: Text('추천 운동을 불러올 수 없습니다.'));
            }

            final exercises = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
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
                          exercise['name']!,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise['description']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        YoutubePlayer(
                          controller: YoutubePlayerController(
                            initialVideoId: YoutubePlayer.convertUrlToId(exercise['youtube_link']!)!,
                            flags: const YoutubePlayerFlags(autoPlay: false),
                          ),
                          showVideoProgressIndicator: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}