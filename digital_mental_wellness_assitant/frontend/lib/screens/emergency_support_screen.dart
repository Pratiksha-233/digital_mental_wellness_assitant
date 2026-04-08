import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/brand_theme.dart';
import '../widgets/app_section_card.dart';

/// Emergency helpline numbers and crisis resources
class EmergencySupportData {
  static const List<EmergencyContact> emergencyContacts = [
    EmergencyContact(
      name: 'National Suicide Prevention Lifeline',
      number: '988',
      description: 'Call or text 988 (available 24/7)',
      region: 'United States',
      icon: Icons.phone,
      type: 'phone',
    ),
    EmergencyContact(
      name: 'Crisis Text Line',
      number: 'Text HOME to 741741',
      description: 'Text-based support available 24/7',
      region: 'United States',
      icon: Icons.message,
      type: 'text',
    ),
    EmergencyContact(
      name: '988 Suicide & Crisis Lifeline',
      number: '1-800-273-8255',
      description: 'Call 1-800-273-8255 (available 24/7)',
      region: 'United States',
      icon: Icons.phone,
      type: 'phone',
    ),
    EmergencyContact(
      name: 'International Association for Suicide Prevention',
      number: 'Find local helpline',
      description:
          'Visit iasp.info/resources/Crisis_Centres/ for global resources',
      region: 'International',
      icon: Icons.language,
      type: 'web',
      url: 'https://www.iasp.info/resources/Crisis_Centres/',
    ),
    EmergencyContact(
      name: 'Befrienders',
      number: '+60 3 7956 8144',
      description: 'Emotional support hotline',
      region: 'Malaysia',
      icon: Icons.phone,
      type: 'phone',
    ),
    EmergencyContact(
      name: 'Samaritans',
      number: '116 123',
      description: 'Emotional support available 24/7',
      region: 'UK',
      icon: Icons.phone,
      type: 'phone',
    ),
    EmergencyContact(
      name: 'Lifeline Australia',
      number: '13 11 14',
      description: 'Crisis support available 24/7',
      region: 'Australia',
      icon: Icons.phone,
      type: 'phone',
    ),
    EmergencyContact(
      name: 'Emergency Services',
      number: '911 / 112 / 999',
      description: 'For immediate life-threatening emergencies',
      region: 'Global',
      icon: Icons.emergency,
      type: 'emergency',
    ),
  ];

  static const List<String> copingStrategies = [
    '🧘 Practice deep breathing: Inhale for 4 counts, hold for 4, exhale for 6.',
    '🚶 Go for a walk or move your body - movement helps process emotions.',
    '💧 Stay hydrated and take care of your basic needs.',
    '📞 Reach out to someone you trust - family, friend, or counselor.',
    '✍️ Write down your thoughts and feelings without judgment.',
    '🎵 Listen to music or sounds that comfort you.',
    '🛁 Take a warm bath or shower to calm your nervous system.',
    '🌿 Step outside and connect with nature if possible.',
    '📱 Distance yourself from social media if it\'s triggering.',
    '🧩 Do a grounding exercise: 5 things you see, 4 you touch, 3 you hear, 2 you smell, 1 you taste.',
  ];

  static const List<String> reminders = [
    'Your feelings are temporary. This moment will pass.',
    'You matter. Your life has value.',
    'It\'s okay to not be okay. That\'s when you reach out.',
    'Crisis support is available 24/7 - you don\'t have to face this alone.',
    'Asking for help is a sign of strength, not weakness.',
    'You have survived 100% of your worst days so far.',
    'This is a moment in your story, not the whole story.',
    'Recovery is possible. Many have been where you are and found hope.',
  ];
}

class EmergencyContact {
  final String name;
  final String number;
  final String description;
  final String region;
  final IconData icon;
  final String type; // 'phone', 'text', 'web', 'emergency'
  final String? url;

  const EmergencyContact({
    required this.name,
    required this.number,
    required this.description,
    required this.region,
    required this.icon,
    required this.type,
    this.url,
  });

  Future<void> launch() async {
    String uri;
    switch (type) {
      case 'phone':
        uri = 'tel:${number.replaceAll(RegExp(r'[^0-9]'), '')}';
        break;
      case 'text':
        uri = 'sms:741741?body=HOME';
        break;
      case 'emergency':
        uri = 'tel:911';
        break;
      case 'web':
        uri = url ?? 'https://www.iasp.info/resources/Crisis_Centres/';
        break;
      default:
        return;
    }

    try {
      if (await canLaunchUrl(Uri.parse(uri))) {
        await launchUrl(Uri.parse(uri));
      }
    } catch (e) {
      debugPrint('Error launching: $e');
    }
  }
}

class EmergencySupportScreen extends StatefulWidget {
  const EmergencySupportScreen({super.key});

  @override
  State<EmergencySupportScreen> createState() => _EmergencySupportScreenState();
}

class _EmergencySupportScreenState extends State<EmergencySupportScreen> {
  int _copingIndex = 0;

