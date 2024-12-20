import 'package:flutter/material.dart';
import 'screens/forum/forum.dart';
import 'package:golekmakanrek_mobile/screens/forum/dummy_data.dart'; // Import dummy data

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Utama"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForumPage()),
            );
          },
          child: const Text("Buka Forum"),
        ),
      ),
    );
  }
}
