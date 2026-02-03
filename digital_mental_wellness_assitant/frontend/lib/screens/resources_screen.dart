import 'package:flutter/material.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ResourceCard(
            title: 'Crisis Support',
            description: 'Immediate help resources and hotlines by region.',
            icon: Icons.support_agent,
            onOpen: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Crisis Support'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Immediate help resources and hotlines by region:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const Text('National Crisis Hotline: 1-800-273-8255 (24/7)'),
                        const SizedBox(height: 8),
                        const Text('Crisis Text Line: Text HOME to 741741'),
                        const SizedBox(height: 8),
                        const Text('International Association for Suicide Prevention: https://www.iasp.info/resources/Crisis_Centres/'),
                        const SizedBox(height: 8),
                        const Text('NAMI Helpline: 1-800-950-NAMI (6264)'),
                        const SizedBox(height: 12),
                        const Text('Available 24/7 for immediate support and guidance.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _ResourceCard(
            title: 'Guided Meditations',
            description: 'Short practices for calm and focus.',
            icon: Icons.self_improvement,
            onOpen: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Guided Meditations'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Short practices for calm and focus:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const Text('• Breathing Exercises (5-10 minutes)'),
                        const SizedBox(height: 6),
                        const Text('Calming breath techniques to reduce anxiety and stress.'),
                        const SizedBox(height: 12),
                        const Text('• Body Scan Meditation (10-15 minutes)'),
                        const SizedBox(height: 6),
                        const Text('Progressive relaxation to release tension and increase awareness.'),
                        const SizedBox(height: 12),
                        const Text('• Mindfulness Meditation (5-20 minutes)'),
                        const SizedBox(height: 6),
                        const Text('Present moment awareness to reduce stress and improve focus.'),
                        const SizedBox(height: 12),
                        const Text('• Sleep Meditation (15-30 minutes)'),
                        const SizedBox(height: 6),
                        const Text('Guided relaxation to improve sleep quality and rest.'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _ResourceCard(
            title: 'Articles & Tips',
            description: 'Evidence-based mental wellness guides.',
            icon: Icons.article_outlined,
            onOpen: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Articles & Tips'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Evidence-based mental wellness guides:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const Text('Understanding Anxiety Disorders'),
                        const SizedBox(height: 6),
                        const Text('Learn about different types of anxiety and evidence-based treatment options.'),
                        const SizedBox(height: 12),
                        const Text('Stress Management Techniques'),
                        const SizedBox(height: 6),
                        const Text('Practical strategies to identify and manage daily stressors effectively.'),
                        const SizedBox(height: 12),
                        const Text('Sleep Hygiene Tips'),
                        const SizedBox(height: 6),
                        const Text('Improve sleep quality with science-backed recommendations and routines.'),
                        const SizedBox(height: 12),
                        const Text('Building Healthy Relationships'),
                        const SizedBox(height: 6),
                        const Text('Communication and connection strategies for emotional wellness.'),
                        const SizedBox(height: 12),
                        const Text('Exercise and Mental Health'),
                        const SizedBox(height: 6),
                        const Text('Discover the proven benefits of physical activity on mental well-being.'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onOpen;
  const _ResourceCard({required this.title, required this.description, required this.icon, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(description, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          TextButton(onPressed: onOpen, child: const Text('Open')),
        ],
      ),
    );
  }
}
