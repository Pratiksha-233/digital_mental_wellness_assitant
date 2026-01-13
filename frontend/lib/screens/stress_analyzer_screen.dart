import 'package:flutter/material.dart';

class StressAnalyzerScreen extends StatefulWidget {
  const StressAnalyzerScreen({super.key});
  @override
  State<StressAnalyzerScreen> createState() => _StressAnalyzerScreenState();
}

class _StressAnalyzerScreenState extends State<StressAnalyzerScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _bgCtrl;
  late final AnimationController _quoteCtrl;
  double _dailyScore = 0; // computed from questionnaire
  final Map<String, int> _answers = {}; // question -> value 0..4
  final List<_StressRecord> _history = []; // daily/weekly records
  DateTime _lastSaved = DateTime.now();
  bool _showGraph = true;
  bool _remindersOn = false;

  final List<_Question> _questions = [
    _Question('I feel tense or “on edge”.'),
    _Question('I find it hard to relax.'),
    _Question('My sleep quality has been poor.'),
    _Question('I feel overwhelmed by tasks.'),
    _Question('I get irritated easily.'),
    _Question('I notice physical signs (e.g., tight shoulders).'),
    _Question('I worry about things repeatedly.'),
    _Question('I struggle to focus.'),
    _Question('I feel tired even after rest.'),
    _Question('I experience racing thoughts.'),
  ];

  final List<String> _quotes = const [
    'Pause. Breathe. You are doing enough.',
    'One small calm moment resets a whole hour.',
    'You are allowed to rest without earning it.',
    'Inhale strength, exhale tension.',
    'Gentle progress is still progress.',
  ];

  String get _currentQuote => _quotes[((_quoteCtrl.value * _quotes.length).floor()) % _quotes.length];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
    _quoteCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _quoteCtrl.dispose();
    super.dispose();
  }

  void _calculateScore() {
    int total = 0;
    for (final q in _questions) {
      total += _answers[q.text] ?? 0;
    }
    // scale to 100
    _dailyScore = (total / (_questions.length * 4)) * 100;
  }

  void _saveRecord() {
    _calculateScore();
    final record = _StressRecord(DateTime.now(), _dailyScore);
    setState(() {
      _history.add(record);
      _lastSaved = record.date;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stress report saved (score: ${_dailyScore.toStringAsFixed(1)})')));
  }

  String _scoreLabel(double score) {
    if (score < 25) return 'Low';
    if (score < 50) return 'Mild';
    if (score < 75) return 'Moderate';
    return 'High';
  }

  void _exportReport() {
    _calculateScore();
    final buffer = StringBuffer('Stress Report\nDate: ${DateTime.now()}\nScore: ${_dailyScore.toStringAsFixed(1)} (${_scoreLabel(_dailyScore)})\n\nAnswers:\n');
    for (final q in _questions) {
      buffer.writeln('${q.text}: ${_answers[q.text] ?? 0}');
    }
    // For now, show in dialog; could integrate share_plus later
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export Report'),
        content: SingleChildScrollView(child: Text(buffer.toString())),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stress Analyzer')),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (context, _) {
              final t = _bgCtrl.value;
              final g1 = Color.lerp(const Color(0xFFE0F7FA), const Color(0xFFE8F5E9), t)!;
              final g2 = Color.lerp(const Color(0xFFF1F8E9), const Color(0xFFE3F2FD), 1 - t)!;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [g1, g2]),
                ),
              );
            },
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header + quote
              AnimatedBuilder(
                animation: _quoteCtrl,
                builder: (context, _) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black12.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Row(children: [
                      const Icon(Icons.psychology_alt, color: Colors.teal, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Daily Stress Check', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
                          const SizedBox(height: 4),
                          Text(_currentQuote, style: TextStyle(color: Colors.teal.shade700, fontStyle: FontStyle.italic)),
                        ]),
                      ),
                      Switch(
                        value: _remindersOn,
                        onChanged: (v) => setState(() => _remindersOn = v),
                      ),
                      const SizedBox(width: 4),
                      const Text('Reminders'),
                    ]),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Questionnaire
              Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Stress Level Questionnaire', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ..._questions.map((q) => _QuestionTile(
                        question: q.text,
                        value: _answers[q.text] ?? 0,
                        onChanged: (v) => setState(() => _answers[q.text] = v),
                      )),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      _calculateScore();
                      setState(() {});
                    },
                    icon: const Icon(Icons.assessment),
                    label: const Text('Calculate Stress Score'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // Score display
              if (_dailyScore > 0)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Today\'s Stress Score', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: _dailyScore / 100, minHeight: 10, borderRadius: BorderRadius.circular(8), color: Colors.teal),
                          const SizedBox(height: 8),
                          Text('${_dailyScore.toStringAsFixed(1)} / 100 (${_scoreLabel(_dailyScore)})'),
                        ]),
                      ),
                      IconButton(onPressed: _saveRecord, icon: const Icon(Icons.save_alt, color: Colors.teal)),
                      IconButton(onPressed: _exportReport, icon: const Icon(Icons.download, color: Colors.teal)),
                    ]),
                  ),
                ),

              const SizedBox(height: 24),

              // Graph
              if (_history.isNotEmpty)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text('Weekly Trend', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        IconButton(onPressed: () => setState(() => _showGraph = !_showGraph), icon: Icon(_showGraph ? Icons.visibility : Icons.visibility_off)),
                      ]),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _showGraph ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        firstChild: SizedBox(height: 180, child: CustomPaint(painter: _StressGraphPainter(_history))),
                        secondChild: const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 12),
                      Text('Last saved: ${_lastSaved.toLocal().toString().split('.').first}')
                    ]),
                  ),
                ),
            ]),
          )
        ],
      ),
    );
  }
}

class _Question {
  final String text;
  const _Question(this.text);
}

class _QuestionTile extends StatelessWidget {
  final String question;
  final int value; // 0..4
  final ValueChanged<int> onChanged;
  const _QuestionTile({required this.question, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(children: List.generate(5, (i) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 28,
                  decoration: BoxDecoration(
                    color: i <= value ? Colors.teal : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text('$i', style: TextStyle(color: i <= value ? Colors.white : Colors.black54, fontSize: 12)),
                  ),
                ),
              ),
            );
          })),
        ]),
      ),
    );
  }
}

class _StressRecord {
  final DateTime date;
  final double score;
  _StressRecord(this.date, this.score);
}

class _StressGraphPainter extends CustomPainter {
  final List<_StressRecord> records;
  _StressGraphPainter(this.records);

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;
    final paintLine = Paint()
      ..color = Colors.teal
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final paintFill = Paint()
      ..shader = LinearGradient(colors: [Colors.teal.withValues(alpha: 0.25), Colors.teal.withValues(alpha: 0.05)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final pathFill = Path();
    final maxScore = 100.0;
    final stepX = size.width / (records.length - 1);
    for (int i = 0; i < records.length; i++) {
      final x = i * stepX;
      final y = size.height - (records[i].score / maxScore) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        pathFill.moveTo(x, size.height);
        pathFill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        pathFill.lineTo(x, y);
      }
    }
    pathFill.lineTo(size.width, size.height);
    pathFill.close();
    canvas.drawPath(pathFill, paintFill);
    canvas.drawPath(path, paintLine);

    // draw points
    final pointPaint = Paint()..color = Colors.teal..style = PaintingStyle.fill;
    for (int i = 0; i < records.length; i++) {
      final x = i * stepX;
      final y = size.height - (records[i].score / maxScore) * size.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StressGraphPainter oldDelegate) => oldDelegate.records != records;
}