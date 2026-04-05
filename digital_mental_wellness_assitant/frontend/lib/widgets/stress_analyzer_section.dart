import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import 'app_section_card.dart';








class StressAnalyzerSection extends StatefulWidget {
  const StressAnalyzerSection({super.key});

  @override
  State<StressAnalyzerSection> createState() => _StressAnalyzerSectionState();
}

class _StressAnalyzerSectionState extends State<StressAnalyzerSection>
    with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _quoteCtrl;
  double _dailyScore = 0;
  final Map<String, int> _answers = {};
  final List<_SAStressRecord> _history = [];
  DateTime _lastSaved = DateTime.now();
  bool _showGraph = true;
  bool _remindersOn = false;

  bool _dbLoading = false;
  bool _dbSaving = false;
  String? _dbError;
  int? _userId;

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

  String get _currentQuote =>
      _quotes[((_quoteCtrl.value * _quotes.length).floor()) % _quotes.length];

  @override
  void initState() {
    super.initState();
    _quoteCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _initDb();
  }

  @override
  void dispose() {
    _quoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _initDb() async {
    setState(() {
      _dbLoading = true;
      _dbError = null;
    });

    try {
      final id = await ProfileService.getUserId();
      if (!mounted) return;
      _userId = id;
      if (id == null) {
        setState(() {
          _dbLoading = false;
          _dbError = 'No user selected. Set a numeric user ID in Profile.';
        });
        return;
      }
      await _loadHistoryFromDb(id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dbLoading = false;
        _dbError = 'Failed to load stress history: $e';
      });
    }
  }

  Future<void> _loadHistoryFromDb(int userId) async {
    final json = await _api.get(
      '/stress/history?user_id=$userId&days=7&limit=50',
    );
    if (!mounted) return;

    final list = (json?['data'] is List)
        ? (json!['data'] as List)
        : const <dynamic>[];
    final records = <_SAStressRecord>[];

    DateTime? parseTs(dynamic value) {
      if (value == null) return null;
      final raw = value.toString();
      if (raw.isEmpty) return null;
      try {
        return DateTime.parse(raw);
      } catch (_) {
        return null;
      }
    }

    for (final row in list) {
      if (row is! Map) continue;
      final ts = parseTs(row['timestamp']);
      final level = row['stress_level'];
      final score = (level is num)
          ? level.toDouble()
          : double.tryParse(level?.toString() ?? '') ?? 0.0;
      if (ts == null) continue;
      records.add(_SAStressRecord(ts, score));
    }

    records.sort((a, b) => a.date.compareTo(b.date));

    setState(() {
      _history
        ..clear()
        ..addAll(records);
      if (_history.isNotEmpty) {
        _lastSaved = _history.last.date;
      }
      _dbLoading = false;
      _dbError = null;
    });
  }

  void _calculateScore() {
    int total = 0;
    for (final q in _questions) {
      total += _answers[q.text] ?? 0;
    }
    _dailyScore = (total / (_questions.length * 4)) * 100;
  }

  Future<void> _saveRecord() async {
    _calculateScore();

    final userId = _userId ?? await ProfileService.getUserId();
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set a user ID in Profile to save to database.'),
        ),
      );
      return;
    }

    setState(() {
      _dbSaving = true;
      _dbError = null;
    });

    final ok = await _api.saveQuestionnaireStress(
      userId: userId,
      stressLevel: _dailyScore,
    );

    if (!mounted) return;
    if (!ok) {
      setState(() {
        _dbSaving = false;
        _dbError = 'Failed to save to database.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save stress report to database.'),
        ),
      );
      return;
    }

    await _loadHistoryFromDb(userId);
    if (!mounted) return;

    setState(() {
      _dbSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved to database (score: ${_dailyScore.toStringAsFixed(1)})',
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
    final userMissing = _userId == null;
    return AppSectionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
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

          AnimatedBuilder(
            animation: _quoteCtrl,
            builder: (context, _) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppSectionCard.gradientFromScheme(
                  cs,
                  a: cs.primary,
                  b: cs.secondary,
                  aAlpha: 0.95,
                  bAlpha: 0.85,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.psychology_alt, color: cs.onPrimary, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stress Analyzer',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currentQuote,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onPrimary.withValues(alpha: 0.85),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Reminders',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Switch(
                          value: _remindersOn,
                          onChanged: (v) => setState(() => _remindersOn = v),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _presetChip('Calm', 0),
              _presetChip('Mild', 1),
              _presetChip('Moderate', 2),
              _presetChip('Tense', 3),
              _presetChip('Overwhelmed', 4),
            ],
          ),
          const SizedBox(height: 12),
          if (_dbLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          if (_dbError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_dbError!)),
                  TextButton(
                    onPressed: _dbLoading ? null : _initDb,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stress Level Questionnaire',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._questions.map(
                  (q) => _SAQuestionTile(
                    question: q.text,
                    value: _answers[q.text] ?? 0,
                    onChanged: (v) => setState(() => _answers[q.text] = v),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      _calculateScore();
                      setState(() {});
                    },
                    icon: const Icon(Icons.assessment),
                    label: const Text('Calculate Stress Score'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_dailyScore > 0)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: _SAGaugePainter(_dailyScore, cs),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _dailyScore.toStringAsFixed(0),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            _scoreLabel(_dailyScore),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Stress Score',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'A higher number indicates higher stress today. Use your result as a gentle nudge, not a judgment.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _dbSaving ? null : _saveRecord,
                            icon: _dbSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_alt),
                            label: Text(_dbSaving ? 'Saving...' : 'Save'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _exportReport,
                            icon: const Icon(Icons.download),
                            label: const Text('Export'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          if (_history.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Weekly Trend',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => _showGraph = !_showGraph),
                      icon: Icon(
                        _showGraph ? Icons.visibility : Icons.visibility_off,
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
                    height: 160,
                    child: CustomPaint(
                      painter: _SAStressGraphPainter(_history, cs),
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
                const SizedBox(height: 6),
                Text(
                  'Last saved: ${_lastSaved.toLocal().toString().split('.').first}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          if (_history.isEmpty &&
              !userMissing &&
              !_dbLoading &&
              _dbError == null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'No saved stress reports yet. Save one to build your weekly trend.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }


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
  final int value;
  final ValueChanged<int> onChanged;
  const _SAQuestionTile({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppSectionCard(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      radius: 16,
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
                    duration: const Duration(milliseconds: 160),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 26,
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
                        style: theme.textTheme.labelSmall?.copyWith(
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

class _SAStressRecord {
  final DateTime date;
  final double score;
  _SAStressRecord(this.date, this.score);
}

class _SAStressGraphPainter extends CustomPainter {
  final List<_SAStressRecord> records;
  final ColorScheme colorScheme;

  _SAStressGraphPainter(this.records, this.colorScheme);

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

    final pointPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;
    for (int i = 0; i < records.length; i++) {
      final x = records.length == 1 ? size.width / 2 : i * stepX;
      final y = size.height - (records[i].score / maxScore) * size.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SAStressGraphPainter oldDelegate) =>
      oldDelegate.records != records;
}


class _SAGaugePainter extends CustomPainter {
  final double score;
  final ColorScheme colorScheme;

  _SAGaugePainter(this.score, this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 6;

    final bg = Paint()
      ..color = colorScheme.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14 * 3 / 4,
      3.14 * 1.5,
      false,
      bg,
    );


    final grad = SweepGradient(
      colors: [colorScheme.primary, colorScheme.secondary],
      startAngle: 0,
      endAngle: 3.14 * 1.5,
    );
    final fg = Paint()
      ..shader = grad.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final sweep = (score.clamp(0, 100) / 100) * (3.14 * 1.5);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14 * 3 / 4,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _SAGaugePainter oldDelegate) =>
      oldDelegate.score != score;
}
