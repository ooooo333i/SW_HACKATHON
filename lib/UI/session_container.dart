import 'package:flutter/material.dart';
class SessionContainer extends StatefulWidget {
  final String exerciseName;
  final Function(String, int) onSetChanged; // 콜백 추가

  const SessionContainer({
    super.key,
    required this.exerciseName,
    required this.onSetChanged,
  });

  @override
  State<SessionContainer> createState() => _SessionContainerState();
}

class _SessionContainerState extends State<SessionContainer> {
  int sets = 0;

  void _updateSets(int newSets) {
    setState(() {
      sets = newSets;
    });
    widget.onSetChanged(widget.exerciseName, sets); // 부모에 알림
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.exerciseName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (sets > 0) _updateSets(sets - 1);
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text("$sets세트", style: const TextStyle(fontSize: 16)),
                IconButton(
                  onPressed: () {
                    _updateSets(sets + 1);
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}