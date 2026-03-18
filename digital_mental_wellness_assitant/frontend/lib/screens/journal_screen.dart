import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_section_card.dart';

class JournalScreen extends StatefulWidget {
  final int userId;
  final DateTime? selectedDate;
  const JournalScreen({super.key, required this.userId, this.selectedDate});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _controller = TextEditingController();
  String? _emotion;
  bool _isLoading = false;
  final ApiService _api = ApiService();

  String _formatSelectedDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _analyzeEmotion() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something before analyzing'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _api.predictEmotion(_controller.text, widget.userId);
      if (!mounted) return;
      setState(() => _emotion = result['emotion']);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error analyzing emotion: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final selected = widget.selectedDate;
    final title = selected == null
        ? 'Journal'
        : 'Journal · ${_formatSelectedDate(selected)}';
    final hint = selected == null
        ? 'How are you feeling today?'
        : 'How did you feel on ${_formatSelectedDate(selected)}?';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppSectionCard(
            gradient: AppSectionCard.gradientFromScheme(
              cs,
              a: cs.primaryContainer,
              b: cs.secondaryContainer,
              aAlpha: 0.35,
              bAlpha: 0.22,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Write your thoughts...',
                    hintText: hint,
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: _analyzeEmotion,
                          icon: const Icon(Icons.analytics_outlined),
                          label: const Text('Analyze Emotion'),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_emotion != null)
            Builder(
              builder: (context) {
                final label = _emotion!.toLowerCase();
                final Color accent;
                switch (label) {
                  case 'happy':
                    accent = cs.tertiary;
                    break;
                  case 'sad':
                    accent = cs.secondary;
                    break;
                  case 'angry':
                  case 'fear':
                  case 'difficult':
                    accent = cs.error;
                    break;
                  default:
                    accent = cs.primary;
                }

                return AppSectionCard(
                  gradient: AppSectionCard.gradientFromScheme(
                    cs,
                    a: accent.withValues(alpha: 0.22),
                    b: cs.surface,
                    aAlpha: 1,
                    bAlpha: 0.65,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Detected Emotion:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _emotion!.toUpperCase(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
