import 'package:flutter/material.dart';
import 'journal_screen.dart';
// recommendation_screen.dart is reachable via routes; not required here

class HomeScreen extends StatelessWidget {
  final int userId;
  final String userName;
  const HomeScreen({super.key, required this.userId, this.userName = 'User'});

  Widget _featureCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color ?? Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 3))]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 28, color: Colors.teal),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: Colors.black54)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // helper to build a labeled progress row used in the dashboard cards
  Widget _progressRow(String label, String value, Color color) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.black87))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: color.withAlpha((0.12 * 255).round()), borderRadius: BorderRadius.circular(8)),
          child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.favorite, color: Colors.white)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Serenity', style: TextStyle(fontWeight: FontWeight.bold)), Text('Your wellness companion', style: TextStyle(fontSize: 12))])),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ListTile(leading: const Icon(Icons.home), title: const Text('Home')),
              ListTile(leading: const Icon(Icons.heart_broken), title: const Text('Mood Tracker')),
              ListTile(leading: const Icon(Icons.book), title: const Text('Journal'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JournalScreen(userId: userId)))),
              ListTile(leading: const Icon(Icons.self_improvement), title: const Text('Meditate')),
              ListTile(leading: const Icon(Icons.bar_chart), title: const Text('Resources')),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Daily Reminder', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 6), Text("You're doing great. Take it one day at a time.")]),
                ),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(title: const Text('Digital Wellness Home')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: ListView(
          children: [
            Text('Good morning, $userName', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.purple)),
            const SizedBox(height: 6),
            const Text('How are you feeling today?', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 18),

            // three feature cards
            Row(
              children: [
                Expanded(child: _featureCard(context, icon: Icons.monitor_heart, title: 'Check In', subtitle: 'Track your mood', onTap: () {/* TODO */}, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: _featureCard(context, icon: Icons.menu_book, title: 'Journal', subtitle: 'Write your thoughts', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JournalScreen(userId: userId))), color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: _featureCard(context, icon: Icons.self_improvement, title: 'Meditate', subtitle: 'Find your calm', onTap: () {/* TODO */}, color: Colors.white)),
              ],
            ),

            const SizedBox(height: 20),

            // Week at a glance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 3))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [const Icon(Icons.calendar_today, color: Colors.purple), const SizedBox(width: 8), const Text('Your Week at a Glance', style: TextStyle(fontWeight: FontWeight.bold))]),
                  // optional small control
                  TextButton(onPressed: () {}, child: const Text('View All'))
                ]),
                const SizedBox(height: 12),
                // days row
                SizedBox(
                  height: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final dayLabel = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][i];
                      final dateNum = 9 + i; // placeholder
                      return Expanded(
                        child: Column(
                          children: [
                            Text(dayLabel, style: const TextStyle(color: Colors.black54)),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: i == 3 ? Border.all(color: Colors.purple, width: 2) : null),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(dateNum.toString(), style: const TextStyle(color: Colors.black45)),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: navigate to mood logging
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Log Today's Mood (not implemented yet)")));
                    },
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    label: const Text("Log Today's Mood"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  ),
                )
              ]),
            ),

            // spacer to push content up
            const SizedBox(height: 18),

            // Your Progress & Recent Reflections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: LayoutBuilder(builder: (context, box) {
                final isWide = box.maxWidth > 720;
                final spacing = 14.0;

                Widget progressCard = Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.pink.shade50, Colors.pink.shade100.withAlpha((0.6 * 255).round())]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 3))],
                  ),
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

                Widget reflectionsCard = Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.lightBlue.shade50, Colors.lightBlue.shade100.withAlpha((0.6 * 255).round())]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Row(children: [Icon(Icons.book, color: Colors.blue.shade700), const SizedBox(width: 8), Text('Recent Reflections', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue.shade700))]),
                    const SizedBox(height: 12),
                    Center(child: Text('No journal entries yet', style: TextStyle(color: Colors.black45))),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JournalScreen(userId: userId))),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 2, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                      child: const Text('Start Writing'),
                    ),
                  ]),
                );

                if (isWide) {
                  return Row(children: [Expanded(child: progressCard), SizedBox(width: spacing), Expanded(child: reflectionsCard)]);
                }

                return Column(children: [progressCard, SizedBox(height: spacing), reflectionsCard]);
              }),
            ),
            // small bottom spacing to avoid content flush with screen edge
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
