import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../services/profile_service.dart';
import '../theme/brand_theme.dart';
import 'analytics_dashboard_screen.dart';
import 'chat_screen.dart';
import 'journal_screen.dart';
import 'meditate_screen.dart';
import 'mood_tracker_screen.dart';
import 'resources_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const HomeScreen({super.key, required this.userId, this.userName = 'User'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  int _affirmationOffset = 0;

  late final Future<List<dynamic>> _moodLogsFuture;

  int? _hoveredWeekIndex;

  int _moodCheckins = 0;
  int _journalEntries = 0;
  int _daysActive = 0;
  bool _loadingProgress = true;

  final List<String> _drawerMessages = const [
    "You're doing great. Take it one day at a time.",
    'Progress is progress, no matter the pace.',
    'Rest is productive. Breathe and soften.',
    'You are worthy of patience and care.',
    'Small steps forward still count forward.',
    'Feelings pass; resilience stays.',
    'You deserve kindness from yourself today.',
  ];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    final userId = widget.userId > 0 ? widget.userId : 1;
    _moodLogsFuture = ApiService().getMoodLogs(userId: userId);

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProgress());
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProgress() async {
    setState(() => _loadingProgress = true);
    try {
      final api = ApiService();
      final userId = widget.userId > 0 ? widget.userId : 1;
      final data = await api.getProgress(userId: userId);
      if (!mounted) return;
      setState(() {
        _moodCheckins = (data['mood_checkins'] is int)
            ? data['mood_checkins'] as int
            : int.tryParse('${data['mood_checkins']}') ?? 0;
        _journalEntries = (data['journal_entries'] is int)
            ? data['journal_entries'] as int
            : int.tryParse('${data['journal_entries']}') ?? 0;
        _daysActive = (data['days_active'] is int)
            ? data['days_active'] as int
            : int.tryParse('${data['days_active']}') ?? 0;
      });
    } catch (_) {

    } finally {
      if (mounted) setState(() => _loadingProgress = false);
    }
  }

  String rotatingDrawerMessage() {
    final base = DateTime(2025, 1, 1);
    final days = DateTime.now().difference(base).inDays;
    final index = ((days ~/ 2) % _drawerMessages.length);
    return _drawerMessages[index];
  }

  DateTime nowIST() =>
      DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));

  DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _extractMoodEmojiForGreeting({
    required List<dynamic> logs,
    required DateTime istToday,
    required String fallback,
  }) {
    if (logs.isEmpty) return fallback;

    String? latestEmoji;
    DateTime? latestTs;

    for (final row in logs) {
      try {
        final ts =
            row['timestamp'] ?? row['created_at'] ?? row['time'] ?? row['date'];
        if (ts == null) continue;
        final dt = DateTime.parse(ts.toString());
        final mood = (row['mood_label'] ?? '').toString();
        final emoji = _moodLabelToEmoji(mood);

        if (dateOnly(dt) == istToday) {
          return emoji;
        }

        if (latestTs == null || dt.isAfter(latestTs)) {
          latestTs = dt;
          latestEmoji = emoji;
        }
      } catch (_) {

      }
    }

    return latestEmoji ?? fallback;
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

  double _moodLabelToScore(String? label) {
    if (label == null) return 0.0;
    switch (label.toLowerCase()) {
      case 'amazing':
        return 1.0;
      case 'good':
      case 'happy':
        return 0.65;
      case 'okay':
      case 'neutral':
        return 0.15;
      case 'struggling':
        return -0.6;
      case 'difficult':
      case 'sad':
      case 'angry':
      case 'fear':
        return -1.0;
      default:
        return 0.0;
    }
  }

  LinearGradient _homeCardGradient(
    ColorScheme cs, {
    Color? a,
    Color? b,
    double aAlpha = 0.55,
    double bAlpha = 0.35,
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        (a ?? cs.primaryContainer).withValues(alpha: aAlpha),
        (b ?? cs.secondaryContainer).withValues(alpha: bAlpha),
      ],
    );
  }

  Widget _homeSectionCard({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Gradient? gradient,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient:
              gradient ??
              _homeCardGradient(
                cs,
                a: cs.surfaceContainerHighest,
                b: cs.surface,
                aAlpha: 0.75,
                bAlpha: 0.55,
              ),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }

  Widget _progressRow(
    BuildContext context,
    String label,
    String value,
    Color accent,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  String timeGreeting() {
    final h = DateTime.now().hour;
    if (h < 12 && h >= 5) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Good night';
  }

  String greetingEmoji() {
    final h = DateTime.now().hour;
    if (h < 12 && h >= 5) return '☀️';
    if (h < 17) return '🌤️';
    if (h < 21) return '🌇';
    return '🌙';
  }

  String dailyAffirmation() {
    final items = [
      'I am safe, capable, and enough.',
      'I choose progress over perfection today.',
      'My feelings are valid and temporary.',
      'I can breathe, soften, and begin again.',
      'Small steps still move me forward.',
      'I deserve rest, care, and kindness.',
      'I trust myself to handle what comes.',
    ];
    final now = DateTime.now();
    final idx =
        (now.difference(DateTime(now.year)).inDays + _affirmationOffset) %
        items.length;
    return items[idx];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentUser = FirebaseAuth.instance.currentUser;
    final resolvedName =
        (widget.userName != 'User' && widget.userName.trim().isNotEmpty)
        ? widget.userName
        : (currentUser?.displayName ??
              (currentUser?.email?.split('@').first ?? 'User'));

    final istNow = nowIST();
    final istToday = dateOnly(istNow);
    final startOfWeek = dateOnly(
      istNow.subtract(Duration(days: istNow.weekday % 7)),
    );
    final weekDays = List<DateTime>.generate(
      7,
      (i) => startOfWeek.add(Duration(days: i)),
    );

    return Scaffold(
      drawer: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (context, _) {
          final t = _bgCtrl.value;
          final drawerCs = Theme.of(context).colorScheme;
          final g1 = Color.lerp(
            drawerCs.surface,
            drawerCs.primaryContainer,
            t,
          )!;
          final g2 = Color.lerp(
            drawerCs.surfaceContainerHighest,
            drawerCs.secondaryContainer,
            1 - t,
          )!;
          final pulse = 0.96 + 0.04 * (0.5 - (t - 0.5).abs());

          return Drawer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [g1, g2],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.home),
                      title: Text('Home'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.heart_broken),
                      title: const Text('Mood Tracker'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MoodTrackerScreen(),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: const Text('Therapy Chatbot'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Journal'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JournalScreen(userId: widget.userId),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.self_improvement),
                      title: const Text('Meditate'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MeditateScreen(),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.show_chart),
                      title: const Text('Stress Analyzer'),
                      onTap: () => Navigator.pushNamed(context, '/stress'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.dashboard_customize),
                      title: const Text('Dashboard & Analytics'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnalyticsDashboardScreen(),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.psychology),
                      title: const Text('Realtime Face Detection'),
                      onTap: () => Navigator.pushNamed(context, '/detection'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.library_books),
                      title: const Text('Resources'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ResourcesScreen(),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Edit Profile'),
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      },
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Transform.scale(
                        scale: pulse,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Text(
                            rotatingDrawerMessage(),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      appBar: AppBar(title: const Text('Digital Wellness Home')),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (context, _) {
              final gradient = theme.extension<BrandGradients>()?.background;
              final t = Curves.easeInOut.transform(_bgCtrl.value);
              final begin = Alignment.lerp(
                Alignment.topLeft,
                Alignment.topRight,
                t,
              )!;
              final end = Alignment.lerp(
                Alignment.bottomRight,
                Alignment.bottomLeft,
                t,
              )!;

              return DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.surface,
                  gradient: gradient == null
                      ? null
                      : LinearGradient(
                          begin: begin,
                          end: end,
                          colors: gradient.colors,
                          stops: gradient.stops,
                        ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ListView(
                children: [
                  _homeSectionCard(
                    context: context,
                    gradient: _homeCardGradient(
                      cs,
                      a: cs.primaryContainer,
                      b: cs.secondaryContainer,
                      aAlpha: 0.55,
                      bAlpha: 0.35,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<List<dynamic>>(
                              future: _moodLogsFuture,
                              builder: (context, snap) {
                                final fallback = greetingEmoji();
                                final emoji = (snap.hasData)
                                    ? _extractMoodEmojiForGreeting(
                                        logs: snap.data!,
                                        istToday: istToday,
                                        fallback: fallback,
                                      )
                                    : fallback;
                                return Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: cs.surface.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: cs.outlineVariant.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FutureBuilder<String?>(
                                future: ProfileService.getDisplayName(),
                                builder: (context, snapshot) {
                                  final display =
                                      (snapshot.data != null &&
                                          snapshot.data!.trim().isNotEmpty)
                                      ? snapshot.data!.trim()
                                      : resolvedName;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${timeGreeting()}, $display',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: cs.onPrimaryContainer,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'How are you feeling today?',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: cs.onPrimaryContainer,
                                            ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _homeSectionCard(
                    context: context,
                    gradient: _homeCardGradient(
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
                                Icon(Icons.calendar_month, color: cs.primary),
                                const SizedBox(width: 10),
                                Text(
                                  'Your Week at a Glance',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/week'),
                              child: const Text('View all'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: FutureBuilder<List<dynamic>>(
                            future: _moodLogsFuture,
                            builder: (context, snap) {
                              final byDateLabel = <String, String>{};
                              if (snap.hasData) {
                                for (final row in snap.data!) {
                                  try {
                                    final ts =
                                        row['timestamp'] ??
                                        row['created_at'] ??
                                        row['time'] ??
                                        '';
                                    if (ts == null) continue;
                                    final dt = DateTime.parse(ts.toString());
                                    final key =
                                        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                                    byDateLabel[key] = (row['mood_label'] ?? '')
                                        .toString();
                                  } catch (_) {}
                                }
                              }

                              final labels = List<String?>.generate(7, (i) {
                                final d = weekDays[i];
                                final key =
                                    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                                return byDateLabel.containsKey(key)
                                    ? byDateLabel[key]
                                    : null;
                              });

                              final waveColors = List<Color>.generate(7, (i) {
                                final label = labels[i];
                                final c = _moodIndicatorColor(context, label);
                                return c.withValues(
                                  alpha: label == null ? 0.18 : 0.55,
                                );
                              });

                              final waveScores = List<double>.generate(7, (i) {
                                return _moodLabelToScore(labels[i]);
                              });

                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return Stack(
                                    children: [
                                      Positioned.fill(
                                        child: IgnorePointer(
                                          child: CustomPaint(
                                            painter: _MoodWavePainter(
                                              colors: waveColors,
                                              scores: waveScores,
                                              colorScheme: cs,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(7, (i) {
                                          final d = weekDays[i];
                                          final dayLabel = const [
                                            'Sun',
                                            'Mon',
                                            'Tue',
                                            'Wed',
                                            'Thu',
                                            'Fri',
                                            'Sat',
                                          ][i];

                                          final isToday = d == istToday;
                                          final isPast = d.isBefore(istToday);
                                          final label = labels[i];
                                          final emoji = (label != null)
                                              ? _moodLabelToEmoji(label)
                                              : (isPast ? '😐' : null);

                                          final indicatorColor =
                                              _moodIndicatorColor(
                                                context,
                                                label,
                                              );
                                          final isHovered =
                                              _hoveredWeekIndex == i;

                                          final todayBorder = Border.all(
                                            color: cs.primary,
                                            width: 2,
                                          );

                                          final borderColor = isToday
                                              ? cs.primary
                                              : (isHovered
                                                    ? cs.onSurface.withValues(
                                                        alpha: 0.22,
                                                      )
                                                    : cs.onSurface.withValues(
                                                        alpha: 0.14,
                                                      ));

                                          final baseFill = cs.surface
                                              .withValues(alpha: 0.28);
                                          final tintFill = indicatorColor
                                              .withValues(
                                                alpha: label == null
                                                    ? 0.0
                                                    : 0.14,
                                              );
                                          final fill = Color.alphaBlend(
                                            tintFill,
                                            baseFill,
                                          );

                                          return Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    dayLabel,
                                                    style: theme
                                                        .textTheme
                                                        .labelMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: cs
                                                              .onSurfaceVariant,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) =>
                                                                JournalScreen(
                                                                  userId: widget
                                                                      .userId,
                                                                  selectedDate:
                                                                      d,
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                      onHover: (hovering) {
                                                        setState(
                                                          () =>
                                                              _hoveredWeekIndex =
                                                                  hovering
                                                                  ? i
                                                                  : null,
                                                        );
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      child: AnimatedScale(
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 120,
                                                            ),
                                                        scale: isHovered
                                                            ? 1.03
                                                            : 1,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          child: BackdropFilter(
                                                            filter:
                                                                ui.ImageFilter.blur(
                                                                  sigmaX: 10,
                                                                  sigmaY: 10,
                                                                ),
                                                            child: AnimatedContainer(
                                                              duration:
                                                                  const Duration(
                                                                    milliseconds:
                                                                        160,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: fill,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                                border: isToday
                                                                    ? todayBorder
                                                                    : Border.all(
                                                                        color:
                                                                            borderColor,
                                                                        width:
                                                                            isHovered
                                                                            ? 1.6
                                                                            : 1,
                                                                      ),
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: DecoratedBox(
                                                                      decoration: BoxDecoration(
                                                                        gradient: LinearGradient(
                                                                          begin:
                                                                              Alignment.topLeft,
                                                                          end: Alignment
                                                                              .bottomRight,
                                                                          colors: [
                                                                            cs.onSurface.withValues(
                                                                              alpha: 0.10,
                                                                            ),
                                                                            cs.onSurface.withValues(
                                                                              alpha: 0.00,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    left: 10,
                                                                    top: 10,
                                                                    child: Container(
                                                                      width: 10,
                                                                      height:
                                                                          10,
                                                                      decoration: BoxDecoration(
                                                                        color:
                                                                            indicatorColor,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Center(
                                                                    child:
                                                                        isToday
                                                                        ? Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Text(
                                                                                emoji ??
                                                                                    '😐',
                                                                                style: const TextStyle(
                                                                                  fontSize: 28,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 6,
                                                                              ),
                                                                              Text(
                                                                                'Today',
                                                                                style: theme.textTheme.labelSmall?.copyWith(
                                                                                  fontWeight: FontWeight.w700,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        : (emoji != null
                                                                              ? Text(
                                                                                  emoji,
                                                                                  style: const TextStyle(
                                                                                    fontSize: 22,
                                                                                  ),
                                                                                )
                                                                              : Text(
                                                                                  '—',
                                                                                  style: TextStyle(
                                                                                    fontSize: 12,
                                                                                    color: cs.onSurfaceVariant.withValues(
                                                                                      alpha: isPast
                                                                                          ? 0.6
                                                                                          : 0.45,
                                                                                    ),
                                                                                  ),
                                                                                )),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    d.day.toString(),
                                                    style: theme
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          color: cs
                                                              .onSurfaceVariant,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton.tonalIcon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MoodTrackerScreen(),
                                  ),
                                ),
                                icon: const Icon(Icons.emoji_emotions_outlined),
                                label: const Text("Log Today's Mood"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, box) {
                      final isWide = box.maxWidth > 720;
                      const spacing = 14.0;

                      final progressCard = _homeSectionCard(
                        context: context,
                        gradient: _homeCardGradient(
                          cs,
                          a: cs.surfaceContainerHighest,
                          b: cs.surface,
                          aAlpha: 0.75,
                          bAlpha: 0.55,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.show_chart, color: cs.primary),
                                const SizedBox(width: 10),
                                Text(
                                  'Your Progress',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_loadingProgress)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else
                              Column(
                                children: [
                                  _progressRow(
                                    context,
                                    'Mood check-ins',
                                    _moodCheckins.toString(),
                                    cs.primary,
                                  ),
                                  const SizedBox(height: 10),
                                  _progressRow(
                                    context,
                                    'Journal entries',
                                    _journalEntries.toString(),
                                    cs.secondary,
                                  ),
                                  const SizedBox(height: 10),
                                  _progressRow(
                                    context,
                                    'Days active',
                                    _daysActive.toString(),
                                    cs.tertiary,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );

                      final affirmationText = dailyAffirmation();
                      final affirmationCard = _homeSectionCard(
                        context: context,
                        gradient: _homeCardGradient(
                          cs,
                          a: cs.secondaryContainer,
                          b: cs.tertiaryContainer,
                          aAlpha: 0.34,
                          bAlpha: 0.22,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.format_quote, color: cs.primary),
                                const SizedBox(width: 10),
                                Text(
                                  'Daily Affirmation',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              affirmationText,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                FilledButton.tonalIcon(
                                  onPressed: () async {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    await Clipboard.setData(
                                      ClipboardData(text: affirmationText),
                                    );
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Affirmation copied'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Copy'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _affirmationOffset++),
                                  child: const Text('New affirmation'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );

                      if (isWide) {
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: progressCard),
                              const SizedBox(width: spacing),
                              Expanded(child: affirmationCard),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: [
                          progressCard,
                          const SizedBox(height: spacing),
                          affirmationCard,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodWavePainter extends CustomPainter {
  final List<Color> colors;
  final List<double> scores;
  final ColorScheme colorScheme;

  const _MoodWavePainter({
    required this.colors,
    required this.scores,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.length < 2 || scores.length < 2) return;

    final n = colors.length < scores.length ? colors.length : scores.length;
    if (n < 2) return;

    final clampedScores = List<double>.generate(n, (i) {
      final v = scores[i];
      if (v.isNaN) return 0.0;
      return v.clamp(-1.0, 1.0);
    });

    final points = <Offset>[];
    final segment = size.width / n;

    final baseline = size.height * 0.70;
    final amplitude = size.height * 0.10;

    for (var i = 0; i < n; i++) {
      final x = segment * (i + 0.5);
      final y = baseline - (clampedScores[i] * amplitude);
      points.add(Offset(x, y));
    }

    final stops = List<double>.generate(n, (i) {
      return n == 1 ? 0.0 : (i / (n - 1));
    });

    final shader = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(size.width, 0),
      colors.take(n).toList(growable: false),
      stops,
    );

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      path.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    final glowPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 12);

    final mainPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, mainPaint);


    final dotPaint = Paint()
      ..color = colorScheme.onSurface.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawCircle(p, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MoodWavePainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.scores != scores ||
        oldDelegate.colorScheme != colorScheme;
  }
}
