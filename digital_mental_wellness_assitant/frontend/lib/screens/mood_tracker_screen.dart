import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../services/profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  // moods: Amazing, Good, Okay, Struggling, Difficult
  int _selectedMood = -1;
  int _energyLevel = 0; // 0 = not selected yet, then 1..5
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

  Widget _moodButton(int idx, String emoji, String label) {
    final isSelected = _selectedMood == idx;
    return GestureDetector(
      onTap: _isSaving ? null : () => setState(() => _selectedMood = idx),
      child: Container(
        width: 108,
        height: 98,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _energySegment(int idx) {
    final active = idx <= _energyLevel;
    return Expanded(
      child: GestureDetector(
        onTap: _isSaving ? null : () => setState(() => _energyLevel = idx),
        child: Container(
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    colors: [Colors.purple.shade300, Colors.pink.shade300],
                  )
                : null,
            color: active ? null : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.purple.shade100.withAlpha(120),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'How Are You Feeling?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Take a moment to check in with yourself',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 18),

                // Main centered card similar to the mockup
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    color: Colors.purple,
                                  ),
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

                          const Text(
                            'Select your mood',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _moodButton(0, '🤩', 'Amazing'),
                                const SizedBox(width: 12),
                                _moodButton(1, '🙂', 'Good'),
                                const SizedBox(width: 12),
                                _moodButton(2, '😐', 'Okay'),
                                const SizedBox(width: 12),
                                _moodButton(3, '😔', 'Struggling'),
                                const SizedBox(width: 12),
                                _moodButton(4, '😣', 'Difficult'),
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
                                style: const TextStyle(color: Colors.black54),
                              ),
                              Text(
                                '${_selectedActivities.length} activity selected',
                                style: const TextStyle(color: Colors.black38),
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
                                  child: _energySegment(i + 1),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 18),
                          const Text(
                            'What did you do today?',
                            style: TextStyle(color: Colors.black54),
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
                          const Text(
                            'Add a note (optional)',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _noteController,
                            minLines: 3,
                            maxLines: 6,
                            enabled: !_isSaving,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                                  backgroundColor: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
      // Save to local storage first (shared_preferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastMood', moodLabel);
      await prefs.setString('lastMoodTime', DateTime.now().toString());
      await prefs.setInt('lastEnergyLevel', _energyLevel);
      await prefs.setStringList('lastActivities', _selectedActivities.toList());
      await prefs.setString('lastNote', _noteController.text);

      // Ensure we have a numeric `user_id` available — read from prefs or attempt automatic lookup via Firebase.
      int? storedId = await ProfileService.getUserId();
      if (storedId == null) {
        // Try to obtain from Firebase-authenticated user by calling backend lookup endpoint
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
            // failed to lookup — prompt user to open Profile settings
            await _promptOpenProfile();
            return;
          }
        } else {
          // No stored id and not signed in with Firebase — prompt the user to set it in Profile settings
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
        // reset form to a clean state so nothing remains filled
        if (mounted) {
          setState(() {
            _selectedMood = -1;
            _energyLevel = 0;
            _selectedActivities.clear();
            _noteController.clear();
          });
        }
      } else {
        // show backend response body for debugging
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

    // Normalize and sort logs by timestamp (newest last for graphs).
    // Be lenient in how we parse the timestamp because different backends
    // may format the datetime slightly differently.
    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      final tsRaw = value.toString();
      if (tsRaw.isEmpty) return null;
      try {
        return DateTime.parse(tsRaw);
      } catch (_) {
        // Try common HTTP/RFC style format like:
        // "Thu, 12 Mar 2026 21:33:40 GMT"
        try {
          final httpFmt = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
          return httpFmt.parseUtc(tsRaw).toLocal();
        } catch (_) {
          // Fallback: trim fractional seconds / timezone text if present
          // and retry ISO8601 parsing.
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
      // If we still could not parse any timestamps, fall back to the
      // simple list history so the user can at least see saved moods.
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

/// Bottom sheet widget that shows advanced weekly & monthly mood graphs
/// and basic mood trend analysis based on the raw mood logs.
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

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Mood Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'View your weekly and monthly mood trends based on your check-ins.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.purple,
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

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            periodLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Average Mood',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(avgEmoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            avgLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
                    const Text(
                      'Mood Trend',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(trendEmoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text(
                          _capitalize(data.trend),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
          const Text(
            'Mood Graph',
            style: TextStyle(fontWeight: FontWeight.w600),
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

    final maxBarHeight = 140.0;

    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((p) {
          final normalized = (p.avgScore.clamp(1.0, 5.0) - 1.0) / 4.0; // 0..1
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
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade300, Colors.green.shade300],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('E').format(p.date),
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
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

    // group by date
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
