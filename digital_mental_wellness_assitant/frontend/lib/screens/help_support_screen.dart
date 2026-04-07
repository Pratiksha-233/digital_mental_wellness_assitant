import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/app_section_card.dart';
import 'emergency_support_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _supportEmail = 'support@mindwell.local';

  Future<void> _copyToClipboard(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            AppSectionCard(
              gradient: AppSectionCard.gradientFromScheme(
                cs,
                a: cs.primaryContainer,
                b: cs.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline, color: cs.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Get help using MindWell',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find quick answers, learn how features work, or reach emergency support when you need it.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmergencySupportScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.emergency),
                        label: const Text('Need help now'),
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.error,
                          foregroundColor: cs.onError,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Back to home'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.map_outlined, color: cs.secondary),
                      const SizedBox(width: 10),
                      Text(
                        'How to use the app',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _TipRow(
                    icon: Icons.heart_broken,
                    title: 'Mood Tracker',
                    body:
                        'Log how you feel daily and review patterns in your weekly view.',
                  ),
                  const SizedBox(height: 10),
                  _TipRow(
                    icon: Icons.show_chart,
                    title: 'Stress Analyzer',
                    body:
                        'Answer a quick check-in to estimate stress and get suggestions.',
                  ),
                  const SizedBox(height: 10),
                  _TipRow(
                    icon: Icons.book_outlined,
                    title: 'Journal',
                    body:
                        'Write private notes to reflect and track what helps you over time.',
                  ),
                  const SizedBox(height: 10),
                  _TipRow(
                    icon: Icons.psychology,
                    title: 'Realtime Face Detection',
                    body:
                        'Use your camera for emotion detection; stop anytime in the screen.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.quiz_outlined, color: cs.tertiary),
                      const SizedBox(width: 10),
                      Text(
                        'FAQ',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _FaqTile(
                    question: 'Is this a replacement for professional care?',
                    answer:
                        'No. This app provides wellness tools and information, but it does not replace professional medical advice or therapy. If you feel unsafe, use “Need help now”.',
                  ),
                  _FaqTile(
                    question: 'What should I do if the camera feature fails?',
                    answer:
                        'Check camera permissions, then re-open the screen. On some devices, restarting the app can help.',
                  ),
                  _FaqTile(
                    question: 'Where can I find emergency contacts?',
                    answer:
                        'Open “Need help now” from this page or from the Home drawer.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contact_support_outlined, color: cs.primary),
                      const SizedBox(width: 10),
                      Text(
                        'Contact & feedback',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'If something isn\'t working, share a screenshot and what you expected to happen.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email support'),
                    subtitle: const Text(_supportEmail),
                    trailing: IconButton(
                      tooltip: 'Copy email',
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(context, _supportEmail),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _TipRow({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: cs.onSurfaceVariant, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 12),
      title: Text(
        question,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            answer,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
          ),
        ),
      ],
    );
  }
}
