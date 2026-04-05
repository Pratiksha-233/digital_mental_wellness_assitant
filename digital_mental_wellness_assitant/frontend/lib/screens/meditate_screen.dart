import 'package:flutter/material.dart';
import 'meditation_breathing.dart';
import '../widgets/app_section_card.dart';

class MeditateScreen extends StatefulWidget {
  const MeditateScreen({super.key});

  @override
  State<MeditateScreen> createState() => _MeditateScreenState();
}

class _MeditateScreenState extends State<MeditateScreen>
    with TickerProviderStateMixin {
  int boxBreathingCycles = 0;
  int fourSevenEightCycles = 0;
  int calmBreathingCycles = 0;
  late final AnimationController _bgController;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _launchBoxBreathing() async {
    if (_navigating) return;
    setState(() => _navigating = true);
    try {
      final cycles = await Navigator.of(context).push<int>(
        MaterialPageRoute(
          builder: (_) => BoxBreathingExercise(initialCount: 0),
        ),
      );
      if (!mounted) return;
      if (cycles != null && cycles > 0) {
        setState(() => boxBreathingCycles += cycles);
      }
    } finally {
      if (mounted) {
        setState(() => _navigating = false);
      }
    }
  }

  Future<void> _launchFourSevenEight() async {
    if (_navigating) return;
    setState(() => _navigating = true);
    try {
      final cycles = await Navigator.of(context).push<int>(
        MaterialPageRoute(
          builder: (_) => const FourSevenEightBreathingExercise(),
        ),
      );
      if (!mounted) return;
      if (cycles != null && cycles > 0) {
        setState(() => fourSevenEightCycles += cycles);
      }
    } finally {
      if (mounted) {
        setState(() => _navigating = false);
      }
    }
  }

  Future<void> _launchCalmBreathing() async {
    if (_navigating) return;
    setState(() => _navigating = true);
    try {
      final cycles = await Navigator.of(context).push<int>(
        MaterialPageRoute(builder: (_) => const CalmBreathingExercise()),
      );
      if (!mounted) return;
      if (cycles != null && cycles > 0) {
        setState(() => calmBreathingCycles += cycles);
      }
    } finally {
      if (mounted) {
        setState(() => _navigating = false);
      }
    }
  }

  Widget _countChip(
    BuildContext context, {
    required Color accent,
    required int count,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.repeat, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _exerciseCard(
    BuildContext context, {
    required Color accent,
    required Color accentContainer,
    required String title,
    required String desc,
    required String duration,
    required VoidCallback onStart,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppSectionCard(
      padding: const EdgeInsets.all(14),
      gradient: AppSectionCard.gradientFromScheme(
        cs,
        a: accentContainer,
        b: cs.surface,
        aAlpha: 0.70,
        bAlpha: 0.85,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentContainer.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: Icon(Icons.self_improvement, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      duration,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 10), trailing],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _navigating ? null : onStart,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: _navigating
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_navigating ? 'Opening…' : 'Start Exercise'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final t = _bgController.value;
        final c1 = Color.lerp(
          cs.surfaceContainerHighest,
          cs.primaryContainer,
          t,
        )!;
        final c2 = Color.lerp(
          cs.surface,
          cs.tertiaryContainer,
          t,
        )!.withValues(alpha: 0.75);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meditation & Breathing'),
            centerTitle: true,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c1, c2],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 18.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),
                  AppSectionCard(
                    gradient: AppSectionCard.gradientFromScheme(
                      cs,
                      a: cs.primaryContainer,
                      b: cs.secondaryContainer,
                      aAlpha: 0.32,
                      bAlpha: 0.22,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meditation & Breathing',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Find your calm through guided breathing exercises',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, box) {
                      const spacing = 24.0;
                      final double w = box.maxWidth;


                      final int columns = w >= 1000
                          ? 3
                          : w >= 680
                          ? 2
                          : 1;

                      final double cardWidth =
                          (w - (columns - 1) * spacing) / columns;
                      final double cardHeight = (cardWidth * 0.65).clamp(
                        240.0,
                        320.0,
                      );

                      final cards = [
                        _exerciseCard(
                          context,
                          accent: cs.primary,
                          accentContainer: cs.primaryContainer,
                          title: 'Box Breathing',
                          desc:
                              'A calming technique to reduce stress and anxiety',
                          duration: '16s per cycle',
                          onStart: _launchBoxBreathing,
                          trailing: _countChip(
                            context,
                            accent: cs.primary,
                            count: boxBreathingCycles,
                          ),
                        ),
                        _exerciseCard(
                          context,
                          accent: cs.tertiary,
                          accentContainer: cs.tertiaryContainer,
                          title: '4-7-8 Breathing',
                          desc:
                              'Perfect for falling asleep and deep relaxation',
                          duration: '19s per cycle',
                          onStart: _launchFourSevenEight,
                          trailing: _countChip(
                            context,
                            accent: cs.tertiary,
                            count: fourSevenEightCycles,
                          ),
                        ),
                        _exerciseCard(
                          context,
                          accent: cs.secondary,
                          accentContainer: cs.secondaryContainer,
                          title: 'Calm Breathing',
                          desc:
                              'Simple and effective for everyday stress relief',
                          duration: '10s per cycle',
                          onStart: _launchCalmBreathing,
                          trailing: _countChip(
                            context,
                            accent: cs.secondary,
                            count: calmBreathingCycles,
                          ),
                        ),
                      ];

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          mainAxisExtent: cardHeight,
                        ),
                        itemCount: cards.length,
                        itemBuilder: (context, index) => cards[index],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
