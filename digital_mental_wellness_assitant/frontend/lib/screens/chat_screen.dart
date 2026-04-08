import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import '../services/voice_service.dart';
import '../widgets/app_section_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_Message> _messages = [
    const _Message(
      text:
          "Hi, I'm your wellness companion. Tell me what's on your mind today.",
      isUser: false,
    ),
    // Safety note: real-world mental health apps should be explicit about limits.
    const _Message(
      text:
          'This chat is supportive, not a replacement for professional care. If you feel unsafe or in immediate danger, contact local emergency services or a trusted person right away.',
      isUser: false,
      isHighlight: true,
    ),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  bool _loadingHistory = false;
  bool _awaitingJournalEntry = false;
  bool _isListening = false;
  double _soundLevel = 0.0;
  final ApiService _api = ApiService();
  final VoiceService _voiceService = VoiceService();

  String? _buildInsightLine(Map<String, dynamic> result) {
    final emotion = (result['emotion'] ?? '').toString().trim();
    final sentiment = (result['sentiment'] ?? '').toString().trim();
    final intent = (result['intent'] ?? '').toString().trim();
    final bool isCrisis = result['is_crisis'] == true;
    final confidenceRaw = result['confidence'];
    final double confidence = confidenceRaw is num
        ? confidenceRaw.toDouble()
        : double.tryParse(confidenceRaw?.toString() ?? '') ?? 0.0;

    if (isCrisis) {
      return 'If you are in immediate danger or thinking about harming yourself, please contact local emergency services or a trusted person right away.';
    }

    switch (intent) {
      case 'sleep_issue':
        return 'It sounds like you’re dealing with sleep trouble. Want quick tips for falling asleep or staying asleep?';
      case 'anxiety':
        return 'It sounds like anxiety is showing up. If you want, we can do a quick grounding exercise together.';
      case 'stress':
        return 'It sounds like stress is building up. Want a 60‑second reset technique?';
      case 'motivation':
        return 'It sounds like motivation is low today. Want a tiny, doable first step?';
    }

    if (emotion.isEmpty && sentiment.isEmpty) return null;

    final tone = sentiment.isNotEmpty ? sentiment : 'mixed';

    if (confidence > 0 && confidence < 0.55) {
      return 'I’m not fully sure, but I sense a $tone tone in what you shared.';
    }
    if (emotion.isNotEmpty) {
      return 'I picked up a sense of $emotion with a $tone tone.';
    }
    return 'I sense a $tone tone in what you shared.';
  }

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();

    // Load saved chat history so users can review past sessions.
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (_loadingHistory) return;
    setState(() {
      _loadingHistory = true;
    });

    try {
      final userId = await _getUserId();
      if (userId == null) return;

      final history = await _api.getChatHistory(userId: userId, limit: 160);
      if (history.isEmpty) return;

      // Convert backend history into local messages.
      final restored = <_Message>[];
      for (final m in history) {
        final role = (m['role'] ?? '').toString();
        final text = (m['text'] ?? '').toString();
        if (text.trim().isEmpty) continue;
        restored.add(_Message(text: text, isUser: role == 'user'));
      }

      if (!mounted) return;
      setState(() {
        // Keep the first greeting + safety highlight, then append restored history.
        final intro = _messages.take(2).toList();
        _messages
          ..clear()
          ..addAll(intro)
          ..addAll(restored);
      });
      _scrollToEnd();
    } catch (_) {
      // If history fails, the chat still works in "live" mode.
    } finally {
      if (mounted) {
        setState(() {
          _loadingHistory = false;
        });
      }
    }
  }

  void _initializeVoiceService() {
    _voiceService.onListeningStarted = () {
      if (mounted) {
        setState(() {
          _isListening = true;
        });
      }
    };

    _voiceService.onListeningStopped = () {
      if (mounted) {
        setState(() {
          _isListening = false;
          _soundLevel = 0.0;
        });
      }
    };

    _voiceService.onTextRecognized = (text) {
      if (mounted) {
        setState(() {
          _controller.text = text;
        });
      }
    };

    _voiceService.onSoundLevelChanged = (level) {
      if (mounted) {
        setState(() {
          _soundLevel = level;
        });
      }
    };

    _voiceService.onError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Voice error: $error')));
      }
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<int?> _getUserId() async {
    try {
      // 1) Use stored user id if available.
      final storedId = await ProfileService.getUserId();
      if (storedId != null) return storedId;

      // 2) Real-world fallback: if the user is authenticated, resolve backend user id.
      final fbUser = FirebaseAuth.instance.currentUser;
      final email = fbUser?.email;
      if (email == null || email.trim().isEmpty) return null;

      final lookedUp = await _api.lookupOrCreateUserByEmail(
        email: email,
        name: fbUser?.displayName,
      );
      if (lookedUp != null) {
        await ProfileService.setUserId(lookedUp);
        return lookedUp;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    if (_sending) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _controller.clear();
      _sending = true;
    });
    _scrollToEnd();

    try {
      final userId = await _getUserId();

      // If the user is responding to a journaling prompt, save to journal_entries.
      if (_awaitingJournalEntry && userId != null) {
        await _api.saveJournalEntry(userId: userId, textEntry: text);
        _awaitingJournalEntry = false;
      }

      final result = await _api.sendChatMessage(message: text, userId: userId);

      String reply;
      String? insightLine;
      if (result != null && result['response'] is String) {
        reply = result['response'] as String;

        insightLine = _buildInsightLine(result);
      } else {
        reply =
            'Thank you for sharing. I had trouble reaching the server, so I will just keep listening.';
      }

      if (!mounted) return;
      setState(() {
        _messages.add(_Message(text: reply, isUser: false));
        if (insightLine != null && insightLine.trim().isNotEmpty) {
          _messages.add(
            _Message(text: insightLine, isUser: false, isHighlight: true),
          );
        }
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          const _Message(
            text:
                'Something went wrong while sending. Please try again in a moment.',
            isUser: false,
            isHighlight: true,
          ),
        );
      });
      _scrollToEnd();
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  Future<void> _insertJournalingPrompt() async {
    if (_sending) return;
    final userId = await _getUserId();
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in / set a profile first.'),
          ),
        );
      }
      return;
    }

    final prompt = await _api.getJournalPrompt();
    if (prompt == null || prompt.trim().isEmpty) return;

    if (!mounted) return;
    setState(() {
      _messages.add(
        _Message(
          text:
              'Journaling prompt: $prompt\n\nWrite a few sentences, then press Send. I will save it to your journal.',
          isUser: false,
          isHighlight: true,
        ),
      );
      _awaitingJournalEntry = true;
    });
    _scrollToEnd();
  }

  Future<void> _startDailyCheckIn() async {
    if (_sending) return;
    final userId = await _getUserId();
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in / set a profile first.'),
          ),
        );
      }
      return;
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    const moodOptions = <String>[
      'Happy',
      'Calm',
      'Neutral',
      'Anxious',
      'Sad',
      'Angry',
      'Stressed',
      'Overwhelmed',
    ];

    String selectedMood = moodOptions.first;
    double energy = 5;
    final noteController = TextEditingController();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder: (ctx, setSheetState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily check-in',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pick your mood and energy. This is saved to your mood history.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedMood,
                      items: [
                        for (final m in moodOptions)
                          DropdownMenuItem(value: m, child: Text(m)),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setSheetState(() {
                          selectedMood = v;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Mood'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Energy: ${energy.round()} / 10',
                      style: theme.textTheme.labelLarge,
                    ),
                    Slider(
                      value: energy,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      onChanged: (v) => setSheetState(() => energy = v),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Optional note',
                        hintText: 'What’s contributing to this mood today?',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              final ok = await _api.logMood(
                                userId: userId,
                                moodLabel: selectedMood,
                                energyLevel: energy.round(),
                                note: noteController.text,
                              );
                              if (ctx.mounted) {
                                Navigator.pop(ctx, ok);
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    noteController.dispose();

    if (!mounted) return;

    if (saved == true) {
      setState(() {
        _messages.add(
          const _Message(
            text:
                'Saved your daily check-in. Want to talk about what led to it?',
            isUser: false,
            isHighlight: true,
          ),
        );
      });
      _scrollToEnd();
    }
  }

  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      await _voiceService.stopListening();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _controller.text.isNotEmpty) {
          _send();
        }
      });
    } else {
      final initialized = await _voiceService.initialize();
      if (initialized) {
        await _voiceService.startListening();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Voice recognition is not available on this device',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bubbleMaxWidth = (MediaQuery.of(context).size.width * 0.86).clamp(
      280.0,
      720.0,
    );
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.primary,
              child: Icon(Icons.psychology, size: 18, color: cs.onPrimary),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness Companion',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Chat safely about how you feel',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.surfaceContainerHighest.withValues(alpha: 0.75),
                    cs.surface,
                  ],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  if (m.isHighlight) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: bubbleMaxWidth - 60,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Text(
                            m.text,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (m.isUser) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          m.text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: cs.primary,
                        child: Icon(
                          Icons.smart_toy,
                          size: 18,
                          color: cs.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Text(
                            m.text,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: AppSectionCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              gradient: AppSectionCard.gradientFromScheme(
                cs,
                a: cs.surfaceContainerHighest,
                b: cs.surface,
                aAlpha: 0.85,
                bAlpha: 0.60,
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  // Common "therapy app" quick actions.
                  _QuickChip(
                    label: 'Daily check-in',
                    onTap: _sending ? null : _startDailyCheckIn,
                  ),
                  _QuickChip(
                    label: 'Journaling prompt',
                    onTap: _sending ? null : _insertJournalingPrompt,
                  ),
                  _QuickChip(
                    label: 'I feel anxious',
                    onTap: _sending
                        ? null
                        : () {
                            _controller.text =
                                'I am feeling very anxious today.';
                            _send();
                          },
                  ),
                  _QuickChip(
                    label: 'I can\'t sleep',
                    onTap: _sending
                        ? null
                        : () {
                            _controller.text =
                                'I am struggling with sleep and insomnia.';
                            _send();
                          },
                  ),
                  _QuickChip(
                    label: 'I feel sad',
                    onTap: _sending
                        ? null
                        : () {
                            _controller.text =
                                'I have been feeling really sad and low.';
                            _send();
                          },
                  ),
                  _QuickChip(
                    label: 'I need motivation',
                    onTap: _sending
                        ? null
                        : () {
                            _controller.text =
                                'I need some motivation to get through today.';
                            _send();
                          },
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: AppSectionCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                gradient: AppSectionCard.gradientFromScheme(
                  cs,
                  a: cs.surfaceContainerHighest,
                  b: cs.surface,
                  aAlpha: 0.90,
                  bAlpha: 0.65,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isListening)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Text(
                              'Listening...',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _soundLevel,
                                minHeight: 4,
                                backgroundColor: cs.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cs.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 5,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            decoration: const InputDecoration(
                              hintText: 'Type a message…',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _sending ? null : _toggleVoiceInput,
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? cs.error : null,
                          ),
                          tooltip: _isListening
                              ? 'Stop listening'
                              : 'Speak instead of type',
                        ),
                        const SizedBox(width: 4),
                        FilledButton.icon(
                          onPressed: _sending ? null : _send,
                          icon: _sending
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(_sending ? 'Sending…' : 'Send'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final bool isHighlight;

  const _Message({
    required this.text,
    required this.isUser,
    this.isHighlight = false,
  });
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _QuickChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: cs.surface.withValues(alpha: 0.80),
      side: BorderSide(color: cs.primary.withValues(alpha: 0.55)),
      labelStyle: theme.textTheme.labelLarge?.copyWith(color: cs.primary),
      elevation: 0,
    );
  }
}
