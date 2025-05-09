import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    );
  }
}
