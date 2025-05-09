import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sw_hackathon/UI/youtube.dart';

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
          'fitCare',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
        ),
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.account_circle)),
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
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/personalsetting');
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
            ],
          ),
        ),
      ),
    );
  }
}
