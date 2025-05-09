import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  Map<String, int> weeklySetData = {
    '월': 0,
    '화': 0,
    '수': 0,
    '목': 0,
    '금': 0,
    '토': 0,
    '일': 0,
  };

  final List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  int totalSets = 0;
  int totalSessions = 0;
  int longestStreak = 0;

  @override
  void initState() {
    super.initState();
    fetchAllSessionData();
  }

  Future<void> fetchAllSessionData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .get();

    Map<String, int> tempWeekly = {
      '월': 0, '화': 0, '수': 0, '목': 0, '금': 0, '토': 0, '일': 0,
    };

    Map<String, int> dateToSet = {}; // yyyy-MM-dd → 세트 수

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
      final exercises = List<Map<String, dynamic>>.from(data['exercises'] ?? []);

      if (timestamp == null) continue;

      final weekday = DateFormat('E', 'ko_KR').format(timestamp);
      final dateKey = DateFormat('yyyy-MM-dd').format(timestamp);

      int sets = 0;
      for (final e in exercises) {
        sets += ((e['sets'] ?? 0) as num).toInt();
      }

      // 주간 세트 요약
      if (tempWeekly.containsKey(weekday)) {
        tempWeekly[weekday] = tempWeekly[weekday]! + sets;
      }

      // 날짜별 세트 수 기록
      dateToSet[dateKey] = (dateToSet[dateKey] ?? 0) + sets;
    }

    // 총 세션 수
    final allDates = dateToSet.keys.toList();
    allDates.sort(); // 날짜순 정렬

    int streak = 0;
    int maxStreak = 0;
    DateTime? prev;

    for (final dateStr in allDates) {
      final current = DateTime.parse(dateStr);
      if (prev == null || current.difference(prev).inDays == 1) {
        streak++;
      } else if (current.difference(prev).inDays == 0) {
        // 같은 날이면 유지
      } else {
        streak = 1;
      }
      maxStreak = maxStreak < streak ? streak : maxStreak;
      prev = current;
    }

    setState(() {
      weeklySetData = tempWeekly;
      totalSets = dateToSet.values.fold(0, (sum, e) => sum + e);
      totalSessions = snapshot.docs.length;
      longestStreak = maxStreak;
    });
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('운동 통계')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: weeklySetData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSummaryCard("총 세트 수", "$totalSets 세트", Icons.fitness_center, Colors.green),
                    _buildSummaryCard("총 세션 수", "$totalSessions 회", Icons.calendar_today, Colors.blue),
                    _buildSummaryCard("연속 운동일", "$longestStreak 일", Icons.local_fire_department, Colors.orange),
                    const SizedBox(height: 30),
                    const Text("요일별 운동량", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    AspectRatio(
                      aspectRatio: 1.6,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  int index = value.toInt();
                                  if (index >= 0 && index < weekdays.length) {
                                    return Text(weekdays[index]);
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                weekdays.length,
                                (index) {
                                  String day = weekdays[index];
                                  double sets = (weeklySetData[day] ?? 0).toDouble();
                                  return FlSpot(index.toDouble(), sets);
                                },
                              ),
                              isCurved: true,
                              color: Colors.teal,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.2)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}