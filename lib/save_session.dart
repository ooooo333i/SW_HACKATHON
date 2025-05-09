import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sw_hackathon/route/preparesession.dart';

Future<void> saveSessionData(List<ExerciseSet> exercises) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('User not logged in');
    return;
  }

  // 세션 데이터를 Firestore에 저장
  try {
    final uid = user.uid;
    final sessionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .doc();  // 새로운 세션 문서 생성

    // 세션 정보로 데이터를 저장
    await sessionRef.set({
      'timestamp': FieldValue.serverTimestamp(),
      'exercises': exercises.map((exercise) => {
        'name': exercise.name,
        'sets': exercise.sets,
      }).toList(),
    });

    print('Session data saved successfully');
  } catch (e) {
    print('Error saving session data: $e');
  }
}