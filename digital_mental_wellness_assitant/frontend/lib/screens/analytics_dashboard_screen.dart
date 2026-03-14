import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  List<dynamic> _mood = const [];
  List<dynamic> _stress = const [];
  Map<String, dynamic> _sentiment = const {
    'positive': 0.0,
    'neutral': 0.0,
    'negative': 0.0,
  };
  List<dynamic> _activity = const [];
  List<_MoodEntry> _recentMoodEntries = const [];
  int _moodCheckins = 0;
  int _journalEntries = 0;
  int _daysActive = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final userId = await ProfileService.getUserId() ?? 1;
    try {
      final mood = await _api.getMoodAnalytics(userId);
      final stress = await _api.getStressAnalytics(userId);
      final sentiment = await _api.getChatSentiment(userId);
      final activity = await _api.getActivityAnalytics(userId);
      final progress = await _api.getProgress(userId: userId);
      final rawLogs = await _api.getMoodLogs(userId: userId);
      if (!mounted) return;
      setState(() {
        _mood = mood;
        _stress = stress;
        _sentiment = sentiment;
        _activity = activity;
        _moodCheckins = (progress['mood_checkins'] as int?) ?? 0;
        _journalEntries = (progress['journal_entries'] as int?) ?? 0;
        _daysActive = (progress['days_active'] as int?) ?? 0;
        _recentMoodEntries = _parseRecentMoodEntries(rawLogs, days: 7);
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Dashboard'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  final grid = SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 3 : 1,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isWide ? 1.3 : 1.1,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryRow(theme, isWide: isWide),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView(
                          gridDelegate: grid,
                          children: [
                            _buildMoodCard(theme),
                            _buildRecentMoodCard(theme),
                            _buildStressCard(theme),
                            _buildSentimentCard(theme),
                            _buildActivityCard(theme),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, {required bool isWide}) {
    final pos = (_sentiment['positive'] as num?)?.toDouble() ?? 0.0;
    final neg = (_sentiment['negative'] as num?)?.toDouble() ?? 0.0;
    String sentimentLabel = 'Balanced';
    if (pos > neg && pos >= 40) {
      sentimentLabel = 'Mostly positive';
    } else if (neg > pos && neg >= 40) {
      sentimentLabel = 'Leaning negative';
    }

    String activityLabel = 'No activity yet';
    if (_activity.isNotEmpty) {
      final items = _activity.cast<Map<String, dynamic>>();
      items.sort((a, b) => (b['count'] as num).compareTo(a['count'] as num));
      final top = items.first;
      activityLabel = '${top['type']} (${top['count']}) most logged';
    }

    final children = <Widget>[
      _summaryTile(
        theme,
        title: 'Check-ins',
        value: '$_moodCheckins moods',
        subtitle: '$_journalEntries journal entries • $_daysActive active days',
        icon: Icons.insights,
        color: Colors.indigo,
      ),
      _summaryTile(
        theme,
        title: 'Sentiment',
        value: '${pos.toStringAsFixed(0)}% positive',
        subtitle: sentimentLabel,
        icon: Icons.chat_bubble_outline,
        color: Colors.teal,
      ),
      _summaryTile(
        theme,
        title: 'Activity',
        value: activityLabel,
        subtitle: 'Last 30 days',
        icon: Icons.local_fire_department,
        color: Colors.orange,
      ),
    ];

    if (isWide) {
      return Row(
        children: children
            .map(
              (w) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: w,
                ),
              ),
            )
            .toList(),
      );
    }
    return Column(
      children: children
          .map(
            (w) =>
                Padding(padding: const EdgeInsets.only(bottom: 12), child: w),
          )
          .toList(),
    );
  }

  Widget _summaryTile(
    ThemeData theme, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    ThemeData theme, {
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard(ThemeData theme) {
    if (_mood.isEmpty) {
      return _buildCard(
        theme,
        title: 'Mood Trend',
        child: const Center(child: Text('No mood data yet. Keep logging!')),
      );
    }
    // Simple line-like chart using bars and a polyline impression
    final maxScore = 5.0;
    return _buildCard(
      theme,
      title: 'Mood Trend (Last 30 days)',
      child: LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth;
          final height = c.maxHeight;
          final points = _mood.cast<Map<String, dynamic>>();
          return CustomPaint(
            painter: _LineChartPainter(
              data: points
                  .map<double>((e) => (e['score'] as num?)?.toDouble() ?? 0.0)
                  .toList(),
              maxY: maxScore,
              lineColor: Colors.indigo,
              fillColor: Colors.indigo.withOpacity(0.15),
            ),
            child: SizedBox(width: width, height: height),
          );
        },
      ),
    );
  }

  Widget _buildRecentMoodCard(ThemeData theme) {
    if (_recentMoodEntries.isEmpty) {
      return _buildCard(
        theme,
        title: 'Recent Mood Entries',
        child: const Center(
          child: Text('No mood entries yet. Start logging your mood!'),
        ),
      );
    }

    return _buildCard(
      theme,
      title: 'Recent Mood Entries',
      child: ListView.builder(
        itemCount: _recentMoodEntries.length,
        itemBuilder: (context, index) {
          final entry = _recentMoodEntries[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Text(
              _labelToEmoji(entry.moodLabel),
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(entry.moodLabel),
            subtitle: Text(
              'Energy: ${entry.energyLevel} • ${DateFormat('EEE, MMM d').format(entry.timestamp)}',
            ),
          );
        },
      ),
    );
  }

  Widget _buildStressCard(ThemeData theme) {
    if (_stress.isEmpty) {
      return _buildCard(
        theme,
        title: 'Stress Levels',
        child: const Center(child: Text('No stress data yet.')),
      );
    }
    final items = _stress.cast<Map<String, dynamic>>();
    final maxLevel = 100.0;
    return _buildCard(
      theme,
      title: 'Stress Levels (Last 30 days)',
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final row = items[index];
          final date = row['date']?.toString() ?? '';
          final level = (row['level'] as num?)?.toDouble() ?? 0.0;
          final fraction = (level / maxLevel).clamp(0.0, 1.0);
          Color barColor;
          if (level < 33) {
            barColor = Colors.green;
          } else if (level < 66) {
            barColor = Colors.orange;
          } else {
            barColor = Colors.red;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(date, style: const TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: barColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: fraction,
                      child: Container(
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  level.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSentimentCard(ThemeData theme) {
    final pos = (_sentiment['positive'] as num?)?.toDouble() ?? 0.0;
    final neu = (_sentiment['neutral'] as num?)?.toDouble() ?? 0.0;
    final neg = (_sentiment['negative'] as num?)?.toDouble() ?? 0.0;
    final total = (pos + neu + neg).clamp(1.0, 100.0);
    return _buildCard(
      theme,
      title: 'Chat Sentiment',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _sentimentBar('Positive', pos / total, Colors.green),
          const SizedBox(height: 8),
          _sentimentBar('Neutral', neu / total, Colors.grey),
          const SizedBox(height: 8),
          _sentimentBar('Negative', neg / total, Colors.red),
        ],
      ),
    );
  }

  Widget _sentimentBar(String label, double fraction, Color color) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction.isNaN ? 0.0 : fraction.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(fraction * 100).toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildActivityCard(ThemeData theme) {
    if (_activity.isEmpty) {
      return _buildCard(
        theme,
        title: 'Activity (Last 30 days)',
        child: const Center(child: Text('No activity data yet.')),
      );
    }
    final items = _activity.cast<Map<String, dynamic>>();
    final maxCount = items
        .fold<num>(
          0,
          (prev, e) =>
              e['count'] is num && e['count'] > prev ? e['count'] as num : prev,
        )
        .toDouble();
    return _buildCard(
      theme,
      title: 'Activity (Last 30 days)',
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final row = items[index];
          final label = row['type']?.toString() ?? 'Unknown';
          final count = (row['count'] as num?)?.toDouble() ?? 0.0;
          final fraction = maxCount == 0
              ? 0.0
              : (count / maxCount).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(label, style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: fraction,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  count.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MoodEntry {
  final String moodLabel;
  final int energyLevel;
  final DateTime timestamp;

  _MoodEntry({
    required this.moodLabel,
    required this.energyLevel,
    required this.timestamp,
  });
}

List<_MoodEntry> _parseRecentMoodEntries(
  List<dynamic> rawLogs, {
  int days = 7,
}) {
  if (rawLogs.isEmpty) return const [];

  final now = DateTime.now();
  final cutoff = now.subtract(Duration(days: days));

  DateTime? parseTs(dynamic value) {
    if (value == null) return null;
    final tsRaw = value.toString();
    if (tsRaw.isEmpty) return null;
    try {
      return DateTime.parse(tsRaw);
    } catch (_) {
      try {
        final httpFmt = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
        return httpFmt.parseUtc(tsRaw).toLocal();
      } catch (_) {
        final cleaned = tsRaw
            .replaceAll('T', ' ')
            .split('.')
            .first
            .split('+')
            .first
            .split('Z')
            .first
            .trim();
        try {
          return DateTime.parse(cleaned);
        } catch (_) {
          return null;
        }
      }
    }
  }

  final list = <_MoodEntry>[];
  for (final row in rawLogs) {
    if (row is! Map<String, dynamic>) continue;
    final ts = parseTs(row['timestamp']);
    if (ts == null || ts.isBefore(cutoff)) continue;
    final label = (row['mood_label'] ?? 'Unknown').toString();
    final energyRaw = row['energy_level'];
    final energy = int.tryParse(energyRaw?.toString() ?? '') ?? 0;
    list.add(_MoodEntry(moodLabel: label, energyLevel: energy, timestamp: ts));
  }

  list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return list.take(5).toList();
}

String _labelToEmoji(String label) {
  switch (label.toLowerCase()) {
    case 'amazing':
      return '🤩';
    case 'good':
      return '🙂';
    case 'okay':
      return '😐';
    case 'struggling':
      return '😔';
    case 'difficult':
      return '😣';
    default:
      return '🙂';
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxY;
  final Color lineColor;
  final Color fillColor;

  _LineChartPainter({
    required this.data,
    required this.maxY,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final paintFill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final dx = size.width / (data.length - 1).clamp(1, 999);
    for (var i = 0; i < data.length; i++) {
      final x = dx * i;
      final value = data[i].clamp(0.0, maxY);
      final y = size.height - (value / maxY) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.maxY != maxY ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}
