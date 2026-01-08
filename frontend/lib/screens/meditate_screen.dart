import 'package:flutter/material.dart';
import 'meditation_breathing.dart';

class MeditateScreen extends StatefulWidget {
  const MeditateScreen({super.key});

  @override
  State<MeditateScreen> createState() => _MeditateScreenState();
}

class _MeditateScreenState extends State<MeditateScreen> with TickerProviderStateMixin {
  int boxBreathingCycles = 0;
  int fourSevenEightCycles = 0;
  int calmBreathingCycles = 0;
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 14))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _launchBoxBreathing() async {
    final cycles = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => BoxBreathingExercise(initialCount: 0)),
    );
    if (cycles != null && cycles > 0) {
      setState(() => boxBreathingCycles += cycles);
    }
  }

  Future<void> _launchFourSevenEight() async {
    final cycles = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => const FourSevenEightBreathingExercise()),
    );
    if (cycles != null && cycles > 0) {
      setState(() => fourSevenEightCycles += cycles);
    }
  }

  Future<void> _launchCalmBreathing() async {
    final cycles = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => const CalmBreathingExercise()),
    );
    if (cycles != null && cycles > 0) {
      setState(() => calmBreathingCycles += cycles);
    }
  }

  Widget _exerciseCard(BuildContext context, {required Color color, required String title, required String desc, required String duration, VoidCallback? onStart, Widget? trailing}) {
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
            if (trailing != null) ...[const SizedBox(height: 8), trailing],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onStart ?? () {},
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
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final t = _bgController.value;
        final c1 = Color.lerp(const Color(0xFFe0f7fa), const Color(0xFFede7f6), t)!;
        final c2 = Color.lerp(const Color(0xFFe8f5e9), const Color(0xFFfff3e0), t)!;
        return Scaffold(
          appBar: AppBar(title: const Text('Meditation & Breathing')),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c1, c2]),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
              child: Column(children: [
                const SizedBox(height: 6),
                const Text('Meditation & Breathing', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple)),
                const SizedBox(height: 6),
                const Text('Find your calm through guided breathing exercises', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: LayoutBuilder(builder: (context, box) {
                    final double w = box.maxWidth;
                    int columns;
                    if (w >= 1000) {
                      columns = 3;
                    } else if (w >= 680) {
                      columns = 2;
                    } else {
                      columns = 1;
                    }
                    final double cardWidth = (w - (columns - 1) * 24) / columns;
                    final cards = [
                      _exerciseCard(
                        context,
                        color: Colors.blue,
                        title: 'Box Breathing',
                        desc: 'A calming technique to reduce stress and anxiety',
                        duration: '16s per cycle',
                        onStart: _launchBoxBreathing,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.repeat, size: 16, color: Colors.blue), const SizedBox(width: 6), Text('$boxBreathingCycles', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold))]),
                        ),
                      ),
                      _exerciseCard(
                        context,
                        color: Colors.purple,
                        title: '4-7-8 Breathing',
                        desc: 'Perfect for falling asleep and deep relaxation',
                        duration: '19s per cycle',
                        onStart: _launchFourSevenEight,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.repeat, size: 16, color: Colors.purple), const SizedBox(width: 6), Text('$fourSevenEightCycles', style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold))]),
                        ),
                      ),
                      _exerciseCard(
                        context,
                        color: Colors.green,
                        title: 'Calm Breathing',
                        desc: 'Simple and effective for everyday stress relief',
                        duration: '10s per cycle',
                        onStart: _launchCalmBreathing,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.repeat, size: 16, color: Colors.green), const SizedBox(width: 6), Text('$calmBreathingCycles', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold))]),
                        ),
                      ),
                    ];
                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 24,
                      runSpacing: 24,
                      children: cards.map((c) => SizedBox(width: cardWidth.clamp(260, 360), child: c)).toList(),
                    );
                  }),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
