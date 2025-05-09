import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Prevsession extends StatefulWidget {
  const Prevsession({super.key});

  @override
  State<Prevsession> createState() => _PrevsessionState();
}

class _PrevsessionState extends State<Prevsession> {
  List<Map<String, dynamic>> previousSessions = [];

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      previousSessions = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    });
  }

  void startSession(List<Map<String, dynamic>> exercises) {
    final exerciseSets = exercises.map((e) {
      return {
        'name': e['name'] ?? '',
        'sets': e['sets'] ?? 1,
      };
    }).toList();

    Navigator.pushNamed(context, '/session', arguments: exerciseSets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("이전 세션")),
      body: previousSessions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: previousSessions.length,
              itemBuilder: (context, index) {
                final session = previousSessions[index];
                final exercises = List<Map<String, dynamic>>.from(session['exercises'] ?? []);
                final date = (session['timestamp'] as Timestamp?)?.toDate();
                final formattedDate = date != null
                    ? "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"
                    : "날짜 없음";

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text("세션 날짜: $formattedDate"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: exercises
                          .map((e) => Text("• ${e['name']} (${e['sets']}세트)"))
                          .toList(),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        startSession(exercises);
                      },
                      child: const Text("다시 시작"),
                    ),
                  ),
                );
              },
            ),
    );
  }
}