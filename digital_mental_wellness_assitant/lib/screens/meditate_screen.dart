import 'package:flutter/material.dart';

class MeditateScreen extends StatelessWidget {
  const MeditateScreen({super.key});

  Widget _exerciseCard(BuildContext context, {required Color color, required String title, required String desc, required String duration}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withAlpha(220), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.self_improvement, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 8),
            Text(duration, style: const TextStyle(color: Colors.black38, fontSize: 12)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Start $title'))),
              style: ElevatedButton.styleFrom(backgroundColor: color),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.play_arrow), SizedBox(width: 8), Text('Start Exercise')]),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meditation & Breathing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        child: Column(children: [
          const SizedBox(height: 6),
          const Text('Meditation & Breathing', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple)),
          const SizedBox(height: 6),
          const Text('Find your calm through guided breathing exercises', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _exerciseCard(context, color: Colors.blue, title: 'Box Breathing', desc: 'A calming technique to reduce stress and anxiety', duration: '16s per cycle')),
                const SizedBox(width: 12),
                Expanded(child: _exerciseCard(context, color: Colors.purple, title: '4-7-8 Breathing', desc: 'Perfect for falling asleep and deep relaxation', duration: '19s per cycle')),
                const SizedBox(width: 12),
                Expanded(child: _exerciseCard(context, color: Colors.green, title: 'Calm Breathing', desc: 'Simple and effective for everyday stress relief', duration: '10s per cycle')),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
