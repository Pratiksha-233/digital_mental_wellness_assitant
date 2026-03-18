import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
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
  bool _hasLoadedOnce = false;
  bool _loadInFlight = false;
  bool _userIdMissing = false;
  Timer? _autoRefreshTimer;

  List<dynamic> _mood = const [];
  List<dynamic> _stress = const [];
  List<Map<String, dynamic>> _stressHistory = const [];
  Map<String, dynamic> _sentiment = const {
    'positive': 0.0,
    'neutral': 0.0,
    'negative': 0.0,
  };
  Map<String, dynamic> _faceDetection = const {
    'total': 0,
    'by_emotion': {},
    'avg_confidence': 0.0,
  };
  List<dynamic> _activity = const [];
  List<_MoodEntry> _recentMoodEntries = const [];
  int _moodCheckins = 0;
  int _journalEntries = 0;
  int _daysActive = 0;

  @override
  void initState() {
    super.initState();
    _load(showSpinner: true);


    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      if (_loadInFlight) return;
      _load(showSpinner: false);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({required bool showSpinner}) async {
    if (_loadInFlight) return;
    _loadInFlight = true;

    final shouldShowSpinner = showSpinner || !_hasLoadedOnce;
    if (mounted) {
      setState(() {
        _userIdMissing = false;
        if (shouldShowSpinner) {
          _loading = true;
        }
      });
    }


    final userId = (await ProfileService.getUserId()) ?? 1;

    try {

      final results = await Future.wait<dynamic>([
        _api.getMoodAnalytics(userId),
        _api.getStressAnalytics(userId),
        _api.get('/stress/history?user_id=$userId&days=30&limit=50'),
        _api.getChatSentiment(userId),
        _api.getFaceDetectionAnalytics(userId),
        _api.getActivityAnalytics(userId),
        _api.getProgress(userId: userId),
        _api.getMoodLogs(userId: userId),
      ]);

      final mood = (results[0] as List<dynamic>?) ?? const [];
      final stress = (results[1] as List<dynamic>?) ?? const [];
      final stressHistoryJson = results[2] as Map<String, dynamic>?;
      final sentiment =
          (results[3] as Map<String, dynamic>?) ??
          const {'positive': 0.0, 'neutral': 0.0, 'negative': 0.0};
      final faceDetection =
          (results[4] as Map<String, dynamic>?) ??
          const {'total': 0, 'by_emotion': {}, 'avg_confidence': 0.0};
      final activity = (results[5] as List<dynamic>?) ?? const [];
      final progress =
          (results[6] as Map<String, dynamic>?) ??
          const {'mood_checkins': 0, 'journal_entries': 0, 'days_active': 0};
      final rawLogs = (results[7] as List<dynamic>?) ?? const [];
      if (!mounted) return;

      final stressHistoryRows = (stressHistoryJson?['data'] is List)
          ? (stressHistoryJson!['data'] as List)
          : const <dynamic>[];
      final parsedStressHistory = <Map<String, dynamic>>[];
      for (final row in stressHistoryRows) {
        if (row is Map) {
          parsedStressHistory.add(row.map((k, v) => MapEntry(k.toString(), v)));
        }
      }
      parsedStressHistory.sort((a, b) {
        final at = (a['timestamp'] ?? '').toString();
        final bt = (b['timestamp'] ?? '').toString();
        return bt.compareTo(at);
      });

      final nextRecentMood = _parseRecentMoodEntries(rawLogs, days: 7);
      final nextMoodCheckins = (progress['mood_checkins'] as int?) ?? 0;
      final nextJournalEntries = (progress['journal_entries'] as int?) ?? 0;
      final nextDaysActive = (progress['days_active'] as int?) ?? 0;


      final changed =
          !_listEqualsDynamic(_mood, mood) ||
          !_listEqualsDynamic(_stress, stress) ||
          !_listEqualsMap(_stressHistory, parsedStressHistory) ||
          !_mapEqualsDynamic(_sentiment, sentiment) ||
          !_mapEqualsDynamic(_faceDetection, faceDetection) ||
          !_listEqualsDynamic(_activity, activity) ||
          _moodCheckins != nextMoodCheckins ||
          _journalEntries != nextJournalEntries ||
          _daysActive != nextDaysActive ||
          !_recentMoodEquals(_recentMoodEntries, nextRecentMood);

      if (changed && mounted) {
        setState(() {
          _mood = mood;
          _stress = stress;
          _stressHistory = parsedStressHistory;
          _sentiment = sentiment;
          _faceDetection = faceDetection;
          _activity = activity;
          _moodCheckins = nextMoodCheckins;
          _journalEntries = nextJournalEntries;
          _daysActive = nextDaysActive;
          _recentMoodEntries = nextRecentMood;
        });
      }
    } finally {
      _hasLoadedOnce = true;
      _loadInFlight = false;
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _calculateStressNow() async {
    final userId = (await ProfileService.getUserId()) ?? 1;
    setState(() {
      _loading = true;
    });
    try {
      await _api.get('/stress/calculate?user_id=$userId');
    } finally {
      await _load(showSpinner: false);
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
            onPressed: (_loading || _loadInFlight)
                ? null
                : () => _load(showSpinner: false),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: _userIdMissing
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No user selected',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set a numeric user ID in Profile settings or sign in to see your personal analytics.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                      child: const Text('Open Profile'),
                    ),
                  ],
                ),
              ),
            )
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
                            _buildFaceDetectionCard(theme),
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

  bool _mapEqualsDynamic(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k)) return false;
      final av = a[k];
      final bv = b[k];
      if (av is Map && bv is Map) {
        final am = av.map((k, v) => MapEntry(k.toString(), v));
        final bm = bv.map((k, v) => MapEntry(k.toString(), v));
        if (!_mapEqualsDynamic(am, bm)) return false;
      } else if (av is List && bv is List) {
        if (!_listEqualsDynamic(av, bv)) return false;
      } else {
        if (av != bv) return false;
      }
    }
    return true;
  }

  bool _listEqualsDynamic(List a, List b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final av = a[i];
      final bv = b[i];
      if (av is Map && bv is Map) {
        final am = av.map((k, v) => MapEntry(k.toString(), v));
        final bm = bv.map((k, v) => MapEntry(k.toString(), v));
        if (!_mapEqualsDynamic(am, bm)) return false;
      } else if (av is List && bv is List) {
        if (!_listEqualsDynamic(av, bv)) return false;
      } else {
        if (av != bv) return false;
      }
    }
    return true;
  }

  bool _listEqualsMap(
    List<Map<String, dynamic>> a,
    List<Map<String, dynamic>> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_mapEqualsDynamic(a[i], b[i])) return false;
    }
    return true;
  }

  bool _recentMoodEquals(List<_MoodEntry> a, List<_MoodEntry> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final ae = a[i];
      final be = b[i];
      if (ae.moodLabel != be.moodLabel) return false;
      if (ae.energyLevel != be.energyLevel) return false;
      if (ae.timestamp != be.timestamp) return false;
      if (ae.note != be.note) return false;
      if (ae.activities != be.activities) return false;
    }
    return true;
  }

  Widget _buildSummaryRow(ThemeData theme, {required bool isWide}) {
    final cs = theme.colorScheme;
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
        color: cs.primary,
      ),
      _summaryTile(
        theme,
        title: 'Sentiment',
        value: '${pos.toStringAsFixed(0)}% positive',
        subtitle: sentimentLabel,
        icon: Icons.chat_bubble_outline,
        color: cs.secondary,
      ),
      _summaryTile(
        theme,
        title: 'Activity',
        value: activityLabel,
        subtitle: 'Last 30 days',
        icon: Icons.local_fire_department,
        color: cs.tertiary,
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
    final cs = theme.colorScheme;
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
                    color: cs.onSurfaceVariant,
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

    final maxScore = 5.0;
    final cs = theme.colorScheme;
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
              lineColor: cs.primary,
              fillColor: cs.primary.withOpacity(0.15),
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
          final when = DateFormat('EEE, MMM d').format(entry.timestamp);
          final activities = entry.activities.trim();
          final note = entry.note.trim();
          final secondLine = activities.isNotEmpty
              ? 'Activities: $activities'
              : (note.isNotEmpty ? 'Note: $note' : '');
          return ListTile(
            contentPadding: EdgeInsets.zero,
            isThreeLine: secondLine.isNotEmpty,
            leading: Text(
              _labelToEmoji(entry.moodLabel),
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(entry.moodLabel),
            subtitle: Text(
              secondLine.isEmpty
                  ? 'Energy: ${entry.energyLevel} • $when'
                  : 'Energy: ${entry.energyLevel} • $when\n$secondLine',
            ),
          );
        },
      ),
    );
  }

  Widget _buildStressCard(ThemeData theme) {
    final cs = theme.colorScheme;

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

    String latestSummary = 'No stress data yet.';
    if (_stressHistory.isNotEmpty) {
      final latest = _stressHistory.first;
      final levelRaw = latest['stress_level'];
      final level = (levelRaw is num)
          ? levelRaw.toDouble()
          : double.tryParse(levelRaw?.toString() ?? '') ?? 0.0;
      final cat = (latest['stress_category'] ?? '').toString();
      final ts = parseTs(latest['timestamp']);
      final when = ts == null ? '' : DateFormat('MMM d').format(ts);
      latestSummary =
          '${level.toStringAsFixed(0)} / 100'
          '${cat.isEmpty ? '' : ' • $cat'}'
          '${when.isEmpty ? '' : ' • $when'}';
    }

    final dailyPoints = List<Map<String, dynamic>>.from(
      _stress.cast<Map<String, dynamic>>(),
    );
    dailyPoints.sort((a, b) {
      final ad = (a['date'] ?? '').toString();
      final bd = (b['date'] ?? '').toString();
      return ad.compareTo(bd);
    });

    final fallbackPoints =
        _stressHistory
            .take(30)
            .map(
              (r) => {
                'date': (r['timestamp'] ?? '').toString().split('T').first,
                'level': r['stress_level'],
              },
            )
            .toList()
          ..sort((a, b) {
            final ad = (a['date'] ?? '').toString();
            final bd = (b['date'] ?? '').toString();
            return ad.compareTo(bd);
          });

    final pointsForChart = dailyPoints.isNotEmpty
        ? dailyPoints
        : fallbackPoints;

    if (pointsForChart.isEmpty) {
      return _buildCard(
        theme,
        title: 'Stress Levels',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No stress records yet.', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                'Calculate now to save a DB record to your history.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loading ? null : _calculateStressNow,
                icon: const Icon(Icons.bolt),
                label: const Text('Calculate Now'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildCard(
      theme,
      title: 'Stress History (Last 30 days)',
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Latest',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  latestSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: CustomPaint(
              painter: _LineChartPainter(
                data: pointsForChart
                    .map<double>(
                      (e) =>
                          (e['level'] as num?)?.toDouble() ??
                          double.tryParse(e['level']?.toString() ?? '') ??
                          0.0,
                    )
                    .toList(),
                maxY: 100.0,
                lineColor: cs.error,
                fillColor: cs.error.withOpacity(0.12),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Data source: stress_logs (DB)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentCard(ThemeData theme) {
    final pos = (_sentiment['positive'] as num?)?.toDouble() ?? 0.0;
    final neu = (_sentiment['neutral'] as num?)?.toDouble() ?? 0.0;
    final neg = (_sentiment['negative'] as num?)?.toDouble() ?? 0.0;
    final total = (pos + neu + neg).clamp(1.0, 100.0);
    final cs = theme.colorScheme;
    return _buildCard(
      theme,
      title: 'Chat Sentiment',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _sentimentBar('Positive', pos / total, cs.primary),
          const SizedBox(height: 8),
          _sentimentBar('Neutral', neu / total, cs.onSurfaceVariant),
          const SizedBox(height: 8),
          _sentimentBar('Negative', neg / total, cs.error),
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

  Widget _buildFaceDetectionCard(ThemeData theme) {
    final cs = theme.colorScheme;
    final total = (_faceDetection['total'] as num?)?.toInt() ?? 0;
    final avgConf =
        (_faceDetection['avg_confidence'] as num?)?.toDouble() ?? 0.0;
    final byEmotion = (_faceDetection['by_emotion'] as Map?) ?? {};

    String description;
    if (total == 0) {
      description = 'No face detection data yet.';
    } else {
      final mostCommon = byEmotion.entries.where((e) => e.value is num).toList()
        ..sort((a, b) => (b.value as num).compareTo(a.value as num));
      final topEmotion = mostCommon.isNotEmpty ? mostCommon.first.key : 'N/A';
      description =
          '$topEmotion detected most frequently (avg confidence ${avgConf.toStringAsFixed(0)}%)';
    }

    final entries =
        byEmotion.entries
            .where((e) => e.value is num)
            .map((e) => MapEntry(e.key.toString(), (e.value as num).toInt()))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return _buildCard(
      theme,
      title: 'Face Detection',
      child: total == 0
          ? Center(
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 10),
                Text(
                  'Breakdown (top 5)',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.builder(
                    itemCount: entries.length < 5 ? entries.length : 5,
                    itemBuilder: (context, index) {
                      final e = entries[index];
                      final fraction = total == 0
                          ? 0.0
                          : (e.value / total).clamp(0.0, 1.0);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                e.key,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: cs.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: fraction,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              e.value.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Avg confidence: ${avgConf.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActivityCard(ThemeData theme) {
    if (_activity.isEmpty) {
      final cs = theme.colorScheme;
      return _buildCard(
        theme,
        title: 'Activity (Last 30 days)',
        child: Center(
          child: Text(
            'No activity records in the database yet.\nLog a mood with activities to populate your activity history.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
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
    final cs = theme.colorScheme;
    return _buildCard(
      theme,
      title: 'Activity (Last 30 days)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Most logged activities',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
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
                        width: 100,
                        child: Text(label, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: cs.secondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: fraction,
                            child: Container(
                              decoration: BoxDecoration(
                                color: cs.secondary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        count.toStringAsFixed(0),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodEntry {
  final String moodLabel;
  final int energyLevel;
  final String activities;
  final String note;
  final DateTime timestamp;

  _MoodEntry({
    required this.moodLabel,
    required this.energyLevel,
    required this.activities,
    required this.note,
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
    final activities = (row['activities'] ?? '').toString();
    final note = (row['note'] ?? '').toString();
    list.add(
      _MoodEntry(
        moodLabel: label,
        energyLevel: energy,
        activities: activities,
        note: note,
        timestamp: ts,
      ),
    );
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
