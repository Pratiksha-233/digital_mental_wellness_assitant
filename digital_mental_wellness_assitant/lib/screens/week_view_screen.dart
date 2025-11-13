import 'package:flutter/material.dart';

class WeekViewScreen extends StatefulWidget {
  const WeekViewScreen({super.key});

  @override
  State<WeekViewScreen> createState() => _WeekViewScreenState();
}

class _WeekViewScreenState extends State<WeekViewScreen> {
  late DateTime _displayMonth; // first day of month
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

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Calendar'),
        actions: [
          IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
          Center(child: Text("${first.year}-${first.month.toString().padLeft(2, '0')}", style: const TextStyle(fontWeight: FontWeight.w600))),
          IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(child: Center(child: Text('Sun'))),
                Expanded(child: Center(child: Text('Mon'))),
                Expanded(child: Center(child: Text('Tue'))),
                Expanded(child: Center(child: Text('Wed'))),
                Expanded(child: Center(child: Text('Thu'))),
                Expanded(child: Center(child: Text('Fri'))),
                Expanded(child: Center(child: Text('Sat'))),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 6),
                itemCount: cells.length,
                itemBuilder: (context, i) {
                  final d = cells[i];
                  if (d == null) {
                    return const SizedBox.shrink();
                  }
                  final isToday = dateOnly(d) == today;
                  final isPast = d.isBefore(today);
                  return InkWell(
                    onTap: () => Navigator.pushNamed(context, '/mood'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: isToday ? Border.all(color: Colors.purple, width: 2) : Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(d.day.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          if (isToday)
                            const Text('Today', style: TextStyle(fontSize: 11, color: Colors.purple))
                          else if (isPast)
                            const Text('No log', style: TextStyle(fontSize: 11, color: Colors.black38))
                          else
                            const Text('—', style: TextStyle(fontSize: 11, color: Colors.black26)),
                        ],
                      ),
                    ),
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
