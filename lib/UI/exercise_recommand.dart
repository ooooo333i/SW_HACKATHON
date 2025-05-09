import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseRecommand extends StatefulWidget {
  final String uid;

  const ExerciseRecommand({super.key, required this.uid});

  @override
  State<ExerciseRecommand> createState() => _ExerciseRecommandState();
}

class _ExerciseRecommandState extends State<ExerciseRecommand> {
  late Future<List<Map<String, String>>> recommendedExercises;

  @override
  void initState() {
    super.initState();
    recommendedExercises = fetchRecommendedExercises(widget.uid);
  }

  Future<List<Map<String, String>>> fetchRecommendedExercises(String uid) async {
    try {
      // 🔹 사용자 정보 불러오기
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) return [];

      final userData = userDoc.data()!;
      final userAge = _convertAgeToRange(userData['age']);
      final userGender = _convertGender(userData['gender']);
      final userDisability = userData['disabilityType'];
      final userGrade = userData['disabilityLevel'];

      // 🔹 조건에 맞는 운동 추천 데이터 불러오기
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

      // 🔹 전체 운동 목록에서 해당 운동들의 정보만 추출
      final exerciseListSnap = await FirebaseFirestore.instance
          .collection('exercise_list')
          .get();

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

  String _convertAgeToRange(dynamic age) {
    if (age is int) {
      if (age < 20) return '10대';
      if (age < 30) return '20대';
      if (age < 40) return '30대';
      if (age < 50) return '40대';
      return '50대이상';
    }
    return '기타';
  }

  String _convertGender(String gender) {
    return gender == "남성" ? "M" : "F";
  }

  void showYoutubePlayerFromUrl(BuildContext context, String youtubeUrl) {
    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
    if (videoId == null) return;

    YoutubePlayerController controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false),
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
  }
}