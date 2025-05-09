import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:horizontal_week_calendar/horizontal_week_calendar.dart';
import 'package:sw_hackathon/UI/menu_container.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime selectedDate = DateTime.now();

  Future<Map<String, dynamic>?> fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = today.add(Duration(days: 7 - today.weekday));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'fitCare',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/prepare');
          },
          icon: const Icon(Icons.play_arrow),
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
            icon: const Icon(Icons.perm_identity),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              
              const SizedBox(height: 20),
              HorizontalWeekCalendar(
                minDate: startOfWeek,
                maxDate: endOfWeek,
                initialDate: today,
                showTopNavbar: false,
                onDateChange: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
              FutureBuilder<Map<String, dynamic>?>(
                future: fetchUserInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Text("개인정보를 불러올 수 없습니다.");
                  }

                  final data = snapshot.data!;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    color: Colors.grey.shade100,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '역할: ${data["role"] ?? "없음"}\n'
                        '성별: ${data["gender"] ?? "없음"}\n'
                        '나이: ${data["age"] ?? "없음"}\n'
                        '장애 등급: ${data["disabilityLevel"] ?? "없음"}\n'
                        '장애 분류: ${data["disabilityType"] ?? "없음"}\n'
                        '척수장애 세부: ${data["spinalDetail"] ?? "해당 없음"}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: MenuContainer(
                      title: '운동\n시작하기',
                      description: '알맞은 루틴으로 운동해보세요.',
                      icon: Icons.directions_run,
                      onTap: () {
                        Navigator.pushNamed(context, '/prevsession');
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
                    setState(() {}); // 돌아와서 새로고침
                  });
                },
              ),
              MenuContainer(
                title: '통계 보기',
                description: '본인의 운동 기록을 돌아보아요.',
                icon: Icons.bar_chart,
                onTap: () {
                  Navigator.pushNamed(context, '/statistics').then((_) {
                    setState(() {});
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