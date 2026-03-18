import 'package:flutter/material.dart';
import '../widgets/stress_analyzer_section.dart';
import '../widgets/app_section_card.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Stress Analyzer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            AppSectionCard(
              padding: const EdgeInsets.all(16),
              gradient: AppSectionCard.gradientFromScheme(
                cs,
                a: cs.primaryContainer,
                b: cs.secondaryContainer,
                aAlpha: 0.60,
                bAlpha: 0.42,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Understand & Track Your Stress',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Answer quick reflective prompts, see a dynamic gauge of your current stress, and build a personal trend—saved to your profile for this user.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const StressAnalyzerSection(),
            const SizedBox(height: 12),
            Text(
              'Use this tool daily to notice patterns early and take gentle action.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
