import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sw_hackathon/UI/youtube.dart';
import 'package:sw_hackathon/UI/exercise_recommand.dart';
import 'package:horizontal_week_calendar/horizontal_week_calendar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime selectedDate = DateTime.now(); // 초기 선택 날짜

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = today.add(Duration(days: 7 - today.weekday));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'fitCare',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/prepare');
          },
          icon: Icon(Icons.play_arrow),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                Navigator.pushNamed(context, '/sign-in');
              } else {
                Navigator.pushNamed(context, '/profile');
              }
            },
            icon: Icon(Icons.perm_identity),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              HorizontalWeekCalendar(
                minDate: startOfWeek,
                maxDate: endOfWeek,
                initialDate: today,
                showTopNavbar: false,
                onDateChange: (date) {
                  setState(() {
                    selectedDate = date; // 날짜 변경 시 setState로 새로고침
                  });
                },
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/personalsetting').then((_) {
                    setState(() {}); // 개인설정 페이지에서 돌아오면 setState로 리렌더링
                  });
                },
                icon: Icon(Icons.settings_accessibility),
              ),
              IconButton(
                icon: Icon(Icons.play_circle),
                onPressed: () {
                  showYoutubePlayerFromUrl(
                    context,
                    "https://www.youtube.com/watch?v=pdojBp7aoBc",
                  );
                },
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.add_circle_rounded),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.add_circle_rounded),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.add_circle_rounded),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.add_circle_rounded),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.add_circle_rounded),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.add_circle_rounded),
              ),
              // ExerciseRecommand 위젯을 Key를 사용해서 새로 그리게 하기
              if (user != null)
                ExerciseRecommand(
                  uid: user.uid,
                  key: ValueKey(selectedDate.toIso8601String()), // 날짜 변경 시 새로 그려짐
                ),
            ],
          ),
        ),
      ),
    );
  }
}