import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseRecommand extends StatefulWidget {
  const ExerciseRecommand({super.key});

  @override
  State<ExerciseRecommand> createState() => _ExerciseRecommandState();
}

class _ExerciseRecommandState extends State<ExerciseRecommand> {
  late Future<List<Map<String, String>>> recommendedExercises;

  @override
  void initState() {
    super.initState();
    recommendedExercises = fetchRecommendedExercises();
  }

  Future<List<Map<String, String>>> fetchRecommendedExercises() async {
    try {
      final userAge = "10대";
      final userGender = "M"; // 남성
      final userDisability = "시각장애";
      final userGrade = "1등급";

      // exercise_data에서 조건에 맞는 운동 추천 데이터 가져오기
      final exerciseDataSnap = await FirebaseFirestore.instance
          .collection('exercise_data')
          .where('AGRDE_FLAG_NM', isEqualTo: userAge)
          .where('SEXDSTN_FLAG_CD', isEqualTo: userGender)
          .where('TROBL_TY_NM', isEqualTo: userDisability)
          .where('TROBL_GRAD_NM', isEqualTo: userGrade)
          .get();

      final recommendedNames = exerciseDataSnap.docs
          .map((doc) => doc.data()['RECOMEND_MVM_NM']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toSet();

      if (recommendedNames.isEmpty) return [];

      // exercise_list에서 운동 정보 가져오기
      final exerciseListSnap = await FirebaseFirestore.instance
          .collection('exercise_list')
          .get();

      // exercise_list를 Map으로 변환하여 이름으로 빠르게 조회할 수 있도록 함
      final exerciseMap = {
        for (var doc in exerciseListSnap.docs)
          doc['name']: {
            'name': doc['name'],
            'description': doc['description'],
            'youtube_link': doc['youtube_link'],
          }
      };

      // 추천된 운동 이름에 맞는 운동 정보를 가져오기
      final exercises = recommendedNames
          .where((name) => exerciseMap.containsKey(name))
          .map((name) {
            final exercise = exerciseMap[name]!;
            return {
              'name': exercise['name'] as String,
              'description': exercise['description'] as String,
              'youtube_link': exercise['youtube_link'] as String,
            };
          })
          .toList();

      return exercises;
    } catch (e) {
      print("🔥 오류 발생: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: recommendedExercises,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text('추천 운동을 불러올 수 없습니다.'));
        }

        final exercises = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true, // ListView의 크기를 적절히 조정
          physics: const NeverScrollableScrollPhysics(), // 부모가 스크롤을 처리하도록 설정
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];

            // YouTube video ID를 추출하여 플레이어를 만듬
            final videoId = YoutubePlayer.convertUrlToId(exercise['youtube_link']!);
            final YoutubePlayerController _controller = YoutubePlayerController(
              initialVideoId: videoId!,
              flags: const YoutubePlayerFlags(autoPlay: false),
            );

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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exercise['description']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    // YouTube Player 컨테이너 내에서 바로 표시
                    Container(
                      height: 200, // YouTube 플레이어 높이 설정
                      child: YoutubePlayer(
                        controller: _controller,
                        showVideoProgressIndicator: true,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}