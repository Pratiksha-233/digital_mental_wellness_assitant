import 'package:flutter/material.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  // moods: Amazing, Good, Okay, Struggling, Difficult
  int _selectedMood = -1;
  int _energyLevel = 3; // 1..5
  final List<String> _activities = ['Exercise', 'Work', 'Social', 'Family', 'Hobbies', 'Rest', 'Nature', 'Reading', 'Music', 'Cooking'];
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
      onTap: () => setState(() => _selectedMood = idx),
      child: Container(
        width: 108,
        height: 98,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade50 : Colors.white,
          border: Border.all(color: isSelected ? Colors.purple : Colors.grey.shade300),
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
        onTap: () => setState(() => _energyLevel = idx),
        child: Container(
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            gradient: active ? LinearGradient(colors: [Colors.purple.shade300, Colors.pink.shade300]) : null,
            color: active ? null : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active ? [BoxShadow(color: Colors.purple.shade100.withAlpha(120), blurRadius: 6, offset: const Offset(0, 3))] : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How Are You Feeling?')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 6),
          const Text('How Are You Feeling?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple)),
          const SizedBox(height: 6),
          const Text('Take a moment to check in with yourself', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),

          // Main centered card similar to the mockup
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 3))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.favorite_border, color: Colors.purple), const SizedBox(width: 8), const Text('Log Your Mood', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]), TextButton(onPressed: () {}, child: const Text('History'))]),
                  const SizedBox(height: 12),

                  const Text('Select your mood', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _moodButton(0, '🤩', 'Amazing'),
                      const SizedBox(width: 12),
                      _moodButton(1, '🙂', 'Good'),
                      const SizedBox(width: 12),
                      _moodButton(2, '😐', 'Okay'),
                      const SizedBox(width: 12),
                      _moodButton(3, '😔', 'Struggling'),
                      const SizedBox(width: 12),
                      _moodButton(4, '😣', 'Difficult'),
                    ]),
                  ),

                  const SizedBox(height: 18),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Energy Level: $_energyLevel/5', style: const TextStyle(color: Colors.black54)),
                    Text('${_selectedActivities.length} activity selected', style: const TextStyle(color: Colors.black38)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: List.generate(5, (i) {
                    return Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 6), child: _energySegment(i + 1)));
                  })),

                  const SizedBox(height: 18),
                  const Text('What did you do today?', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: _activities.map((a) {
                    final selected = _selectedActivities.contains(a);
                    return FilterChip(label: Text(a), selected: selected, onSelected: (v) => setState(() => v ? _selectedActivities.add(a) : _selectedActivities.remove(a)));
                  }).toList()),

                  const SizedBox(height: 18),
                  const Text('Add a note (optional)', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 8),
                  TextField(controller: _noteController, minLines: 3, maxLines: 6, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), hintText: 'What\'s on your mind? Any thoughts or reflections...')),

                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        final moodLabel = _selectedMood >= 0 ? ['Amazing', 'Good', 'Okay', 'Struggling', 'Difficult'][_selectedMood] : 'Not selected';
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved mood: $moodLabel — Energy: $_energyLevel')));
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), backgroundColor: Colors.purple),
                    )
                  ])
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
