import 'package:flutter/material.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ResourceCard(
            title: 'Crisis Support',
            description: 'Immediate help resources and hotlines by region.',
            icon: Icons.support_agent,
          ),
          SizedBox(height: 12),
          _ResourceCard(
            title: 'Guided Meditations',
            description: 'Short practices for calm and focus.',
            icon: Icons.self_improvement,
          ),
          SizedBox(height: 12),
          _ResourceCard(
            title: 'Articles & Tips',
            description: 'Evidence-based mental wellness guides.',
            icon: Icons.article_outlined,
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
  const _ResourceCard({required this.title, required this.description, required this.icon});

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
          TextButton(onPressed: () {}, child: const Text('Open')),
        ],
      ),
    );
  }
}
