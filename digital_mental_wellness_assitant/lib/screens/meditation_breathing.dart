import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MeditationBreathingPage extends StatefulWidget {
  const MeditationBreathingPage({Key? key}) : super(key: key);

  @override
  State<MeditationBreathingPage> createState() => _MeditationBreathingPageState();
}

// Simple soft blobs background painter. 't' ranges 0..1 for animation phase.
class _BackgroundPainter extends CustomPainter {
  final double t;
  _BackgroundPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint();
    // blob 1
    final double r1 = size.width * 0.45;
    final Offset c1 = Offset(size.width * (0.15 + 0.05 * t), size.height * 0.12);
    p.color = Colors.teal.withOpacity(0.06 + 0.02 * (1 - t));
    canvas.drawCircle(c1, r1, p);

    // blob 2
    final double r2 = size.width * 0.35;
    final Offset c2 = Offset(size.width * (0.85 - 0.05 * t), size.height * 0.28);
    p.color = Colors.purple.withOpacity(0.04 + 0.02 * t);
    canvas.drawCircle(c2, r2, p);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => oldDelegate.t != t;
}

class _MeditationBreathingPageState extends State<MeditationBreathingPage> with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final AnimationController _bgController;
  late final Animation<double> _bgPulse;
  int boxBreathingCounter = 0;
  final Map<int, double> _cardScale = {0: 1.0, 1: 1.0, 2: 1.0};

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _bgPulse = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _startBoxBreathing() async {
    final cycles = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => BoxBreathingExercise(initialCount: 0)),
    );
    if (cycles != null && cycles > 0) {
      setState(() => boxBreathingCounter += cycles);
    }
  }

  Widget _buildCard({
    required Color accent,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onStart,
    Widget? trailing,
    int index = 0,
  }) {
    final animation = CurvedAnimation(
      parent: _staggerController,
      curve: Interval(0.1 * index, 0.6 + 0.1 * index, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
        child: AnimatedScale(
          scale: _cardScale[index] ?? 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutBack,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: accent.withOpacity(0.12),
              highlightColor: Colors.black12.withOpacity(0.02),
              onTapDown: (_) {
                setState(() => _cardScale[index] = 0.97);
              },
              onTapCancel: () {
                setState(() => _cardScale[index] = 1.0);
              },
              onTapUp: (_) {
                setState(() => _cardScale[index] = 1.0);
              },
              onTap: () {
                HapticFeedback.selectionClick();
                onStart();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                width: 340,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: accent.withOpacity(0.14), borderRadius: BorderRadius.circular(10)),
                        child: Hero(tag: 'icon_$index', child: Icon(Icons.self_improvement, color: accent, size: 28)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                      if (trailing != null) trailing,
                    ]),
                    const SizedBox(height: 8),
                    Text(subtitle, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            onStart();
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: Text(buttonLabel),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation & Breathing'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFEEF7F4),
      body: Stack(
        children: [
          // animated background blobs
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgPulse,
              builder: (context, child) {
                final t = _bgPulse.value;
                return CustomPaint(
                  painter: _BackgroundPainter(t),
                );
              },
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 6),
              // header animation
              FadeTransition(
                opacity: CurvedAnimation(parent: _staggerController, curve: const Interval(0.0, 0.25, curve: Curves.easeOut)),
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero).animate(CurvedAnimation(parent: _staggerController, curve: const Interval(0.0, 0.25, curve: Curves.easeOut))),
                  child: const Text('Meditation & Breathing', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF7B3DD6))),
                ),
              ),
              const SizedBox(height: 6),
              FadeTransition(
                opacity: CurvedAnimation(parent: _staggerController, curve: const Interval(0.05, 0.35, curve: Curves.easeOut)),
                child: const Text('Find your calm through guided breathing exercises', style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  _buildCard(
                    index: 0,
                    accent: Colors.blue.shade600,
                    title: 'Box Breathing',
                    subtitle: 'A calming technique to reduce stress and anxiety\n16s per cycle',
                    buttonLabel: 'Start Exercise',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        const Icon(Icons.repeat, size: 16, color: Colors.blue),
                        const SizedBox(width: 6),
                        Text('$boxBreathingCounter', style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                    onStart: _startBoxBreathing,
                  ),
                  _buildCard(
                    index: 1,
                    accent: Colors.purple,
                    title: '4-7-8 Breathing',
                    subtitle: 'Perfect for falling asleep and deep relaxation\n19s per cycle',
                    buttonLabel: 'Start Exercise',
                    onStart: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => BasicExerciseDemo(title: '4-7-8 Breathing')));
                    },
                  ),
                  _buildCard(
                    index: 2,
                    accent: Colors.green.shade600,
                    title: 'Calm Breathing',
                    subtitle: 'Simple and effective for everyday stress relief\n10s per cycle',
                    buttonLabel: 'Start Exercise',
                    onStart: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => BasicExerciseDemo(title: 'Calm Breathing')));
                    },
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class BasicExerciseDemo extends StatefulWidget {
  final String title;
  const BasicExerciseDemo({Key? key, required this.title}) : super(key: key);

  @override
  State<BasicExerciseDemo> createState() => _BasicExerciseDemoState();
}

