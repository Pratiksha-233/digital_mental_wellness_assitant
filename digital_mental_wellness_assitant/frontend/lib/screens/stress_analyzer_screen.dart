import 'package:flutter/material.dart';
import '../widgets/app_section_card.dart';

class StressAnalyzerScreen extends StatefulWidget {
  const StressAnalyzerScreen({super.key});
  @override
  State<StressAnalyzerScreen> createState() => _StressAnalyzerScreenState();
}

class _StressAnalyzerScreenState extends State<StressAnalyzerScreen>
    with TickerProviderStateMixin {
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

  String get _currentQuote =>
      _quotes[((_quoteCtrl.value * _quotes.length).floor()) % _quotes.length];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _quoteCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Stress report saved (score: ${_dailyScore.toStringAsFixed(1)})',
        ),
      ),
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
    final buffer = StringBuffer(
      'Stress Report\nDate: ${DateTime.now()}\nScore: ${_dailyScore.toStringAsFixed(1)} (${_scoreLabel(_dailyScore)})\n\nAnswers:\n',
    );
    for (final q in _questions) {
      buffer.writeln('${q.text}: ${_answers[q.text] ?? 0}');
    }
    // For now, show in dialog; could integrate share_plus later
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export Report'),
        content: SingleChildScrollView(child: Text(buffer.toString())),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Stress Analyzer')),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (context, _) {
              final t = _bgCtrl.value;
              final g1 = Color.lerp(
                cs.surface,
                cs.primaryContainer,
                t,
              )!.withValues(alpha: 0.75);
              final g2 = Color.lerp(
                cs.surfaceContainerHighest,
                cs.secondaryContainer,
                1 - t,
              )!.withValues(alpha: 0.55);
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [g1, g2],
                  ),
                ),
              );
            },
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header + quote
                AnimatedBuilder(
                  animation: _quoteCtrl,
                  builder: (context, _) {
                    return AppSectionCard(
                      gradient: AppSectionCard.gradientFromScheme(
                        cs,
                        a: cs.primaryContainer,
                        b: cs.secondaryContainer,
                        aAlpha: 0.40,
                        bAlpha: 0.26,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.psychology_alt,
                            color: cs.primary,
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily Stress Check',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentQuote,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onPrimaryContainer,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _remindersOn,
                            onChanged: (v) => setState(() => _remindersOn = v),
                          ),
                          const SizedBox(width: 4),
                          const Text('Reminders'),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Questionnaire
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stress Level Questionnaire',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._questions.map(
                        (q) => _QuestionTile(
                          question: q.text,
                          value: _answers[q.text] ?? 0,
                          onChanged: (v) =>
                              setState(() => _answers[q.text] = v),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          _calculateScore();
                          setState(() {});
                        },
                        icon: const Icon(Icons.assessment),
                        label: const Text('Calculate Stress Score'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Score display
                if (_dailyScore > 0)
                  AppSectionCard(
                    gradient: AppSectionCard.gradientFromScheme(
                      cs,
                      a: cs.primaryContainer,
                      b: cs.surface,
                      aAlpha: 0.38,
                      bAlpha: 0.60,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today\'s Stress Score',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: _dailyScore / 100,
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(8),
                                color: cs.primary,
                                backgroundColor: cs.surfaceContainerHighest,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_dailyScore.toStringAsFixed(1)} / 100 (${_scoreLabel(_dailyScore)})',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _saveRecord,
                          icon: Icon(Icons.save_alt, color: cs.primary),
                        ),
                        IconButton(
                          onPressed: _exportReport,
                          icon: Icon(Icons.download, color: cs.primary),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Graph
                if (_history.isNotEmpty)
                  AppSectionCard(
                    gradient: AppSectionCard.gradientFromScheme(
                      cs,
                      a: cs.surfaceContainerHighest,
                      b: cs.surface,
                      aAlpha: 0.78,
                      bAlpha: 0.60,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Weekly Trend',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _showGraph = !_showGraph),
                              icon: Icon(
                                _showGraph
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ],
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: _showGraph
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: SizedBox(
                            height: 180,
                            child: CustomPaint(
                              painter: _StressGraphPainter(_history, cs),
                            ),
                          ),
                          secondChild: const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Last saved: ${_lastSaved.toLocal().toString().split('.').first}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
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
  const _QuestionTile({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppSectionCard(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      gradient: AppSectionCard.gradientFromScheme(
        cs,
        a: cs.surfaceContainerHighest,
        b: cs.surface,
        aAlpha: 0.78,
        bAlpha: 0.60,
      ),
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              final selected = i <= value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 28,
                    decoration: BoxDecoration(
                      color: selected ? cs.primary : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected
                            ? cs.primary.withValues(alpha: 0.65)
                            : cs.outlineVariant,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$i',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
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
  final ColorScheme colorScheme;

  _StressGraphPainter(this.records, this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;
    final paintLine = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final paintFill = Paint()
      ..shader = LinearGradient(
        colors: [
          colorScheme.primary.withValues(alpha: 0.22),
          colorScheme.primary.withValues(alpha: 0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

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
    final pointPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;
    for (int i = 0; i < records.length; i++) {
      final x = i * stepX;
      final y = size.height - (records[i].score / maxScore) * size.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StressGraphPainter oldDelegate) =>
      oldDelegate.records != records;
}
