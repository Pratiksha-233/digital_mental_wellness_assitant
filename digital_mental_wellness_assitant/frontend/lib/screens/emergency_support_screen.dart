import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
      description: 'Visit iasp.info/resources/Crisis_Centres/ for global resources',
      region: 'International',
      icon: Icons.language,
      type: 'web',
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

  const EmergencyContact({
    required this.name,
    required this.number,
    required this.description,
    required this.region,
    required this.icon,
    required this.type,
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
  int _reminderIndex = 0;

  @override
  void initState() {
    super.initState();
    _copingIndex = DateTime.now().hour % EmergencySupportData.copingStrategies.length;
    _reminderIndex = DateTime.now().day % EmergencySupportData.reminders.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Need Help Now?'),
        elevation: 0,
        backgroundColor: cs.errorContainer,
        foregroundColor: cs.onErrorContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crisis Alert Banner
            AppSectionCard(
              gradient: LinearGradient(
                colors: [
                  cs.error.withValues(alpha: 0.85),
                  cs.errorContainer.withValues(alpha: 0.70),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: cs.onError,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You Are Not Alone',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onError,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Crisis support is available 24/7. Reach out right now.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onError,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Emergency Contacts
            Text(
              '🆘 Emergency Helplines',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: EmergencySupportData.emergencyContacts.length,
              itemBuilder: (context, index) {
                final contact = EmergencySupportData.emergencyContacts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildContactCard(
                    context,
                    contact,
                    cs,
                    theme,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Coping Strategies
            Text(
              '💪 Quick Coping Strategies',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            AppSectionCard(
              margin: EdgeInsets.zero,
              gradient: LinearGradient(
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
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _copingIndex =
                                  (_copingIndex - 1 +
                                      EmergencySupportData.copingStrategies.length) %
                                      EmergencySupportData.copingStrategies.length;
                            });
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              _copingIndex =
                                  (_copingIndex + 1) %
                                      EmergencySupportData.copingStrategies.length;
                            });
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Inspirational Reminder
            Text(
              '✨ Remember',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            AppSectionCard(
              margin: EdgeInsets.zero,
              gradient: LinearGradient(
                colors: [
                  cs.primaryContainer.withValues(alpha: 0.50),
                  cs.tertiaryContainer.withValues(alpha: 0.40),
                ],
              ),
              child: Center(
                child: Text(
                  EmergencySupportData.reminders[_reminderIndex],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    height: 1.8,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Additional Resources
            Text(
              '📚 Additional Resources',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            AppSectionCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              gradient: LinearGradient(
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
                    '🧠 Mental Health Information',
                    'Learn more about mental health conditions and treatments',
                    theme,
                    cs,
                  ),
                  const SizedBox(height: 12),
                  _buildResourceItem(
                    context,
                    '👥 Support Groups',
                    'Connect with others in similar situations',
                    theme,
                    cs,
                  ),
                  const SizedBox(height: 12),
                  _buildResourceItem(
                    context,
                    '💻 Online Resources',
                    'Access mental health websites and apps',
                    theme,
                    cs,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Safety Plan Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: cs.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Create a Safety Plan',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A safety plan is a list of people, places, and things that help you when you\'re in crisis. '
                    'Consider writing down:\n'
                    '• Warning signs that a crisis might be coming\n'
                    '• Internal coping strategies\n'
                    '• Support persons and social settings\n'
                    '• Professional contacts to reach out to\n'
                    '• Ways to make your environment safer',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    EmergencyContact contact,
    ColorScheme cs,
    ThemeData theme,
  ) {
    Color cardColor;
    switch (contact.type) {
      case 'emergency':
        cardColor = cs.error.withValues(alpha: 0.15);
        break;
      case 'phone':
        cardColor = cs.primary.withValues(alpha: 0.15);
        break;
      case 'text':
        cardColor = cs.tertiary.withValues(alpha: 0.15);
        break;
      default:
        cardColor = cs.secondary.withValues(alpha: 0.15);
    }

    return AppSectionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(0),
      gradient: LinearGradient(
        colors: [cardColor, cardColor.withValues(alpha: 0.5)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: contact.type == 'web' ? null : () => contact.launch(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(
                        contact.icon,
                        color: cs.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contact.number,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contact.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(
                              contact.region,
                              style: theme.textTheme.labelSmall,
                            ),
                            backgroundColor: cs.secondary.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                    if (contact.type != 'web')
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Icon(
                          Icons.arrow_forward,
                          color: cs.primary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
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
