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
  Map<String, int> weeklySetData = {}; // {월: 4, 화: 3, 수: 0, ...}
  final List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  void initState() {
    super.initState();
    fetchWeeklyData();
  }

  Future<void> fetchWeeklyData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // 월요일
    final userId = user.uid;

    Map<String, int> tempData = {};

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final weekday = DateFormat('E', 'ko_KR').format(date); // 예: 월, 화, 수

      final docSnapshot = await FirebaseFirestore.instance
          .collection('exerciseRecords')
          .doc(userId)
          .collection('daily')
          .doc(formattedDate)
          .get();

      int totalSets = 0;
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final exercises = List<Map<String, dynamic>>.from(data?['exercises'] ?? []);
        for (final e in exercises) {
          totalSets += (e['sets'] ?? 0) as int;
        }
      }

      tempData[weekday] = totalSets;
    }

    setState(() {
      weeklySetData = tempData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('운동 통계')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: weeklySetData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : LineChart(
                LineChartData(
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
                      color: Colors.blue,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
