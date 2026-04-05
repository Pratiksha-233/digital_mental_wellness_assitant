import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../services/profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../widgets/app_section_card.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {

  int _selectedMood = -1;
  int _energyLevel = 0;
  bool _isSaving = false;
  final List<String> _activities = [
    'Exercise',
    'Work',
    'Social',
    'Family',
    'Hobbies',
    'Rest',
    'Nature',
    'Reading',
    'Music',
    'Cooking',
  ];
  final Set<String> _selectedActivities = {};
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Widget _moodButton(
    BuildContext context,
    int idx,
    String emoji,
    String label,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _selectedMood == idx;
    return GestureDetector(
      onTap: _isSaving ? null : () => setState(() => _selectedMood = idx),
      child: Container(
        width: 108,
        height: 98,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.secondaryContainer.withValues(alpha: 0.55)
              : cs.surface.withValues(alpha: 0.75),
          border: Border.all(
            color: isSelected ? cs.secondary : cs.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 13, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _energySegment(BuildContext context, int idx) {
    final cs = Theme.of(context).colorScheme;
    final active = idx <= _energyLevel;
    return Expanded(
      child: GestureDetector(
        onTap: _isSaving ? null : () => setState(() => _energyLevel = idx),
        child: Container(
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(colors: [cs.secondary, cs.tertiary])
                : null,
            color: active ? null : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('How Are You Feeling?')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 18.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
                Text(
                  'How Are You Feeling?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Take a moment to check in with yourself',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),


                SizedBox(
                  width: double.infinity,
                  child: AppSectionCard(
                    padding: const EdgeInsets.all(20),
                    gradient: AppSectionCard.gradientFromScheme(
                      cs,
                      a: cs.primaryContainer,
                      b: cs.secondaryContainer,
                      aAlpha: 0.40,
                      bAlpha: 0.26,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.favorite_border, color: cs.primary),
                                const SizedBox(width: 8),
                                const Text(
                                  'Log Your Mood',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _showHistory,
                              child: const Text('History'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Select your mood',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _moodButton(context, 0, '🤩', 'Amazing'),
                              const SizedBox(width: 12),
                              _moodButton(context, 1, '🙂', 'Good'),
                              const SizedBox(width: 12),
                              _moodButton(context, 2, '😐', 'Okay'),
                              const SizedBox(width: 12),
                              _moodButton(context, 3, '😔', 'Struggling'),
                              const SizedBox(width: 12),
                              _moodButton(context, 4, '😣', 'Difficult'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _energyLevel > 0
                                  ? 'Energy Level: $_energyLevel/5'
                                  : 'Energy Level: --/5',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${_selectedActivities.length} activity selected',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (i) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: _energySegment(context, i + 1),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 18),
                        Text(
                          'What did you do today?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _activities.map((a) {
                            final selected = _selectedActivities.contains(a);
                            return FilterChip(
                              label: Text(a),
                              selected: selected,
                              onSelected: _isSaving
                                  ? null
                                  : (v) => setState(
                                      () => v
                                          ? _selectedActivities.add(a)
                                          : _selectedActivities.remove(a),
                                    ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 18),
                        Text(
                          'Add a note (optional)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _noteController,
                          minLines: 3,
                          maxLines: 6,
                          enabled: !_isSaving,
                          decoration: InputDecoration(
                            hintText:
                                'What\'s on your mind? Any thoughts or reflections...',
                          ),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isSaving ? null : _saveMood,
                              icon: const Icon(Icons.save),
                              label: const Text('Save'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                backgroundColor: cs.primary,
                                foregroundColor: cs.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveMood() async {
    final moodLabel = _selectedMood >= 0
        ? ['Amazing', 'Good', 'Okay', 'Struggling', 'Difficult'][_selectedMood]
        : null;
    if (moodLabel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood before saving.')),
      );
      return;
    }

    final payload = {
      'mood_label': moodLabel,
      'energy_level': _energyLevel,
      'activities': _selectedActivities.toList(),
      'note': _noteController.text,
    };

    setState(() {
      _isSaving = true;
    });

    try {

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastMood', moodLabel);
      await prefs.setString('lastMoodTime', DateTime.now().toString());
      await prefs.setInt('lastEnergyLevel', _energyLevel);
      await prefs.setStringList('lastActivities', _selectedActivities.toList());
      await prefs.setString('lastNote', _noteController.text);


      int? storedId = await ProfileService.getUserId();
      if (storedId == null) {

        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser != null && fbUser.email != null) {
          final api = ApiService();
          final lookedUp = await api.lookupOrCreateUserByEmail(
            email: fbUser.email!,
            name: fbUser.displayName,
          );
          if (lookedUp != null) {
            storedId = lookedUp;
            await ProfileService.setUserId(storedId);
          } else {

            await _promptOpenProfile();
            return;
          }
        } else {

          await _promptOpenProfile();
          return;
        }
      }

      payload['user_id'] = storedId;

      final uri = Uri.parse('$apiBaseUrl/mood/log');
      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood saved successfully')),
        );

        if (mounted) {
          setState(() {
            _selectedMood = -1;
            _energyLevel = 0;
            _selectedActivities.clear();
            _noteController.clear();
          });
        }
      } else {

        final body = resp.body;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save mood: $body')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving mood: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<int?> _getOrLookupUserId() async {
    int? storedId = await ProfileService.getUserId();
    if (storedId != null) return storedId;
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null && fbUser.email != null) {
      final api = ApiService();
      final lookedUp = await api.lookupOrCreateUserByEmail(
        email: fbUser.email!,
        name: fbUser.displayName,
      );
      if (lookedUp != null) {
        await ProfileService.setUserId(lookedUp);
        return lookedUp;
      }
    }
    return null;
  }

  Future<void> _promptOpenProfile() async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('User ID required'),
          content: const Text(
            'A numeric `user_id` is required to save moods. You can set it in Profile settings or sign in with Google to automatically obtain it.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pushNamed(context, '/profile');
              },
              child: const Text('Open Profile'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showHistory() async {
    final storedId = await _getOrLookupUserId();
    if (storedId == null) {
      await _promptOpenProfile();
      return;
    }

    final api = ApiService();
    final rawLogs = await api.getMoodLogs(userId: storedId);

    if (rawLogs.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('History'),
          content: Text('No logs found.'),
        ),
      );
      return;
    }




    DateTime? parseTimestamp(dynamic value) {
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

    final logs =
        rawLogs
            .map<Map<String, dynamic>>((row) {
              final ts = parseTimestamp(row['timestamp']);
              return {
                'mood_label': row['mood_label'] ?? 'Unknown',
                'energy_level': row['energy_level'],
                'activities': row['activities'] ?? '',
                'timestamp': ts,
              };
            })
            .where((row) => row['timestamp'] != null)
            .toList()
          ..sort(
            (a, b) => (a['timestamp'] as DateTime).compareTo(
              b['timestamp'] as DateTime,
            ),
          );

    if (logs.isEmpty) {


      showModalBottomSheet(
        context: context,
        builder: (_) {
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: rawLogs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final row = rawLogs[i] as Map<String, dynamic>;
              final activities = (row['activities'] ?? '').toString();
              return ListTile(
                title: Text(row['mood_label']?.toString() ?? 'Unknown'),
                subtitle: Text(
                  'Energy: ${row['energy_level'] ?? '-'} • $activities',
                ),
                trailing: Text(
                  (row['timestamp'] ?? '').toString().split('.').first,
                ),
              );
            },
          );
        },
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return _MoodInsightsSheet(
              logs: logs,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }
}



class _MoodInsightsSheet extends StatefulWidget {
  final List<Map<String, dynamic>> logs;
  final ScrollController scrollController;

  const _MoodInsightsSheet({
    required this.logs,
    required this.scrollController,
  });

  @override
  State<_MoodInsightsSheet> createState() => _MoodInsightsSheetState();
}

class _MoodInsightsSheetState extends State<_MoodInsightsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = widget.logs;
    final weeklyData = _aggregateMood(logs, days: 7);
    final monthlyData = _aggregateMood(logs, days: 30);

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mood Insights',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'View your weekly and monthly mood trends based on your check-ins.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            indicatorColor: cs.primary,
            tabs: const [
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMoodSection(weeklyData, periodLabel: 'Last 7 days'),
                _buildMoodSection(monthlyData, periodLabel: 'Last 30 days'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection(_MoodAggregate data, {required String periodLabel}) {
    final avgLabel = _scoreToLabel(data.averageScore);
    final avgEmoji = _labelToEmoji(avgLabel);
    final trendEmoji = _trendEmoji(data.trend);

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            periodLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          AppSectionCard(
            padding: const EdgeInsets.all(12),
            gradient: AppSectionCard.gradientFromScheme(
              cs,
              a: cs.primaryContainer,
              b: cs.secondaryContainer,
              aAlpha: 0.28,
              bAlpha: 0.18,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Mood',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(avgEmoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            avgLabel,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Mood Trend',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(trendEmoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text(
                          _capitalize(data.trend),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Mood Graph',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          _buildMoodBarChart(data.dailyScores),
          const SizedBox(height: 24),
          const Text(
            'Recent Entries',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...data.recentEntries.map(
            (e) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(
                _labelToEmoji(e.moodLabel),
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(e.moodLabel),
              subtitle: Text(
                'Energy: ${e.energyLevel} • ${DateFormat('EEE, MMM d').format(e.timestamp)}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodBarChart(List<_DailyMoodScore> points) {
    if (points.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        child: const Text('Not enough data yet. Keep logging your mood!'),
      );
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final maxBarHeight = 140.0;

    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((p) {
          final normalized = (p.avgScore.clamp(1.0, 5.0) - 1.0) / 4.0;
          final barHeight = 40 + normalized * maxBarHeight;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _labelToEmoji(_scoreToLabel(p.avgScore)),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('E').format(p.date),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  _MoodAggregate _aggregateMood(
    List<Map<String, dynamic>> logs, {
    required int days,
  }) {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: days));

    final filtered = logs
        .where((row) => (row['timestamp'] as DateTime).isAfter(cutoff))
        .toList();

    if (filtered.isEmpty) {
      return _MoodAggregate.empty();
    }


    final Map<DateTime, List<_MoodEntry>> byDate = {};
    for (final row in filtered) {
      final ts = row['timestamp'] as DateTime;
      final dateKey = DateTime(ts.year, ts.month, ts.day);
      final moodLabel = row['mood_label']?.toString() ?? 'Unknown';
      final energyLevel =
          int.tryParse(row['energy_level']?.toString() ?? '') ?? 0;
      byDate.putIfAbsent(dateKey, () => []);
      byDate[dateKey]!.add(
        _MoodEntry(
          moodLabel: moodLabel,
          energyLevel: energyLevel,
          timestamp: ts,
        ),
      );
    }

    final dailyScores = byDate.entries.map((e) {
      final avgScore =
          e.value
              .map((m) => _labelToScore(m.moodLabel))
              .fold<double>(0, (p, c) => p + c) /
          e.value.length;
      return _DailyMoodScore(date: e.key, avgScore: avgScore);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    final allScores = dailyScores.map((d) => d.avgScore).toList();
    final averageScore = allScores.reduce((a, b) => a + b) / allScores.length;

    String trend = 'stable';
    if (allScores.length >= 2) {
      final mid = allScores.length ~/ 2;
      final firstAvg = allScores.sublist(0, mid).reduce((a, b) => a + b) / mid;
      final secondAvg =
          allScores.sublist(mid).reduce((a, b) => a + b) /
          (allScores.length - mid);
      final diff = secondAvg - firstAvg;
      const threshold = 0.3;
      if (diff > threshold) {
        trend = 'improving';
      } else if (diff < -threshold) {
        trend = 'declining';
      }
    }

    final recentEntries =
        filtered
            .map(
              (row) => _MoodEntry(
                moodLabel: row['mood_label'] as String,
                energyLevel:
                    int.tryParse(row['energy_level']?.toString() ?? '') ?? 0,
                timestamp: row['timestamp'] as DateTime,
              ),
            )
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return _MoodAggregate(
      averageScore: averageScore,
      trend: trend,
      dailyScores: dailyScores,
      recentEntries: recentEntries.take(5).toList(),
    );
  }

  static int _labelToScore(String label) {
    switch (label.toLowerCase()) {
      case 'amazing':
        return 5;
      case 'good':
        return 4;
      case 'okay':
        return 3;
      case 'struggling':
        return 2;
      case 'difficult':
        return 1;
      default:
        return 3;
    }
  }

  static String _scoreToLabel(double score) {
    if (score >= 4.5) return 'Amazing';
    if (score >= 3.5) return 'Good';
    if (score >= 2.5) return 'Okay';
    if (score >= 1.5) return 'Struggling';
    return 'Difficult';
  }

  static String _labelToEmoji(String label) {
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

  static String _trendEmoji(String trend) {
    switch (trend) {
      case 'improving':
        return '📈';
      case 'declining':
        return '📉';
      default:
        return '➡️';
    }
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
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

class _DailyMoodScore {
  final DateTime date;
  final double avgScore;

  _DailyMoodScore({required this.date, required this.avgScore});
}

class _MoodAggregate {
  final double averageScore;
  final String trend;
  final List<_DailyMoodScore> dailyScores;
  final List<_MoodEntry> recentEntries;

  _MoodAggregate({
    required this.averageScore,
    required this.trend,
    required this.dailyScores,
    required this.recentEntries,
  });

  factory _MoodAggregate.empty() {
    return _MoodAggregate(
      averageScore: 3,
      trend: 'stable',
      dailyScores: const [],
      recentEntries: const [],
    );
  }
}
