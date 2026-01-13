import 'package:flutter/material.dart';
import '../widgets/stress_analyzer_section.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  // Recommendation functionality removed per request; screen repurposed as dedicated Stress Analyzer.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stress Analyzer'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Understand & Track Your Stress', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
            const SizedBox(height: 8),
            Text(
              'Answer quick reflective prompts, see a dynamic gauge of your current stress, and build a personal trend—kept locally on your device.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            const StressAnalyzerSection(),
            const SizedBox(height: 12),
            Text('Your responses are private. Use this tool daily to notice patterns early and take gentle action.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