  @override
  void initState() {
    super.initState();
    _copingIndex =
        DateTime.now().hour % EmergencySupportData.copingStrategies.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bgGradient =
        theme.extension<BrandGradients>()?.background ??
        AppSectionCard.gradientFromScheme(cs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Need Help Now?'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cs.surface.withValues(alpha: 0.95),
        foregroundColor: cs.onSurface,
      ),
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: bgGradient),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crisis Alert Banner
                AppSectionCard(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.error.withValues(alpha: 0.85),
                      cs.errorContainer.withValues(alpha: 0.70),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: cs.onError,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You are not alone',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onError,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Crisis support is available 24/7. If you feel unsafe, reach out right now.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onError,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Emergency Contacts
                _buildEmergencyHelplinesSection(context),

                const SizedBox(height: 22),

                // Coping Strategies
                _buildSectionHeader(
                  context,
                  icon: Icons.favorite_rounded,
                  title: 'Quick coping strategies',
                  subtitle: 'Small steps to get through this moment.',
                ),
                const SizedBox(height: 12),
                AppSectionCard(
                  margin: EdgeInsets.zero,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.tertiaryContainer.withValues(alpha: 0.60),
                      cs.secondaryContainer.withValues(alpha: 0.40),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EmergencySupportData.copingStrategies[_copingIndex],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 520;
                          const compactMaxWidth = 320.0;
                          final buttonWidth = ((constraints.maxWidth - 12) / 2)
                              .clamp(160.0, 260.0);
                          final prevButton = OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _copingIndex =
                                    (_copingIndex -
                                        1 +
                                        EmergencySupportData
                                            .copingStrategies
                                            .length) %
                                    EmergencySupportData
                                        .copingStrategies
                                        .length;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              alignment: Alignment.center,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_back),
                                SizedBox(width: 10),
                                Text('Previous'),
                              ],
                            ),
                          );

                          final nextButton = FilledButton(
                            onPressed: () {
                              setState(() {
                                _copingIndex =
                                    (_copingIndex + 1) %
                                    EmergencySupportData
                                        .copingStrategies
                                        .length;
                              });
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              alignment: Alignment.center,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Next'),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: compactMaxWidth,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: prevButton,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: compactMaxWidth,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: nextButton,
                                  ),
                                ),
                              ],
                            );
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: buttonWidth, child: prevButton),
                              const SizedBox(width: 12),
                              SizedBox(width: buttonWidth, child: nextButton),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Additional Resources
                _buildSectionHeader(
                  context,
                  icon: Icons.menu_book_rounded,
                  title: 'Additional resources',
                  subtitle: 'Learn, connect, and explore support options.',
                ),
                const SizedBox(height: 12),
                AppSectionCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.surfaceContainerHighest.withValues(alpha: 0.60),
                      cs.surface.withValues(alpha: 0.40),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResourceItem(
                        context,
                        'Mental health information',
                        'Learn about conditions, treatments, and coping tools',
                        theme,
                        cs,
                      ),
                      const SizedBox(height: 12),
                      _buildResourceItem(
                        context,
                        'Support groups',
                        'Connect with others in similar situations',
                        theme,
                        cs,
                      ),
                      const SizedBox(height: 12),
                      _buildResourceItem(
                        context,
                        'Online resources',
                        'Explore reputable mental health websites and apps',
                        theme,
                        cs,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Safety Plan Info
                AppSectionCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(16),
                  gradient: AppSectionCard.gradientFromScheme(
                    cs,
                    a: cs.surfaceContainerHighest,
                    b: cs.surface,
                    aAlpha: 0.72,
                    bAlpha: 0.52,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_rounded, color: cs.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Create a safety plan',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'A safety plan is a list of people, places, and steps that help you when you\'re in crisis. '
                        'Consider writing down:\n'
                        '• Warning signs that a crisis might be coming\n'
                        '• Internal coping strategies\n'
                        '• Support persons and social settings\n'
                        '• Professional contacts to reach out to\n'
                        '• Ways to make your environment safer',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
          ),
          child: Icon(icon, color: cs.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyHelplinesSection(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final primaryCall = EmergencySupportData.emergencyContacts.firstWhere(
      (c) => c.number.trim() == '988',
      orElse: () => EmergencySupportData.emergencyContacts.first,
    );
    final primaryText = EmergencySupportData.emergencyContacts.firstWhere(
      (c) => c.type == 'text',
      orElse: () => EmergencySupportData.emergencyContacts.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.sos_rounded,
          title: 'Emergency helplines',
          subtitle: 'Use quick actions or choose a resource below.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () => primaryCall.launch(),
              icon: const Icon(Icons.call_rounded),
              label: const Text('Call 988'),
            ),
            OutlinedButton.icon(
              onPressed: () => primaryText.launch(),
              icon: const Icon(Icons.message_rounded),
              label: const Text('Text HOME'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppSectionCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface.withValues(alpha: 0.75),
              cs.surfaceContainerHighest.withValues(alpha: 0.55),
            ],
          ),
          child: Column(
            children: [
              for (
                int i = 0;
                i < EmergencySupportData.emergencyContacts.length;
                i++
              ) ...[
                _buildContactListItem(
                  context,
                  EmergencySupportData.emergencyContacts[i],
                ),
                if (i != EmergencySupportData.emergencyContacts.length - 1)
                  Divider(
                    height: 16,
                    color: cs.outlineVariant.withValues(alpha: 0.6),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactListItem(BuildContext context, EmergencyContact contact) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final (IconData actionIcon, String actionLabel) = switch (contact.type) {
      'web' => (Icons.open_in_new_rounded, 'Open'),
      'text' => (Icons.message_rounded, 'Text'),
      'emergency' => (Icons.call_rounded, 'Call'),
      _ => (Icons.call_rounded, 'Call'),
    };

    final Color tint = switch (contact.type) {
      'emergency' => cs.error,
      'text' => cs.tertiary,
      'web' => cs.secondary,
      _ => cs.primary,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => contact.launch(),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.55),
                  ),
                ),
                child: Icon(contact.icon, color: tint),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.number,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: tint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        contact.region,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => contact.launch(),
                    icon: Icon(actionIcon),
                    tooltip: actionLabel,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    actionLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceItem(
    BuildContext context,
    String title,
    String description,
    ThemeData theme,
    ColorScheme cs,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: cs.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
