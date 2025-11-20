import 'package:flutter/material.dart';

// Dedicated Self-care Tips screen (moved out from landing page)
class SelfCareTipsScreen extends StatelessWidget {
  const SelfCareTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Self-care Tips')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(child: _SelfCareTipsContent()),
      ),
    );
  }
}

class _SelfCareTipsContent extends StatefulWidget {
  const _SelfCareTipsContent();

  @override
  State<_SelfCareTipsContent> createState() => _SelfCareTipsContentState();
}

class _SelfCareTipsContentState extends State<_SelfCareTipsContent> {
  final List<_TipCategory> _categories = const [
    _TipCategory('Breathing', Icons.air),
    _TipCategory('Mindfulness', Icons.self_improvement),
    _TipCategory('Sleep', Icons.nightlight_round),
    _TipCategory('Movement', Icons.directions_walk),
    _TipCategory('Journaling', Icons.menu_book_outlined),
    _TipCategory('Nutrition', Icons.restaurant),
    _TipCategory('Digital Detox', Icons.phonelink_erase_rounded),
  ];

  final Map<String, List<String>> _tips = const {
    'Breathing': [
      'Box breathing: inhale 4s, hold 4s, exhale 4s, hold 4s — 4 rounds.',
      '4-7-8 method for calm sleep prep.',
      'Alternate nostril breathing for balance (5 cycles).',
    ],
    'Mindfulness': [
      '5-4-3-2-1 grounding with senses.',
      'Mindful sip: focus fully on one warm drink.',
      'Name and note 3 emotions without judgment.',
    ],
    'Sleep': [
      'Same wake time daily improves rhythm.',
      'No caffeine 6 hours before bed.',
      'Dark, cool room (18–20°C) aids deeper sleep.',
    ],
    'Movement': [
      '60s posture reset: roll shoulders + neck stretch.',
      'Pomodoro walk break: 5 mins light walk.',
      'Gentle 10 bodyweight squats + 10 wall push-ups.',
    ],
    'Journaling': [
      'Write 3 things that felt okay today.',
      'Finish: “One thing I handled well was…”.',
      'Turn a worry into a next best small step.',
    ],
    'Nutrition': [
      'Add one colorful fruit/veg to next meal.',
      'Hydrate: drink a full glass of water now.',
      'Slow down: 20 chews before swallowing once today.',
    ],
    'Digital Detox': [
      'Silent mode for 15 minutes focus block.',
      'Move social apps off home screen.',
      'Screen-free 10 mins before bed tonight.',
    ],
  };

  int _selected = 0;
  late String _currentTip;
  final List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _currentTip = _tips[_categories[_selected].name]!.first;
  }

  void _nextTip() {
    final list = [..._tips[_categories[_selected].name]!];
    list.shuffle();
    setState(() => _currentTip = list.first);
  }

  void _toggleFavorite() {
    setState(() {
      if (_favorites.contains(_currentTip)) {
        _favorites.remove(_currentTip);
      } else {
        _favorites.add(_currentTip);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final twoCol = width > 900;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Self-care Tips', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.teal.shade700, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Explore practical micro‑actions across wellbeing domains.', style: TextStyle(color: Colors.grey.shade700)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_categories.length, (i) {
            final cat = _categories[i];
            final selected = _selected == i;
            return ChoiceChip(
              label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(cat.icon, size: 18), const SizedBox(width: 6), Text(cat.name)]),
              selected: selected,
              onSelected: (_) => setState(() {
                _selected = i;
                _currentTip = _tips[cat.name]!.first;
              }),
              selectedColor: Colors.teal.shade50,
            );
          }),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, _) {
          return Flex(
            direction: twoCol ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: twoCol ? 5 : 0,
                child: _TipCard(
                  category: _categories[_selected].name,
                  tip: _currentTip,
                  favorited: _favorites.contains(_currentTip),
                  onNext: _nextTip,
                  onFavorite: _toggleFavorite,
                ),
              ),
              if (twoCol) const SizedBox(width: 24) else const SizedBox(height: 24),
              Expanded(
                flex: twoCol ? 4 : 0,
                child: _FavoritesList(favorites: _favorites, onSelect: (t) => setState(() => _currentTip = t)),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final String category;
  final String tip;
  final bool favorited;
  final VoidCallback onFavorite;
  final VoidCallback onNext;
  const _TipCard({required this.category, required this.tip, required this.favorited, required this.onFavorite, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.teal.shade50, Colors.white]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.teal.shade100),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(backgroundColor: Colors.teal.shade100, child: Text(category.characters.first, style: const TextStyle(color: Colors.teal))),
            const SizedBox(width: 12),
            Expanded(child: Text(category, style: const TextStyle(fontWeight: FontWeight.w600))),
            IconButton(onPressed: onFavorite, icon: Icon(favorited ? Icons.favorite : Icons.favorite_border, color: Colors.pinkAccent)),
          ]),
          const SizedBox(height: 12),
          Text(tip, style: const TextStyle(fontSize: 15, height: 1.3)),
          const SizedBox(height: 16),
          Row(children: [
            ElevatedButton.icon(onPressed: onNext, icon: const Icon(Icons.refresh), label: const Text('Another'), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white)),
            const SizedBox(width: 12),
            OutlinedButton.icon(onPressed: favorited ? onFavorite : onFavorite, icon: Icon(favorited ? Icons.check : Icons.favorite_outline), label: Text(favorited ? 'Saved' : 'Save')),
          ])
        ]),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  final List<String> favorites;
  final ValueChanged<String> onSelect;
  const _FavoritesList({required this.favorites, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white, border: Border.all(color: Colors.teal.shade100)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Icon(Icons.favorite, color: Colors.pinkAccent), SizedBox(width: 8), Text('Saved Tips', style: TextStyle(fontWeight: FontWeight.w600))]),
          const SizedBox(height: 12),
          if (favorites.isEmpty)
            Text('No favorites yet.', style: TextStyle(color: Colors.grey.shade600))
          else
            ...favorites.map((t) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.bookmark_outline, size: 18),
                  title: Text(t, style: const TextStyle(fontSize: 13)),
                  onTap: () => onSelect(t),
                )),
        ]),
      ),
    );
  }
}

class _TipCategory {
  final String name;
  final IconData icon;
  const _TipCategory(this.name, this.icon);
}