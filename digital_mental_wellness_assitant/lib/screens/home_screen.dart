import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import '../services/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  Widget _featureCard(BuildContext context,
      {required IconData icon, required String title, required String subtitle, required VoidCallback onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))]),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 28, color: Colors.teal)),
          const SizedBox(width: 16),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
          ]))
        ]),
      ),
    );
  }

  Widget _progressRow(String label, String value, Color color) => Row(children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.black87))),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(8)),
            child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)))
      ]);

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
      'I trust myself to handle what comes.'
    ];
    final now = DateTime.now();
    final idx = (now.difference(DateTime(now.year)).inDays + _affirmationOffset) % items.length;
    return items[idx];
  }

  DateTime nowIST() => DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
  DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final resolvedName = (widget.userName != 'User' && widget.userName.trim().isNotEmpty)
        ? widget.userName
        : (currentUser?.displayName ?? (currentUser?.email?.split('@').first ?? 'User'));

    final istNow = nowIST();
    final istToday = dateOnly(istNow);
    final startOfWeek = dateOnly(istNow.subtract(Duration(days: istNow.weekday % 7)));
    final weekDays = List<DateTime>.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(children: [
            ListTile(leading: const Icon(Icons.home), title: const Text('Home')),
            ListTile(
                leading: const Icon(Icons.heart_broken),
                title: const Text('Mood Tracker'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodTrackerScreen()))),
            ListTile(
                leading: const Icon(Icons.book),
                title: const Text('Journal'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JournalScreen(userId: widget.userId))),
            ),
            ListTile(
                leading: const Icon(Icons.self_improvement),
                title: const Text('Meditate'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MeditateScreen()))),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Resources'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResourcesScreen()))),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Text("You're doing great. Take it one day at a time."),
              ),
            )
          ]),
        ),
      ),
      appBar: AppBar(title: const Text('Digital Wellness Home')),
      body: Stack(children: [
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (context, _) {
            final t = _bgCtrl.value;
            final c1 = Color.lerp(const Color(0xFFCCFBF1), const Color(0xFFE0E7FF), t)!;
            final c2 = Color.lerp(const Color(0xFFEFF6FF), const Color(0xFFFFF7ED), 1 - t)!;
            return Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c1, c2])));
          },
        ),
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (context, _) => IgnorePointer(child: CustomPaint(size: Size.infinite, painter: _HomeBubblesPainter(t: _bgCtrl.value))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: ListView(children: [
            Row(children: [
              Expanded(
                child: FutureBuilder<String?>(
                  future: ProfileService.getDisplayName(),
                  builder: (context, snapshot) {
                    final display = (snapshot.data != null && snapshot.data!.trim().isNotEmpty) ? snapshot.data!.trim() : resolvedName;
                    return Text('${greetingEmoji()} ${timeGreeting()}, $display',
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.purple));
                  },
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.teal.shade400]),
                      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Colors.white24)),
                      shadows: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 3))]),
                  child: Row(children: const [Icon(Icons.person_outline, color: Colors.white, size: 18), SizedBox(width: 6), Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))]),
                ),
              )
            ]),
            const SizedBox(height: 6),
            const Text('How are you feeling today?', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: _featureCard(context, icon: Icons.monitor_heart, title: 'Check In', subtitle: 'Track your mood', onTap: () => Navigator.pushNamed(context, '/mood'), color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(child: _featureCard(context, icon: Icons.menu_book, title: 'Journal', subtitle: 'Write your thoughts', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JournalScreen(userId: widget.userId))), color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(child: _featureCard(context, icon: Icons.self_improvement, title: 'Meditate', subtitle: 'Find your calm', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MeditateScreen())), color: Colors.white)),
            ]),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 3))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [const Icon(Icons.calendar_today, color: Colors.purple), const SizedBox(width: 8), const Text('Your Week at a Glance', style: TextStyle(fontWeight: FontWeight.bold))]),
                  TextButton(onPressed: () => Navigator.pushNamed(context, '/week'), child: const Text('View All'))
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: FutureBuilder<List<dynamic>>(
                    future: ApiService().getMoodLogs(userId: widget.userId > 0 ? widget.userId : 1),
                    builder: (context, snap) {
                      Map<String, String> byDate = {}; // yyyy-mm-dd -> emoji
                      if (snap.hasData) {
                        for (final row in snap.data!) {
                          try {
                            final ts = row['timestamp'] ?? row['created_at'] ?? row['time'] ?? '';
                            if (ts == null) continue;
                            final dt = DateTime.parse(ts.toString());
                            final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                            byDate[key] = _moodLabelToEmoji((row['mood_label'] ?? '').toString());
                          } catch (_) {}
                        }
                      }

                      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(7, (i) {
                        final d = weekDays[i];
                        final dayLabel = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][i];
                        final isToday = d == istToday;
                        final isPast = d.isBefore(istToday);
                        final dateNum = d.day;
                        final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                        final emoji = byDate.containsKey(key) ? byDate[key] : (isPast ? '😐' : null);

                        return Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pushNamed(context, '/mood'),
                            child: Column(children: [
                              Text(dayLabel, style: const TextStyle(color: Colors.black54)),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isToday ? Border.all(color: Colors.purple, width: 2) : null,
                                  ),
                                  child: Center(
                                    child: isToday
                                        ? Column(mainAxisSize: MainAxisSize.min, children: [
                                            Text(emoji ?? '😐', style: const TextStyle(fontSize: 28)),
                                            const SizedBox(height: 6),
                                            const Text('Today', style: TextStyle(fontSize: 12, color: Colors.purple)),
                                          ])
                                        : (emoji != null
                                            ? Text(emoji, style: const TextStyle(fontSize: 22))
                                            : (isPast ? const Text('😐', style: TextStyle(fontSize: 12, color: Colors.black38)) : const Text('—', style: TextStyle(fontSize: 12, color: Colors.black26)))),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(dateNum.toString(), style: const TextStyle(color: Colors.black45))
                            ]),
                          ),
                        );
                      }));
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodTrackerScreen())),
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    label: const Text("Log Today's Mood"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  ),
                )
              ]),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: LayoutBuilder(builder: (context, box) {
                final isWide = box.maxWidth > 720;
                final spacing = 14.0;
                final progressCard = Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.pink.shade50, Colors.pink.shade100.withAlpha(150)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Icon(Icons.show_chart, color: Colors.purple.shade700), const SizedBox(width: 8), Text('Your Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.purple.shade700))]),
                    const SizedBox(height: 12),
                    _progressRow('Mood check-ins', '0', Colors.purple),
                    const SizedBox(height: 8),
                    _progressRow('Journal entries', '0', Colors.blue),
                    const SizedBox(height: 8),
                    _progressRow('Days active', '0', Colors.green),
                  ]),
                );
                final affirmationCard = Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.indigo.shade50, Colors.purple.shade100.withAlpha(130)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Icon(Icons.format_quote, color: Colors.purple.shade700), const SizedBox(width: 8), Text('Daily Affirmation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.purple.shade700))]),
                    const SizedBox(height: 12),
                    Text(dailyAffirmation(), style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    Row(children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await Clipboard.setData(ClipboardData(text: dailyAffirmation()));
                          messenger.showSnackBar(const SnackBar(content: Text('Affirmation copied')));
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      TextButton(onPressed: () => setState(() => _affirmationOffset++), child: const Text('New affirmation'))
                    ])
                  ]),
                );
                if (isWide) {
                  return Row(children: [Expanded(child: progressCard), SizedBox(width: spacing), Expanded(child: affirmationCard)]);
                }
                return Column(children: [progressCard, SizedBox(height: spacing), affirmationCard]);
              }),
            ),
            const SizedBox(height: 24)
          ]),
        )
      ]),
    );
  }
}

// Subtle animated bubbles painter for Home background
class _HomeBubblesPainter extends CustomPainter {
  final double t; // 0..1 animation progress
  _HomeBubblesPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final bubbles = [
      _HBubble(0.10, Colors.white.withValues(alpha: 0.10), Offset(size.width * 0.2 + 30 * math.sin(t * math.pi * 2), size.height * 0.2)),
      _HBubble(0.08, Colors.white.withValues(alpha: 0.08), Offset(size.width * 0.8 + 40 * math.cos(t * math.pi), size.height * 0.3 + 20 * math.sin(t * math.pi))),
      _HBubble(0.14, Colors.white.withValues(alpha: 0.06), Offset(size.width * 0.6 + 50 * math.sin(t * math.pi * 1.5), size.height * 0.75)),
    ];
    for (final b in bubbles) {
      paint.color = b.color;
      canvas.drawCircle(b.center, size.shortestSide * b.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HomeBubblesPainter oldDelegate) => oldDelegate.t != t;
}

class _HBubble {
  final double radius;
  final Color color;
  final Offset center;
  _HBubble(this.radius, this.color, this.center);
}
