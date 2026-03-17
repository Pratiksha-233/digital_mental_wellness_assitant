import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/profile_service.dart';
import 'journal_screen.dart';

class WeekViewScreen extends StatefulWidget {
  const WeekViewScreen({super.key});

  @override
  State<WeekViewScreen> createState() => _WeekViewScreenState();
}

class _WeekViewScreenState extends State<WeekViewScreen> {
  late DateTime _displayMonth; // first day of month

  late final Future<int> _userIdFuture;
  late final Future<List<dynamic>> _moodLogsFuture;

  int _resolvedUserId = 1;

  int? _hoveredCellIndex;

  DateTime get _todayIST {
    final nowUtc = DateTime.now().toUtc();
    return nowUtc.add(const Duration(hours: 5, minutes: 30));
  }

  DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    final t = _todayIST;
    _displayMonth = DateTime(t.year, t.month, 1);

    _userIdFuture = ProfileService.getUserId().then((v) => (v ?? 1));
    _userIdFuture.then((id) {
      _resolvedUserId = id;
    });
    _moodLogsFuture = _userIdFuture.then(
      (id) => ApiService().getMoodLogs(userId: id),
    );
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    });
  }

  String _monthLabel(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _moodLabelToEmoji(String? label) {
    if (label == null) return '😐';
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
        return '😐';
    }
  }

  Color _moodIndicatorColor(BuildContext context, String? moodLabel) {
    final cs = Theme.of(context).colorScheme;
    if (moodLabel == null) return cs.outlineVariant;
    switch (moodLabel.toLowerCase()) {
      case 'amazing':
      case 'good':
      case 'happy':
        return cs.tertiary;
      case 'okay':
      case 'neutral':
        return cs.secondary;
      case 'struggling':
      case 'difficult':
      case 'sad':
      case 'angry':
      case 'fear':
        return cs.error;
      default:
        return cs.outline;
    }
  }

  int _currentStreak(DateTime today, Map<DateTime, String> moodByDay) {
    var streak = 0;
    var cursor = dateOnly(today);
    while (moodByDay.containsKey(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _longestStreakForMonth(
    DateTime monthFirst,
    int daysInMonth,
    Map<DateTime, String> moodByDay,
  ) {
    var best = 0;
    var current = 0;
    for (var day = 1; day <= daysInMonth; day++) {
      final d = DateTime(monthFirst.year, monthFirst.month, day);
      if (moodByDay.containsKey(d)) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  Widget _statChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Chip(
      avatar: Icon(icon, size: 18, color: cs.primary),
      label: RichText(
        text: TextSpan(
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(text: value),
            TextSpan(
              text: '  $label',
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      side: BorderSide(color: cs.outlineVariant),
      backgroundColor: cs.surface,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final today = dateOnly(_todayIST);
    final first = _displayMonth;
    final firstWeekday = first.weekday % 7; // Sun=0..Sat=6
    final daysInMonth = DateTime(first.year, first.month + 1, 0).day;
    final cells = <DateTime?>[];
    // leading blanks to align to Sunday
    for (int i = 0; i < firstWeekday; i++) {
      cells.add(null);
    }
    // dates
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(first.year, first.month, d));
    }
    // pad to complete rows of 7
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_monthLabel(first)),
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back'),
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Previous month',
            onPressed: _prevMonth,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'Next month',
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _moodLogsFuture,
                builder: (context, snap) {
                  final moodByDay = <DateTime, String>{};
                  final latestTsByDay = <DateTime, DateTime>{};
                  if (snap.hasData) {
                    for (final row in snap.data!) {
                      try {
                        final ts = row['timestamp'] ?? row['created_at'];
                        if (ts == null) continue;
                        final dt = DateTime.parse(ts.toString());
                        final label = (row['mood_label'] ?? '').toString();
                        final day = dateOnly(dt);

                        // Keep the latest label of the day if multiple logs exist.
                        final prevTs = latestTsByDay[day];
                        if (prevTs == null || dt.isAfter(prevTs)) {
                          latestTsByDay[day] = dt;
                          moodByDay[day] = label;
                        }
                      } catch (_) {}
                    }
                  }

                  final monthEntries = <DateTime, String>{};
                  for (final e in moodByDay.entries) {
                    final d = e.key;
                    if (d.year == first.year && d.month == first.month) {
                      monthEntries[d] = e.value;
                    }
                  }

                  final thisMonthCheckins = monthEntries.length;
                  final mostCommonMood = () {
                    final counts = <String, int>{};
                    for (final v in monthEntries.values) {
                      final key = v.toLowerCase().trim();
                      if (key.isEmpty) continue;
                      counts[key] = (counts[key] ?? 0) + 1;
                    }
                    if (counts.isEmpty) return null;
                    final best = counts.entries.reduce(
                      (a, b) => a.value >= b.value ? a : b,
                    );
                    return best.key;
                  }();

                  final longestStreak = _longestStreakForMonth(
                    first,
                    daysInMonth,
                    monthEntries,
                  );

                  final currentStreak = _currentStreak(today, moodByDay);

                  final legendItems = <MapEntry<String, Color>>[
                    MapEntry('Good', cs.tertiary),
                    MapEntry('Okay', cs.secondary),
                    MapEntry('Tough', cs.error),
                  ];

                  return Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.insights, color: cs.primary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Monthly Snapshot',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                  if (mostCommonMood != null)
                                    Text(
                                      '${_moodLabelToEmoji(mostCommonMood)}  ${mostCommonMood[0].toUpperCase()}${mostCommonMood.substring(1)}',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _statChip(
                                    context,
                                    icon: Icons.check_circle_outline,
                                    value: thisMonthCheckins.toString(),
                                    label: 'check-ins',
                                  ),
                                  _statChip(
                                    context,
                                    icon: Icons.local_fire_department_outlined,
                                    value: currentStreak.toString(),
                                    label: 'day streak',
                                  ),
                                  _statChip(
                                    context,
                                    icon: Icons.emoji_events_outlined,
                                    value: longestStreak.toString(),
                                    label: 'best streak',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  for (final item in legendItems) ...[
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: item.value,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.key,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(width: 14),
                                  ],
                                  const Spacer(),
                                  Text(
                                    'Tap a day to open journal',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                            child: Column(
                              children: [
                                DefaultTextStyle.merge(
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(
                                        child: Center(child: Text('Sun')),
                                      ),
                                      Expanded(
                                        child: Center(child: Text('Mon')),
                                      ),
                                      Expanded(
                                        child: Center(child: Text('Tue')),
                                      ),
                                      Expanded(
                                        child: Center(child: Text('Wed')),
                                      ),
                                      Expanded(
                                        child: Center(child: Text('Thu')),
                                      ),
                                      Expanded(
                                        child: Center(child: Text('Fri')),
                                      ),
                                      Expanded(
                                        child: Center(child: Text('Sat')),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 7,
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                          childAspectRatio: 1.05,
                                        ),
                                    itemCount: cells.length,
                                    itemBuilder: (context, i) {
                                      final d = cells[i];
                                      if (d == null) {
                                        return const SizedBox.shrink();
                                      }

                                      final day = dateOnly(d);
                                      final isToday = day == today;
                                      final isPast = day.isBefore(today);
                                      final label = moodByDay[day];
                                      final emoji = (label != null)
                                          ? _moodLabelToEmoji(label)
                                          : (isPast ? '😐' : null);
                                      final indicatorColor =
                                          _moodIndicatorColor(context, label);
                                      final isHovered = _hoveredCellIndex == i;

                                      final border = isToday
                                          ? Border.all(
                                              color: cs.primary,
                                              width: 2,
                                            )
                                          : Border.all(
                                              color: indicatorColor.withValues(
                                                alpha: label == null
                                                    ? 0.4
                                                    : 0.85,
                                              ),
                                            );

                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => JournalScreen(
                                                userId: _resolvedUserId,
                                                selectedDate: day,
                                              ),
                                            ),
                                          );
                                        },
                                        onHover: (hovering) {
                                          setState(
                                            () => _hoveredCellIndex = hovering
                                                ? i
                                                : null,
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(14),
                                        child: AnimatedScale(
                                          duration: const Duration(
                                            milliseconds: 120,
                                          ),
                                          scale: isHovered ? 1.02 : 1.0,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 160,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color.alphaBlend(
                                                indicatorColor.withValues(
                                                  alpha: label == null
                                                      ? 0.0
                                                      : 0.10,
                                                ),
                                                cs.surface,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: border,
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 10,
                                                  top: 10,
                                                  child: Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      color: indicatorColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 10,
                                                          right: 10,
                                                        ),
                                                    child: Text(
                                                      d.day.toString(),
                                                      style: theme
                                                          .textTheme
                                                          .labelMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: cs
                                                                .onSurfaceVariant,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: isToday
                                                      ? Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              emoji ?? '😐',
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        24,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              height: 6,
                                                            ),
                                                            Text(
                                                              'Today',
                                                              style: theme
                                                                  .textTheme
                                                                  .labelSmall
                                                                  ?.copyWith(
                                                                    color: cs
                                                                        .primary,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                  ),
                                                            ),
                                                          ],
                                                        )
                                                      : (emoji != null
                                                            ? Text(
                                                                emoji,
                                                                style:
                                                                    const TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                    ),
                                                              )
                                                            : Text(
                                                                '—',
                                                                style: theme
                                                                    .textTheme
                                                                    .labelMedium
                                                                    ?.copyWith(
                                                                      color: cs.onSurfaceVariant.withValues(
                                                                        alpha:
                                                                            isPast
                                                                            ? 0.6
                                                                            : 0.45,
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                              )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
