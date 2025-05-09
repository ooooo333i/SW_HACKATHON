import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class Loginscreen extends StatelessWidget {
  const Loginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];

    return SignInScreen(
      providers: providers,
      actions: [
        AuthStateChangeAction<UserCreated>((context, state) {
          Navigator.pushReplacementNamed(context, '/profile');
        }),
        AuthStateChangeAction<SignedIn>((context, state) {
          Navigator.pushReplacementNamed(context, '/profile');
        }),
      ],
    );
  }
}
 