import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sw_hackathon/UI/youtube.dart';
import 'package:sw_hackathon/UI/exercise_recommand.dart';
import 'package:sw_hackathon/UI/menu_container.dart';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  Expanded(
                    child: MenuContainer(
                      title: '운동\n추천받기',
                      description: '알맞은 맞춤 운동을 학습해보세요.',
                      icon: Icons.fitness_center,
                      onTap: () {
                        Navigator.pushNamed(context, '/recommand');
                      },
                    ),
                  ),
                  const SizedBox(width: 10), // 두 컨테이너 사이에 간격 추가
                  Expanded(
                    child: MenuContainer(
                      title: '운동\n시작하기',
                      description: '알맞은 루틴으로 운동해보세요.',
                      icon: Icons.directions_run,
                      onTap: () {
                        Navigator.pushNamed(context, '/prepare');
                      },
                    ),
                  ),
                ],
              ),
              MenuContainer(
                title: '개인정보 수정',
                description: '원활한 추천을 위해 정보를 알맞게 작성해주세요.',
                icon: Icons.settings_accessibility,
                onTap: () {
                  Navigator.pushNamed(context, '/personalsetting').then((_) {
                    setState(() {}); // 개인설정 페이지에서 돌아오면 setState로 리렌더링
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
