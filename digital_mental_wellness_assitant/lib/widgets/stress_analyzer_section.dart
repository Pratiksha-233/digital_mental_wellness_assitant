import 'package:flutter/material.dart';

/// Embeddable Stress Analyzer section with:
/// 1) Questionnaire (10 items)
/// 2) Stress score calculation
/// 3) Weekly trend graph
/// 4) Reminders toggle (UI only)
/// 5) Export report (dialog preview)
/// 6) Rotating calming quotes
class StressAnalyzerSection extends StatefulWidget {
  const StressAnalyzerSection({super.key});

  @override
  State<StressAnalyzerSection> createState() => _StressAnalyzerSectionState();
}

class _StressAnalyzerSectionState extends State<StressAnalyzerSection> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _quoteCtrl;
  double _dailyScore = 0;
  final Map<String, int> _answers = {};
  final List<_SAStressRecord> _history = [];
  DateTime _lastSaved = DateTime.now();
  bool _showGraph = true;
  bool _remindersOn = false;

  final List<_SAQuestion> _questions = const [
    _SAQuestion('I feel tense or “on edge”.'),
    _SAQuestion('I find it hard to relax.'),
    _SAQuestion('My sleep quality has been poor.'),
    _SAQuestion('I feel overwhelmed by tasks.'),
    _SAQuestion('I get irritated easily.'),
    _SAQuestion('I notice physical signs (e.g., tight shoulders).'),
    _SAQuestion('I worry about things repeatedly.'),
    _SAQuestion('I struggle to focus.'),
    _SAQuestion('I feel tired even after rest.'),
    _SAQuestion('I experience racing thoughts.'),
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
    _quoteCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _quoteCtrl.dispose();
    super.dispose();
  }

  void _calculateScore() {
    int total = 0;
    for (final q in _questions) {
      total += _answers[q.text] ?? 0;
    }
    _dailyScore = (total / (_questions.length * 4)) * 100;
  }

  void _saveRecord() {
    _calculateScore();
    final record = _SAStressRecord(DateTime.now(), _dailyScore);
    setState(() {
      _history.add(record);
      _lastSaved = record.date;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stress report saved (score: ${_dailyScore.toStringAsFixed(1)})')),
    );
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Hero header with gradient and rotating quote
          AnimatedBuilder(
            animation: _quoteCtrl,
            builder: (context, _) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.teal.shade400, Colors.indigo.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                const Icon(Icons.psychology_alt, color: Colors.white, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Stress Analyzer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(_currentQuote, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                  ]),
                ),
                Row(children: [
                  const Text('Reminders', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 6),
                  Switch(
                    value: _remindersOn,
                    onChanged: (v) => setState(() => _remindersOn = v),
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white24,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          // Quick presets to fill answers fast
          Wrap(spacing: 8, runSpacing: 8, children: [
            _presetChip('Calm', 0),
            _presetChip('Mild', 1),
            _presetChip('Moderate', 2),
            _presetChip('Tense', 3),
            _presetChip('Overwhelmed', 4),
          ]),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Stress Level Questionnaire', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ..._questions.map((q) => _SAQuestionTile(
                    question: q.text,
                    value: _answers[q.text] ?? 0,
                    onChanged: (v) => setState(() => _answers[q.text] = v),
                  )),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _calculateScore();
                    setState(() {});
                  },
                  icon: const Icon(Icons.assessment),
                  label: const Text('Calculate Stress Score'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          if (_dailyScore > 0)
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              // Circular gauge
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _SAGaugePainter(_dailyScore),
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(_dailyScore.toStringAsFixed(0), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(_scoreLabel(_dailyScore), style: const TextStyle(fontSize: 12)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Today\'s Stress Score', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('A higher number indicates higher stress today. Use your result as a gentle nudge, not a judgment.'),
                  const SizedBox(height: 8),
                  Row(children: [
                    ElevatedButton.icon(onPressed: _saveRecord, icon: const Icon(Icons.save_alt), label: const Text('Save')),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(onPressed: _exportReport, icon: const Icon(Icons.download), label: const Text('Export')),
                  ]),
                ]),
              ),
            ]),
          const SizedBox(height: 10),
          if (_history.isNotEmpty)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('Weekly Trend', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(onPressed: () => setState(() => _showGraph = !_showGraph), icon: Icon(_showGraph ? Icons.visibility : Icons.visibility_off)),
              ]),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _showGraph ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: SizedBox(height: 160, child: CustomPaint(painter: _SAStressGraphPainter(_history))),
                secondChild: const SizedBox.shrink(),
              ),
              const SizedBox(height: 6),
              Text('Last saved: ${_lastSaved.toLocal().toString().split('.').first}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
        ]),
      ),
    );
  }

  // Quick preset chip builder
  Widget _presetChip(String label, int level) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.bolt, size: 16),
      onPressed: () {
        setState(() {
          for (final q in _questions) {
            _answers[q.text] = level;
          }
          _calculateScore();
        });
      },
    );
  }
}

class _SAQuestion {
  final String text;
  const _SAQuestion(this.text);
}

class _SAQuestionTile extends StatelessWidget {
  final String question;
  final int value; // 0..4
  final ValueChanged<int> onChanged;
  const _SAQuestionTile({Key? key, required this.question, required this.value, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(children: List.generate(5, (i) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 26,
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

class _SAStressRecord {
  final DateTime date;
  final double score;
  _SAStressRecord(this.date, this.score);
}

class _SAStressGraphPainter extends CustomPainter {
  final List<_SAStressRecord> records;
  _SAStressGraphPainter(this.records);

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;
    final paintLine = Paint()
      ..color = Colors.teal
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final paintFill = Paint()
      ..shader = LinearGradient(colors: [Colors.teal.withOpacity(0.25), Colors.teal.withOpacity(0.05)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final pathFill = Path();
    const maxScore = 100.0;
    final stepX = records.length == 1 ? 0.0 : size.width / (records.length - 1);
    for (int i = 0; i < records.length; i++) {
      final x = records.length == 1 ? size.width / 2 : i * stepX;
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

    final pointPaint = Paint()..color = Colors.teal..style = PaintingStyle.fill;
    for (int i = 0; i < records.length; i++) {
      final x = records.length == 1 ? size.width / 2 : i * stepX;
      final y = size.height - (records[i].score / maxScore) * size.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SAStressGraphPainter oldDelegate) => oldDelegate.records != records;
}

// Circular gauge painter for unique visualization
class _SAGaugePainter extends CustomPainter {
  final double score; // 0..100
  _SAGaugePainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 6;
    // background circle
    final bg = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.14 * 3 / 4, 3.14 * 1.5, false, bg);

    // progress arc
    final grad = SweepGradient(colors: [Colors.teal, Colors.indigo], startAngle: 0, endAngle: 3.14 * 1.5);
    final fg = Paint()
      ..shader = grad.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final sweep = (score.clamp(0, 100) / 100) * (3.14 * 1.5);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.14 * 3 / 4, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _SAGaugePainter oldDelegate) => oldDelegate.score != score;
}