class _BasicExerciseDemoState extends State<BasicExerciseDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0),
      body: Center(
        child: ScaleTransition(
          scale: Tween(begin: 0.8, end: 1.15).animate(CurvedAnimation(parent: _ctl, curve: Curves.easeInOut)),
          child: Container(width: 220, height: 220, decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle)),
        ),
      ),
    );
  }
}

class BoxBreathingExercise extends StatefulWidget {
  final int initialCount;
  const BoxBreathingExercise({Key? key, required this.initialCount}) : super(key: key);

  @override
  State<BoxBreathingExercise> createState() => _BoxBreathingExerciseState();
}

class _BoxBreathingExerciseState extends State<BoxBreathingExercise> with SingleTickerProviderStateMixin {
  final List<String> phases = ['Inhale', 'Hold', 'Exhale', 'Hold'];
  final List<int> phaseDurations = [4, 4, 4, 4];
  int phaseIndex = 0;
  int secondLeft = 4;
  Timer? _timer;
  bool running = false;
  int cyclesCompleted = 0;

  late final AnimationController _circleController;
  late final Animation<double> _circleScale;

  @override
  void initState() {
    super.initState();
    secondLeft = phaseDurations[0];
    _circleController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _circleScale = Tween<double>(begin: 0.8, end: 1.15).animate(CurvedAnimation(parent: _circleController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _circleController.dispose();
    super.dispose();
  }

  void _start() {
    if (running) return;
    running = true;
    _circleController.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    setState(() {});
  }

  void _stopAndReturn() {
    _timer?.cancel();
    _circleController.stop();
    running = false;
    Navigator.of(context).pop(cyclesCompleted);
  }

  void _tick() {
    setState(() {
      secondLeft -= 1;
      if (secondLeft <= 0) {
        phaseIndex = (phaseIndex + 1) % phases.length;
        secondLeft = phaseDurations[phaseIndex];
        if (phaseIndex == 0) {
          cyclesCompleted += 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final phase = phases[phaseIndex];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Box Breathing'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Center(child: Text('Cycles: $cyclesCompleted', style: const TextStyle(fontWeight: FontWeight.w600)))),
        ],
      ),
      body: Container(
        color: const Color(0xFFF6FBFA),
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(phase, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('$secondLeft s', style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 28),
          ScaleTransition(
            scale: _circleScale,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.blue.withOpacity(0.16), width: 2),
                  ),
                  child: Center(child: Hero(tag: 'icon_0', child: Icon(Icons.self_improvement, size: 72, color: Colors.blue.shade700))),
                ),
          ),
          const SizedBox(height: 36),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: running ? null : _start,
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12), child: Text('Start')),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: running ? _stopAndReturn : () => Navigator.of(context).pop(cyclesCompleted),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), child: Text(running ? 'Stop & Save' : 'Close')),
            )
          ]),
          const SizedBox(height: 20),
          const Text('Complete cycles will be added to your counter.', style: TextStyle(color: Colors.black54)),
        ]),
      ),
    );
  }
}
