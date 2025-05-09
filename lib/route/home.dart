import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SW_HACKATHON',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
        ),
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.add_box)),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add_box))],
      ),
    );
  }
}
