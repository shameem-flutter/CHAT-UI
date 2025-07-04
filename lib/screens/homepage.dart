import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: signOut, icon: Icon(Icons.logout))],
      ),
      body: Text(
        "LOGGED IN AS:\n${user?.email ?? 'unknown'} ",
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
