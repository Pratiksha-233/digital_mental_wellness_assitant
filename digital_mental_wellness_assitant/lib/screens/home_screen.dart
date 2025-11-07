import 'package:flutter/material.dart';
import 'journal_screen.dart';
import 'recommendation_screen.dart';

class HomeScreen extends StatelessWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Wellness Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JournalScreen(userId: userId),
                ),
              ),
              child: const Text('Write Journal'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RecommendationScreen()),
              ),
              child: const Text('View Recommendations'),
            ),
          ],
        ),
      ),
    );
  }
}
