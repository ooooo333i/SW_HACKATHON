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
  final List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  Map<String, int> weeklySetData = {
    '월': 0, '화': 0, '수': 0, '목': 0, '금': 0, '토': 0, '일': 0
  };
  Map<String, int> exerciseCounts = {}; // 운동 이름별 빈도수
  int totalSessions = 0;
  int totalSets = 0;

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

    Map<String, int> tempDayData = {
      '월': 0, '화': 0, '수': 0, '목': 0, '금': 0, '토': 0, '일': 0
    };
    Map<String, int> tempExerciseCounts = {};
    int totalSetCounter = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
      final exercises = List<Map<String, dynamic>>.from(data['exercises'] ?? []);

      if (timestamp == null) continue;
      final weekday = DateFormat('E', 'ko_KR').format(timestamp);

      for (final e in exercises) {
        final name = e['name'] ?? '기타';
        final sets = (e['sets'] ?? 0) as int;
        totalSetCounter += sets;
        tempDayData[weekday] = (tempDayData[weekday] ?? 0) + sets;
        tempExerciseCounts[name] = (tempExerciseCounts[name] ?? 0) + sets;
      }
    }

    setState(() {
      totalSessions = snapshot.docs.length;
      totalSets = totalSetCounter;
      weeklySetData = tempDayData;
      exerciseCounts = tempExerciseCounts;
    });
  }

  Widget _buildSummaryCard(String label, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.green),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.black54)),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyLineChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
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
                (i) => FlSpot(i.toDouble(), (weeklySetData[weekdays[i]] ?? 0).toDouble()),
              ),
              isCurved: true,
              color: Colors.blue,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseFrequencyChart() {
    final sorted = exerciseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(sorted.length, (i) {
            final e = sorted[i];
            return BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(toY: e.value.toDouble(), color: Colors.orange)],
            );
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  int idx = value.toInt();
                  if (idx < sorted.length) {
                    return Text(sorted[idx].key, style: TextStyle(fontSize: 10));
                  }
                  return Text('');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('운동 통계')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard("총 세션", "$totalSessions", Icons.calendar_today),
                _buildSummaryCard("총 세트 수", "$totalSets", Icons.fitness_center),
              ],
            ),
            const SizedBox(height: 30),
            const Text("요일별 세트 수", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildWeeklyLineChart(),
            const SizedBox(height: 30),
            const Text("운동 종류별 빈도 수", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildExerciseFrequencyChart(),
          ],
        ),
      ),
    );
  }
}