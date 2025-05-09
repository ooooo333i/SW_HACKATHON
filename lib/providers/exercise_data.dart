import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ExerciseData extends ChangeNotifier {
  List<String> _recommendedExerciseNames = [];

  // 외부에서 읽기 위한 getter
  List<String> get recommendedExerciseNames => _recommendedExerciseNames;

  // 외부에서 수동 설정도 가능
  void setRecommendedExercises(List<String> names) {
    _recommendedExerciseNames = names;
    notifyListeners();
  }

  // Firestore에서 추천 운동 이름을 불러와 저장
  Future<void> fetchRecommendedExercises(String uid) async {
    print("📌 [fetchRecommendedExercises] 시작");
    print("👉 입력된 uid: $uid");

    try {
      // 🔍 유저 문서 확인
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid);
      print("📄 유저 문서 경로: ${userDocRef.path}");

      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        print("❌ 유저 문서가 존재하지 않음");
        _recommendedExerciseNames = [];
        notifyListeners();
        return;
      }

      final userData = userDoc.data()!;
      print("✅ 유저 데이터 로딩 성공: $userData");

      // 🔧 사용자 정보 변환
      final userAge = _convertAgeToRange(userData['age']);
      final userGender = _convertGender(userData['gender']);
      final userDisability = userData['disabilityType'];
      final userGradeRaw = userData['disabilityLevel'];
      final userGrade = _normalizeDisabilityLevel(userGradeRaw);

      print("🔄 변환된 정보:");
      print("   • 나이: $userAge");
      print("   • 성별: $userGender");
      print("   • 장애유형: $userDisability");
      print("   • 장애등급: $userGrade");

      // 🔍 조건에 맞는 운동 필터링
      final exerciseDataSnap =
          await FirebaseFirestore.instance
              .collection('exercise_data')
              .where('AGRDE_FLAG_NM', isEqualTo: userAge)
              .where('SEXDSTN_FLAG_CD', isEqualTo: userGender)
              .where('TROBL_TY_NM', isEqualTo: userDisability)
              .where('TROBL_GRAD_NM', isEqualTo: userGrade)
              .get();

      print("📊 필터링된 운동 문서 수: ${exerciseDataSnap.docs.length}");

      final recommendedNames =
          exerciseDataSnap.docs
              .map((doc) => doc.data()['RECOMEND_MVM_NM']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList();

      print("🎯 최종 추천 운동 이름 목록:");
      for (final name in recommendedNames) {
        print("   • $name");
      }

      _recommendedExerciseNames = recommendedNames;
      notifyListeners();
      print("✅ 추천 운동 저장 및 notifyListeners 완료");
    } catch (e, stackTrace) {
      print("🔥 예외 발생: $e");
      print("📍 StackTrace:\n$stackTrace");
      _recommendedExerciseNames = [];
      notifyListeners();
    }

    print("📌 [fetchRecommendedExercises] 종료");
  }

  // 유틸 함수들

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

  String _normalizeDisabilityLevel(String level) {
    level = level.replaceAll('급', '등급');
    level = level.replaceAll('완전마비', '완전 마비');
    level = level.replaceAll('불완전마비', '불완전 마비');
    return level;
  }
}
