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
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FourSevenEightBreathingExercise()));
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
  final List<String> phases = ['Breathe In', 'Hold', 'Breathe Out', 'Hold'];
  final List<int> phaseDurations = [4, 4, 4, 4];
  int phaseIndex = 0;
  int secondsLeft = 4;
  Timer? _timer;
  bool running = false;
  bool paused = false;
  int cyclesCompleted = 0;

  late AnimationController _phaseController; // drives progress ring

  @override
  void initState() {
    super.initState();
    secondsLeft = phaseDurations[0];
    _phaseController = AnimationController(vsync: this, duration: Duration(seconds: phaseDurations[0]));
    // Auto start after build to match desired UX (show Pause & End only)
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phaseController.dispose();
    super.dispose();
  }

  void _start() {
    if (running) return;
    running = true;
    paused = false;
    _phaseController.forward(from: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    setState(() {});
  }

  void _pauseResume() {
    if (!running) return; // nothing to pause
    if (!paused) {
      // pause now
      paused = true;
      _timer?.cancel();
      _phaseController.stop();
    } else {
      // resume
      paused = false;
      _phaseController.forward();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
    setState(() {});
  }

  void _stopAndReturn() {
    _timer?.cancel();
    _phaseController.stop();
    running = false;
    Navigator.of(context).pop(cyclesCompleted);
  }

  void _tick() {
    setState(() {
      secondsLeft -= 1;
      if (secondsLeft <= 0) {
        phaseIndex = (phaseIndex + 1) % phases.length;
        secondsLeft = phaseDurations[phaseIndex];
        _phaseController.duration = Duration(seconds: secondsLeft);
        _phaseController.forward(from: 0);
        if (phaseIndex == 0) cyclesCompleted += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final phase = phases[phaseIndex];
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7EB2F3), Color(0xFF29B9E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text('Box Breathing', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 36),
            AnimatedBuilder(
              animation: _phaseController,
              builder: (context, _) {
                // remaining fraction
                final remaining = secondsLeft / phaseDurations[phaseIndex];
                return SizedBox(
                  width: 300,
                  height: 300,
                  child: CustomPaint(
                    painter: _RemainingRingPainter(fraction: remaining),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$secondsLeft', style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(paused ? 'Paused' : phase, style: const TextStyle(fontSize: 20, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Text('Cycle ${cyclesCompleted + 1}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            _PhaseSequence(currentIndex: phaseIndex, phases: phases),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _glassButton(
                  icon: paused ? Icons.play_arrow : Icons.pause,
                  label: paused ? 'Resume' : 'Pause',
                  onTap: running ? _pauseResume : null,
                ),
                const SizedBox(width: 20),
                _glassButton(
                  icon: Icons.refresh,
                  label: 'End Session',
                  onTap: _stopAndReturn,
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

// New painter drawing a base translucent ring and remaining arc in solid white.
class _RemainingRingPainter extends CustomPainter {
  final double fraction; // remaining fraction 0..1
  _RemainingRingPainter({required this.fraction});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 12;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = Colors.white.withOpacity(0.35)
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = Colors.white
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, base);
    final sweep = 2 * 3.141592653589793 * fraction;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.141592653589793 / 2, sweep, false, active);
  }

  @override
  bool shouldRepaint(covariant _RemainingRingPainter oldDelegate) => oldDelegate.fraction != fraction;
}

class _PhaseSequence extends StatelessWidget {
  final int currentIndex;
  final List<String> phases;
  const _PhaseSequence({required this.currentIndex, required this.phases});

  @override
  Widget build(BuildContext context) {
    final styleInactive = const TextStyle(color: Colors.white70, fontSize: 14);
    final styleActive = const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
    final children = <InlineSpan>[];
    for (int i = 0; i < phases.length; i++) {
      children.add(TextSpan(text: phases[i], style: i == currentIndex ? styleActive : styleInactive));
      if (i != phases.length - 1) {
        children.add(const TextSpan(text: '  →  ', style: TextStyle(color: Colors.white54, fontSize: 14)));
      }
    }
    return RichText(text: TextSpan(children: children));
  }
}

Widget _glassButton({required IconData icon, required String label, required VoidCallback? onTap}) {
  return Opacity(
    opacity: onTap == null ? 0.6 : 1,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ),
  );
}

// 4-7-8 Breathing Exercise (Inhale 4s, Hold 7s, Exhale 8s)
class FourSevenEightBreathingExercise extends StatefulWidget {
  const FourSevenEightBreathingExercise({Key? key}) : super(key: key);

  @override
  State<FourSevenEightBreathingExercise> createState() => _FourSevenEightBreathingExerciseState();
}

// Calm Breathing Exercise (simple 5s in, 5s out)
class CalmBreathingExercise extends StatefulWidget {
  const CalmBreathingExercise({Key? key}) : super(key: key);

  @override
  State<CalmBreathingExercise> createState() => _CalmBreathingExerciseState();
}

class _CalmBreathingExerciseState extends State<CalmBreathingExercise> with SingleTickerProviderStateMixin {
  final List<String> phases = ['Breathe In', 'Breathe Out'];
  final List<int> phaseDurations = [5, 5]; // total 10s per cycle
  int phaseIndex = 0;
  int secondsLeft = 5;
  int cyclesCompleted = 0;
  bool running = false;
  bool paused = false;
  Timer? _timer;
  late AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctl.dispose();
    super.dispose();
  }

  void _start() {
    if (running) return;
    running = true;
    paused = false;
    secondsLeft = phaseDurations[phaseIndex];
    _ctl.duration = Duration(seconds: secondsLeft);
    _ctl.forward(from: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    setState(() {});
  }

  void _pauseResume() {
    if (!running) return;
    if (!paused) {
      paused = true;
      _timer?.cancel();
      _ctl.stop();
    } else {
      paused = false;
      _ctl.forward();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
    setState(() {});
  }

  void _endSession() {
    _timer?.cancel();
    _ctl.stop();
    Navigator.of(context).pop(cyclesCompleted);
  }

  void _tick() {
    setState(() {
      secondsLeft -= 1;
      if (secondsLeft <= 0) {
        phaseIndex = (phaseIndex + 1) % phases.length;
        secondsLeft = phaseDurations[phaseIndex];
        _ctl.duration = Duration(seconds: secondsLeft);
        _ctl.forward(from: 0);
        if (phaseIndex == 0) cyclesCompleted += 1; // new cycle
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final phase = phases[phaseIndex];
    return Scaffold(
      backgroundColor: const Color(0xFFF3FDF7),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF55D895), Color(0xFF21BF6B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text('Calm Breathing', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 36),
            AnimatedBuilder(
              animation: _ctl,
              builder: (context, _) {
                final remainingFraction = secondsLeft / phaseDurations[phaseIndex];
                return SizedBox(
                  width: 300,
                  height: 300,
                  child: CustomPaint(
                    painter: _RemainingRingPainter(fraction: remainingFraction),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$secondsLeft', style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(paused ? 'Paused' : phase, style: const TextStyle(fontSize: 20, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Text('Cycle ${cyclesCompleted + 1}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            _PhaseSequence(currentIndex: phaseIndex, phases: phases),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _glassButton(
                  icon: paused ? Icons.play_arrow : Icons.pause,
                  label: paused ? 'Resume' : 'Pause',
                  onTap: running ? _pauseResume : null,
                ),
                const SizedBox(width: 20),
                _glassButton(
                  icon: Icons.refresh,
                  label: 'End Session',
                  onTap: _endSession,
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _FourSevenEightBreathingExerciseState extends State<FourSevenEightBreathingExercise> with SingleTickerProviderStateMixin {
  final List<String> phases = ['Breathe In', 'Hold', 'Breathe Out'];
  final List<int> phaseDurations = [4, 7, 8];
  int phaseIndex = 0;
  int secondsLeft = 4;
  int cyclesCompleted = 0;
  bool running = false;
  bool paused = false;
  Timer? _timer;
  late AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctl.dispose();
    super.dispose();
  }

  void _start() {
    if (running) return;
    running = true;
    paused = false;
    secondsLeft = phaseDurations[phaseIndex];
    _ctl.duration = Duration(seconds: secondsLeft);
    _ctl.forward(from: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    setState(() {});
  }

  void _pauseResume() {
    if (!running) return;
    if (!paused) {
      paused = true;
      _timer?.cancel();
      _ctl.stop();
    } else {
      paused = false;
      _ctl.forward();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
    setState(() {});
  }

  void _endSession() {
    _timer?.cancel();
    _ctl.stop();
    Navigator.of(context).pop(cyclesCompleted);
  }

  void _tick() {
    setState(() {
      secondsLeft -= 1;
      if (secondsLeft <= 0) {
        phaseIndex = (phaseIndex + 1) % phases.length;
        secondsLeft = phaseDurations[phaseIndex];
        _ctl.duration = Duration(seconds: secondsLeft);
        _ctl.forward(from: 0);
        if (phaseIndex == 0) cyclesCompleted += 1; // new cycle begins after exhale completes
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final phase = phases[phaseIndex];
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC6A4FA), Color(0xFFE86ABF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text('4-7-8 Breathing', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 36),
            AnimatedBuilder(
              animation: _ctl,
              builder: (context, _) {
                final remainingFraction = secondsLeft / phaseDurations[phaseIndex];
                return SizedBox(
                  width: 300,
                  height: 300,
                  child: CustomPaint(
                    painter: _RemainingRingPainter(fraction: remainingFraction),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$secondsLeft', style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(paused ? 'Paused' : phase, style: const TextStyle(fontSize: 20, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Text('Cycle ${cyclesCompleted + 1}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            _PhaseSequence(currentIndex: phaseIndex, phases: phases),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _glassButton(
                  icon: paused ? Icons.play_arrow : Icons.pause,
                  label: paused ? 'Resume' : 'Pause',
                  onTap: running ? _pauseResume : null,
                ),
                const SizedBox(width: 20),
                _glassButton(
                  icon: Icons.refresh,
                  label: 'End Session',
                  onTap: _endSession,
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
